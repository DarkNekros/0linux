#!/bin/env bash
# On liste les partitions Linux, swap exceptée :
listelinux  > $TMP/liste_partitions_linux

# Boucle d'affichage du menu :
selectrootdev
 
# En cas de problème, on quitte :
if [ ! $? = 0 ]; then
	rm -f $TMP/reponse
	exit
fi

PARTITIONRACINE="`cat $TMP/reponse`"
rm -f $TMP/reponse

# Si l'utilisateur choisit une rubrique vide, on quitte :
if [ "$PARTITIONRACINE" = "---" ]; then
	exit
fi

# On demande si l'on doit formater :
formateroupas ${PARTITIONRACINE}

DO_FORMAT="`cat $TMP/reponse`"
rm -f $TMP/reponse

# Si l'utilisateur veut formater :
if [ ! "${DO_FORMAT}" = "Non !" ]; then
	
	# On demande en quoi formater :
	quel_format ${PARTITIONRACINE}
	
	FS_RACINE="`cat $TMP/reponse`"
	rm -f $TMP/reponse
	
	# Formatage avec ou sans vérification des secteurs :
	if [ "${DO_FORMAT}" = "${LINUXCHECKFORMAT_LABEL}" ]; then
		formater ${FS_RACINE} ${PARTITIONRACINE} "oui"
	else
		formater ${FS_RACINE} ${PARTITIONRACINE} "non"
	fi

fi

# On synchronise avant toute chose :
sync

# On va faire confiance à 'blkid' pour s'assurer du système de fichiers créé et non à nos variables ;) :
FSRACINE=$(blkid -s TYPE ${PARTITIONRACINE} | cut -d'=' -f2 | tr -d \")

# On monte enfin le système de fichiers racine :
mount ${PARTITIONRACINE} ${SETUPROOT} -t ${FSRACINE} 1> /dev/null 2> /dev/null

# On ajoute le choix de la racine à ajouter à '/etc/fstab' :
echo "${PARTITIONRACINE}     /     ${FSRACINE}     defaults     1     1" > $TMP/choix_partitions

# Si plusieurs partitions Linux sont détectées :
if [ "`cat $TMP/liste_partitions_linux | grep -v swap | wc -l`" -gt "1" ]; then

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
