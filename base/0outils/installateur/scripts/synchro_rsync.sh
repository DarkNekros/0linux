#!/usr/bin/env bash

# On nettoie :
unset CHOIXSYNCHRO CHOIXDEPOTS

while [ 0 ]; do
	if [ "${INSTALLDEBUG}" = "" ]; then
		clear
	fi
	echo -e "\033[1;32mSynchronisation des paquets distants.\033[0;0m"
	echo ""
	echo "L'installateur peut maintenant télécharger les paquets en synchronisant"
	echo "le dépôt distant de 0linux dans le répertoire '/0/paquets' de votre partition"
	echo "racine. Tapez le code de la rubrique désirée pour démarrer la synchronisation"
	echo "ou appuyez sur ENTRÉE (ou 2) pour annuler."
	echo ""
	echo "1 : SYNCHRONISER  - synchroniser 'base/', 'opt/' et 'xorg/'"
	echo "2 : ANNULER       - ne pas synchroniser, retourner au menu principal"
	echo ""
	echo -n "Votre choix : "
	read CHOIXSYNCHRO;
	case "$CHOIXSYNCHRO" in
	"1")
		CHOIXDEPOTS="base opt xorg"
	;;
	"2")
		CHOIXDEPOTS=""
		break
	;;
	*)
		echo "Veuillez entrer un numéro valide (entre 1 et 4)."
		sleep 2
		continue
	esac
	
	# Si on doit synchroniser :
	if [ ! "${CHOIXDEPOTS}" = "" ]; then
		if [ "${INSTALLDEBUG}" = "" ]; then
			clear
		fi
		echo -e "\033[1;32mSynchronisation en cours...\033[0;0m"
		echo ""
		echo "Faites-vous donc un thé, un café ou une infusion ! :)"
		echo ""
		
		# On synchronise chaque dépôt :
		mkdir -p ${SETUPROOT}/0/paquets
		
		for depot in ${CHOIXDEPOTS}; do
			rsync -ahvPz --del --progress ${RSYNC0LINUX}/${depot} ${SETUPROOT}/0/paquets/
		done
		
		# On a normalement nos paquets :
		echo "${SETUPROOT}/0/paquets" > $TMP/choix_media
		
		# On supprime tout marqueur d'échec éventuellement présent :
		rm -f $TMP/depot_invalide
		sleep 2
		break
	else
		# On place un marqueur d'échec pour redemander un média dans le menu PAQUETS :
		touch $TMP/depot_invalide
		break
	fi
done

# C'est fini !
