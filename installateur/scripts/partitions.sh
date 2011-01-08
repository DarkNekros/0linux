#!/bin/env bash

# On nettoie avant toute chose :
rm -f $TMP/choix_partitions
unset KHGFKJ ROOTSELECT DOFORMAT VERIF FSFORMAT AJOUTLINUX OKPARTS
unset MOUNTPOINT LINUXADD FORMATOK BLAH CONFIRM

# On tente de détecter une ou plusieurs partitions Linux, swap exceptée.
# On retire l'astérisque "*" des partitions amorçables pour avoir 6 champs partout :
listelinux() {
	LISTELINUX=$(fdisk -l | grep Linux 2> /dev/null | grep -v swap 2> /dev/null | tr -d "*" 2> /dev/null)
	echo "${LISTELINUX}"
}

# Cette fonction supprime les espaces superflus via 'echo' :
crunch() {
	read STRING;
	echo $STRING;
}

# taille_partition(périphérique) :
taille_partition() {
	Taille=$(fdisk -l | grep $1 | tr -d "*" | tr -d "+" | crunch | cut -f4 -d' ')
	TailleGo=$(echo "$Taille / 1000000" | bc)
	echo "$TailleGo Go"
}

# formater(type,périphérique,vérifier)
# Paramètres : type : système de fichiers (ext{2,3,4},reiserfs,jfs,xfs)
#              périphérique : nom du périphérique (/dev/*)
#              vérifier : vérifier le système de fichiers (oui,non)
formater() {
	
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
			mkfs.ext4 $VERIF $2 1> /dev/null 2> /dev/null
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

# Afficher si les partitions Linux sont configurées ou pas :
afficherlinux() {
	listelinux | crunch | while read PARTITION; do
		NOMPARTITION=$(echo $PARTITION | cut -d' ' -f1)
		# Si on trouve la partition dans le fichier temporaire :
		if grep "${NOMPARTITION} " $TMP/choix_partitions; then
			POINTMONTAGE=$(grep "$NOMPARTITION " $TMP/choix_partitions | crunch | cut -d' ' -f2)
			echo "${NOMPARTITION} ($(taille_partition ${NOMPARTITION})), configurée (${POINTMONTAGE})"
		else
			echo "${NOMPARTITION}, partition Linux de $(taille_partition ${NOMPARTITION})"
		fi
	done
}

# On détecte les partitions Linux, si aucune on prévient l'utilisateur :
if [ "$(listelinux 2> /dev/null)" = "" ]; then
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
	# On crée une liste des partitions Linux dans un fichier :
	listelinux 1> $TMP/liste_partitions 2> /dev/null
	
	# Boucle d'affichage du menu du choix de racine :
	while [ ! "$(cat $TMP/liste_partitions)" = "" ]; do
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
				echo "Le système sera installé sur ${ROOTSELECT}."
				sleep 2
				break
			fi
		fi
	done
		
	# Boucle d'affichage du formatage :
	while [ ! "${ROOTFORMATOK}" = "ok" ]; do
		clear
		echo -e "\033[1;32mFormatage de la partition ${ROOTSELECT}.\033[0;0m"
		echo ""
		echo "Si cette partition n'a pas été formatée, vous devez le faire"
		echo "maintenant. N.B.: Ceci effacera toutes les données s'y trouvant !"
		echo "La vérification des secteurs défectueux est généralement inutile,"
		echo "les disques durs intégrant déjà nativement ce type de vérification."
		echo "Entrez le code de la méthode de formatage souhaitée parmi la liste suivante :"
		echo ""
		echo "1 : FORMATER - formater sans vérification des secteurs défectueux"
		echo "2 : VÉRIFIER - formater avec vérification des secteurs défectueux"
		echo "3 : NON ! - ne rien faire, la partition est déjà formatée correctement"
		echo ""
		echo -n "Votre choix : "
		read DOFORMAT;
		if [ "$DOFORMAT" = "3" ]; then
			break
		elif [ "$DOFORMAT" = "2" ]; then
			VERIF="oui"
		elif [ "$DOFORMAT" = "1" ]; then
			VERIF="non"
		else
			echo "Veuillez entrer un numéro valide (entre 1 et 3)."
			sleep 2
			continue
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
			echo "ext3     : version journalisée répandue de Ext2"
			echo "ext4     : récent successeur de Ext3"
			echo "jfs      : système de fichiers journalisé d'IBM"
			echo "reiserfs : système journalisé performant"
			echo "xfs      : système de SGI performant sur les gros fichiers"
			echo ""
			echo -n "Votre choix : "
			read FSFORMAT;
			# Si l'utilisateur écrit n'importe quoi :
			if [ "$(echo ${FSFORMAT} | grep -E 'ext2|ext3|ext4|jfs|reiserfs|xfs')" = "" ]; then
				echo "Veuillez entrer un système de fichiers valide."
				sleep 2
				unset FSFORMAT
				continue
			# Sinon, on formate :
			else
				echo "La partition ${ROOTSELECT} s'apprête à être formatée en ${FSFORMAT}."
				echo "N.B.: Ceci effacera toutes les données s'y trouvant !"
				echo ""
				echo "Confirmez-vous ?" 
				echo ""
				echo -n "Votre choix (oui/non) : "
				read CONFIRM;
				# On a confirmation : 
				if [ "${CONFIRM}" = "oui" ]; then
					echo "Formatage en cours de ${ROOTSELECT} en ${FSFORMAT}..."
					formater ${FSFORMAT} ${ROOTSELECT} ${VERIF}
					ROOTFORMATOK="ok"
					break
				else
					break
				fi
			fi
		done
	done

	# On synchronise avant toute chose :
	sync

	# On va faire confiance à 'blkid' pour s'assurer du système de fichiers créé :
	FSRACINE=$(blkid -s TYPE ${ROOTSELECT} | cut -d'=' -f2 | tr -d \")

	# On monte enfin le système de fichiers racine dans $SETUPROOT :
	echo "Montage de ${ROOTSELECT} dans ${SETUPROOT}..."
	mount ${ROOTSELECT} ${SETUPROOT} -t ${FSRACINE} 1> /dev/null 2> /dev/null

	# On ajoute le choix de la racine à ajouter à '/etc/fstab' :
	echo "${ROOTSELECT}     /     ${FSRACINE}     defaults     1     1" > $TMP/choix_partitions

	# Si plusieurs partitions Linux sont détectées :
	if [ "$(listelinux | wc -l)" -gt "1" ]; then

		# Boucle d'affichage du choix pour des montages supplémentaires :
		while [ ! "${OKPARTS}" = "ok" ]; do
			clear
			echo -e "\033[1;32mPartitions Linux détectées.\033[0;0m"
			echo ""
			echo "D'autres partitions Linux sont présentes sur cette machine."
			echo "Vous pouvez utiliser ces partitions pour distribuer votre système"
			echo "Linux sur plusieurs partitions. Actuellement, votre racine (« / »)"
			echo "pour Linux est montée. Vous pouvez également monter des partitions"
			echo "sur des répertoires séparés tels que '/home', '/usr/local',"
			echo "'/sauvegarde' ou '/mes_documents'."
			echo ""
			echo "Voulez-vous configurer ces partitions pour y accéder automatiquement ?"
			echo ""
			echo -n "Votre choix (oui/non): "
			read AJOUTLINUX;
			if [ "$AJOUTLINUX" = "non" ]; then
				break
			elif [ "$AJOUTLINUX" = "oui" ]; then
				# Boucle d'affichage du menu du choix de la partition à ajouter :
				while [ 0 ]; do
					clear
					echo -e "\033[1;32mAjouter une partition Linux à monter.\033[0;0m"
					echo ""
					echo "Entrez la partition Linux supplémentaire que vous souhaitez"
					echo "monter dans votre système (exemples : /dev/sda1 ; /dev/hda3 ;"
					echo "etc) parmi la liste ci-dessous ou entrez le mot-clé « continuer »"
					echo "pour terminer maintenant cette étape."
					echo ""
					# On liste les partitions Linux utilisées ou pas :
					afficherlinux
					echo ""
					echo "continuer : terminer l'ajout de partitions Linux"
					echo ""
					echo -n "Votre choix : "
					read LINUXADD;
					if [ "$LINUXADD" = "continuer" ]; then
						OKPARTS = "ok"
						break
					else
						# Si l'utilisateur ne saisit pas un périph' de la forme « /dev/**** » :
						if [ "$(echo ${LINUXADD} | sed -e 's/\(\/dev\/\).*$/\1/')" = "" ]; then
							echo "Veuillez entrer une partition de la forme « /dev/xxxx »."
							sleep 2
							unset LINUXADD
							continue
						else
							# Boucle d'affichage du menu du choix du point de montage :
							while [ ! "${FORMATOK}" = "ok" ]; do
								clear
								echo -e "\033[1;32mChoix du point de montage pour ${LINUXADD}.\033[0;0m"
								echo ""
								echo "Bien, il vous faut maintenant indiquer l'emplacement"
								echo "de votre choix pour monter et accéder à cette partition."
								echo "Exemples : /home ; /usr/local ; /sauvegarde ; /mes_documents"
								echo "Dans quel répertoire désirez-vous monter ${LINUXADD} ?"
								echo ""
								echo -n "Votre choix : "
								read MOUNTPOINT;
								# Si le point de montage est incorrect :
								if [ "${MOUNTPOINT}" = "" -o "$(echo ${MOUNTPOINT} | cut -b1)" = " " -o ! "$(echo ${MOUNTPOINT} | cut -b1)" = "/"]; then
									echo "Veuillez entrer un point de montage de la forme « /quelquepart» ou"
									echo "« /quelque/part»."
									sleep 2
									unset MOUNTPOINT
									break
								fi
								# Boucle d'affichage du formatage :
								while [ 0 ]; do
									clear
									echo -e "\033[1;32mFormatage de la partition ${LINUXADD}.\033[0;0m"
									echo ""
									echo "Voulez-vous formater cette partition ?"
									echo "N.B.: Ceci effacera toutes les données s'y trouvant !"
									echo "Entrez le code de la méthode de formatage souhaitée parmi la liste suivante :"
									echo ""
									echo "1 : FORMATER - formater sans vérification des secteurs défectueux"
									echo "2 : VÉRIFIER - formater avec vérification des secteurs défectueux"
									echo "3 : NON ! - ne rien faire, la partition est déjà formatée correctement"
									echo ""
									echo -n "Votre choix : "
									read DOFORMAT;
									if [ "$DOFORMAT" = "3" ]; then
										FORMATOK="ok"
										break
									elif [ "$DOFORMAT" = "2" ]; then
										VERIF="oui"
									elif [ "$DOFORMAT" = "1" ]; then
										VERIF="non"
									else
										echo "Veuillez entrer un numéro valide (entre 1 et 3)."
										sleep 2
										unset DOFORMAT
										continue
									fi
									# Boucle d'affichage du choix du système de fichiers :
									while [ 0 ]; do
										clear
										echo -e "\033[1;32mChoix du système de fichiers pour ${LINUXADD}.\033[0;0m"
										echo ""
										echo "La partition ${LINUXADD} va être formatée."
										echo "Entrez le système de fichiers souhaité parmi la liste ci-dessous."
										echo ""
										echo "ext2     : système de fichiers traditionnel sous Linux"
										echo "ext3     : version journalisée répandue de Ext2"
										echo "ext4     : récent successeur de Ext3"
										echo "jfs      : système de fichiers journalisé d'IBM"
										echo "reiserfs : système journalisé performant"
										echo "xfs      : système de SGI performant sur les gros fichiers"
										echo ""
										echo -n "Votre choix : "
										read FSFORMAT;
										# Si l'utilisateur écrit n'importe quoi :
										if [ "$(echo ${FSFORMAT} | grep -E 'ext2|ext3|ext4|jfs|reiserfs|xfs')" = "" ]; then
											echo "Veuillez entrer un système de fichiers valide."
											sleep 2
											unset FSFORMAT
											continue
										# Sinon, on formate :
										else
											echo "Formatage en cours de ${LINUXADD} en ${FSFORMAT}..."
											formater ${FSFORMAT} ${ROOTSELECT} ${VERIF}
											FORMATOK="ok"
											break
										fi
									done
								done
							done
							# On synchronise avant toute chose :
							sync
							
							# On va faire confiance à 'blkid' pour s'assurer du système de fichiers créé :
							FSLINUXADD=$(blkid -s TYPE ${LINUXADD} | cut -d'=' -f2 | tr -d \")
							
							# On crée le point de montage :
							mkdir -p ${SETUPROOT}/${MOUNTPOINT}
							
							# On monte enfin le système de fichiers :
							echo "Montage de ${LINUXADD} dans ${SETUPROOT}/${MOUNTPOINT}..."
							mount ${LINUXADD} ${SETUPROOT}/${MOUNTPOINT} -t ${FSLINUXADD} 1> /dev/null 2> /dev/null
							
							# On ajoute le choix de la partition à ajouter à '/etc/fstab' :
							echo "${LINUXADD}     ${MOUNTPOINT}     ${FSLINUXADD}     defaults     1     2" >> $TMP/choix_partitions
						fi
					fi
				done
			fi
		done
	fi

	# Message de fin avec récapitulatif :
	clear
	echo -e "\033[1;32mPartitions Linux configurées.\033[0;0m"
	echo ""
	echo "Les informations suivantes seront ajoutées à votre"
	echo "fichier '/etc/fstab'" :
	echo ""
	cat $TMP/choix_partitions
	echo ""
	echo -n "Appuyez sur ENTRÉE pour continuer."
	read BLAH;
fi

# C'est fini !
