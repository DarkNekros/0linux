#!/usr/bin/env bash

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
	echo "1 : DISQUE DUR/USB - depuis un disque dur, une clé USB, une carte mémoire"
	echo "2 : CD/DVD         - depuis un disque optique (CD ou DVD)"
	echo "3 : RÉPERTOIRE     - depuis un répertoire déjà monté manuellement"
	echo ""
	echo -n "Votre choix : "
	read MEDIA;
	case "$MEDIA" in
	"1")
		. disque.sh
		break
	;;
	"2")
		. optique.sh
		break
	;;
	"3")
		. repertoire.sh
		break
	;;
	*)
		echo "Veuillez entrer un numéro valide (entre 1 et 3)."
		sleep 2
		unset MEDIA
		continue
	esac
done

# C'est fini !
