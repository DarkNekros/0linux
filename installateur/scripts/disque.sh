#!/usr/bin/env bash

# On nettoie :
rm -f $TMP/choix_media
unset MEDIASELECT DIRBASE DIR0

# Boucle d'affichage du menu :
while [ 0 ]; do
	clear
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
	echo ""
	echo -n "Votre choix : "
	read MEDIASELECT;
	# Si l'utilisateur ne saisit pas un périph' de la forme « /dev/**** » :
	if [ "$(echo ${MEDIASELECT} | sed -e 's/\(\/dev\/\).*$/\1/')" = "" ]; then
		echo "Veuillez entrer un périphérique de la forme « /dev/xxxx »."
		sleep 2
		unset MEDIASELECT
		continue
	else
		# On monte le périphérique :
		echo "Montage en cours du périphérique ${MEDIASELECT} dans /var/log/mount..."
		mount ${MEDIASELECT} /var/log/mount 1> /dev/null 2> /dev/null
		
		# Si le volume contient un répertoire 'base/', lequel contient un paquet
		# 'eglibc' alors on considère qu'on tient là notre support d'installation :
		DIRBASE=$(find /var/log/mount -type d -name "base" -print 2>/dev/null)
		if [ ! "${DIRBASE}" = "" ]; then
			DIR0=$(basename $(dirname ${DIRBASE}))
			if [ ! "$(find ${DIR0}/base -type f -name 'eglibc-*')" = "" ]; then
				echo ${MEDIASELECT} > $TMP/choix_media
				echo "Un dépôt de paquets a été trouvé sur ce volume !"
				sleep 2
				break
			fi
		else
			echo "Ce périphérique ne contient pas de dépôt des paquets : j'ai recherché"
			echo "le répertoire 'base/' et son paquet 'eglibc-*', en vain. Démontage..."
			sleep 4
			umount /var/log/mount 1> /dev/null 2> /dev/null
			continue
		fi
	fi
done

# C'est fini !
