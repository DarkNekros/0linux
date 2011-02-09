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
	# Le point de montage
	MOUNTDIR="$(echo ${LINE} | crunch | cut -d' ' -f2)"
	
	# On va faire confiance à 'blkid' pour s'assurer du système de fichiers :
	FSMOUNT=$(blkid -s TYPE ${MOUNTPART} | cut -d'=' -f2 | tr -d \")
	
	# On définit les options pour la racine système :
	if [ "${MOUNTDIR}" = "/" ]; then
		MOUNTOPTIONS="defaults"
		MAJORMINOR="1 1"
		
		# On note la partition racine pour plus tard :
		echo ${MOUNTPART} > $TMP/partition_racine
		
		# On monte la racine au passage :
		echo "Montage de la racine... "
		mount ${MOUNTPART} ${SETUPROOT} 2>/dev/null
		
	# On définit les options par défaut pour le reste :
	else
		MOUNTOPTIONS="defaults"
		MAJORMINOR="1 2"
	fi
	
	# On ajoute la ligne résultante au fichier 'fstab' :
	echo "${MOUNTPART}	${MOUNTDIR}		${FSMOUNT}		${MOUNTOPTIONS}		${MAJORMINOR}" >> $TMP/fstab
	
	# On crée le point de montage :
	mkdir -p ${SETUPROOT}/${MOUNTDIR}
	
	# On monte la partition :
	echo "Montage de ${MOUNTDIR}... "
	mount ${MOUNTPART} -t ${FSMOUNT} ${SETUPROOT}/${MOUNTDIR} 2>/dev/null
	
done

# Pour chaque montage DOS/Windows :
cat $TMP/choix_partitions_fat | while read LINEDOS; do
	
	# La partition :
	MOUNTPART="$(echo ${LINEDOS} | crunch | cut -d' ' -f1)"
	# Le point de montage
	MOUNTDIR="$(echo ${LINEDOS} | crunch | cut -d' ' -f2)"
	
	# On va faire confiance à 'blkid' pour s'assurer du système de fichiers :
	FSMOUNT=$(blkid -s TYPE ${MOUNTPART} | cut -d'=' -f2 | tr -d \")
	
	# On définit les options pour les FAT/NTFS :
	if [ "${FSMOUNT}" = "ntfs" ]; then
		FSMOUNT="ntfs-3g"
		MOUNTOPTIONS="umask=000"
		MAJORMINOR="1 0"
	elif [ "${FSMOUNT}" = "vfat" ]; then
		FSMOUNT="vfat"
		MOUNTOPTIONS="defaults"
		MAJORMINOR="1 0"
	fi
	
	# On ajoute la ligne résultante au fichier 'fstab' :
	echo "${MOUNTPART}	${MOUNTDIR}		${FSMOUNT}		${MOUNTOPTIONS}		${MAJORMINOR}" >> $TMP/fstab
	
	# On crée le point de montage :
	mkdir -p ${SETUPROOT}/${MOUNTDIR}
	
	# Il est inutile de monter ce type de partition ici.
	
done

# On écrit le fichier '/etc/fstab'. D'abord la partition swap :
if [ ! -r $TMP/ignorer_swap ]; then
	if [ -r $TMP/choix_swap ]; then
		mkdir -p ${SETUPROOT}/etc
		touch ${SETUPROOT}/etc/fstab
		echo "# Partition d'échange « swap » :" >> ${SETUPROOT}/etc/fstab
		cat $TMP/choix_swap >> ${SETUPROOT}/etc/fstab
		echo "" >> ${SETUPROOT}/etc/fstab
	fi
fi

# Puis les systèmes de fichiers spéciaux vitaux :
echo "# Système de fichiers spéciaux :" >> ${SETUPROOT}/etc/fstab
echo "devpts		/dev/pts		devpts		gid=5,mode=620		0 0" >> ${SETUPROOT}/etc/fstab
echo "proc		/proc		proc		defaults		0 0" >> ${SETUPROOT}/etc/fstab
echo "tmpfs		/dev/shm		tmpfs		defaults		0 0" >> ${SETUPROOT}/etc/fstab
echo "" >> ${SETUPROOT}/etc/fstab

# Puis le reste de notre 'fstab' temporaire :
echo "# Partitions physiques :" >> ${SETUPROOT}/etc/fstab
cat $TMP/fstab >> ${SETUPROOT}/etc/fstab
echo "" >> ${SETUPROOT}/etc/fstab

# C'est fini !
