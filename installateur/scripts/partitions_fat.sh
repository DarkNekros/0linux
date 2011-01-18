#!/usr/bin/env bash

# On nettoie avant toute chose :
rm -f $TMP/choix_partitions_fat
unset FATADD FATADD1 FATADD2

# Cette fonction supprime les espaces superflus via 'echo' :
crunch() {
	read STRING;
	echo $STRING;
}

# Si une ou des partitions FAT/NTFS sont détectées :
if [ ! "$(fdisk -l | grep 'Win9' 'NTFS' 'W95 F' 'FAT' | grep -v tendue 2> /dev/null | wc -l)" -eq "0" ]; then
	# Boucle d'affichage du menu du choix de la partition à ajouter :
	while [ 0 ]; do
		clear
		echo -e "\033[1;32mAjouter une partition FAT/NTFS à monter.\033[0;0m"
		echo ""
		echo "Entrez la partition FAT/NTFS supplémentaire que vous souhaitez"
		echo "monter dans votre système, suivie du répertoire de votre"
		echo "choix (il sera créé automatiquement)."
		echo "Exemples : /dev/sda4 /mes_documents ; /dev/hda2 /sauvegarde ; etc."
		echo "Appuyez sur ENTRÉE pour ignorer cette étape ou quand vous avez terminé."
		echo ""
		echo "Voici les montages FAT/NTFS déjà configurés : "
		echo ""
		cat $TMP/choix_partitions_fat
		echo ""
		echo -n "Votre choix : "
		read FATADD;
		if [ "$FATADD" = "" ]; then
			break
		else
			# La partition :
			FATADD1="$(echo ${FATADD} | crunch | cut -d' ' -f1)"
			# Le point de montage :
			FATADD2="$(echo ${FATADD} | crunch | cut -d' ' -f2)"
			
			# Si l'utilisateur ne saisit pas un périph' de la forme « /dev/**** » 
			# et si le point de montage est incorrect :
			if [ "$(echo ${FATADD1} | sed -e 's/\(\/dev\/\).*$/\1/')" = "" -o \
				"$(echo ${FATADD2})" = "" -o ! "$(echo ${FATADD2} | cut -b1)" = "/" ]; then
				echo "Veuillez entrer une partition de la forme « /dev/xxxx », suivie"
				echo "d'un point de montage de la forme « /quelque_part »."
				sleep 2
				unset FATADD
				continue
			else
				
				# On ajoute la partition et le montage au fichier temporaire :
				echo "${FATADD1} ${FATADD2}" >> $TMP/choix_partitions_fat
				unset FATADD
			fi
		fi
	done
fi

# C'est fini !
