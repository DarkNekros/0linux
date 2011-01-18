#!/usr/bin/env bash

# On nettoie avant toute chose :
rm -f $TMP/choix_partitions $TMP/formatages
unset KHGFKJ ROOTSELECT BLAHFORMAT ROOTFORMAT

# Cette fonction supprime les espaces superflus via 'echo' :
crunch() {
	read STRING;
	echo $STRING;
}

# On détecte les partitions Linux, si aucune on prévient l'utilisateur :
if [ "$(fdisk -l | grep Linux | grep -v swap 2> /dev/null)" = "" ]; then
	clear
	echo -e "\033[1;32mAucune partition Linux n'a été détectée.\033[0;0m"
	echo ""
	echo "Il ne semble pas y avoir de partition de type Linux sur cette"
	echo "machine. Il vous faut créer au moins une partition de ce type pour"
	echo "installer Linux. Pour ce faire, utilisez 'cfdisk', 'fdisk' ou 'parted'."
	echo "Pour en savoir plus, lisez l'aide de l'installateur."
	echo ""
	echo -n "Appuyez sur ENTRÉE pour continuer."
	read KJGFKJ;
else
	# Boucle d'affichage du menu du choix de racine :
	while [ 0 ]; do
		clear
		echo -e "\033[1;32mPréparer la partition racine pour Linux.\033[0;0m"
		echo ""
		echo "Dans la console n°2, utilisez au choix les outils suivants pour"
		echo " déterminer vos partitions Linux existantes :"
		echo ""
		echo "		# cfdisk"
		echo "		# fdisk -l"
		echo ""
		echo "Entrez la partition qui va servir de racine (« / ») pour accueillir"
		echo "votre installation de Linux. Exemples : /dev/sda1 ; /dev/hda3 ; etc."
		echo ""
		echo -n "Votre choix : "
		read ROOTSELECT;
		if [ "$ROOTSELECT" = "" ]; then
			echo "Veuillez entrer une partition de la forme « /dev/xxxx »."
			sleep 2
			continue
		else
			# Si l'utilisateur ne saisit pas un périph' de la forme « /dev/**** » :
			if [ "$(echo ${ROOTSELECT} | sed -e 's/\(\/dev\/\).*$/\1/')" = "" ]; then
				echo "Veuillez entrer une partition de la forme « /dev/xxxx »."
				sleep 2
				continue
			else
				# On ajoute le choix de la racine à ajouter à '/etc/fstab' :
				echo "${ROOTSELECT} /" > $TMP/choix_partitions
				break
			fi
		fi
	done
		
	# Boucle d'affichage du formatage :
	while [ 0 ]; do
		clear
		echo -e "\033[1;32mFormat de la partition ${ROOTSELECT}.\033[0;0m"
		echo ""
		echo "Entrez le système de fichiers souhaité parmi la liste ci-dessous"
		echo "pour formater la partition ${ROOTSELECT} ou bien appuyez sur"
		echo "ENTRÉE pour ignorer le formatage."
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
			ROOTFORMAT="mkfs.ext2 ${ROOTSELECT} 2> /dev/null"
			break
		;;
		"2")
			ROOTFORMAT="mkfs.ext3 -j ${ROOTSELECT} 2> /dev/null"
			break
		;;
		"3")
			ROOTFORMAT="mkfs.ext4 ${ROOTSELECT} 2> /dev/null"
			break
		;;
		"4")
			ROOTFORMAT="mkfs.jfs -q ${ROOTSELECT} 2> /dev/null"
			break
		;;
		"5")
			ROOTFORMAT="echo \"y\" | mkreiserfs ${ROOTSELECT} 2> /dev/null"
			break
		;;
		"6")
			ROOTFORMAT="mkfs.xfs -f ${ROOTSELECT} 2> /dev/null"
			break
		;;
		"")
			ROOTFORMAT=""
			break
		;;
		*)
			echo "Veuillez entrer un numéro valide (entre 1 et 6) ou appuyez"
			echo "sur ENTRÉE."
			sleep 2
			unset ROOTFORMAT BLAHFORMAT
			continue
		esac
		
	done
	
	# On ajoute la commande de formatage prévue dans un fichier temporaire :
	if [ ! "${ROOTFORMAT}" = "" ]; then
		echo "${ROOTFORMAT}" > $TMP/formatages
	fi

fi

# C'est fini !
