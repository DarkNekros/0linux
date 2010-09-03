#!/bin/sh
#
# /etc/rc.d/rc.M : ce fichier est exécuté lors du passage en mode multi-
# utilisateur par 'init' (donc dans les niveaux d'exécution 2 à 6).
# Très lourdement inspiré de Slackware.

echo "Passage en mode multi-utilisateur..."

if [ -x /sbin/ldconfig ]; then
	ldconfig &
fi

# L'écran se vide au bout de 15 minutes et entre en veille au bout d'une heure :
setterm -blank 15 -powersave powerdown -powerdown 60

# On spécifie le nom de l'hôte si celui-ci n'existe pas :
if [ -r /etc/HOSTNAME ]; then
	hostname $(cat /etc/HOSTNAME | cut -f1 -d .)
else
	echo "pingouin.exemple.net" > /etc/HOSTNAME
	hostname pingouin
fi

# Sauvegarde du contenu de 'dmesg' :
dmesg -s 65536 > /var/log/dmesg

# Lancement de syslog :
if [ -x /etc/rc.d/rc.syslog -a -x /usr/sbin/syslogd -a -d /var/log ]; then
	. /etc/rc.d/rc.syslog start
fi

# Initialisation du matériel réseau :
if [ -x /etc/rc.d/rc.inet1 ]; then
	. /etc/rc.d/rc.inet1
fi

# Lancement des démons réseau :
if [ -x /etc/rc.d/rc.inet2 ]; then
	. /etc/rc.d/rc.inet2
fi

# Montage du reste des systèmes de fichiers :
mount -a -v 2> /dev/null | grep -v "already mounted"

# Nettoyage du système après le montage de systèmes de fichiers, superflu compris :
rm -f /var/lock/* /tmp/.X*lock /tmp/core /core 2> /dev/null

# Nettoyage des connecteurs réseau :
if [ -r /tmp/hunt -o -r /tmp/hunt.stats ]; then
	rm -f /tmp/hunt*
fi

# Correction des permissions au cas où :
chmod 755 / 2> /dev/null
chmod 1777 /tmp /var/tmp

# Lancement des scripts System V s'il en existe pour ce niveau d'exécution :
if [ -x /etc/rc.d/rc.sysvinit ]; then
	. /etc/rc.d/rc.sysvinit
fi

# Mise à jour de l'indexation des polices :
if [ -x /usr/bin/fc-cache ]; then
	echo "Mise à jour de l'indexation des polices..."
	/usr/bin/fc-cache -f
fi

# Lancement des programmes pour GTK+ et Pango dans les 2 architectures :
if [ -d /etc/gtk-2.0 ]; then
	echo "Mise à jour des modules GTK+..."
	gdk-pixbuf-query-loaders-32 > /etc/gtk-2.0-32/gdk-pixbuf.loaders
	gdk-pixbuf-query-loaders-64 > /etc/gtk-2.0-64/gdk-pixbuf.loaders
	gtk-query-immodules-2.0-32 > /etc/gtk-2.0-32/gtk.immodules
	gtk-query-immodules-2.0-64 > /etc/gtk-2.0-64/gtk.immodules
fi

if [ -d /etc/pango ]; then
	echo "Mise à jour des modules Pango..."
	pango-querymodules-32 > /etc/pango-32/pango.modules
	pango-querymodules-64 > /etc/pango-64/pango.modules
fi

# Mise à jour du cache des icônes :
if find /usr/share/icons 2> /dev/null | grep -q icon-theme.cache ; then
	echo "Mise à jour du cache des icônes..."
	for theme_dir in /usr/share/icons/* ; do
		if [ -r ${theme_dir}/icon-theme.cache ]; then
			/usr/bin/gtk-update-icon-cache -t -f ${theme_dir} 1> /dev/null 2> /dev/null
		fi
	done
	
	# On supprime donc ce gros fichier :
	if [ -r /usr/share/icons/icon-theme.cache ]; then
		rm -f /usr/share/icons/icon-theme.cache
	fi
fi

# Mise à jour de la base de données de types MIME :
if [ -x /usr/bin/update-mime-database -a -d /usr/share/mime ]; then
	echo "Mise à jour de la base de données de types MIME..."
	/usr/bin/update-mime-database /usr/share/mime 1> /dev/null 2> /dev/null
fi

# Lancement de D-Bus :
if [ -x /etc/rc.d/rc.messagebus ]; then
	. /etc/rc.d/rc.messagebus start
fi

# Lancement de dcron :
echo "Lancement de dcron..."
if [ -x /usr/sbin/crond ]; then
	/usr/sbin/crond -l10 >> /var/log/cron 2>&1
fi

# Lancement du serveur de pointage GPM :
if [ -x /etc/rc.d/rc.gpm ]; then
	. /etc/rc.d/rc.gpm start
fi

# Lancement du script « local » personnel :
if [ -x /etc/rc.d/rc.local ]; then
	. /etc/rc.d/rc.local
fi

# C'est fini !
