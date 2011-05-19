#!/bin/sh
# rc.S : Initialisation du système.

# On spécifie un $PATH avant tout:
PATH=/sbin:/usr/sbin:/bin:/usr/bin
export PATH

# On monte /proc :
mount /proc 1> /dev/null 2> /dev/null

# On monte tout notre 'fstab' :
mount -a 2> /dev/null

# On met à jour les dépendances des modules noyau :
depmod -a &

# On lance 'udev' :
. /etc/rc.d/rc.udev start

# On spécifie le nom de l'hôte si celui-ci n'existe pas :
if [ -r /etc/HOSTNAME ]; then
	hostname $(cat /etc/HOSTNAME | cut -f1 -d .)
else
	echo "pingouin.exemple.net" > /etc/HOSTNAME
	hostname pingouin
fi

# On charge la police :
. /etc/rc.d/rc.font

# On charge les paramètres pour le shell ($PATH, invite, etc.)
source /etc/profile

# C'est fini  !
