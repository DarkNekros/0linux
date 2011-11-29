#!/usr/bin/env bash

# On nettoie :
unset BLURB APPSDIR APPTAB INDICE APPSCODES BLAH

# Si l'on trouve le dépôt supplémentaire 'apps/' :
APPSDIR=$(find /var/log/mount -type d -name "apps")

if [ ! "${APPSDIR}" = "" ]; then
	clear
	echo -e "\033[1;32mDépôt de paquets 'apps/' détecté.\033[0;0m"
	echo ""
	echo "Le dépôt de paquets supplémentaires 'apps/' a été détecté ."
	echo ""
	echo "Une liste numérotée des dépôts va vous être présentée. Vous entrerez alors"
	echo "les codes correspondants aux dépôts que vous souhaitez installer, séparés"
	echo "par des espaces."
	echo ""
	echo "Exemple : si vous souhaitez installer les dépôts 'xfce/' et 'mozilla-firefox/',"
	echo "portant les numéros 10 et 26, vous entrerez alors : 10 26"
	echo ""
	echo "Appuyez sur ENTRÉE pour continuer."
	read BLURB;
	
	# On liste tous les dépôts dans l'ordre et on affecte une variable tableau au tout pour l'afficher:
	clear
	echo -e "\033[1;32mChoix des dépôts de paquets à installer.\033[0;0m"
	echo ""
	echo "Spécifiez les dépôts à installer ou appuyez sur ENTRÉE pour ignorer"
	echo "cette étape."
	echo ""
	
	INDICE=0
	for app in $(find ${APPSDIR} -mindepth 1 -type d | sort); do
		INDICE=$(( ${INDICE}+1 ))
		APPTAB[${INDICE}]="${app}"
		echo -n "${INDICE}:$(basename ${APPTAB[${INDICE}]}) "
	done
	
	echo ""
	echo ""
	echo -n "Votre choix (par exemple : 1 8 14 16 37) : "
	read APPSCODES;
	
	if [ ! "${APPSCODES}" = "" ]; then
		# On fait confiance à l'utilisateur et on installe chaque dépôt
		# correspondant aux codes entrés :
		clear
		echo -e "\033[1;32mInstallation des dépôts.\033[0;0m"
		echo ""
		echo "Les paquets supplémentaires vont maintenant être installés sur votre"
		echo "disque dur."
		echo ""
		echo "Appuyez sur ENTRÉE pour continuer ou tapez « non » pour ignorer"
		echo "cette étape."
		echo ""
		echo -n "Votre choix (ENTRÉE/non) : "
		read BLAH;
		
		if [ "${BLAH}" = "" ]; then
			# On installe chaque dépôt dépôt spécifié :
			for depot in ${APPSCODES}; do
				for paquet in $(find ${APPTAB[${depot}]} -type f -name "*.spack"); do
					spackadd --about ${paquet}
					spackadd --root=${SETUPROOT} ${paquet} &>/dev/null 2>&1
				done
			done
		else
			echo "Dépôt 'apps/' ignoré."
			sleep 2
		fi
	else
		echo "Dépôt 'apps/' ignoré."
		sleep 2
	fi
fi

# C'est fini !
