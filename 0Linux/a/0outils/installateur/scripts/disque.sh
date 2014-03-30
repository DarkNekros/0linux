#!/usr/bin/env bash

# On nettoie :
rm -f $TMP/choix_media
unset MEDIASELECT SPACKBASE

# Boucle d'affichage du menu :
while [ 0 ]; do
	if [ "${INSTALLDEBUG}" = "" ]; then
		clear
	fi
	echo -e "\033[1;32mSaisie du périphérique.\033[0;0m"
	echo ""
	echo "Dans la console n°2, utilisez au choix les outils suivants pour"
	echo "déterminer le périphérique contenant les paquets à installer :"
	echo ""
	echo "		# cfdisk"
	echo "		# fdisk -l"
	echo ""
	echo "Puis, entrez ci-dessous le périphérique concerné."
	echo "Exemples : /dev/sdc4 ; /dev/sdd1 ; /dev/hdb2 ; etc."
	echo "Ou appuyez simplement sur ENTRÉE pour annuler."
	echo ""
	echo -n "Votre choix : "
	read MEDIASELECT;
	
	# Si l'utilisateur ne saisit pas un périph' de la forme « /dev/**** » :
	if [ "$(echo ${MEDIASELECT} | sed -e 's/\(\/dev\/\).*$/\1/')" = "" ]; then
		echo "Veuillez entrer un périphérique de la forme « /dev/xxxx »."
		sleep 2
		unset MEDIASELECT
		continue
	elif [ "${MEDIASELECT}" = "" ]; then
		
		# On place un marqueur d'échec pour redemander un média dans le menu MÉDIA :
		touch $TMP/depot_invalide
		break
	else
		
		# On monte le périphérique doucement :
		echo "Montage en cours du périphérique ${MEDIASELECT} dans '/mnt/hd'..."
		mount ${MEDIASELECT} /mnt/hd 2>/dev/null
		sleep 3
		
		# Périphérique monté :
		if [ $? = 0 ]; then
			
			# On recherche le dépôt :
			SPACKBASE=$(find /mnt/hd -type d -name "${VERSION}" 2>/dev/null)
			
			# Si l'on trouve plusieurs dépôts valides :
			if [ "$(echo ${SPACKBASE} | wc -l)" -gt 1 ]; then
				echo "Plusieurs dépôts ont été trouvés sur ce volume !"
				echo ""
				echo "Utilisez plutôt la rubrique RÉPERTOIRE déjà monté et indiquez le"
				echo "chemin du dépôt désiré. Le volume est déjà monté sous '/mnt/hd'. Vous"
				echo "indiquerez donc dans RÉPERTOIRE un chemin du type :"
				echo "	'/mnt/hd/mes_paquets/depot1'."
				echo ""
				echo "Appuyez sur ENTRÉE pour revenir au menu PAQUETS"
				read BLAH;
				
				# On place un marqueur d'échec pour redemander un média dans le menu PAQUETS :
				touch $TMP/depot_invalide
				break
			else
				
				# On vérifie que 'paquets.db' se trouve bien dans le dépôt :
				if [ -r ${SPACKBASE}/$(uname -m)/paquets.db ]; then
					echo "$(dirname ${SPACKBASE})" > $TMP/choix_media
					echo "Un dépôt de paquets a été trouvé sur ce volume !"
					
					# On supprime tout marqueur d'échec éventuellement présent :
					rm -f $TMP/depot_invalide
					sleep 2
					break
				else
					echo "Ce périphérique ne contient pas de dépôt de paquets : j'ai recherché"
					echo "la base de données des paquets de 0Linux :"
					echo "'${SPACKBASE})/$(uname -m)/paquets.db', en vain."
					echo "Démontage..."
					sleep 4
					umount /mnt/hd 2>/dev/null
					continue
				fi
			fi
		
		# Échec du montage :
		else
			echo "Le périphérique n'a pas pu être monté. Vous pouvez aussi monter manuellement"
			echo "le volume et choisir plutôt la rubrique RÉPERTOIRE déjà monté."
			sleep 4
			continue
		fi
	fi
done

# C'est fini !
