#!/bin/sh
# rc.S : Initialisation du système.

# On supprime tout 'mtab' superflu :
/bin/rm -f /etc/mtab* /etc/nologin 1> /dev/null 2> /dev/null

# On monte /proc :
/sbin/mount /proc 1> /dev/null 2> /dev/null

# On lance 'udev' :
/bin/bash /etc/rc.d/rc.udev start

# On active 'syslog' pour épurer l'affichage :
/sbin/syslogd 2> /dev/null
/sbin/klogd -c 3 1> /dev/null

# On monte tout notre 'fstab' :
/sbin/mount -o remount,rw /
/sbin/mount -a 1> /dev/null 2> /dev/null

# On tente d'activer le réseau :
if [ -x /etc/rc.d/rc.inet1 ]; then
	/bin/sh /etc/rc.d/rc.inet1
fi

# On charge les paramètres pour le shell ($PATH, invite, etc.)
. /etc/profile

# On affiche la mini-aide de bienvenue :
cat /etc/issue

# C'est fini  !
