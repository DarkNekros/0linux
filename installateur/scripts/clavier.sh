#!/bin/env bash

# On crée les répertoires temporaires s'ils n'existent pas :
TMP=${TMP:-/var/log/setup/tmp}
TMPMOUNT=${TMPMOUNT:-/var/log/mount}
mkdir -p ${TMP} ${TMPMOUNT}

unset CHOIXCLAVIER TESTCLAVIER
rm -f $TMP/choix_clavier

# Boucle pour l'affichage du menu :
while [ ! -r $TMP/choix_clavier ]; do
	clear
	echo -e "\033[1;32mChoix de la disposition du clavier.\033[0;0m"
	echo ""
	echo "Tapez le code de clavier souhaité parmi la liste ci-dessous. "
	echo "Si vous avez un doute, sachez que les dispositions francophones les"
	echo "plus répandues pour chaque pays figurent en premier."
	echo ""
	echo "1  : 'cf' - QWERTY canadien-français"
	echo "2  : 'fr_CH-latin1' - QWERTZ suisse francophone latin-1"
	echo "3  : 'fr_CH' - QWERTZ suisse francophone"
	echo "4  : 'be-latin1' - AZERTY belge"
	echo "5  : 'fr-latin9' - AZERTY français étendu latin-9"
	echo "6  : 'fr-latin1' - AZERTY français latin-1"
	echo "7  : 'fr-pc' - AZERTY français"
	echo "8  : 'fr' - AZERTY français"
	echo "9  : 'azerty' - AZERTY standard"
	echo "10 : 'fr-dvorak-bepo-utf8' - BÉPO + UTF-8"
	echo "11 : 'fr-dvorak-bepo' - BÉPO"
	echo "12 : 'dvorak-fr' - Dvorak français"
	echo "13 : 'us' - QWERTY des États-Unis (par défaut)"
	echo ""
	echo -n "Votre choix : "
	read CHOIXCLAVIER;
	case "$CHOIXCLAVIER" in
	"1")
		CHOIXCLAVIER="cf"
	;;
	"2")
		CHOIXCLAVIER="fr_CH-latin1"
	;;
	"3")
		CHOIXCLAVIER="fr_CH"
	;;
	"4")
		CHOIXCLAVIER="be-latin1"
	;;
	"5")
		CHOIXCLAVIER="fr-latin9"
	;;
	"6")
		CHOIXCLAVIER="fr-latin1"
	;;
	"7")
		CHOIXCLAVIER="fr-pc"
	;;
	"8")
		CHOIXCLAVIER="fr"
	;;
	"9")
		CHOIXCLAVIER="azerty"
	;;
	"10")
		CHOIXCLAVIER="fr-dvorak-bepo-utf8"
	;;
	"11")
		CHOIXCLAVIER="fr-dvorak-bepo"
	;;
	"12")
		CHOIXCLAVIER="dvorak-fr"
	;;
	"13")
		CHOIXCLAVIER="us"
	;;
	*)
		echo "Veuillez entrer un numéro valide (entre 1 et 13)."
		sleep 2
		continue
	esac
	
	# On charge le clavier :
	loadkeys ${CHOIXCLAVIER} 1> /dev/null 2> /dev/null
	
	# Test du clavier :
	while [ 0 ]; do
		clear
		echo -e "\033[1;32mTest de la disposition du clavier.\033[0;0m"
		echo ""
		echo "La nouvelle disposition est maintenant activée. Tapez tout ce que vous"
		echo "voulez pour la tester. Pour quitter le test du clavier, entrez simplement"
		echo "le chiffre « 1 » et appuyez sur ENTRÉE pour valider votre choix ou bien"
		echo "entrez « 2 » pour refuser la disposition et en choisir une autre."
		echo ""
		echo -n "Test : "
		read TESTCLAVIER;
		# Si le choix est validé, on sort du script :
		if [ "$TESTCLAVIER" = "1" ]; then
			touch $TMP/choix_clavier
			echo "${CHOIXCLAVIER}" > $TMP/choix_clavier
			break
		# Sinon, on retourne au choix du clavier :
		elif  [ "$TESTCLAVIER" = "2" ]; then
			# On recharge le clavier US par défaut et on sort de la boucle :
			loadkeys us 1> /dev/null 2> /dev/null
			unset CHOIXCLAVIER TESTCLAVIER
			break
		fi
	done
done

# C'est fini !
