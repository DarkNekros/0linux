#!/bin/sh
#
# /etc/rc.d/rc.M : ce fichier est exécuté lors du passage en mode multi-
# utilisateur par 'init' (donc dans les niveaux d'exécution 2 à 6).

# L'écran se vide au bout de 15 minutes et entre en veille au bout d'une heure :
setterm -blank 15 -powersave powerdown -powerdown 60

# On spécifie le nom de l'hôte si celui-ci n'existe pas :
if [ -r /etc/hostname ]; then
	hostname $(cat /etc/hostname | cut -f1 -d .)
else
	echo "pingouin.exemple.net" > /etc/hostname
	hostname pingouin
fi

# On sauvegarde le contenu de 'dmesg' dans un fichier :
dmesg -s 262144 >> /var/log/dmesg

# Lancement de syslog :
if [ -x /etc/rc.d/rc.syslog -a -x /usr/sbin/syslogd -a -d /var/log ]; then
	/etc/rc.d/rc.syslog start
fi

# Lancement du réseau :
if [ -x /etc/rc.d/rc.reseau ]; then
	/etc/rc.d/rc.reseau start
fi

# Montage du reste des systèmes de fichiers :
mount -v -F -a | grep -v "already mounted"

# Nettoyage du système après le montage de systèmes de fichiers, superflu compris :
rm -f /var/lock/* /tmp/.X*lock /tmp/core /core /tmp/hunt* 2> /dev/null

# Correction des permissions au cas où :
chmod 755 /
chmod 1777 /tmp /var/lock /var/tmp

# Lancement de SSH :
if [ -x /etc/rc.d/rc.ntp ]; then
	/etc/rc.d/rc.sshd start
fi

# Lancement de iptables (règles pour pare-feu rudimentaire) :
if [ -x /etc/rc.d/rc.iptables ]; then
	/etc/rc.d/rc.iptables start
fi

# Lancement de NTP :
if [ -x /etc/rc.d/rc.ntp ]; then
	/etc/rc.d/rc.ntp start
fi

# Lancement de D-Bus :
if [ -x /etc/rc.d/rc.messagebus ]; then
	/etc/rc.d/rc.messagebus start
fi

# Lancement des programmes pour GDK-Pixbuf :
gdk-pixbuf-query-loaders --update-cache

# Lancement des programmes pour les modules GTK+ :
if [ -x /etc/rc.d/rc.gtk+ ]; then
	/etc/rc.d/rc.gtk+ start
fi

# Lancement des programmes pour les modules Pango :
if [ -x /etc/rc.d/rc.pango ]; then
	/etc/rc.d/rc.pango start
fi

# Lancement de ConsoleKit :
if [ -x /etc/rc.d/rc.consolekit ]; then
	/etc/rc.d/rc.consolekit start
fi

# Restauration de ALSA :
if [ -x /etc/rc.d/rc.alsa ]; then
	/etc/rc.d/rc.alsa start
fi

# Lancement de Avahi :
if [ -x /etc/rc.d/rc.avahi ]; then
	/etc/rc.d/rc.avahi start
fi

# Lancement du démon SASL :
if [ -x /etc/rc.d/rc.sasl ]; then
	/etc/rc.d/rc.sasl start
fi

# Lancement de wicd :
if [ -x /etc/rc.d/rc.wicd ]; then
	. /etc/rc.d/rc.wicd start
fi

# Lancement de dcron :
if [ -x /usr/sbin/crond ]; then
	/usr/sbin/crond -l10 >> /var/log/cron 2>&1
fi

# Lancement de MySQL :
if [ -x /etc/rc.d/rc.mysqld ]; then
	/etc/rc.d/rc.mysqld start
fi

# Lancement d'Apache :
if [ -x /etc/rc.d/rc.httpd ]; then
	/etc/rc.d/rc.httpd start
fi

# Lancement de GPSd :
if [ -x /etc/rc.d/rc.gpsd ]; then
	/etc/rc.d/rc.gpsd start
fi

# On lance RPC Bind :
if [ -x /etc/rc.d/rc.rpcbind ]; then
	/etc/rc.d/rc.rpcbind start
fi
# On lance NFS :
if [ -x /etc/rc.d/rc.nfsd ]; then
	/etc/rc.d/rc.nfsd start
fi

# On lance « l'IP forward » :
if [ -x /etc/rc.d/rc.ip_forward ]; then
	/etc/rc.d/rc.ip_forward start
fi

# Lancement de Samba :
if [ -x /etc/rc.d/rc.samba ]; then
	/etc/rc.d/rc.samba start
fi

# Lancement du serveur de pointage GPM :
if [ -x /etc/rc.d/rc.gpm ]; then
	/etc/rc.d/rc.gpm start
fi

# Lancement de CUPS :
if [ -x /etc/rc.d/rc.cups ]; then
	/etc/rc.d/rc.cups start
fi

# Lancement de VirtualBox :
if [ -x /etc/rc.d/rc.vboxdrv ]; then
	/etc/rc.d/rc.vboxdrv start
fi

# Lancement du script « local » personnel :
if [ -x /etc/rc.d/rc.local ]; then
	/etc/rc.d/rc.local
fi

# C'est fini !
