#!/usr/bin/env bash

# On nettoie :
rm -f $TMP/choix_media
unset USBSELECT BLAH

# Boucle d'affichage du menu :
while [ 0 ]; do
	clear
	echo -e "\033[1;32mSaisie du périphérique USB.\033[0;0m"
	echo ""
	echo "Dans la console n°2, utilisez au choix les outils suivants pour"
	echo "déterminer le périphérique USB contenant les paquets à installer :"
	echo ""
	echo "		# cfdisk"
	echo "		# fdisk -l"
	echo ""
	echo "Puis, entrez ci-dessous le périphérique USB concerné."
	echo "Exemples : /dev/sdc1 ; /dev/sdd1 ; etc."
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
		mount -o ro ${USBSELECT} /var/log/mount 1> /dev/null 2> /dev/null
		# Si le volume contient le répertoire '0/paquets/base', alors on
		# considère qu'on tient là notre support d'installation :
		if [ -d /var/log/mount/0/paquets/base ]; then
			LECTEUR_USB=${USBSELECT}
			echo ${USBSELECT} > $TMP/choix_media
			echo "Un dépôt de paquets a été trouvé sur ce volume !"
			sleep 2
			break
		# Sinon, on a affaire à une simple partition :
		else
			
			echo "Ce périphérique ne contient pas de dépôt des paquets : j'ai recherché"
			echo "le répertoire /var/log/mount/0/paquets/base, en vain. Démontage..."
			sleep 2
			umount /var/log/mount 1> /dev/null 2> /dev/null
			continue
		fi
	fi
done

# C'est fini !
