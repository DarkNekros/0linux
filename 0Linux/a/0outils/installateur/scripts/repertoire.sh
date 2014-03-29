#!/usr/bin/env bash

# On nettoie :
rm -f $TMP/choix_media
unset BLAH DIRSELECT SPACKBASE

while [ 0 ]; do
	if [ "${INSTALLDEBUG}" = "" ]; then
		clear
	fi
	echo -e "\033[1;32mSaisie de l'emplacement contenant les paquets.\033[0;0m"
	echo ""
	echo "Veuillez entrer ci-dessous le chemin du répertoire (préalablement monté)"
	echo "contenant '${VERSION}', lequel doit contenir un dépôt de paquets, "
	echo "ou appuyez sur ENTRÉE pour annuler."
	echo ""
	echo "Exemples : /mnt/tmp/mes_fichiers/paquets"
	echo "           /sauvegarde/0/paquets"
	echo "           /mes_paquets/0linux"
	echo ""
	echo -n "Votre choix : "
	read DIRSELECT;
	if [ "${DIRSELECT}" = "" ]; then
		
		# On place un marqueur d'échec pour redemander un média dans le menu PAQUETS :
		touch $TMP/depot_invalide
		break
	elif [ ! -d ${DIRSELECT} ]; then
		echo "Ce répertoire est introuvable. Veuillez entrer un emplacement valide."
		sleep 2
		unset DIRSELECT
		continue
	else
		
		# On recherche le dépôt :
		SPACKBASE=$(find ${DIRSELECT} -type d -name "${VERSION}" 2>/dev/null)
		
		# Si l'on trouve plusieurs dépôts valides :
		if [ "$(echo ${SPACKBASE} | wc -l)" -gt 1 ]; then
			echo -e "\033[1;32mPlusieurs dépôts ont été trouvés dans ce répertoire !\033[0;0m"
			echo ""
			echo "Plusieurs dépôts 'base' contenant un paquet nommé"
			echo "'base-systeme-*-$(uname-m)-*.spack' ont été trouvés dans"
			echo "ce répertoire. Soyez plus précis quant au dépôt que vous désirez"
			echo "utiliser !"
			echo ""
			echo "Appuyez sur ENTRÉE pour spécifier un autre répertoire."
			read BLAH;
			continue
		else
			
			# On vérifie que 'paquets.db' se trouve bien dans le dépôt :
			if [ -r ${SPACKBASE}/$(uname -m)/paquets.db ]; then
				echo "$(dirname ${SPACKBASE})" > $TMP/choix_media
				echo "Un dépôt de paquets a été trouvé dans ce répertoire !"
				
				# On supprime tout marqueur d'échec éventuellement présent :
				rm -f $TMP/depot_invalide
				sleep 2
				break
			else
				echo "Ce périphérique ne contient pas de dépôt de paquets : j'ai recherché"
				echo "la base de données des paquets de 0Linux :"
				echo "'${SPACKBASE})/$(uname -m)/paquets.db', en vain."
				echo "Appuyez sur ENTRÉE pour spécifier un autre répertoire."
				read BLAH;
				unset DIRSELECT
				continue
			fi
		fi
	fi
done

# C'est fini !
