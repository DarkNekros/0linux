#!/usr/bin/env bash

# Note : les variables contiennent « USB » car ce script n'était destiné
# à l'origine qu'à l'installation via clés USB ;)

# On nettoie :
rm -f $TMP/choix_media
unset USBSELECT BLAH

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
	read USBSELECT;
	# Si l'utilisateur ne saisit pas un périph' de la forme « /dev/**** » :
	if [ "$(echo ${USBSELECT} | sed -e 's/\(\/dev\/\).*$/\1/')" = "" ]; then
		echo "Veuillez entrer un périphérique de la forme « /dev/xxxx »."
		sleep 2
		unset USBSELECT
		continue
	else
		echo "Montage en cours du périphérique ${USBSELECT} dans /var/log/mount..."
		mount ${USBSELECT} /var/log/mount 1> /dev/null 2> /dev/null
		# Si le volume contient un répertoire 'paquets/base', alors on
		# considère qu'on tient là notre support d'installation :
		DIR0=$(find /var/log/mount -type d -name "paquets" -print 2>/dev/null)
		if [ ! "${DIR0}" = "" ]; then
			if [ -d ${DIR0}/base ]; then
				LECTEUR_USB=${USBSELECT}
				echo ${USBSELECT} > $TMP/choix_media
				echo "Un dépôt de paquets a été trouvé sur ce volume !"
				sleep 2
				break
			fi
		else
			echo "Ce périphérique ne contient pas de dépôt des paquets : j'ai recherché"
			echo "le répertoire contenant 'paquets/base', en vain. Démontage..."
			sleep 2
			umount /var/log/mount 1> /dev/null 2> /dev/null
			continue
		fi
	fi
done

# C'est fini !
