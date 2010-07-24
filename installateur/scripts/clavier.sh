#!/bin/env bash

unset CHOIXCLAVIER TESTCLAVIER
rm -f $TMP/choix_clavier

# Boucle pour l'affichage du menu :
while [ 0 ]; do
	clear
	echo -e "\033[1;32mChoix de la disposition du clavier.\033[0;0m"
	echo ""
	echo "Tapez le code de clavier souhaité parmi la liste ci-dessous. "
	echo "Si vous avez un doute, sachez que les dispositions francophones les"
	echo "plus répandues pour chaque pays figurent en premier."
	echo "Pour conserver la disposition QWERTY des États-Unis, appuyez"
	echo "simplement sur ENTRÉE. Les autre codes dispositions disponibles"
	echo "se trouvent dans '/lib/kbd/keymaps/i386'."
	echo ""
	echo "cf                  : QWERTY canadien-français"
	echo "fr_CH-latin1        : QWERTZ suisse francophone latin-1"
	echo "fr_CH               : QWERTZ suisse francophone"
	echo "be-latin1           : AZERTY belge"
	echo "fr-latin9           : AZERTY français étendu latin-9"
	echo "fr-latin1           : AZERTY français latin-1"
	echo "fr-pc               : AZERTY français"
	echo "fr                  : AZERTY français"
	echo "azerty              : AZERTY standard"
	echo "fr-dvorak-bepo-utf8 : BÉPO + UTF-8"
	echo "fr-dvorak-bepo      : BÉPO"
	echo "dvorak-fr           : Dvorak français"
	echo "us                  : QWERTY des États-Unis"
	echo -n "Votre choix : "
	read CHOIXCLAVIER;
	if [ "$CHOIXCLAVIER" = "" ]; then
		CHOIXCLAVIER="us"
	fi
	
	# On charge le clavier :
	loadkeys ${CHOIXCLAVIER} 1> /dev/null 2> /dev/null
	
	# Test du clavier :
	while [ 0 ]; do
		echo -e "\033[1;32mTest de la disposition di clavier.\033[0;0m"
		echo ""
		echo "La nouvelle disposition est maintenant activée. Tapez tout ce que vous"
		echo "voulez pour la tester. Pour quitter le test du clavier, entrez simplement"
		echo "le chiffre « 1 » et appuyez sur ENTRÉE pour valider votre choix ou bien"
		echo "entrez « 2 » pour refuser la disposition et en choisir une autre."
		echo -n "Test : "
		read TESTCLAVIER;
		# Si le choix est validé, on sort du script :
		if [ "$TESTCLAVIER" = "1" ]; then
			touch $TMP/choix_clavier
			echo "${CHOIXCLAVIER}" > $TMP/choix_clavier
			exit 0
		# Sinon, on retourne au choix du clavier :
		elif  [ "$TESTCLAVIER" = "2" ]; then
			# On recharge le clavier US par défaut et on sort de la boucle :
			loadkeys us 1> /dev/null 2> /dev/null
			unset CHOIXCLAVIER TESTCLAVIER
			break;
		fi
	done
done

# C'est fini !
