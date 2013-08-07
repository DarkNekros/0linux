#!/bin/sh
# rc.S : Initialisation du système.

# On spécifie un $PATH avant tout:
PATH=/sbin:/usr/sbin:/bin:/usr/bin
export PATH

# On monte les systèmes de fichiers virtuels :
mount -v -n -o mode=0755,nosuid    -t devtmpfs devtmpfs /dev
mount -v -n -o nosuid,noexec,nodev -t proc     proc     /proc
mount -v -n -o defaults            -t tmpfs    tmpfs    /run
mount -v -n -o nosuid,noexec,nodev -t sysfs    sysfs    /sys

# on ne peut créer ces répertoires que maintenant :
mkdir -p /dev/pts /dev/shm

# On peut les monter :
mount -v -n -o gid=5,mode=620      -t devpts  devpts  /dev/pts
mount -v -n -o defaults            -t tmpfs   tmpfs   /dev/shm

# On met à jour les dépendances des modules noyau :
depmod -a

# On lance très tôt le module 'loop' :
modprobe loop 2>/dev/null

# Chargement de la police console en premier lieu :
if [ -x /etc/rc.d/rc.police ]; then
	. /etc/rc.d/rc.police start
fi

# On lance Udev :
if [ -x /etc/rc.d/rc.udev ]; then
	. /etc/rc.d/rc.udev start
fi

# On règle l'horloge système selon l'horloge matérielle :
if [ -x /sbin/hwclock ]; then
	if grep -wq "^UTC" /etc/hardwareclock ; then
		hwclock --utc --hctosys
	else
		hwclock --localtime --hctosys
	fi
fi

# On spécifie le nom de l'hôte si celui-ci n'existe pas :
if [ -r /etc/hostname ]; then
	hostname $(cat /etc/hostname | cut -f1 -d .)
else
	echo "pingouin.exemple.net" > /etc/hostname
	hostname pingouin
fi

# On charge les paramètres pour le shell ($PATH, invite, etc.)
source /etc/profile

# C'est fini  !
