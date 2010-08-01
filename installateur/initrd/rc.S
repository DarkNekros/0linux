#!/bin/sh
# rc.S : Initialisation du système.

# On spécifie un $PATH avant tout:
PATH=/sbin:/usr/sbin:/bin:/usr/bin
export PATH

# On supprime tout 'mtab' superflu :
rm -f /etc/mtab* /etc/nologin 1> /dev/null 2> /dev/null

# On monte /proc :
mount /proc 1> /dev/null 2> /dev/null

# On lance 'udev' :
. /etc/rc.d/rc.udev start

# On règle l'horloge système selon l'horloge matérielle :
if [ -x /sbin/hwclock ]; then
	if grep -wq "^UTC" /etc/hardwareclock ; then
		hwclock --utc --hctosys
	else
		hwclock --localtime --hctosys
	fi
fi

# On active 'syslog' pour épurer l'affichage :
syslogd 2> /dev/null
klogd -c 3 1> /dev/null

# On monte tout notre 'fstab' :
mount -o remount,rw /
mount -a 1> /dev/null 2> /dev/null

# On tente d'activer le réseau :
if [ -x /etc/rc.d/rc.inet1 ]; then
	. /etc/rc.d/rc.inet1
fi

# On charge la police :
. /etc/rc.d/rc.font

# On charge les paramètres pour le shell ($PATH, invite, etc.)
source /etc/profile

# On lance la configuration du clavier d'office :
. /usr/lib/installateur/clavier.sh

# On affiche la mini-aide de bienvenue :
clear
echo -e "\033[1;32mSystème autonome 0 Linux - Bienvenue !\033[0;0m"
echo "--------------------------------------"
echo ""
echo "Vous devez avoir préparé une ou plusieurs partitions de type 'Linux' pour"
echo "installer le système 0. Il est également recommandé de créer une partition"
echo "d'échange (type 'swap')."
echo "Utilisez pour cela 'cfdisk', 'fdisk' ou 'parted'. Voyez l'aide dans"
echo "l'installateur ci-après pour plus d'informations."
echo ""
echo "Appuyez sur ENTRÉE pour continuer."
read BLAH;

/bin/bash --login +h

# C'est fini  !
