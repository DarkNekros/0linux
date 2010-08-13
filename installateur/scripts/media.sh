#!/bin/env bash

# On nettoie avant tout :
rm -f $TMP/choix_media
unset MEDIA

# Boucle pour l'affichage du menu :
while [ 0 ]; do
	clear
	echo -e "\033[1;32mChoix du média d'installation.\033[0;0m"
	echo ""
	echo "Veuillez entrez ci-dessous le média d'installation dont vous"
	echo "disposez pour installer votre système Linux."
	echo "Note : la seule méthode à ce jour est l'installation via un"
	echo "périphérique USB ! :)"
	echo ""
	echo "* Installer depuis un média amovible (disque/clé/carte) :"
	echo "usb     : vous installez depuis une clé USB/une carte mémoire"
	echo ""
	echo -n "Votre choix : "
	read MEDIA;
	case "$MEDIA" in
	"dvd")
		#. dvd.sh
		break
	;;
	"usb")
		. usb.sh
		break
	;;
	"distant")
		#. rsync.sh
		break
	;;
	"local")
		#. hdd.sh
		break
	*)
		echo "Veuillez entrer un média ou un emplacement valide."
		sleep 2
		unset MEDIA
		continue
	esac
done

# C'est fini !
