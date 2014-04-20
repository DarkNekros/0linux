#!/bin/sh
#
# /etc/rc.d/rc.S : ce script est le premier à être exécuté par 'init'. Il
# initialise le système.

# On spécifie un $PATH avant tout:
PATH=/sbin:/usr/sbin:/bin:/usr/bin
export PATH

# On s'assure de la prise en charge de l'UTF-8 :
unicode_start

# On charge les variables d'identification du système :
source /etc/os-release

# On exporte la variable pour la couleur des messages, utilisée par les '/etc/rc.d.rc*' :
export ANSI_COLOR="${ANSI_COLOR}"

# On dit bonjour :
echo -e "\033[${ANSI_COLOR}m${PRETTY_NAME}\033[0;0m ${VERSION} vous souhaite la bienvenue !"

# '/dev' est censé être déjà monté en devtmpfs par le noyau.
# On monte les systèmes de fichiers virtuels sur notre système en lecture seule
# (donc, pas de '/etc/mtab' rempli) :
mount -v -n -t proc   proc   /proc
mount -v -n -t sysfs  sysfs  /sys
mount -v -n -t tmpfs  tmpfs  /run

# Mode débogage :
DEBUGBOOTLINE="$(cat /proc/cmdline | grep '0linuxdebug')"

if [ ! "${DEBUGBOOTLINE}" = "" ]; then
	echo "--- MODE DÉBOGAGE ---"
	
	# Mode lent avec pause entre chaque étape :
	if [ ! "$(echo "${DEBUGBOOTLINE}" | grep '0linuxdebug lent')" = "" ]; then
		set -x
		trap "sleep 5" DEBUG
	
	# Mode de débogage normal :
	else
		set -x
	fi
fi

# On lance très tôt le module 'loop' :
modprobe loop 2>/dev/null

# Chargement de la police console en premier lieu :
if [ -x /etc/rc.d/rc.police ]; then
	/etc/rc.d/rc.police start
fi

# Chargement de la locale :
if [ -x /etc/rc.d/rc.locale ]; then
	/etc/rc.d/rc.locale start
fi

# On lance Udev :
if [ -x /etc/rc.d/rc.udev ]; then
	/etc/rc.d/rc.udev start
fi

# On active la partition d'échange (« swap ») :
swapon -a

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

# Chargement de la disposition des touches du clavier :
if [ -x /etc/rc.d/rc.clavier ]; then
	/etc/rc.d/rc.clavier start
fi

# On voit si une vérification forcée n'a pas eu lieu la dernière fois :
if [ -r /etc/forcefsck ]; then
	FORCEFSCK="-f"
fi

# On vérifie le système de fichiers racine :
if [ ! $LECTURESEULE = non ]; then
	VALEURRETOUR=0
	if [ ! -r /etc/fastboot ]; then
		echo "Vérification du système de fichiers de la racine..."
		fsck -V $FORCEFSCK -C -a /
		VALEURRETOUR=$?
	fi
	
	# Une valeur de retour supérieure à 2 nécessite un redémarrage. Ue valeur 
	# supérieure à 4 nécessite des opérations manuelles :
	if [ $VALEURRETOUR -ge 2 ]; then
		if [ $VALEURRETOUR -ge 4 ]; then
			echo "IMPORTANT : Une erreur est survenue lors de la vérification de"
			echo "votre système de fichiers racine (voir ci-dessus). Veuillez régler"
			echo "le problème à l'aide du système autonome."
			echo -n "Appuyez sur ENTRÉE pour redémarrer maintenant."
			read BLAH;
		
		else
			echo "Le système de fichiers racine a été modifié."
			echo "Le système va donc redémarrer maintenant."
			echo ""
		fi
		
		# On démonte tout et on redémarre :
		echo "Démontage des systèmes de fichiers..."
		umount -v -a -r
		mount -v -n -o remount,ro /
		echo "Redémarrage du système."
		reboot -f
	fi

	# On remonte le système de fichiers racine en lecture-écriture :
	echo "Remontage du système de fichiers racine en mode lecture-écriture."
	mount -v -n -w -o remount /
else
	echo "Évaluation du système de fichiers racine : lecture-écriture."
	echo ""
	echo "IMPORTANT : La partition racine est déjà montée en lecture-écriture."
	echo "Il m'est donc impossible de la vérifier avec 'fsck' !"
	echo ""
	echo "Pour que la vérification de votre système de fichiers racine soit"
	echo "possible, celui-ci doit être initialement monté en lecture seule."
	echo "Veuillez modifier vos paramètres d'amorçage pour obliger"
	echo "le chargeur d'amorçage à amorcer votre système en lecture seule"
	echo "(mots-clés « read-only », « ro », etc.)."
	echo ""
	echo -n "Appuyez sur ENTRÉE pour continuer le démarrage."
	read blabla;
fi

# On remonte la partition racine pour générer un nouveau fichier /etc/mtab :
rm -f /etc/mtab /etc/mtab~ /etc/mtab.tmp && touch /etc/mtab
mount -v -f -w  /

# Ces répertoires viennent souvent à manquer, on s'assure qu'ils sont bien là :
mkdir -p /dev/{pts,shm}

# On remonte normalement les systèmes de fivchiers virtuels pour les ajouter à
# '/etc/mtab' :
mount -v -o remount /proc
mount -v -o remount /sys
mount -v -o remount /run
mount -v /dev/pts
mount -v /dev/shm

# On active les espaces d'échange (« swap »), qui peuvent être des fichiers :
swapon -a

# Un peu de nettoyage :
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

# On crée un nouvel 'utmp' sain sous '/run' :
touch           /run/utmp
chmod 664       /run/utmp
chown root:utmp /run/utmp

# On crée un 'lock' sous '/run' car '/var/lock' ne pointe sur rien pour le moment:
mkdir -p /run/lock

# On charge les modules trouvés dans le fichier '/etc/rc.d/rc.modules' :
if [ -x /etc/rc.d/rc.modules ]; then
	/etc/rc.d/rc.modules
fi

# On paramètre le noyau si le fichier existe :
if [ -x /sbin/sysctl -a -r /etc/sysctl.conf ]; then
	sysctl -e -p /etc/sysctl.conf
fi

# On démarre FUSE :
if [ -x /etc/rc.d/rc.fuse ]; then
	/etc/rc.d/rc.fuse start
fi

# On vérifie tous les systèmes de fichiers hors racine :
echo "Vérification des systèmes de fichiers..."
fsck -V $FORCEFSCK -C -R -A -a

# On monte tous les systèmes de fichiers locaux et non distants (le réseau
# n'est pas encore activé à ce stade). devpts, sysfs et proc sont déjà montés :
echo "Montage des sytèmes de fichiers locaux..."
mount -v -a -F -t nonnfs,nonnfs3,nonnfs4,nosmbfs,nocifs,noproc,nosysfs,nodevpts

# Si random-seed est présent, on « crée du hasard » :
if [ -f /etc/random-seed ]; then
	cat /etc/random-seed > /dev/urandom
fi

# On utilise le fichier « poolsize » du noyau :
dd if=/dev/urandom of=/etc/random-seed count=1 bs=$(cat /proc/sys/kernel/random/poolsize) 2> /dev/null
chmod 600 /etc/random-seed

# C'est fini !
