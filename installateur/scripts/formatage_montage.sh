#!/usr/bin/env bash

# On nettoie avant toute chose :
rm -f $TMP/fstab
unset FORMATALL MOUNTPART MOUNTDIR FSMOUNT ROOTPART MOUNTOTIONS MAJORMINOR

# Cette fonction supprime les espaces superflus via 'echo' :
crunch() {
	read STRING;
	echo $STRING;
}

# Boucle d'affichage pour les formatages et montages des partitions choisies : :
while [ 0 ]; do
	clear
	echo -e "\033[1;32mConfirmation des formatages des partitions.\033[0;0m"
	echo ""
	echo "L'installateur s'apprête à exécuter les commandes de formatage suivantes."
	echo "N.B.: toutes les données se trouvant sur ces partitions seront perdues !"
	echo ""
	cat $TMP/formatages
	echo ""
	echo "Pour confirmer les formatages, tapez « oui »."
	echo "Pour annuler et revenir au menu principal, appuyez sur ENTRÉE."
	echo ""
	echo -n "Votre choix : "
	read FORMATALL;
	if [ "$FORMATALL" = "" ]; then
		break
	elif [ "$FORMATALL" = "oui" ]; then
		# On a confirmation du formatage :
		sync
		chmod +x $TMP/formatages
		echo -n "Formatages en cours... "
		# On lance tous les formatages présents dans le fichier temporaire :
		sh $TMP/formatages
		echo "Terminés."
		
		# Création du fichier 'fstab' :
		
		# Pour chaque montage :
		cat $TMP/choix_partitions $TMP/choix_partitions_fat | crunch | while read LINE; do
			
			# La partition :
			MOUNTPART="$(echo ${LINE} | cut -d' ' -f1)"
			# Le point de montage
			MOUNTDIR="$(echo ${LINE} | cut -d' ' -f2)"
			
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
			# On définit les options pour la racine système :
			elif [ "${MOUNTDIR}" = "/" ]; then
				# On monte la racine au passage :
				echo "Montage de la racine... "
				mount ${ROOTPART} ${SETUPROOT} 2>/dev/null
				MOUNTOPTIONS="defaults"
				MAJORMINOR="1 1"
			# On définit les options par défaut :
			else
				MOUNTOPTIONS="defaults"
				MAJORMINOR="1 2"
			fi
			
			# On crée 'fstab' s'il est absent :
			elif [ ! -r $TMP/fstab ]; then
				touch $TMP/fstab
			fi
			
			# On ajoute la ligne résultante au fichier 'fstab' :
			echo "${MOUNTPART} ${MOUNTDIR} ${FSMOUNT} ${MOUNTOPTIONS} ${MAJORMINOR}" >> $TMP/fstab
			
			# On crée le point de montage :
			mkdir -p ${SETUPROOT}/${MOUNTDIR}
			
			# On monte la partition :
			echo "Montage de ${MOUNTDIR}... "
			mount ${MOUNTPART} -t ${FSMOUNT} ${SETUPROOT}/${MOUNTDIR} 2>/dev/null
			
		done
		
		# On écrit le fichier '/etc/fstab'. D'abord la partition swap :
		if [ -r $TMP/choix_swap ]; then
			echo "# Partition d'échange «swap » :" >> ${SETUPROOT}/etc/fstab
			cat $TMP/choix_swap >> ${SETUPROOT}/etc/fstab
			echo "" >> ${SETUPROOT}/etc/fstab
		fi
		
		# Puis les systèmes de fichiers spéciaux vitaux :
		echo "# Système de fichiers spéciaux :" >> ${SETUPROOT}/etc/fstab
		echo "devpts		/dev/pts		devpts		gid=5,mode=620		0	0" >> ${SETUPROOT}/etc/fstab
		echo "proc		/proc		proc		defaults		0	0" >> ${SETUPROOT}/etc/fstab
		echo "tmpfs		/dev/shm		tmpfs		defaults		0	0" >> ${SETUPROOT}/etc/fstab
		echo "/dev/shm		/tmp		tmpfs		defaults		0	0" >> ${SETUPROOT}/etc/fstab
		echo "" >> ${SETUPROOT}/etc/fstab
		
		# Puis le reste de notre 'fstab' temporaire :
		echo "# Partitions physiques :" >> ${SETUPROOT}/etc/fstab
		cat $TMP/fstab >> ${SETUPROOT}/etc/fstab
		echo "" >> ${SETUPROOT}/etc/fstab
		
		break
		
	else
		echo "Veuillez entrer « oui » ou appuyer sur ENTRÉE uniquement."
		sleep 2
		unset FORMATALL
		continue
	fi
done
