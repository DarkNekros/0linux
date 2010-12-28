#!/bin/env bash
# Voyez le fichier LICENCES pour connaître la licence de ce script.

# *** À LANCER EN ROOT ! ***

set -e
umask 022
CWD=$(pwd)

SOURCES=${SOURCES:-/marmite/0/sources}
PAQUETS=${PAQUETS:-/marmite/0/paquets}
LIVEOS=${LIVEOS:-/marmite/0/liveos}
INITRDGZ=${INITRDGZ:-/tmp/initrd.gz}
DVDROOT=${DVDROOT:-/tmp/dvdroot}

# On crée et on vide le répertoire d'accueil :
rm -rf ${LIVEOS}
mkdir -p ${LIVEOS}
mkdir -p ${DVDROOT}/{boot/isolinux,0/paquets}

# On installe les paquets pour le LiveOS :
echo "Création de l'image ISO du DVD autonome en cours..."
echo -n "Installation : base... "
for paq in base-systeme* etc* eglibc* sgml*; do
	spkadd --quiet --root=${LIVEOS} ${PAQUETS}/base/${paq} &>/dev/null 2>&1
done

for paq in $(find ${PAQUETS}/base -type f \! -name "linux-source*"); do
	spkadd --quiet --root=${LIVEOS} ${paq} &>/dev/null 2>&1
done

echo -n "xorg... "
spkadd --quiet --root=${LIVEOS} ${PAQUETS}/xorg/*.cpio &>/dev/null 2>&1

echo -n "opt... "
for paq in dbus-1* expat* gcc* glib2* gmp* lesstif* libgcrypt* libgpg-error* \
	libidn* libpng* libssh2* popt* python-2* ruby*; do
	spkadd --quiet --root=${LIVEOS} ${PAQUETS}/opt/${paq}.cpio &>/dev/null 2>&1
done
echo "Terminé."

# On allège :
rm -rf ${LIVEOS}/usr/doc/*
rm -rf ${LIVEOS}/usr/share/gtk-doc/*
rm -f ${LIVEOS}/lib/*.{a,la,so.*,so}
rm -rf ${LIVEOS}/usr/lib/*

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

# On évite que se lance 'sshd' (+ effet d'escalier à l'affichage) :
chmod -x ${LIVEOS}/etc/rc.d/rc.sshd

# On évite aussi que se lance 'rc.firewall' :
chmod -x ${LIVEOS}/etc/rc.d/rc.firewall

# On copie le nouveau noyau dans /tmp sans sa version :
rm -f /tmp/noyau
cp ${LIVEOS}/boot/noyau-2* /tmp/noyau

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
cp -a ${INITRDGZ} /tmp/noyau ${DVDROOT}/boot/

# On copie tous les paquets :
rsync -auv --delete-after ${PAQUETS}/* ${DVDROOT}/0/paquets

# On s'assure des permissions :
chown -R root:root ${DVDROOT}/* 2> /dev/null || true

# On crée enfin l'image ISO :
cd ${DVDROOT}
mkisofs -o /tmp/0linux-2011-DVD.iso \
	-b boot/isolinux/isolinux.bin \
	-c boot/isolinux/boot.cat \
	-boot-load-size 4 \
	-boot-info-table \
	-no-emul-boot \
	${DVDROOT}

echo "L'image '/tmp/0linux-2011-DVD.iso' a été créée ."

exit 0
