#!/usr/bin/env bash
# Voyez le fichier LICENCES pour connaître la licence de ce script.

# *** À LANCER EN ROOT !

set -e
umask 022
CWD=$(pwd)

syntaxerror() {
	echo "Erreur : ligne de commande incorrecte. "
	echo ""
	echo "Exemples :"
	echo "Créer une clé USB (préalablement formatée en ext2/3/4) :"
	echo "	./construction-live.sh usb /dev/sdc1 ext "
	echo "Créer une clé USB (préalablement formatée en FAT/NTFS) :"
	echo "	./construction-live.sh usb /dev/sdd1"
	echo "Créer une image ISO de DVD amorçable avec la version \"alpha4\" :"
	echo "	./construction-live.sh dvd alpha4"
	echo ""
	exit 1
}
		
# On vérifie qu'on est bien root :
if [ ! "$(whoami)" = "root" ]; then
	echo "Erreur : veuillez m'exécuter en tant que root uniquement !"
	exit 1
fi

# Si l'on veut créer une clé USB, on doit choisir entre 'extlinux' et 'syslinux' :
if [ "$1" = "usb" ]; then
	if [ ! "$(echo $2 | grep dev)" = "" ]; then
		if [ "$3" = "ext" ]; then
			SYSLINUXDIR="extlinux"
			SYSLINUXINSTALL="extlinux --install"
		else
			SYSLINUXDIR="syslinux"
			SYSLINUXINSTALL="syslinux"
		fi
	else
		syntaxerr
	fi
elif [ "$1" = "dvd" ]; then




	
	break
elif [ "$CHOIXMETHODE" = "2" ]; then
	break
elif [ "$CHOIXMETHODE" = "3" ]; then
	break
else
	echo "Veuillez entrer un numéro valide (entre 1 et 3)."
	sleep 2
	unset CHOIXMETHODE
	continue
fi



SOURCES=${SOURCES:-/marmite/0/sources}
PAQUETS=${PAQUETS:-/marmite/0/paquets}
TMP=${TMP:-/usr/local/temp}

LIVEOS=${LIVEOS:-$TMP/liveos}
MEDIAROOT=${MEDIAROOT:-$TMP/mediaroot}
ISODIR=${ISODIR:-$TMP/iso}
INITRDGZ=${INITRDGZ:-$TMP/initrd.gz}
NOYAU=${NOYAU:-$TMP/noyau}

if [ ! "$1" = "" ]; then
	VERSION="$1"
else
	VERSION="2011"
fi

rm -rf $TMP
mkdir -p $TMP

# On crée et on vide les répertoires d'accueil :
rm -rf ${MEDIAROOT} ${LIVEOS} ${NOYAU} ${INITRDGZ}
rm -f ${ISODIR}/0linux-${VERSION}-DVD.iso
mkdir -p ${LIVEOS} ${ISODIR} 
mkdir -p ${MEDIAROOT}/{boot/{extlinux,isolinux,syslinux}},0/paquets}

# On installe les paquets pour le LiveOS :
echo "Installation du système temporaire en cours... "

# base :
echo -n "base... "
for paq in $(find ${PAQUETS}/base -type f \! -name "linux-source*"); do
	spkadd --quiet --root=${LIVEOS} ${paq} &>/dev/null 2>&1
done

# xorg :
echo -n "xorg... "
spkadd --quiet --root=${LIVEOS} ${PAQUETS}/xorg/{libxcb*,freetype*,libX*,x11-libs*,libSM*,libICE*}.cpio &>/dev/null 2>&1

# opt :
echo -n "opt... "
for paq in bc-* berkeley-db* dbus-1* expat* gcc* glib2* gmp* lesstif* libgcrypt* libgpg-error* \
libidn* libpng* libssh2* mpc* mpfr* popt* python-2* ruby*; do
	
	spkadd --quiet --root=${LIVEOS} ${PAQUETS}/opt/${paq}.cpio &>/dev/null 2>&1
	
done

echo "Nettoyage..."
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

# On récupère le minimum de l'éditeur 'vim' (on dispose aussi de 'nano') :
cp -a ${LIVEOS}/usr/bin/vim ${LIVEOS}/conserver
cp -ar ${LIVEOS}/usr/share/vim/lang/fr ${LIVEOS}/conserver
cp -a ${LIVEOS}/etc/vimrc ${LIVEOS}/conserver

# On supprime la vérification orthographique de 'vim' :
sed -i "s@set spell@\" &@g" ${LIVEOS}/conserver/vimrc

# On désinstalle les paquets superflus, maintenant qu'on a les bibliothèques en lieu sûr :
# opt
for paq in bc-* dbus-1* expat* gcc* glib2* gmp* lesstif* libgcrypt* libgpg-error* \
libidn* libpng* python-2* ruby* mpfr* mpc* libssh2* berkeley-db*; do
	
	chroot ${LIVEOS} spkrm /var/log/paquets/${paq} &>/dev/null 2>&1
	
done

# xorg
chroot ${LIVEOS} spkrm /var/log/paquets/{libX*,libxcb*,freetype*,x11-libs*,libSM*,libICE*} &>/dev/null 2>&1

# base
for paq in multiarch_wrapper* vim* bzip2* zlib* tar* \
linux-headers* dhcp-* perl* infozip* gfxboot* dialog* libxml2* sgml-common* \
linux-modules* popt* binutils* tree* vim*; do
	
	chroot ${LIVEOS} spkrm /var/log/paquets/${paq} &>/dev/null 2>&1
	
done

# On ramène les bibliothèques : 
cp -a ${LIVEOS}/conserver/usr/lib64/* ${LIVEOS}/usr/lib64/
cp -a ${LIVEOS}/conserver/lib64/* ${LIVEOS}/lib64/
rm -rf ${LIVEOS}/conserver

# On allège : les bibliothèques 32 bits sous '/lib' :
rm -f ${LIVEOS}/lib/*.{a,la,so.*,so}
# La documentation :
rm -rf ${LIVEOS}/usr/doc/*
# La documentation pour 'gtk-doc' :
rm -rf ${LIVEOS}/usr/share/gtk-doc/*
# Les bibliothèques 32 bits :
rm -rf ${LIVEOS}/usr/lib/*
# Toutes les bibliothéques statiques et pour 'libtool' :
find ${LIVEOS} -type f -name "*.a" -delete
find ${LIVEOS} -type f -name "*.la" -delete
# Tous les fichiers entêtes :
rm -rf ${LIVEOS}/usr/include/*

echo "Copie des fichiers..."
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
echo -n "Création de l'initrd... "
rm -f ${INITRDGZ}
cd ${LIVEOS}
find . | cpio -o -H newc | gzip -9 > ${INITRDGZ}
echo "Terminé."

echo "Copie des paquets, du noyau et de l'initrd..."
# On copie le noyau et l'initrd :
cp -a ${INITRDGZ} ${NOYAU} ${MEDIAROOT}/boot/

# On copie tous les paquets :
rsync -au --delete-after ${PAQUETS}/* ${MEDIAROOT}/0/paquets

echo "Copie des paquets et du chargeur d'amorçage..."
# On copie tous les fichiers de isolinux/ :
cp -ar ${SOURCES}/installateur/isolinux/* ${MEDIAROOT}/boot/isolinux/

# On copie les modules binaires pour isolinux :
cp -a /usr/share/syslinux/{{chain,kbdmap,linux,reboot,vesamenu}.c32,isolinux.bin} ${MEDIAROOT}/boot/isolinux/
chmod +x ${MEDIAROOT}/boot/isolinux/*.c32
# On copie les modules binaires pour extlinux :
cp -a /usr/share/syslinux/{chain,kbdmap,linux,reboot,vesamenu}.c32 /mnt/tmp/boot/extlinux/
chmod +x /mnt/tmp/boot/extlinux/*.c32


# On s'assure des permissions :
chown -R root:root ${MEDIAROOT}/* 2> /dev/null || true

# On crée enfin l'image ISO :
cd ${MEDIAROOT}
mkisofs -o ${ISODIR}/0linux-${VERSION}-DVD.iso \
	-A "DVD 0linux" \
	-b boot/isolinux/isolinux.bin \
	-c boot/isolinux/boot.cat \
	-d \
	-J \
	-l \
	-N \
	-R \
	-V "DVD0linux" \
	-boot-load-size 4 \
	-boot-info-table \
	-hide-rr-moved \
	-no-emul-boot \
	${MEDIAROOT}

echo "L'image '${ISODIR}/0linux-${VERSION}-DVD.iso' a été créée ."

exit 0
