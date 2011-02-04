#!/usr/bin/env bash
# Voyez le fichier LICENCES pour connaître la licence de ce script.

# *** À LANCER EN ROOT ! Suivi de la version souhaitée dans le nom de l'ISO. Ex. :
#
#	./construction-livedvd.sh alpha4
#
# ... créera l'image ISO '/tmp/0linux-alpha4-DVD.iso'.

set -e
umask 022
CWD=$(pwd)

SOURCES=${SOURCES:-/marmite/0/sources}
PAQUETS=${PAQUETS:-/marmite/0/paquets}
TMP=${TMP:-/marmite/temp}

LIVEOS=${LIVEOS:-$TMP/liveos}
DVDROOT=${DVDROOT:-$TMP/dvdroot}
ISODIR=${ISODIR:-$TMP/iso}
INITRDGZ=${INITRDGZ:-$TMP/initrd.gz}
NOYAU=${NOYAU:-$TMP/noyau}

if [ ! "$1" = "" ]; then
	VERSION="$1"
else
	VERSION="2011"
fi

mkdir -p $TMP

# On crée et on vide les répertoires d'accueil :
rm -rf ${DVDROOT} ${NOYAU} ${LIVEOS} ${NOYAU}
rm -f ${ISODIR}/0linux-${VERSION}-DVD.iso
mkdir -p ${LIVEOS} ${ISODIR} 
mkdir -p ${DVDROOT}/{boot/isolinux,0/paquets}

# On installe les paquets pour le LiveOS :
echo "Création du DVD autonome en cours..."
echo -n "Installation en cours... "

# base :
for paq in $(find ${PAQUETS}/base -type f \! -name "linux-source*"); do
	spkadd --quiet --root=${LIVEOS} ${paq} &>/dev/null 2>&1
done

# xorg :
spkadd --quiet --root=${LIVEOS} ${PAQUETS}/xorg/{libxcb*,freetype*,libX*,x11-libs*,libSM*,libICE*}.cpio &>/dev/null 2>&1

# opt :
for paq in bc-* berkeley-db* dbus-1* expat* gcc* glib2* gmp* lesstif* libgcrypt* libgpg-error* \
libidn* libpng* libssh2* mpc* mpfr* popt* python-2* ruby*; do
	
	spkadd --quiet --root=${LIVEOS} ${PAQUETS}/opt/${paq}.cpio &>/dev/null 2>&1
	
done

# On copie les bibliothèques requises en dépendances pour les isoler :
mkdir -p ${LIVEOS}/conserver/{,usr/}lib64

for libbb in libICE.so* libSM.so* libX11.so* libXaw*.so* libXmu.so* libXt.so* \
libbz2.so* libdb-*.so* libdbus-1.so* libexpat.so* libfreetype.so* libgcc_s.so* \
libgcj.so* libglib-2.0.so* libgmp.so* libgobject-2.0.so* libgomp.so* \
libgthread-2.0.so* libidn.so* libpopt.so* libpython*.so* libmpc.so* libmpfr.so* libssh2.so* \
libstdc++.so* libperl.so* libz.so* libxcb.so* libfreetype.so* libdb-5*.so*; do
	
	find ${LIVEOS}/lib64 -name "${libbb}" -exec cp -a {} ${LIVEOS}/conserver/lib64 \;
	find ${LIVEOS}/usr/lib64 -name "${libbb}" -exec cp -a {} ${LIVEOS}/conserver/usr/lib64 \;
	
done

# On désinstalle les paquets superflus, maintenant qu'on a les bibliothèques en lieu sûr :
# opt
for paq in bc-* dbus-1* expat* gcc* glib2* gmp* lesstif* libgcrypt* libgpg-error* \
libidn* libpng* python-2* ruby* mpfr* mpc* libssh2* berkeley-db*; do
	
	chroot ${LIVEOS} spkrm /var/log/paquets/${paq} &>/dev/null 2>&1
	
done

# xorg
chroot ${LIVEOS} spkrm /var/log/paquets/{libXpm-*,libxcb*,freetype*,x11-libs*,libSM*,libICE*,libX*} &>/dev/null 2>&1

# base
for paq in multiarch_wrapper* vim* bzip2* zlib* tar* \
linux-headers* dhcp-* perl* infozip* gfxboot* dialog* libxml2* sgml-common* \
linux-modules* popt* binutils* tree*; do
	
	chroot ${LIVEOS} spkrm /var/log/paquets/${paq} &>/dev/null 2>&1
	
done

echo "Terminé."

# On ramène les bibliothèques : 
cp -a ${LIVEOS}/conserver/usr/lib64/* ${LIVEOS}/usr/lib64/
cp -a ${LIVEOS}/conserver/lib64/* ${LIVEOS}/lib64/
rm -rf ${LIVEOS}/conserver

# On allège :
rm -rf ${LIVEOS}/usr/doc/*
rm -rf ${LIVEOS}/usr/share/gtk-doc/*
rm -f ${LIVEOS}/lib/*.{a,la,so.*,so}
rm -f ${LIVEOS}/{,usr/}lib64/*.{a,la}
rm -rf ${LIVEOS}/usr/lib/*
rm -rf ${LIVEOS}/usr/include/*

# On copie nos fichiers spéciaux pour le Live :
install -m 644 $CWD/fstab ${LIVEOS}/etc
install -m 755 $CWD/{HOSTNAME,profile} ${LIVEOS}/etc
install -m 755 $CWD/rc.* ${LIVEOS}/etc/rc.d

# On copie l'installateur et l'aide :
install -m 755 $CWD/../scripts/{installateur,*.sh} ${LIVEOS}/sbin
install -m 644 $CWD/../scripts/aide.txt ${LIVEOS}

# On crée le lien pour 'init' :
ln -sf sbin/init ${LIVEOS}/init

# On s'assure de la présence de 'bash' :
if [ -r ${LIVEOS}/bin/bash4.new ]; then
	mv ${LIVEOS}/bin/bash{4.new,}
fi

# On met à jour les liens des bibliothèques :
chroot ${LIVEOS} /sbin/ldconfig
 
# On met à jour les dépendances des modules du noyau :
chroot ${LIVEOS} /usr/sbin/depmod -a

# On évite que se lance 'rc.sshd' (+ effet d'escalier à l'affichage) :
chmod -x ${LIVEOS}/etc/rc.d/rc.sshd

# On évite aussi que se lance 'rc.firewall' :
chmod -x ${LIVEOS}/etc/rc.d/rc.firewall

# On déplace et on renomme le nouveau noyau sans sa version :
rm -f ${NOYAU}
mv ${LIVEOS}/boot/noyau-2* ${NOYAU}

# On positionne le fuseau à Paris car on est franco-français et chauvin :
echo "localtime" > ${LIVEOS}/etc/hardwareclock
ln -sf ../usr/share/zoneinfo/Europe/Paris ${LIVEOS}/etc/localtime

# On crée l'initrd :
echo -n "Création de l'initrd en cours... "
rm -f ${INITRDGZ}
cd ${LIVEOS}
find . | cpio -v -o -H newc | gzip -9 > ${INITRDGZ}
echo "Terminé."

echo -n "Copie des fichiers en cours... "
# On copie tous les fichiers de isolinux/ :
cp -ar ${SOURCES}/installateur/isolinux/* ${DVDROOT}/boot/isolinux/

# On copie les modules binaires de Syslinux :
cp -a /usr/share/syslinux/{{chain,kbdmap,linux,reboot,vesamenu}.c32,isolinux.bin} ${DVDROOT}/boot/isolinux/
chmod +x ${DVDROOT}/boot/isolinux/*.c32

# On copie le noyau et l'initrd :
cp -a ${INITRDGZ} ${NOYAU} ${DVDROOT}/boot/

# On copie tous les paquets :
rsync -auv --delete-after ${PAQUETS}/* ${DVDROOT}/0/paquets

# On s'assure des permissions :
chown -R root:root ${DVDROOT}/* 2> /dev/null || true

# On crée enfin l'image ISO :
cd ${DVDROOT}
mkisofs -o ${ISODIR}/0linux-${VERSION}-DVD.iso \
	-A "0 linux DVD" \
	-b boot/isolinux/isolinux.bin \
	-c boot/isolinux/boot.cat \
	-d \
	-J \
	-l \
	-N \
	-R \
	-V "0linuxDVD" \
	-boot-load-size 4 \
	-boot-info-table \
	-hide-rr-moved \
	-no-emul-boot \
	${DVDROOT}

echo "L'image '${ISODIR}/0linux-${VERSION}-DVD.iso' a été créée ."

exit 0
