#!/bin/env bash

# On nettoie avant toute chose :
rm -f $TMP/choix_partitions_fat
unset AJOUTFAT FATADD okparts MOUNTPOINT SECU SECUOK FSTYPE BLAH

# On tente de détecter une ou plusieurs partitions FAT/DOS/Windows, partition étendue exceptée.
# On retire l'astérisque "*" des partitions amorçables pour avoir 6 champs partout :
listefat() {
	LISTEFAT=$(fdisk -l 2> /dev/null | grep "Win9" "NTFS" "W95 F" "FAT" 2> /dev/null | grep -v tendue 2> /dev/null | tr -d "*" 2> /dev/null)
	echo "${LISTEFAT}"
}

# Cette fonction supprime les espaces superflus via 'echo' :
crunch() {
	read STRING;
	echo $STRING;
}

# taille_partition(périphérique) :
taille_partition() {
	Taille=$(fdisk -l | grep $1 | crunch | tr -d "*" | tr -d "+" | cut -f4 -d' ')
	TailleGo=$(echo "$Taille / 1000000" | bc)
	echo "$TailleGo Go"
}

# Afficher si les partitions FAT/NTFS sont configurées ou pas :
afficherfat() {
	listefat | while [ 0 ]; do
		read PARTITION;
		# Pas de partitions ? On quitte :
		if [ "$PARTITION" = "" ]; then
			break
		fi
		NOMPARTITION=$(echo $PARTITION | crunch | cut -d' ' -f1)
		DESCMONTAGE=""
		# On scanne le fichier temporaire pour savoir si la partition est déjà utilisée :
		if grep "${NOMPARTITION} " $TMP/choix_partitions_fat 1> /dev/null; then
			# On extrait le point de montage choisi :
			POINTMONTAGE=$(grep "$NOMPARTITION " $TMP/choix_partitions | crunch | cut -d' ' -f2)
		fi
		if [ "${POINTMONTAGE}" = "" ]; then
			echo "${NOMPARTITION}, partition FAT/NTFS de $(taille_partition ${NOMPARTITION})"
		else
			echo "${NOMPARTITION}, déjà montée sur ${POINTMONTAGE} ($(taille_partition ${NOMPARTITION}))"
		fi
	done
}

# Si des partitions FAT/NTFS sont détectées :
if [ $(listefat | wc -l) -gt 0 ]; then

	# Boucle d'affichage du choix des montages supplémentaires :
	while [ ! "${OKPARTS}" = "ok" ]; do
		clear
		echo -e "\033[1;32mPartitions FAT/NTFS détectées.\033[0;0m"
		echo ""
		echo "D'autres partitions FAT/NTFS (typiquement pour DOS/Windows) sont"
		echo "présentes sur cette machine."
		echo "Vous pouvez monter ces partitions dans un répertoire de votre choix,"
		echo "par exemple /windows, pour pouvoir y accéder depuis votre système Linux."
		echo "Voulez-vous configurer ces partitions pour y accéder automatiquement ?"
		echo ""
		echo -n "Votre choix (oui/non): "
		read AJOUFAT;
		if [ "$AJOUTFAT" = "non" ]; then
			break
		elif [ "$AJOUTFAT" = "oui" ]; then
			# Boucle d'affichage du menu du choix de la partition à ajouter :
			while [ 0 ]; do
				unset SECUOK
				clear
				echo -e "\033[1;32mAjouter une partition FAT/NTFS à monter.\033[0;0m"
				echo ""
				echo "Entrez la partition FAT/NTFS que vous souhaitez"
				echo "monter dans votre système parmi la liste ci-dessous ou entrez"
				echo "le mot-clé « continuer » pour terminer cette étape."
				echo ""
				# On liste les partitions FAT utilisées ou pas :
				afficherfat
				echo "continuer : terminer l'ajout de partitions FAT/NTFS"
				echo ""
				echo -n "Votre choix : "
				read FATADD;
				if [ "$FATADD" = "continuer" ]; then
					OKPARTS = "ok"
					break
				else
					# Si l'utilisateur ne saisit pas un périph' de la forme « /dev/**** » :
					if [ "$(echo ${FATADD} | sed -e 's/\(\/dev\/\).*$/\1/')" = "" ]; then
						echo "Veuillez entrer une partition de la forme « /dev/xxxx »."
						sleep 2
						unset FATADD
						continue
					else
						# Boucle d'affichage du menu du choix du point de montage :
						while [ ! "${SECUOK}" = "ok" ]; do
							clear
							echo -e "\033[1;32mChoix du point de montage pour ${FATADD}.\033[0;0m"
							echo ""
							echo "Bien, il vous faut maintenant indiquer l'emplacement"
							echo "de votre choix pour monter et accéder à cette partition. Par exemple,"
							echo "pour la monter dans le répertoire '/windows', répondez : /windows"
							echo "Dans quel répertoire désirez-vous monter ${FATADD} ?"
							echo ""
							echo -n "Votre choix : "
							read MOUNTPOINT;
							# Si le point de montage est incorrect :
							if [ "${MOUNTPOINT}" = "" -o "$(echo ${MOUNTPOINT} | cut -b1)" = " " -o ! "$(echo ${MOUNTPOINT} | cut -b1)" = "/"]; then
								echo "Veuillez entrer un système de fichiers de la forme « /quelquepart» ou"
								echo "« /quelque/part»."
								sleep 2
								unset MOUNTPOINT
								break
							fi
							# Si la partition choisie est une NTFS, on doit s'occuper du masque des permissions :
							if [ ! "$(listefat | grep -w ${FATADD} | grep NTFS 1> /dev/null 2> /dev/null)" = "" ]; then
								FSTYPE=ntfs
								# Boucle d'affichage du choix des permissions par défaut :
								while [ 0 ]; do
									clear
									echo -e "\033[1;32mPermission de la partitions NTFS ${FATADD}.\033[0;0m"
									echo ""
									echo "Puisque les utilisateurs peuvent accéder à cette partition NTFS, vous"
									echo "devez definir ses permissions en lecture et en écriture. Les niveaux"
									echo "de sécurité de ces permissions vont du tout-restrictif (aucun droit)"
									echo "au tout-permissif (accès en lecture/écriture/exécution pour tous)."
									echo "Une valeur raisonnable serait « 022 » mais beaucoup utilisent « 000 »."
									echo "Quel masque de permissions voulez-vous utiliser pour ${FATADD} ?"
									echo ""
									echo "077 : aucun accès, seul root a tous les droits"
									echo "222 : lecture seule pour tous"
									echo "022 : lecture seule pour tous mais root a tous les droits"
									echo "000 : tout le monde a tous les droits"
									echo ""
									echo -n "Votre choix : "
									read SECU;
									if [ "$(echo ${SECU} | grep -E '077|222|022|000')" = "" ]; then
										echo "Veuillez entrer un masque de permissions valide."
										sleep 2
										unset SECU
										continue
									else
										# Le pilote du noyau ne gère pas le masque :
										if [ "$SECU" = "222" ]; then
											FSTYPE="ntfs"
											SECU="defaults"
										# Seul le programme en espace utilisateur 'ntfs-3g' le gère :
										else
											FSTYPE="ntfs-3g"
										fi
										SECUOK="ok"
										break
									fi
								done
							# Sinon, la partition est une simple FAT :
							else
								FSTYPE="vfat"
								SECU="defaults"
								SECUOK="ok"
								break
							fi
						done
						# On crée le point de montage :
						mkdir -p ${SETUPROOT}/${MOUNTPOINT}
						
						# On ajoute le choix de la partition à ajouter à '/etc/fstab' :
						echo "${FATADD}     ${MOUNTPOINT}     ${FSTYPE}     ${SECU}     1     0" >> $TMP/choix_partitions_fat
					fi
				fi
			done
		else
			echo "Veuillez répondre par « oui » ou par « non » uniquement."
			sleep 2
			unset AJOUTFAT
			continue
		fi
	done
fi

# Message de fin avec récapitulatif :
clear
echo -e "\033[1;32mPartitions FAT/NTFS configurées.\033[0;0m"
echo ""
echo "Les informations suivantes seront ajoutées à votre"
echo "fichier '/etc/fstab'" :
echo ""
cat $TMP/choix_partitions_fat
echo ""
echo -n "Appuyez sur ENTRÉE pour continuer."
read BLAH;

# C'est fini !
