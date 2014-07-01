#!/usr/bin/env bash

# On nettoie avant tout :
rm -f $TMP/choix_media
unset MEDIA REPONSEREZO REPONSEDEPOT

# Boucle pour l'affichage du menu :
while [ 0 ]; do
	if [ "${INSTALLDEBUG}" = "" ]; then
		clear
	fi
	echo -e "\033[1;32mChoix de la source du dépôt de paquets.\033[0;0m"
	echo ""
	echo "Veuillez entrez ci-dessous le code de la source contenant le dépôt de"
	echo "paquets de 0Linux. Celui-ci doit contenir le répertoire '${VERSION}'"
	echo "désignant la version de 0Linux, et contenant la hiérarchie suivante :"
	echo ""
	echo "Si vous avez :          /mes_paquets/0linux/${VERSION}/$(uname -m)/paquets.db"
	echo "Alors vous indiquerez : /mes_paquets/0linux"
	echo ""
	echo "N.B. : si vous utilisez le média d'installation '0linux-mini', celui-ci"
	echo "NE contient PAS de dépôt de paquets, il vous faudra choisir l'installation"
	echo "via le réseau ou un répertoire déjà monté par vos soins."
	echo ""
	echo "1 : USB/DISQUE DUR - depuis un disque dur, une clé USB, une carte mémoire"
	echo "2 : CD/DVD         - depuis un disque optique (CD ou DVD)"
	echo "3 : RÉSEAU         - depuis le réseau ou Internet"
	echo "4 : RÉPERTOIRE     - depuis un répertoire déjà monté manuellement"
	echo ""
	echo -n "Votre choix : "
	read MEDIA;
	case "$MEDIA" in
	"1")
		. disque.sh
		
		# Si le script a crée un marqueur d'échec, on re-boucle :
		if [ -r $TMP/depot_invalide ]; then
			continue
		else
			break
		fi
	;;
	"2")
		. optique.sh
		
		# Si le script a crée un marqueur d'échec, on re-boucle :
		if [ -r $TMP/depot_invalide ]; then
			continue
		else
			break
		fi
	;;
	"3")
		. reseau.sh
	;;
	"4")
		. repertoire.sh
		
		# Si le script a crée un marqueur d'échec, on re-boucle :
		if [ -r $TMP/depot_invalide ]; then
			continue
		else
			break
		fi
	;;
	*)
		echo "Veuillez entrer un numéro valide (entre 1 et 4)."
		sleep 2
		unset MEDIA
		continue
	esac
done

# C'est fini !
