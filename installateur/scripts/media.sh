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
	echo "1 : USB - vous installez depuis une clé USB/une carte mémoire"
	echo ""
	echo -n "Votre choix : "
	read MEDIA;
	case "$MEDIA" in
	"1")
		. usb.sh
		break
	;;
	"2")
		#. dvd.sh
		break
	;;
	"3")
		#. rsync.sh
		break
	;;
	"4")
		#. hdd.sh
		break
	;;
	*)
		echo "Veuillez entrer un numéro valide (entre 1 et 4)."
		sleep 2
		unset MEDIA
		continue
	esac
done

# C'est fini !
