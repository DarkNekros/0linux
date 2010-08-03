#!/bin/sh
# rc.S : Initialisation du système.

# On spécifie un $PATH avant tout:
PATH=/sbin:/usr/sbin:/bin:/usr/bin
export PATH

# On supprime tout 'mtab' superflu :
rm -f /etc/mtab* /etc/nologin 1> /dev/null 2> /dev/null

# On monte /proc :
mount /proc 1> /dev/null 2> /dev/null

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

# On lance 'udev' :
. /etc/rc.d/rc.udev start

# On donne un nom à notre hôte :
hostname --file /etc/HOSTNAME

# On tente d'activer le réseau :
if [ -x /etc/rc.d/rc.inet1 ]; then
	. /etc/rc.d/rc.inet1
fi

# On charge la police :
. /etc/rc.d/rc.font

# On charge les paramètres pour le shell ($PATH, invite, etc.)
source /etc/profile

# C'est fini  !
