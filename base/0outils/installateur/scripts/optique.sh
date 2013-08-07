#!/usr/bin/env bash

# On nettoie :
rm -f $TMP/choix_media
unset BLAH ABANDON SPACKBASE

# Boucle d'affichage du menu :
while [ 0 ]; do
	if [ "${INSTALLDEBUG}" = "" ]; then
		clear
	fi
	echo -e "\033[1;32mRecherche d'un lecteur optique.\033[0;0m"
	echo ""
	echo "Recherche en cours d'un lecteur optique contenant un média d'installation..."
	echo ""
	
	# On recherche les lecteurs optique :
	for optique in /dev/sr{0,1,2,3}; do
		mount -o ro -t iso9660 ${optique} /mnt/cdrom 2>/dev/null
		
		# Périphérique trouvé :
		if [ $? = 0 ]; then
			if [ "${INSTALLDEBUG}" = "" ]; then
				clear
			fi
			echo -e "\033[1;32mDisque détecté.\033[0;0m"
			echo ""
			echo "Un disque a été trouvé dans ${optique}."
			echo ""
			
			# Si le volume contient un paquet 'base/base-systeme-$(uname -m)', alors
			# on considère qu'on tient là notre support d'installation :
			SPACKBASE=$(find /mnt/cdrom -type f -name "base-systeme-*-$(uname -m)-*.spack" 2>/dev/null)
			
			# Si l'on trouve plusieurs dépôts valides :
			if [ "$(echo ${SPACKBASE} | wc -l)" -gt 1 ]; then
				echo -e "\033[1;32mPlusieurs dépôts ont été trouvés sur ce disque !\033[0;0m"
				echo ""
				echo "Utilisez plutôt la rubrique RÉPERTOIRE déjà monté et indiquez le"
				echo "chemin du dépôt désiré. Le volume est déjà monté sous '/mnt/cdrom'. Vous"
				echo "indiquerez donc dans RÉPERTOIRE un chemin du type :"
				echo "	'/mnt/cdrom/mes_paquets/depot1'."
				echo ""
				echo "Appuyez sur ENTRÉE pour revenir au menu PAQUETS"
				read BLAH;
				
				# On place un marqueur d'échec pour redemander un média dans le menu PAQUETS :
				touch $TMP/depot_invalide
				break
			else
				
				# On vérifie que 'base-systeme' se trouve bien dans un dépôt 'base' :
				if [ "$(basename $(dirname ${SPACKBASE}))" = "base" ]; then
					echo "$(dirname (dirname ${SPACKBASE}))" > $TMP/choix_media
					echo "Un dépôt de paquets a été trouvé sur ce volume !"
					
					# On supprime tout marqueur d'échec éventuellement présent :
					rm -f $TMP/depot_invalide
					sleep 2
					break
				else
					echo "Le volume ne contient pas de dépôt de paquets valide :"
					echo " j'ai recherché 'base/base-systeme-*-$(uname -m)-*.spack',"
					echo "en vain. Démontage..."
					sleep 4
					umount /mnt/cdrom 2>/dev/null
					continue
				fi
		else
			echo "Aucun disque n'a été trouvé. Retour au menu... "
			ABANDON=1
			sleep 2
			break
		fi
	done
	
	if [ ${ABANDON} -eq 1 ]; then
		
		# On place un marqueur d'échec pour redemander un média dans le menu MÉDIA :
		touch $TMP/depot_invalide
		break
	fi
done

# C'est fini !
