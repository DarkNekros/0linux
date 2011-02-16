#!/bin/sh
#
# /etc/rc.d/rc.S : ce script est le premier à être exécuté par 'init'. Il
# initialise le système.

# On spécifie un $PATH avant tout:
PATH=/sbin:/usr/sbin:/bin:/usr/bin
export PATH

# On monte /proc :
mount -F proc /proc -n -t proc

# On monte sysfs:
if grep -wq sysfs /proc/filesystems ; then
	if ! grep -wq sysfs /proc/mounts ; then
		mount -F sysfs /sys -n -t sysfs
	fi
fi

# On lance udev :
if grep -wq sysfs /proc/mounts && grep -wq tmpfs /proc/filesystems ; then
	if [ -x /etc/rc.d/rc.udev ]; then
		. /etc/rc.d/rc.udev start
	fi
fi

# On active la partition d'échange (« swap ») :
swapon -a

# Chargement de la police console en premier lieu :
if [ -x /etc/rc.d/rc.font ]; then
	. /etc/rc.d/rc.font
fi

# On règle l'horloge système selon l'horloge matérielle :
if [ -x /sbin/hwclock ]; then
	if grep -wq "^UTC" /etc/hardwareclock ; then
		hwclock --utc --hctosys
	else
		hwclock --localtime --hctosys
	fi
fi

# La racine doit être montée en lecture seule :
LECTURESEULE=oui
if touch /fichier_test 2>/dev/null; then
	rm -f /fichier_test
	LECTURESEULE=non
fi

# On voit si une vérification forcée n'a pas eu lieu la dernière fois :
if [ -r /etc/forcefsck ]; then
	FORCEFSCK="-f"
fi

# On vérifie le système de fichiers racine :
if [ ! $LECTURESEULE = non ]; then
	VALEURRETOUR=0
	if [ ! -r /etc/fastboot ]; then
		echo "Vérification du système de fichiers racine..."
		fsck $FORCEFSCK -C -a /
		VALEURRETOUR=$?
	fi
	
	# Une valeur de retour supérieure à 2 nécessite un redémarrage. Ue valeur 
	# supérieure à 4 nécessite des opérations manuelles :
	if [ $VALEURRETOUR -ge 2 ]; then
		if [ $VALEURRETOUR -ge 4 ]; then
			echo "IMPORTANT : Une erreur est survenue lors de la vérification de"
			echo "votre système de fichiers racine. Il vous est possible de vous"
			echo "connecter au système en mode mono-utilisateur afin de pouvoir"
			echo "régler le problème manuellement."
			echo ""
			echo "Une fois que vous aurez quitté cet environnement de secours,"
			echo "le système redémarrera."
			echo ""
			
			# On active une invite de secours :
			PS1="(Mode maintenance) \#"; export PS1
			
			# On lance la connexion :
			sulogin
		
		else
			echo "IMPORTANT : Le système de fichiers racine a été modifié."
			echo "Le système va donc redémarrer maintenant."
			echo ""
		fi
		
		# On démonte tout et on redémarre :
		echo "Démontage des systèmes de fichiers..."
		umount -a -r
		mount -F -n -o remount,ro /
		echo "Redémarrage du système."
		reboot -f
	fi

	# On remonte le système de fichiers racine en lecture-écriture :
	echo "Remontage du système de fichiers racine en mode lecture-écriture."
	mount -F -w -n -o remount /

	# Traitement des erreurs de montage :
	if [ $? -gt 0 ] ; then
		echo "IMPORTANT : Échec à la tentative de montage du système de fichiers"
		echo "racine en lecture-écriture. Nous avons là un sérieux probléme."
		echo
		echo "Veuillez appuyer sur ENTRÉE pour continuer puis redémarrez après avoir"
		echo "examiné sérieusement votre machine et sa configuration."
		read blabla;
	fi
	
else
	echo "Évaluation du système de fichiers racine : lecture-écriture."
	echo
	echo "IMPORTANT : La partition racine est déjà montée en lecture-écriture."
	echo "Il est donc impossible de la vérifier !"
	echo
	echo "Pour que la vérification de votre système de fichiers racine soit"
	echo "possible, celui-ci doit être initialement monté en lecture seule."
	echo "Veuillez modifier vos paramètres d'amorçage."
	echo
	echo "Si vous amorcez avec LILO, ajoutez la ligne suivante :"
	echo "	read-only"
	echo "à la section concernée dans votre fichier '/etc/lilo.conf' puis tapez"
	echo "'lilo' pour le réinstaller correctement."
	echo -n "Appuyez sur ENTRÉE pour continuer."
	read blabla;
fi

# Chargement de la disposition des touches du clavier :
if [ -x /etc/rc.d/rc.keymap ]; then
	. /etc/rc.d/rc.keymap
fi

# Toute présence d'un fichier /etc/mtab est forcément obsolète, on le supprime :
rm -f /etc/mtab*

# On remonte la partition racine pour générer un nouveau fichier /etc/mtab :
mount -F -w -o remount /

# On corrige /etc/mtab concernant les systèmes de fichiers sys and proc au cas où
# ils ne seraient pas inscrits sur un système en lecture seule :
if [ -d /proc/sys ]; then
	mount -F -f proc /proc -t proc
fi

if [ -d /sys/bus ]; then
	mount -F -f sysfs /sys -t sysfs
fi

# On charge les modules trouvés dans le fichier /etc/rc.d/rc.modules
if [ -x /etc/rc.d/rc.modules ]; then
	. /etc/rc.d/rc.modules
fi

# On paramètre le noyau si le fichier existe :
if [ -x /sbin/sysctl -a -r /etc/sysctl.conf ]; then
	sysctl -e -p /etc/sysctl.conf
fi

# On vérifie tous les systèmes de fichiers hors racine :
echo "Vérification des systèmes de fichiers..."
fsck $FORCEFSCK -C -R -A -a

# On monte l'usbfs s'il y a lieu :
if grep -wq usbfs /proc/filesystems; then
	if ! grep -wq usbfs /proc/mounts ; then
		if ! grep -wq usbfs /etc/fstab; then
			mount -F usbfs /proc/bus/usb -t usbfs
		else
			mount -F /proc/bus/usb
		fi
	fi
fi

# On monte tous les systèmes de fichiers locaux et non distants (le réseau
# n'est pas encore activé à ce stade). devpts est déjà monté par udev, sysfs et
# et proc sont déjà montés aussi :
echo "Montage des sytèmes de fichiers locaux..."
mount -a -F -t nonfs,nosmbfs,nocifs,noproc,nosysfs,nodevpts

# On réactive la partition d'échange au cas où :
swapon -a

# Un peu de nettoyage :
find /var/run -type f -delete
rm -f /etc/nologin /etc/forcefsck /etc/fastboot /tmp/.Xauth* 1>/dev/null 2>/dev/null

# On crée /tmp/{.ICE-unix,.X11-unix} s'il sont absents :
if [ ! -e /tmp/.ICE-unix ]; then
	mkdir -p /tmp/.ICE-unix
	chmod 1777 /tmp/.ICE-unix
fi

if [ ! -e /tmp/.X11-unix ]; then
	mkdir -p /tmp/.X11-unix
	chmod 1777 /tmp/.X11-unix
fi

# On crée un nouvel 'utmp' sain :
touch /var/run/utmp
chown root:utmp /var/run/utmp
chmod 664 /var/run/utmp

# Si des scripts SysV sont présents pour ce niveau, on les exécute :
if [ -x /etc/rc.d/rc.sysvinit ]; then
	. /etc/rc.d/rc.sysvinit
fi

# Si random-seed est présent, on « crée du hasard » :
if [ -f /etc/random-seed ]; then
	cat /etc/random-seed > /dev/urandom
fi

# On utilise le fichier « poolsize » du noyau :
dd if=/dev/urandom of=/etc/random-seed count=1 bs=$(cat /proc/sys/kernel/random/poolsize) 2> /dev/null
chmod 600 /etc/random-seed

# C'est fini !
