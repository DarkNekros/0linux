#!/bin/env bash
# On tente de détecter une ou plusieurs partitions FAT/DOS/Windows, partition étendue exceptée.
# On retire l'astérisque "*" des partitions amorçables pour avoir 6 champs partout :
LISTEFAT=`fdisk -l 2> /dev/null | grep "Win9" "NTFS" "W95 F" "FAT" 2> /dev/null | grep -v tendue 2> /dev/null | tr -d "*" 2> /dev/null`

# Si aucune partition DOS n'est trouvée, on peut quitter :
if [ "$LISTEFAT" = "" ]; then
	exit
fi

# On demande si l'on va ajouter des partitions FAT/NTFS :
addfat

# Si l'utilisateur refuse d'en monter :
if [ ! $? = 0 ]; then
	exit
fi

# Boucle d'affichage pour les partitions FAT :
while [ 0 ]; do
	
	selectfat
	
	# En cas de problème, on quitte :
	if [ ! $? = 0 ]; then
		rm -f $TMP/reponse
		exit
	fi
	
	PARTITIONFAT="`cat $TMP/reponse`"
	rm -f $TMP/reponse
	
	# Si l'on choisit une rubrique vide, on quitte :
	if [ "$PARTITIONFAT" = "---" ]; then
		break;
	# Si l'on choisit une rubrique déjà configurée, on continue la boucle :
	elif [ "$PARTITIONFAT" = "(${CONFIGURED_MSG})" ]; then
		continue;
	fi
	
	# Si la partition choisie est en NTFS, on doit s'occuper du masque des permissions :
	if echo "$LISTEFAT" | grep -w ${PARTITIONFAT} | grep NTFS 1> /dev/null 2> /dev/null; then
	
		ntfssecu 2> $TMP/ntfs_umask
		
		# En cas de problème, on quitte :
		if [ ! $? = 0 ]; then
			rm -f $TMP/{ntfs_umask,choix_partitions_fat}
			echo 1
		fi
		
		FS_UMASK="$(cat $TMP/ntfs_umask)"
		rm -f $TMP/ntfs_umask
		
		if [ "$FS_UMASK" = "1" ]; then
			exit 1
		else
			# Le pilote du noyau ne gère pas le masque :
			if [ "$FS_UMASK" = "umask=222" ]; then
				FS_TYPE="ntfs"
				FS_UMASK="defaults"
			# Seul le programme en espace utilisateur 'ntfs-3g' le gère :
			else
				FS_TYPE="ntfs-3g"
			fi
		fi
	
	# Si le système de fichiers est du simple FAT :
	else
		FS_TYPE=vfat
		FS_UMASK=defaults
	fi
	
	selectfatmountpoint 2> $TMP/reponse
	
	if [ ! $? = 0 ]; then
		rm -f $TMP/{ntfs_umask,reponse}
		exit
	fi
	
	POINTMONTAGEFAT="`cat $TMP/reponse`"
	rm -f $TMP/reponse
	
	# Si le point de montage est vide ou est un simple slash, on quitte :
	if [ "${POINTMONTAGEFAT}" = "" -o "${POINTMONTAGEFAT}" = "/" ]; then
		continue;
	fi
	
	# Si le point de montage commence par un espace, on quitte :
	if [ "`echo ${POINTMONTAGEFAT} | cut -b1`" = " " ]; then
		continue;
	fi
	
	# Si le point de montage ne commence pas par un slash, on est gentil et on corrige :
	if [ ! "`echo ${POINTMONTAGEFAT} | cut -b1`" = "/" ]; then
		POINTMONTAGEFAT="/${POINTMONTAGEFAT}"1
	fi
	
	# On crée le point de montage :
	mkdir -p ${SETUPROOT}/${POINTMONTAGEFAT}
	
	# On ajoute le choix de la partition à ajouter à '/etc/fstab' :
	echo "${PARTITIONFAT}     ${POINTMONTAGEFAT}     ${FS_TYPE}     ${FS_UMASK}     1     0" >> $TMP/choix_partitions_fat
	
done

# Message récapitulatif :
fatpartitionscreated

# C'est fini !
