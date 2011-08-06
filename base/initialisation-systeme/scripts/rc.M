#!/bin/sh
#
# /etc/rc.d/rc.M : ce fichier est exécuté lors du passage en mode multi-
# utilisateur par 'init' (donc dans les niveaux d'exécution 2 à 6).

# L'écran se vide au bout de 15 minutes et entre en veille au bout d'une heure :
setterm -blank 15 -powersave powerdown -powerdown 60

# On spécifie le nom de l'hôte si celui-ci n'existe pas :
if [ -r /etc/HOSTNAME ]; then
	hostname $(cat /etc/HOSTNAME | cut -f1 -d .)
else
	echo "pingouin.exemple.net" > /etc/HOSTNAME
	hostname pingouin
fi

# On sauvegarde le contenu de 'dmesg' dans un fichier :
dmesg -s 262144 > /var/log/dmesg

# Lancement de syslog :
if [ -x /etc/rc.d/rc.syslog -a -x /usr/sbin/syslogd -a -d /var/log ]; then
	. /etc/rc.d/rc.syslog start
fi

# Lancement du réseau :
if [ -x /etc/rc.d/rc.reseau ]; then
	. /etc/rc.d/rc.reseau start
fi

# Montage du reste des systèmes de fichiers :
mount -F -a 2> /dev/null | grep -v "already mounted"

# Nettoyage du système après le montage de systèmes de fichiers, superflu compris :
rm -f /var/lock/* /tmp/.X*lock /tmp/core /core /tmp/hunt* 2> /dev/null

# Correction des permissions au cas où :
chmod 755 / 2>/dev/null
chmod 1777 /tmp /var/tmp

# Lancement des scripts System V s'il en existe pour ce niveau d'exécution :
if [ -x /etc/rc.d/rc.sysvinit ]; then
	. /etc/rc.d/rc.sysvinit
fi

# Lancement des programmes pour GTK+ et Pango dans les 2 architectures :
if [ ! -r etc/gtk-2.0-64/gdk-pixbuf.loaders ]; then
	echo "Mise à jour des modules GTK+..."
	gdk-pixbuf-query-loaders-32 > /etc/gtk-2.0-32/gdk-pixbuf.loaders
	gdk-pixbuf-query-loaders-64 > /etc/gtk-2.0-64/gdk-pixbuf.loaders
	gdk-pixbuf-query-loaders-32 --update-cache
	gdk-pixbuf-query-loaders-64 --update-cache
	gtk-query-immodules-2.0-32 > /etc/gtk-2.0-32/gtk.immodules
	gtk-query-immodules-2.0-64 > /etc/gtk-2.0-64/gtk.immodules
fi

if [ ! -r /etc/pango-64/pango.modules ]; then
	echo "Mise à jour des modules Pango..."
	pango-querymodules-32 > /etc/pango-32/pango.modules
	pango-querymodules-64 > /etc/pango-64/pango.modules
fi

# Lancement de D-Bus :
if [ -x /etc/rc.d/rc.messagebus ]; then
	. /etc/rc.d/rc.messagebus start
fi

# Lancement de ConsoleKit :
if [ -x /etc/rc.d/rc.consolekit ]; then
	. /etc/rc.d/rc.consolekit start
fi

# Restauration de ALSA :
if [ -x /etc/rc.d/rc.alsa ]; then
	. /etc/rc.d/rc.alsa
fi

# Lancement de Avahi :
if [ -x /etc/rc.d/rc.avahidaemon ]; then
	. /etc/rc.d/rc.avahidaemon start
fi

# Lancement de 'avahidnsconfd' : 
if [ -x /etc/rc.d/rc.avahidnsconfd ]; then
	. /etc/rc.d/rc.avahidnsconfd start
fi

# Lancement de wicd :
if [ -x /etc/rc.d/rc.wicd ]; then
	. /etc/rc.d/rc.wicd start
fi

# Lancement de dcron :
echo "Lancement de dcron..."
if [ -x /usr/sbin/crond ]; then
	/usr/sbin/crond -l10 >> /var/log/cron 2>&1
fi

# Lancement de MySQL :
if [ -x /etc/rc.d/rc.mysqld ]; then
	. /etc/rc.d/rc.mysqld start
fi

# Lancement d'Apache :
if [ -x /etc/rc.d/rc.httpd ]; then
	. /etc/rc.d/rc.httpd start
fi

# Lancement de Samba :
if [ -x /etc/rc.d/rc.samba ]; then
	. /etc/rc.d/rc.samba start
fi

# Lancement du serveur de pointage GPM :
if [ -x /etc/rc.d/rc.gpm ]; then
	. /etc/rc.d/rc.gpm start
fi

# Lancement de CUPS :
if [ -x /etc/rc.d/rc.cups ]; then
	. /etc/rc.d/rc.cups start
fi

# Lancement du script « local » personnel :
if [ -x /etc/rc.d/rc.local ]; then
	. /etc/rc.d/rc.local
fi

# C'est fini !
