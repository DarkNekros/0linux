#!/usr/bin/env bash
# Voyez le fichier LICENCES pour connaître la licence de ce script.

# *** À LANCER EN ROOT ! ***
# Lancer comme suit :  './construction-liveusb.recette PÉRIPHÉRIQUE_USB', par ex. :
# 	# ./construction-liveusb.recette /dev/sdc

# ATTENTION : Bien vérifier qu'on désigne la clé USB et PAS un disque dur 
# système et/ou données !!! Ne spécifiez PAS une partition (se terminant par un
# chiffre comme '/dev/sdc1') mais bien le PÉRIPHÉRIQUE ('/dev/sdc', '/dev/sdd', etc.)!

# ATTENTION : relisez les avertissements 2 fois, vous êtes prévenu(e) !

# Un périphérique en argument est obligatoire. 
if [ "$1" = "" ]; then
	echo "Veuillez spécifier un périphérique USB, ex. : "
	echo "	# ./construction-liveusb.sh /dev/sdd"
	exit 1
fi

set -e
umask 022
CWD=$(pwd)

# Changer ces paramètres via la ligne de commande, par ex. :
# 	# SOURCES=/ici PAQUETS=/quelque/part LIVEOS=/ailleurs ./construction-liveusb.recette /dev/sdX

SOURCES=${SOURCES:-/marmite/0/sources}
PAQUETS=${PAQUETS:-/marmite/0/paquets}
TMP=${TMP:-/marmite/temp}

LIVEOS=${LIVEOS:-$TMP/liveos}
INITRDGZ=${INITRDGZ:-$TMP/initrd.gz}
NOYAU=${NOYAU:-$TMP/noyau}
USBDEV=${USBDEV:-$1}

mkdir -p $TMP

# On crée et on vide le répertoire d'accueil :
rm -rf ${LIVEOS} ${INITRDGZ} ${NOYAU}
mkdir -p ${LIVEOS}

# On installe les paquets pour le LiveOS :
echo "Création de la clé USB autonome en cours..."
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
rm -rf ${LIVEOS}/usr/lib/*
find ${LIVEOS} -type f -name "*.a" -delete
find ${LIVEOS} -type f -name "*.la" -delete

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
chroot ${LIVEOS} /sbin/ldconfig 2>/dev/null
 
# On met à jour les dépendances des modules du noyau :
chroot ${LIVEOS} /usr/sbin/depmod -a

# On évite que se lance 'sshd' (+ effet d'escalier à l'affichage) :
chmod -x ${LIVEOS}/etc/rc.d/rc.sshd

# On évite aussi que se lance 'rc.firewall' :
chmod -x ${LIVEOS}/etc/rc.d/rc.firewall

# On copie le nouveau noyau dans /tmp sans sa version :
rm -f ${NOYAU}
cp ${LIVEOS}/boot/noyau-2* ${NOYAU}

# On positionne le fuseau à Paris car on est franco-français et chauvin :
echo "localtime" > ${LIVEOS}/etc/hardwareclock
ln -sf ../usr/share/zoneinfo/Europe/Paris ${LIVEOS}/etc/localtime

# On crée l'initrd :
echo -n "Création de l'initrd en cours... "
cd ${LIVEOS}
find . | cpio -v -o -H newc | gzip -9 > ${INITRDGZ}
echo "Terminé."

# On monte la clé, sans la presser :
echo "La clé utilisée sera ${USBDEV}1."
echo "Appuyez sur ENTRÉE pour confirmer la création de la clé"
echo "ou bien appuyez sur CTRL+C pour annuler maintenant."
read PLOP;
mount ${USBDEV}1 /mnt/tmp || true
sleep 4

# On nettoie la clé et on dévérouille 'ldlinux.sys' :
echo -n "Nettoyage... "
for f in $(find /mnt/tmp -name "ldlinux.sys" -print); do
	chattr -i ${f}
	rm -f ${f}
done

rm -rf /mnt/tmp/boot/extlinux
mkdir -p /mnt/tmp/0/paquets
mkdir -p /mnt/tmp/boot/extlinux
echo "Terminé."

echo -n "Copie des fichiers en cours... "
# On copie toutes les sources de extlinux/ :
cp -ar ${SOURCES}/installateur/extlinux/* /mnt/tmp/boot/extlinux/

# On copie les modules binaires de Syslinux :
cp -a /usr/share/syslinux/{chain,kbdmap,linux,reboot,vesamenu}.c32 /mnt/tmp/boot/extlinux/
chmod +x /mnt/tmp/boot/extlinux/*.c32

# On copie le noyau et l'initrd :
cp -a ${INITRDGZ} ${NOYAU} /mnt/tmp/boot/

# On copie les paquets :
rsync -auv --delete-after ${PAQUETS}/* /mnt/tmp/0/paquets

# On s'assure des permissions :
chown -R root:root /mnt/tmp/* 2> /dev/null || true

# On copie un MBR propre :
dd if=/usr/share/syslinux/mbr.bin of=${USBDEV}

# On installe enfin extlinux :
extlinux --install /mnt/tmp/boot/extlinux

# On démonte la clé :
umount /mnt/tmp
echo "Terminé. Clé USB autonome créée."

exit 0
