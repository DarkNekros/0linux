#!/bin/env bash

unset MEDIA
rm -f $TMP/choix_media

# Boucle pour l'affichage du menu :
while [ 0 ]; do
	clear
	echo -e "\033[1;32mChoix du média d'installation.\033[0;0m"
	echo ""
	echo "Veuillez entrez ci-dessous le média d'installation dont vous"
	echo "disposez ou bien la méthode d'installation distante souhaitée"
	echo "pour votre système Linux."
	echo ""
	echo "*  Via un média amovible (disque/clé/carte) :"
	echo "dvd     : vous installez depuis un disque optique"
	echo "usb     : vous installez depuis une clé USB/une carte mémoire"
	echo ""
	echo "*  Via un dépôt de paquets (local ou distant) :"
	echo "distant : les paquets sont sur un dépôt distant"
	echo "local   : les paquets sont dans un répertoire/volume local"
	echo ""
	echo -n "Votre choix : "
	read MEDIA;
	# On analyse le choix de l'utilisateur et on exécute le script ad-hoc en conséquence :
case "$MEDIASOURCE" in
	${SELECTDVD_LABEL})
		. $PWD/detection_dvd.sh
	;;
	${SELECTUSB_LABEL})
		. $PWD/detection_usb.sh
	;;
	${SELECTHDD_LABEL})
		. $PWD/detection_hdd.sh
	#;;
	#${SELECTNFS_LABEL})
	#	detection_nfs.sh
	#;;
	#${SELECTFTP_LABEL})
	#	detection_ftp.sh
esac
	if [ "$CHOIXCLAVIER" = "" ]; then
		CHOIXCLAVIER="us"
	fi
	
	# On charge le clavier :
	loadkeys ${CHOIXCLAVIER} 1> /dev/null 2> /dev/null
	break
done

# C'est fini !
