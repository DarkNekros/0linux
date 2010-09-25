#!/bin/env bash

# On nettoie :
rm -f $TMP/choix_media
unset USBSELECT BLAH

# Boucle d'affichage du menu :
while [ 0 ]; do
	clear
	echo -e "\033[1;32mSaisie du périphérique USB.\033[0;0m"
	echo ""
	echo "Dans la console n°2, utilisez les outils suivants pour déterminer le"
	echo "périphérique USB contenant les paquets à installer :"
	echo ""
	echo "		# cfdisk"
	echo "		# fdisk -l"
	echo ""
	echo "Puis, entrez ci-dessous le périphérique USB concerné."
	echo "Exemples : /dev/sdc1 ; /dev/sdd1 ; etc."
	echo ""
	echo -n "Votre choix : "
	read USBSELECT;
	if [ "$USBSELECT" = "" ]; then
		echo "Veuillez entrer un périphérique de la forme « /dev/xxxx »."
		sleep 2
		unset USBSELECT
		continue
	else
		# Si l'utilisateur ne saisit pas un périph' de la forme « /dev/**** » :
		if [ "$(echo ${USBSELECT} | grep '/dev/')" = "" ]; then
			echo "Veuillez entrer un périphérique de la forme « /dev/xxxx »."
			sleep 2
			unset USBSELECT
			continue
		else
			echo "Montage en cours du périphérique ${USBSELECT} dans /var/log/mount..."
			mount -o ro ${USBSELECT} ${TMPMOUNT} 1> /dev/null 2> /dev/null
			# Si le volume contient le répertoire '0/paquets/base', alors on
			# considère qu'on tient notre support d'installation :
			if [ -r ${TMPMOUNT}/0/paquets/base ]; then
				LECTEUR_USB=${USBSELECT}
				echo ${USBSELECT} > $TMP/choix_media
				echo "Un dépôt de paquets a été trouvé sur ce volume !"
				sleep 2
				break
			# Sinon, on a affaire à une simple partition :
			else
				umount ${TMPMOUNT} 1> /dev/null 2> /dev/null
				echo "Ce périphérique ne contient pas de dépôt des paquets : j'ai recherché"
				echo "le répertoire /var/log/mount/0/paquets/base, en vain. Démontage..."
				echo ""
				echo -n "Appuyez sur ENTRÉE pour continuer."
				read BLAH;
				unset USBSELECT
				continue
			fi
		fi
	fi
done

# C'est fini !
