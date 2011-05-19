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
dmesg -s  262144 > /var/log/dmesg &

# Lancement de syslog :
if [ -x /etc/rc.d/rc.syslog -a -x /usr/sbin/syslogd -a -d /var/log ]; then
	. /etc/rc.d/rc.syslog start
fi

# On tente d'activer le réseau :
if [ -x /etc/rc.d/rc.reseau ]; then
	. /etc/rc.d/rc.reseau
fi

# Montage du reste des systèmes de fichiers :
mount -a 2> /dev/null | grep -v "already mounted"

# Nettoyage du système après le montage de systèmes de fichiers, superflu compris :
rm -f /var/lock/* /tmp/.X*lock /tmp/core /core 2> /dev/null

# Nettoyage des connecteurs réseau :
if [ -r /tmp/hunt -o -r /tmp/hunt.stats ]; then
	rm -f /tmp/hunt*
fi

# Correction des permissions au cas où :
chmod 755 / 2> /dev/null
chmod 1777 /tmp /var/tmp

# On lance la configuration du clavier d'office :
. clavier.sh

# On affiche la mini-aide de bienvenue :
clear
echo "--------------------------------------"
echo -e "\033[1;32mSystème autonome 0 Linux - Bienvenue !\033[0;0m"
echo "--------------------------------------"
echo ""
echo "Pour partitionner vos disques durs, 'cfdisk', 'fdisk' et 'parted'"
echo "sont disponibles."
echo "Pour débuter l'installation, tapez « installateur »."
echo ""
echo "Mais connectez-vous tout d'abord en « root »."

# C'est fini !
