#!/usr/bin/env bash

# On nettoie avant toute chose :
unset LINUXADD LINUXADD1 LINUXADD2 BLAHFORMAT LINUXFORMAT

# Cette fonction supprime les espaces superflus via 'echo' :
crunch() {
	read STRING;
	echo $STRING;
}

# Si plusieurs partitions Linux sont détectées :
if [ "$(fdisk -l | grep Linux | grep -v swap 2> /dev/null | wc -l)" -gt "1" ]; then
	# Boucle d'affichage du menu du choix de la partition à ajouter :
	while [ 0 ]; do
		clear
		echo -e "\033[1;32mAjouter une partition Linux à monter.\033[0;0m"
		echo ""
		echo "Entrez la partition Linux supplémentaire que vous souhaitez"
		echo "monter dans votre système, suivie du répertoire de votre"
		echo "choix (il sera créé automatiquement)."
		echo "Exemples : /dev/sda3 /home ; /dev/hda1 /usr/local ; etc."
		echo "Appuyez sur ENTRÉE pour ignorer cette étape ou quand vous avez terminé."
		echo ""
		echo "Voici les montages Linux déjà configurés : "
		echo ""
		cat $TMP/choix_partitions
		echo ""
		echo -n "Votre choix : "
		read LINUXADD;
		if [ "$LINUXADD" = "" ]; then
			break
		else
			# La partition :
			LINUXADD1="$(echo ${LINUXADD} | crunch | cut -d' ' -f1)"
			# Le point de montage :
			LINUXADD2="$(echo ${LINUXADD} | crunch | cut -d' ' -f2)"
			
			# Si l'utilisateur ne saisit pas un périph' de la forme « /dev/**** » 
			# et si le point de montage est incorrect :
			if [ "$(echo ${LINUXADD1} | sed -e 's/\(\/dev\/\).*$/\1/')" = "" -o \
				"$(echo ${LINUXADD2})" = "" -o ! "$(echo ${LINUXADD2} | cut -b1)" = "/" ]; then
				echo "Veuillez entrer une partition de la forme « /dev/xxxx », suivie"
				echo "d'un point de montage de la forme « /quelque_part »."
				sleep 2
				unset LINUXADD
				continue
			else
				
				# Boucle d'affichage du formatage :
				while [ 0 ]; do
					clear
					echo -e "\033[1;32mFormat de la partition ${LINUXADD1}.\033[0;0m"
					echo ""
					echo "Entrez le système de fichiers souhaité parmi la liste ci-dessous"
					echo "pour formater la partition ${LINUXADD1} (à monter dans"
					echo "${LINUXADD2}), ou bien appuyez sur ENTRÉE pour ignorer le formatage."
					echo ""
					echo "1 : EXT2     - système de fichiers traditionnel sous Linux"
					echo "2 : EXT3     - version journalisée répandue de Ext2"
					echo "3 : EXT4     - récent successeur de Ext3"
					echo "4 : JFS      - système de fichiers journalisé d'IBM"
					echo "5 : REISERFS - système journalisé performant"
					echo "6 : XFS      - système de SGI performant sur les gros fichiers"
					echo ""
					echo -n "Votre choix : "
					read BLAHFORMAT;
					case "$BLAHFORMAT" in
					"1")
						LINUXFORMAT="mkfs.ext2 ${LINUXADD1} 2> /dev/null"
						break
					;;
					"2")
						LINUXFORMAT="mkfs.ext3 -j ${LINUXADD1} 2> /dev/null"
						break
					;;
					"3")
						LINUXFORMAT="mkfs.ext4 ${LINUXADD1} 2> /dev/null"
						break
					;;
					"4")
						LINUXFORMAT="mkfs.jfs -q ${LINUXADD1} 2> /dev/null"
						break
					;;
					"5")
						LINUXFORMAT="echo \"y\" | mkreiserfs ${LINUXADD1} 2> /dev/null"
						break
					;;
					"6")
						LINUXFORMAT="mkfs.xfs -f ${LINUXADD1} 2> /dev/null"
						break
					;;
					"")
						LINUXFORMAT=""
						break
					;;
					*)
						echo "Veuillez entrer un numéro valide (entre 1 et 6) ou appuyez"
						echo "sur ENTRÉE."
						sleep 2
						unset LINUXFORMAT BLAHFORMAT
						continue
					esac
					
					# On *ajoute* la commande de formatage prévue dans un fichier temporaire :
					if [ ! "${LINUXFORMAT}" = "" ]; then
						echo "${LINUXFORMAT}" >> $TMP/formatages
					fi
					unset LINUXFORMAT BLAHFORMAT
				done
			
			# On ajoute la partition et le montage au fichier temporaire :
			echo "${LINUXADD1} ${LINUXADD2}" >> $TMP/choix_partitions
			unset LINUXADD
			
			fi
		fi
	done
fi


# C'est fini !
