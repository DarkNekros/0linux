#!/usr/bin/env bash

# On nettoie avant toute chose :
rm -f $TMP/choix_swap $TMP/ignorer_swap
unset NOSWAP JHVF SWAPSELECT ABANDONSWAP FORMATSWAP

# On tente de détecter une ou plusieurs partitions swap existantes :
listeswap() {
	LISTESWAP=$(fdisk -l 2>/dev/null | grep swap 2>/dev/null)
	echo "${LISTESWAP}"
}

# Cette fonction supprime les espaces superflus via 'echo' :
crunch() {
	read STRING;
	echo $STRING;
}

# Si aucune swap n'est détectée :
while [ listeswap = "" ]; do
	if [ "${INSTALLDEBUG}" = "" ]; then
		clear
	fi
	echo -e "\033[1;32mAucune partition d'échange « swap » n'a été trouvée.\033[0;0m"
	echo ""
	echo "Aucune partition d'échange « swap » n'a été trouvée sur cette machine."
	echo "Voulez-vous continuer l'installation sans partition d'échange ?"
	echo ""
	echo -n "Votre choix (oui/non) : "
	read NOSWAP;
	# Si l'utilisateur ne veut pas continuer :
	if [ "$NOSWAP" = "non" ]; then
		echo "Abandon. Créez une partition d'échange « swap » avec 'cfdisk',"
		echo "'fdisk' ou 'parted' puis recommencez cette étape."
		echo -n "Appuyez sur ENTRÉE pour continuer."
		touch $TMP/ignorer_swap
		read JHVF;
		break
	# Si l'utilisateur ne veut pas de swap :
	elif [ "$NOSWAP" = "oui" ]; then
		touch $TMP/ignorer_swap
		break
	else
		echo "Veuillez répondre par « oui » ou par « non » uniquement."
		sleep 2
		continue
	fi
done

# Si l'on trouve une swap :
while [ 0 ]; do
	if [ -r $TMP/ignorer_swap ]; then
		break
	fi
	if [ "${INSTALLDEBUG}" = "" ]; then
		clear
	fi
	echo -e "\033[1;32mUne partition d'échange a été détectée.\033[0;0m"
	echo ""
	echo "Dans la console n°2, utilisez au choix les outils suivants pour"
	echo "déterminer vos partitions d'échange « swap » existantes :"
	echo ""
	echo "	# cfdisk"
	echo "	# fdisk -l"
	echo ""
	echo "Puis, entrez ci-dessous la partition d'échange « swap » que vous souhaitez"
	echo "activer pour votre système Linux. Exemples : /dev/sda1 ; /dev/hda3 ; etc."
	echo ""
	echo -n "Votre choix : "
	read SWAPSELECT;
	# Si l'utilisateur n'entre aucune partition :
	if [ "$SWAPSELECT" = "" ]; then
		echo "Aucune partition n'a été entrée. Voulez-vous ignorer la création"
		echo "d'une partition d'échange ?"
		echo ""
		echo -n "Votre choix (oui/non) : "
		read ABANDONSWAP;
		# Si l'utilisateur ne veut pas continuer :
		if [ "$ABANDONSWAP" = "oui" ]; then
			echo "La création de partition d'échange sera ignorée."
			sleep 2
			touch $TMP/ignorer_swap
			continue
		elif [ "$ABANDONSWAP" = "non" ]; then
			unset SWAPSELECT ABANDONSWAP
			continue
		else
			echo "Veuillez répondre par « oui » ou par « non » uniquement."
			sleep 2
			unset ABANDONSWAP
			continue
		fi
	else
		# Si l'utilisateur ne saisit pas un périph' de la forme « /dev/**** » :
		if [ "$(echo ${SWAPSELECT} | sed -e 's/\(\/dev\/\).*$/\1/')" = "" ]; then
			echo "Veuillez entrer une partition de la forme « /dev/xxxx »."
			sleep 2
			unset SWAPSELECT
			continue
		# Si tout semble OK, on active la swap et on l'ajoute au fichier 'choix_swap' :
		else
			if [ "${INSTALLDEBUG}" = "" ]; then
				clear
			fi
			echo -e "\033[1;32mFormatage de la partition d'échange ?\033[0;0m"
			echo ""
			echo "Si la partition ${SWAPSELECT} est déjà formatée ou sert déjà à d'autres"
			echo "systèmes, il est recommandé de ne pas la formater (le formatage modifie"
			echo "l'identificateur UUID de la partition et peut la rendre inutilisable sur"
			echo "d'autres systèmes Linux). Si elle vient d'être créée, vous devez la"
			echo "formater maintenant."
			echo ""
			echo "Dois-je formater la partition d'échange '${SWAPSELECT}' ?"
			echo "Répondez « oui » pour formater cette partition d'échange ou appuyez sur"
			echo "ENTRÉE pour ignorer son formatage."
			echo ""
			echo -n "Votre choix (oui/ENTRÉE) : "
			read FORMATSWAP;
			
			# Si l'utilisateur veut formater :
			if [ "${FORMATSWAP}" = "oui" ]; then
				echo "Formatage de la partition d'échange : "
				echo "		mkswap -v1 ${SWAPSELECT}"
				sleep 1
				mkswap -v1 ${SWAPSELECT}
			else
				echo "Activation de la partition d'échange :"
				echo "		swapon ${SWAPSELECT}"
				sleep 1
				swapon ${SWAPSELECT}
			fi
			
			# On enregistre le choix de la swap :
			touch $TMP/choix_swap
			echo "${SWAPSELECT}" > $TMP/choix_swap
			break
		fi
	fi
done

# C'est fini !
