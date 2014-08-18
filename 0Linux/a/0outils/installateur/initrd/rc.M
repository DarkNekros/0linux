#!/bin/sh
#
# Initialisation du système en mode multi-utilisateur.

# Ça ne fait pas de mal :
if [ -x /sbin/ldconfig ]; then
	ldconfig &
fi

# L'écran se vide au bout de 15 minutes et entre en veille au bout d'une heure :
setterm -blank 15 -powersave powerdown -powerdown 60

# Sauvegarde du contenu de 'dmesg' :
dmesg -s 262144 > /var/log/dmesg

# Lancement de syslog :
if [ -x /etc/rc.d/rc.syslog -a -x /usr/sbin/syslogd -a -d /var/log ]; then
	. /etc/rc.d/rc.syslog start
fi

# On tente d'activer le réseau :
if [ -x /etc/rc.d/rc.reseau ]; then
	. /etc/rc.d/rc.reseau start
fi

# Montage du reste des systèmes de fichiers :
mount -a 2> /dev/null | grep -v "already mounted"

# Correction des permissions au cas où :
chmod 755 /
chmod 1777 /tmp /var/tmp

# Si l'auto-installation a été demandé sur la ligne d'amorçage :
if grep -q "autoinstall0linux=" /proc/cmdline; then
	
	# On analyse la ligne "boot:"
	for ARG in $(cat /proc/cmdline); do
		case $ARG in
			autoinstall0linux=*)
				AUTOINSTALLSOURCE=$(echo $ARG | cut -d'=' -f2-)
			;;
		esac
	done
	
	# On lance l'installateur en mode automatique d'office :
	/usr/share/0outils/installateur/scripts/installateur auto ${AUTOINSTALLSOURCE}
else
	# On lance la configuration du clavier d'office :
	/usr/share/0outils/installateur/scripts/clavier.sh
fi

# C'est fini !
