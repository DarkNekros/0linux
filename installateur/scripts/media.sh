#!/bin/env bash

# On nettoie avant tout :
rm -f $TMP/choix_media
unset MEDIA

# Boucle pour l'affichage du menu :
while [ 0 ]; do
	clear
	echo -e "\033[1;32mChoix du média d'installation.\033[0;0m"
	echo ""
	echo "Veuillez entrez ci-dessous le code du média d'installation dont vous"
	echo "disposez pour installer votre système Linux."
	echo ""
	echo "1 : USB - vous installez depuis une clé USB ou une carte mémoire"
	echo "2 : DISQUE - vous installez depuis un disque optique"
	echo ""
	echo -n "Votre choix : "
	read MEDIA;
	case "$MEDIA" in
	"1")
		. usb.sh
		break
	;;
	"2")
		. disque.sh
		break
	;;
	"3")
		#. rsync.sh
		continue
	;;
	"4")
		#. hdd.sh
		continue
	;;
	*)
		echo "Veuillez entrer un numéro valide (entre 1 et 2)."
		sleep 2
		unset MEDIA
		continue
	esac
done

# C'est fini !
