#!/bin/env bash

# On tente de détecter une ou plusieurs partitions Linux, swap exceptée.
# On retire l'astérisque "*" des partitions amorçables pour avoir 6 champs partout :
listelinux() {
	LISTELINUX=$(fdisk -l 2> /dev/null | grep Linux 2> /dev/null | grep -v swap 2> /dev/null | tr -d "*" 2> /dev/null)
	echo "${LISTELINUX}"
}

# Cette fonction supprime les espaces superflus via 'echo' :
crunch() {
	read STRING;
	echo $STRING;
}

# taille_partition(périphérique) :
taille_partition() {
	Taille=$(fdisk -l | grep $1 | crunch | tr -d "*" | tr -d "+" | cut -f4 -d' ')
	echo "$Taille blocs"
}

# formater(type,périphérique,vérifier)
# Paramètres : type : système de fichiers (ext{2,3,4},reiserfs,jfs,xfs)
#              périphérique : nom du périphérique (/dev/*)
#              vérifier : vérifier le système de fichiers (oui,non)
formater() {
	
	TAILLEPART=$(taille_partition $1)
	
	# On s'assure de démonter le volume :
	if mount | grep "$2 " 1> /dev/null 2> /dev/null; then
		umount $2 2> /dev/null
	fi
	
	# Vérifier le système de fichiers créé ?
	if [ "$3" = "oui" ]; then
		VERIF="-c"
	else
		VERIF=" "
	fi
		
	# On formate avec les bonnes options :
	case "$1" in
		ext2)
			mkfs.ext2 $VERIF $2 /dev/null 2> /dev/null
		;;
		ext3)
			mkfs.ext3 $VERIF -j $2 /dev/null 2> /dev/null
		;;
		ext4)
			mkfs.ext4 -f $2 1> /dev/null 2> /dev/null
		;;
		reiserfs)
			echo "y" | mkreiserfs $2 1> /dev/null 2> /dev/null
		;;
		jfs)
			mkfs.jfs $VERIF -q $2 1> /dev/null 2> /dev/null
		;;
		xfs)
			mkfs.xfs -f $2 1> /dev/null 2> /dev/null
	esac

}

# Boucle d'affichage du menu du choix de racine :
while [ 0 ]; do
	clear
	echo -e "\033[1;32mPréparer la partition racine pour Linux.\033[0;0m"
	echo ""
	echo "Entrez la partition qui va servir de racine (« / ») pour"
	echo "accueillir votre installation de Linux :"
	echo ""
	# On liste les swaps et leur taille :
	for partitionlinux in listelinux ; do
		TAILLE=taille_partition ${partitionlinux}
		echo "${partitionlinux} : partition Linux de ${TAILLE}"
	done
	echo -n "Votre choix : "
	read ROOTSELECT;
	if [ "$ROOTSELECT" = "" ]; then
		echo "Veuillez entrer une partition de la forme « /dev/xxxx »."
		sleep 2
		continue;
	else
		# Si l'utilisateur ne saisit pas un périph' de la forme « /dev/**** » :
		if ! grep "/dev/" ${ROOTSELECT}; then
			echo "Veuillez entrer une partition de la forme « /dev/xxxx »."
			sleep 2
			continue;
		else
			echo "Le système sera installé sur ${ROOTSELECT}."
			sleep 2
			break
		fi
	fi
done
	
# Boucle d'affichage du formatage :
while [ 0 ]; do
	clear
	echo -e "\033[1;32mFormatage de la partition ${ROOTSELECT}.\033[0;0m"
	echo ""
	echo "Si cette partition n'a pas été formatée, vous devez le faire"
	echo "maintenant. N.B.: Ceci effacera toutes les données s'y trouvant !"
	echo "Entrez la méthode de formatage souhaitée parmi la liste suivante :"
	echo ""
	echo "formater : formater sans vérification des secteurs défectueux"
	echo "vérifier : formater avec vérification des secteurs défectueux"
	echo "non      : ne rien faire, la partition est déjà formatée"
	echo -n "Votre choix : "
	read DOFORMAT;
	if [ "$DOFORMAT" = "" ]; then
		echo "Veuillez entrer une méthode de formatage valide."
		sleep 2
		continue;
	else
		if [ "$DOFORMAT" = "non" ]; then
			break
		elif [ "$DOFORMAT" = "vérifier" ]; then
			VERIF="oui"
		elif [ "$DOFORMAT" = "formater" ]; then
			VERIF="non"
		else
			echo "Veuillez entrer une méthode de formatage valide."
			sleep 2
			continue;
		fi
		
		# Boucle d'affichage du choix du système de fichiers :
		while [ 0 ]; do
			clear
			echo -e "\033[1;32mChoix du système de fichiers pour ${ROOTSELECT}.\033[0;0m"
			echo ""
			echo "La partition ${ROOTSELECT} va être formatée."
			echo "Entrez le système de fichiers souhaité parmi la liste ci-dessous."
			echo ""
			echo "ext2     : système de fichiers traditionnel sous Linux"
			echo "ext3     : version journalisée et plus récente de Ext2"
			echo "ext4     : le récent successeur de Ext3"
			echo "jfs      : système de fichiers journalisé d'IBM"
			echo "reiserfs : système journalisé performant"
			echo "xfs      : système de SGI performant sur les gros fichiers"
			echo -n "Votre choix : "
			read FSFORMAT;
			if [ "$FSFORMAT" = "" ]; then
				echo "Veuillez entrer un système de fichiers valide."
				sleep 2
				continue;
			else
				# Si l'utilisateur écrit n'importe quoi :
				if [ ! grep -E 'ext2|ext3|ext4|jfs|reiserfs|xfs' ${FSFORMAT} ]; then
					echo "Veuillez entrer un système de fichiers valide."
					sleep 2
					continue;
				# Sinon, on formate :
				else
					echo "Formatage en cours de ${ROOTSELECT} en ${FSFORMAT}..."
					formater ${FSFORMAT} ${ROOTSELECT} ${VERIF}
					break
				fi
			fi
		done
	fi
done

# On synchronise avant toute chose :
sync

# On va faire confiance à 'blkid' pour s'assurer du système de fichiers créé et non à nos variables ;) :
FSRACINE=$(blkid -s TYPE ${ROOTSELECT} | cut -d'=' -f2 | tr -d \")

# On monte enfin le système de fichiers racine dans $SETUPROOT :
mount ${ROOTSELECT} ${SETUPROOT} -t ${FSRACINE} 1> /dev/null 2> /dev/null

# On ajoute le choix de la racine à ajouter à '/etc/fstab' :
echo "${ROOTSELECT}     /     ${FSRACINE}     defaults     1     1" > $TMP/choix_partitions

# Si plusieurs partitions Linux sont détectées :
if [ $(listelinux | wc -l) -gt "1" ]; then

	# Boucle d'affichage du choix pour des montages supplémentaires :
	while [ 0 ]; do
		clear
		echo -e "\033[1;32mPartitions Linux détectées.\033[0;0m"
		echo ""
		echo "D'autres partitions Linux sont présentes sur cette machine."
		echo "Voulez-vous configurer ces partitions pour pouvoir les monter"
		echo "automatiquementau démarrage ?"
		echo -n "Votre choix (oui/non): "
		read AJOUTLINUX;
		if [ "$AJOUTLINUX" = "non" ]; then
			break
		elif [ "$AJOUTLINUX" = "oui" ]; then
			
		else
			echo "Veuillez répondre par « oui » ou par « non » uniquement."
			sleep 2
			continue;
		fi
	done
		
		
		
		
		

	listelinux | while [ 0 ]; do
		read PARTITION;
		
		if [ "$PARTITION" = "" ]; then
			break;
		fi
		
		NOMPARTITION=$(echo $PARTITION | crunch | cut -d' ' -f1)
		TAILLEPARTITION=$(taille_partition $NOMPARTITION)
		DESCMONTAGE=""
		
		# On scanne le fichier temporaire pour savoir si la partition est déjà utilisée :
		if grep "${NOMPARTITION} " $TMP/choix_partitions 1> /dev/null; then
			# On extrait le point de montage choisi :
			POINTMONTAGE=`grep "$NOMPARTITION " $TMP/choix_partitions | crunch | cut -d' ' -f2`
			DESCMONTAGE="${NOMPARTITION} ${MOUNTEDON_MSG} ${POINTMONTAGE}, Linux, ${TAILLEPARTITION}"
		fi
		
		if [ "${POINTMONTAGE}" = "" ]; then
			echo "\"${NOMPARTITION}\" \"Linux, ${TAILLEPARTITION}\" \\"
		else
			echo "\"${CONFIGURED_MSG}\" \"${DESCMONTAGE}\" \\"
		fi
	done
	
	
	# Boucle d'affichage du menu d'ajout des partitions Linux :
	while [ 0 ]; do
		
		addanotherlinux
		
		# En cas de problème, on quitte :
		if [ ! $? = 0 ]; then
			rm -f $TMP/reponse
			break;
		fi
		
		PARTITION_SUIVANTE="`cat $TMP/reponse`"
		rm -f $TMP/reponse
		
		# Si l'on choisit une rubrique vide, on quitte :
		if [ "$NEXT_PARTITION" = "---" ]; then
			break;
		# Si l'on choisit une rubrique déjà configurée, on continue la boucle :
		elif [ "$NEXT_PARTITION" = "(${CONFIGURED_MSG})" ]; then
			continue;
		fi
		
		# On demande si l'on doit formater :
		formateroupas ${PARTITION_SUIVANTE}
		
		DO_FORMAT="`cat $TMP/reponse`"
		rm -f $TMP/reponse
		
		# Si l'utilisateur veut formater :
		if [ ! "${DO_FORMAT}" = "${LINUXDONTFORMAT_LABEL}" ]; then
			
			# On demande en quoi formater :
			quel_format ${PARTITION_SUIVANTE}
			
			FS_SUIVANT="`cat $TMP/reponse`"
			rm -f $TMP/reponse
			
			# Formatage avec ou sans vérification des secteurs :
			if [ "${DO_FORMAT}" = "${LINUXCHECKFORMAT_LABEL}" ]; then
				formater ${PARTITION_SUIVANTE} ${FS_SUIVANT} "oui"
			else
				formater ${PARTITION_SUIVANTE} ${FS_SUIVANT} "non"
			fi
		
		fi
		
		# On demande à l'utilisateur l'emplacement du point de montage :
		selectmountpoint 2> $TMP/reponse
		
		# En cas de problème, on continue la boucle :
		if [ ! $? = 0 ]; then
			continue;
		fi
		
		POINTMONTAGE="`cat $TMP/reponse`"
		rm -f $TMP/reponse
		
		# Si le point de montage est vide, on quitte :
		if [ "${POINTMONTAGE}" = "" ]; then
			continue;
		fi
		
		# Si le point de montage commence par un espace, on quitte :
		if [ "`echo ${POINTMONTAGE} | cut -b1`" = " " ]; then
			continue;
		fi
		
		# Si le point de montage ne commence pas par un slash, on est gentil et on corrige :
		if [ ! "`echo ${POINTMONTAGE} | cut -b1`" = "/" ]; then
			POINTMONTAGE="/${POINTMONTAGE}"
		fi
		
		# On synchronise avant toute chose :
		sync
		
		# On va faire confiance à 'blkid' pour s'assurer du système de fichiers créé et non à nos variables ;) :
		FSSUIVANT=$(blkid -s TYPE ${PARTITION_SUIVANTE} | cut -d'=' -f2 | tr -d \")
		
		# On crée le point de montage :
		mkdir -p ${SETUPROOT}/${POINTMONTAGE}
		 
		# On monte enfin le système de fichiers :
		mount ${PARTITION_SUIVANTE} ${SETUPROOT}/${POINTMONTAGE} -t ${FSSUIVANT} 1> /dev/null 2> /dev/null
		
		# On ajoute le choix de la partition à ajouter à '/etc/fstab' :
		echo "${PARTITION_SUIVANTE}     ${POINTMONTAGE}     ${FSSUIVANT}     defaults     1     2" >> $TMP/choix_partitions
		
	# Fin de la boucle :
	done

# Fin de l'ajout des partitions Linux supplémentaires :
fi

# Message de fin avec récapitulatif :
partitionscreated

# C'est fini !
