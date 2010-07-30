#!/bin/env bash

unset MEDIA
rm -f $TMP/choix_media

# Boucle pour l'affichage du menu :
while [ 0 ]; do
	clear
	echo -e "\033[1;32mChoix du média d'installation.\033[0;0m"
	echo ""
	echo "Veuillez entrez ci-dessous le média d'installation dont vous"
	echo "disposez ou bien l'emplacement des paquets logiciels que vous"
	echo "souhaitez utiliser pour installer votre système Linux."
	echo ""
	echo "* Installer depuis un média amovible (disque/clé/carte) :"
	echo "dvd     : vous installez depuis un disque optique (CD/DVD)"
	echo "usb     : vous installez depuis une clé USB/une carte mémoire"
	echo ""
	echo "* Installer via un dépôt de paquets (local ou distant) :"
	echo "distant : les paquets sont sur un dépôt distant"
	echo "local   : les paquets sont dans un répertoire ou un volume local"
	echo ""
	echo -n "Votre choix : "
	read MEDIA;
	case "$MEDIA" in
	"dvd")
		. $PWD/dvd.sh
		break
	;;
	"usb")
		. $PWD/usb.sh
		break
	;;
	"distant")
		. $PWD/rsync.sh
		break
	;;
	"local")
		. $PWD/hdd.sh
		break
	*)
		echo "Veuillez entrer un média ou un emplacement valide."
		sleep 2
		continue
	esac
done

# C'est fini !
