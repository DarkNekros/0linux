#!/usr/bin/env bash

# On nettoie avant tout :
rm -f $TMP/choix_media
unset MEDIA REPONSEREZO

# Boucle pour l'affichage du menu :
while [ 0 ]; do
	if [ "${INSTALLDEBUG}" = "" ]; then
		clear
	fi
	echo -e "\033[1;32mChoix du média d'installation.\033[0;0m"
	echo ""
	echo "Veuillez entrez ci-dessous le code du support d'installation contenant le"
	echo "dépôt des paquets de 0Linux, qui doit contenir le fichier 'paquets.db'"
	echo "ainsi que des répertoires nommés 'a/', 'b/', 'd/', 'z/', etc."
	echo ""
	echo "N.B. : si vous utilisez le média d'installation '0linux-mini', celui-ci"
	echo "NE contient PAS de dépôt de paquets, il vous faudra choisir l'installation"
	echo "via le réseau."
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
		echo "Une connexion filaire de type Ethernet avec une IP attribuée automatiquement"
		echo "par DHCP a déjà été tentée au démarrage du système."
		echo "Vous pouvez tenter de vous connecter manuellement via un autre"
		echo "terminal à l'aide des commandes 'ifconfig', 'dhcpcd', 'iwconfig', etc. si"
		echo "vous avez une connexion différente."
		echo ""
		echo "Appuyez sur ENTRÉE une fois votre réseau configuré (l'installateur ne testera"
		echo "pas la connexion)."
		read REPONSEREZO;
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
