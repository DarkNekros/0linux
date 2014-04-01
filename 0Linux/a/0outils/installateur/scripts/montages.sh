#!/usr/bin/env bash

# On nettoie avant toute chose :
rm -f $TMP/fstab
unset MOUNTPART MOUNTDIR FSMOUNT MOUNTOPTIONS MAJORMINOR LINE LINEDOS

# Cette fonction supprime les espaces superflus via 'echo' :
crunch() {
	read STRING;
	echo $STRING;
}

# On crée 'fstab' s'il est absent :
if [ ! -r $TMP/fstab ]; then
	touch $TMP/fstab
fi

# Pour chaque montage Linux :
cat $TMP/choix_partitions | while read LINE; do
	
	# La partition :
	MOUNTPART="$(echo ${LINE} | crunch | cut -d' ' -f1)"
	
	# Le point de montage :
	MOUNTDIR="$(echo ${LINE} | crunch | cut -d' ' -f2)"
	
	# On va faire confiance à 'blkid' pour s'assurer du système de fichiers :
	FSMOUNT="$(blkid -s TYPE ${MOUNTPART} | cut -d'=' -f2 | crunch | tr -d \")"
	
	# On définit les options pour la racine système :
	if [ "${MOUNTDIR}" = "/" ]; then
		MOUNTOPTIONS="defaults"
		MAJORMINOR="1 1"
		
		# On monte la racine au passage :
		echo "Montage de la racine dans '${SETUPROOT}'... "
		mount -v ${MOUNTPART} ${SETUPROOT}
		sleep 1
		
		# On note la partition racine pour plus tard :
		echo ${MOUNTPART} > $TMP/partition_racine
		
	# On définit les options par défaut pour le reste :
	else
		MOUNTOPTIONS="defaults"
		MAJORMINOR="1 2"
		
		# On crée le point de montage :
		mkdir -p ${SETUPROOT}/${MOUNTDIR}
	fi
	
	# On ajoute la ligne résultante au fichier 'fstab' :
	echo "${MOUNTPART}	${MOUNTDIR}		${FSMOUNT}	${MOUNTOPTIONS}		${MAJORMINOR}" >> $TMP/fstab
	
	# On monte la partition :
	echo "Montage de ${SETUPROOT}/${MOUNTDIR}... "
	mount -v ${MOUNTPART} -t ${FSMOUNT} ${SETUPROOT}/${MOUNTDIR} 2>/dev/null
	sleep 1
	
done

# Pour chaque montage DOS/Windows :
if [ -r $TMP/choix_partitions_fat ]; then
	cat $TMP/choix_partitions_fat | while read LINEDOS; do
		
		# La partition :
		MOUNTPART="$(echo ${LINEDOS} | crunch | cut -d' ' -f1)"
		
		# Le point de montage
		MOUNTDIR="$(echo ${LINEDOS} | crunch | cut -d' ' -f2)"
		
		# On va faire confiance à 'blkid' pour s'assurer du système de fichiers :
		DOSFSMOUNT="$(blkid -s TYPE ${MOUNTPART} | cut -d'=' -f2 | crunch | tr -d \")"
		
		# On définit les options pour les FAT/NTFS :
		if [ "${DOSFSMOUNT}" = "ntfs" ]; then
			FSMOUNT="ntfs-3g"
			MOUNTOPTIONS="umask=000"
			MAJORMINOR="1 0"
		elif [ "${DOSFSMOUNT}" = "vfat" ]; then
			FSMOUNT="vfat"
			MOUNTOPTIONS="defaults"
			MAJORMINOR="1 0"
		fi
		
		# On ajoute la ligne résultante au fichier 'fstab' :
		echo "${MOUNTPART}	${MOUNTDIR}		${FSMOUNT}	${MOUNTOPTIONS}		${MAJORMINOR}" >> $TMP/fstab
		
		# On crée le point de montage :
		mkdir -p ${SETUPROOT}/${MOUNTDIR}
		
		# Il est inutile de monter ce type de partition ici.
		
	done
fi

# On va avoir besoin de /proc, /sys, /dev et /run plus tard pour le chroot :
if [ ! "${SETUPROOT}" = "/" ]; then
	mkdir -p ${SETUPROOT}/{dev,proc,run,sys}
	echo "Montage des systèmes de fichiers virtuels dans ${SETUPROOT}... "
	mount -v --bind /proc ${SETUPROOT}/proc
	mount -v --bind /sys  ${SETUPROOT}/sys
	mount -v --bind /dev  ${SETUPROOT}/dev
	mount -v --bind /run  ${SETUPROOT}/run
	sleep 1
fi

# On écrit notre 'fstab' temporaire depuis rien pour éviter de l'écrire plusieurs
# fois si 'montages.sh' est appelé plusieurs fois:
mkdir -p ${SETUPROOT}/etc
echo "" > ${SETUPROOT}/etc/fstab

# On ajoute la section pour la swap :
if [ ! -r $TMP/ignorer_swap ]; then
	if [ -r $TMP/choix_swap ]; then
		
		echo "# Partition d'échange « swap » :" >> ${SETUPROOT}/etc/fstab
		echo "$(cat $TMP/choix_swap)	swap		swap		defaults		0 0" >> ${SETUPROOT}/etc/fstab
		echo "" >> ${SETUPROOT}/etc/fstab
	fi
fi

# Puis les systèmes de fichiers spéciaux vitaux :
echo "# Système de fichiers spéciaux :" >> ${SETUPROOT}/etc/fstab
echo "devpts      /dev/pts    devpts      gid=5,mode=620         0 0" >> ${SETUPROOT}/etc/fstab
echo "tmpfs       /dev/shm    tmpfs       defaults               0 0" >> ${SETUPROOT}/etc/fstab
echo "proc        /proc       proc        nosuid,noexec,nodev    0 0" >> ${SETUPROOT}/etc/fstab
echo "tmpfs       /run        tmpfs       defaults               0 0" >> ${SETUPROOT}/etc/fstab
echo "sysfs       /sys        sysfs       nosuid,noexec,nodev    0 0" >> ${SETUPROOT}/etc/fstab

# Boucle d'affichage du menu du choix pour le montage de '/tmp' en tmpfs :
while [ 0 ]; do
	if [ "${INSTALLDEBUG}" = "" ]; then
		clear
	fi
	echo -e "\033[1;32mMonter '/tmp' en RAM ?\033[0;0m"
	echo ""
	echo "Si vous possédez suffisamment de mémoire vive (RAM), vous pouvez décider"
	echo "de monter le répertoire système '/tmp' en RAM dans un « tmpfs » afin"
	echo "d'accélérer le fonctionnement des applications. Évitez de monter '/tmp'"
	echo "en tmpfs si vous l'utlisez pour stocker des fichiers persistants car tous"
	echo "les tmpfs sont effacés à chaque démarrage."
	echo ""
	echo "- Entrez « oui » pour ajouter une entrée tmpfs '/tmp' à '/etc/fstab' (moitié de"
	echo "  la quantité de RAM par défaut) - OU"
	echo "- Entrez une valeur en méga-octets (M) ou giga-octets (G) pour décider"
	echo "  de la quantité de RAM allouée à '/tmp' - OU"
	echo "- Appuyez sur ENTRÉE pour ignorer cette étape."
	echo ""
	echo "Exemples : oui ; 1024M ; 4G ; etc."
	echo ""
	echo -n "Votre choix : "
	read TMPFSMOUNT;
	if [ "${TMPFSMOUNT}" = "" ]; then
		# On ne fait rien :
		break
	else
		if [ "${TMPFSMOUNT}" = "oui" ] || [ "${TMPFSMOUNT}" = "OUI" ]; then
			# On ajoute le tmpfs à '/etc/fstab' :
			echo "tmpfs       /tmp        tmpfs       defaults               0 0" >> ${SETUPROOT}/etc/fstab
			break
		else
			if [ "$(echo ${TMPFSMOUNT} | grep -E 'M$')" = "" ] && [ "$(echo ${TMPFSMOUNT} | grep -E 'G$')" = "" ]; then
				# On ne sait pas ce que l'utilisateur a entré, on ignore :
				break
			else
				# On ajoute le tmpfs à '/etc/fstab' avec la taille :
				echo "tmpfs       /tmp        tmpfs       size=${TMPFSMOUNT}             0 0" >> ${SETUPROOT}/etc/fstab
				break
			fi
		fi
	fi
done

# Puis on ajoute le reste des différentes partitions :
echo "" >> ${SETUPROOT}/etc/fstab
echo "# Partitions physiques :" >> ${SETUPROOT}/etc/fstab
cat $TMP/fstab >> ${SETUPROOT}/etc/fstab
echo "" >> ${SETUPROOT}/etc/fstab

# C'est fini !
