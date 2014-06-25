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
echo -e "[ \033[${ANSI_COLOR}m$(basename $0)\033[0;0m ] Initialisation du système..."

# '/dev' est censé être déjà monté en devtmpfs par le noyau (ou l'initrd).
# On monte les systèmes de fichiers virtuels sur notre système en lecture seule
# (donc, pas de '/etc/mtab' rempli) s'ils sont absents (l'initrd les monte) :
mount -v -n -t proc   proc   /proc 2>/dev/null
mount -v -n -t sysfs  sysfs  /sys  2>/dev/null
mount -v -n -t tmpfs  tmpfs  /run  2>/dev/null

# Chargement de la police console en premier lieu :
if [ -x /etc/rc.d/rc.police ]; then
	/etc/rc.d/rc.police start
fi

# Chargement de la locale :
if [ -x /etc/rc.d/rc.locale ]; then
	/etc/rc.d/rc.locale start
fi

# Mode débogage :
DEBUGBOOTLINE="$(cat /proc/cmdline | grep '0linuxdebug')"

if [ ! "${DEBUGBOOTLINE}" = "" ]; then
	echo -e "[ \033[${ANSI_COLOR}m$(basename $0)\033[0;0m ] --- MODE DÉBOGAGE ---"
	
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
modprobe -v loop 2>/dev/null

# On lance Udev :
if [ -x /etc/rc.d/rc.udev ]; then
	/etc/rc.d/rc.udev start
fi

# On active la partition d'échange (« swap ») :
swapon -av

# On règle l'horloge système selon l'horloge matérielle :
if [ -x /sbin/hwclock ]; then
	if grep -wq "^UTC" /etc/hardwareclock ; then
		hwclock --utc --hctosys
	else
		hwclock --localtime --hctosys
	fi
fi

# Chargement de la disposition des touches du clavier :
if [ -x /etc/rc.d/rc.clavier ]; then
	/etc/rc.d/rc.clavier start
fi

# On vérifie si la racine est montée en lecture seule ou non :
if touch /fichier_test 2>/dev/null; then
	
	# DÉMARRAGE EN LECTURE-ÉCRITURE SANS VÉRIF DE LA RACINE :
	rm -f /fichier_test
else
	
	# DÉMARRAGE EN LECTURE SEULE AVEC VÉRIF DE LA RACINE:
	if [ ! -r /etc/fastboot ]; then
		
		# On vérifie si on a demandé une vérification forcée :
		if [ -r /etc/forcefsck ]; then
			FORCEFSCK="-f"
		fi
		
		echo -e "[ \033[${ANSI_COLOR}m$(basename $0)\033[0;0m ] Vérification du système de fichiers de la racine..."
		fsck -V $FORCEFSCK -C -a /
		VALEURRETOUR=$?
		
		# Une valeur de retour supérieure à 2 nécessite un redémarrage. Une valeur 
		# supérieure à 4 nécessite des opérations manuelles :
		if [ $VALEURRETOUR -ge 2 ]; then
			if [ $VALEURRETOUR -ge 4 ]; then
				echo "IMPORTANT : Une erreur est survenue lors de la vérification de"
				echo "votre système de fichiers racine (voir ci-dessus). Veuillez régler"
				echo "le problème en démarrant sur le système autonome."
				echo -n "Appuyez sur ENTRÉE pour redémarrer maintenant."
				read BLAH;
			else
				echo "Le système de fichiers racine a été modifié."
				echo "Le système va donc redémarrer dans 3 secondes..."
				sleep 3
			fi
			
			# On démonte tout et on redémarre :
			echo -e "[ \033[${ANSI_COLOR}m$(basename $0)\033[0;0m ] Démontage des systèmes de fichiers..."
			umount -v -a -r
			mount -v -n -o remount,ro /
			echo -e "[ \033[${ANSI_COLOR}m$(basename $0)\033[0;0m ] Redémarrage du système."
			reboot -f
		fi
	fi
	
	# On remonte silencieusement le système de fichiers racine en lecture-écriture :
	mount -v -n -w -o remount /
fi

# On est maintenant en lecture-écriture, mais '/etc/mtab' est vide ou erroné. On nettoie :
rm -f /etc/mtab /etc/mtab~ /etc/mtab.tmp
touch /etc/mtab

# On remonte normalement la partition racine pour écrire dans le nouveau fichier '/etc/mtab' :
echo -e "[ \033[${ANSI_COLOR}m$(basename $0)\033[0;0m ] Remontage de la racine en lecture-écriture..."
mount -v -f -w /

# On remonte normalement les systèmes de fichiers virtuels pour les ajouter à
# '/etc/mtab' :
mount -v -o remount /proc
mount -v -o remount /sys
mount -v -o remount /run

# Ces répertoires viennent souvent à manquer, on s'assure qu'ils sont bien là :
mkdir -p /dev/{pts,shm}

mount -v /dev/pts
mount -v /dev/shm

# On monte maintenant les « control groups » :
if grep -wq cgroup /proc/filesystems ; then
	if [ -d /sys/fs/cgroup ]; then
		mount -t cgroup cgroup /sys/fs/cgroup
	else
		mkdir -p /dev/cgroup
		mount -t cgroup cgroup /dev/cgroup
	fi
fi

# On tente de démonter l'ancienne racine de l'initrd mais on ignore toute erreur :
umount -n -f /oldroot/dev/pts 2>/dev/null
umount -n -f /oldroot/dev  2>/dev/null
umount -n -f /oldroot/run  2>/dev/null
umount -n -f /oldroot/proc 2>/dev/null
umount -n -f /oldroot/sys  2>/dev/null
umount -n -f /oldroot      2>/dev/null

# On active à nouveau les espaces d'échange (« swap »), qui peuvent être des fichiers :
swapon -av

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
if [ -x /usr/sbin/sysctl -a -r /etc/sysctl.conf ]; then
	sysctl -e -p /etc/sysctl.conf
fi

# On charge le module FUSE :
modprobe -v fuse

# On vérifie tous les systèmes de fichiers hors racine :
echo -e "[ \033[${ANSI_COLOR}m$(basename $0)\033[0;0m ] Vérification des systèmes de fichiers locaux..."
fsck -V $FORCEFSCK -C -R -A -a

# On monte tous les systèmes de fichiers locaux et non distants (le réseau
# n'est pas encore activé à ce stade). devpts, sysfs et proc sont déjà montés :
echo -e "[ \033[${ANSI_COLOR}m$(basename $0)\033[0;0m ] Montage des sytèmes de fichiers locaux..."
mount -v -a -F -t nonfs,nonnfs,nonnfs3,nonnfs4,nosmbfs,nocifs,noproc,nosysfs,nodevpts

# Si random-seed est présent, on « crée du hasard » :
if [ -f /etc/random-seed ]; then
	cat /etc/random-seed > /dev/urandom
fi

# On utilise le fichier « poolsize » du noyau :
dd if=/dev/urandom of=/etc/random-seed count=1 bs=$(cat /proc/sys/kernel/random/poolsize) 2> /dev/null
chmod 600 /etc/random-seed

# C'est fini.
