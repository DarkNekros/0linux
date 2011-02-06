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
if grep -wq "^UTC" /etc/hardwareclock ; then
	hwclock --utc --hctosys 2>/dev/null
else
	hwclock --localtime --hctosys 2>/dev/null
fi

# On monte tout notre 'fstab' :
mount -a 2> /dev/null

# On lance 'udev' :
. /etc/rc.d/rc.udev start

# On donne un nom à notre hôte :
hostname --file /etc/HOSTNAME

# On charge la police :
. /etc/rc.d/rc.font

# On charge les paramètres pour le shell ($PATH, invite, etc.)
source /etc/profile

# C'est fini  !
