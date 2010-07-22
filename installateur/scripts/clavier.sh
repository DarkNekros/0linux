#!/bin/env bash
# On inclut nos fonctions ('clavier.sh' peut être appelé seul au démarrage) :
. /usr/lib/installateur/fonctions.sh

## Début de la boucle pour l'affichage du menu :
while [ 0 ]; do
	keymapmenu 2> $TMP/choix_clavier
		
	# En cas de problème, on nettoie :
	if [ ! $? = 0 ]; then
		rm -f $TMP/choix_clavier
		exit
	fi
	
	# On charge le clavier choisi :
	CLAVIER="`cat $TMP/choix_clavier`"
	loadkeys /lib/kbd/keymaps/i386/${CLAVIER}.map.gz 1>/dev/null 2>/dev/null
	
	# Boucle pour l'affichage de la page de test du clavier :
	while [ 0 ]; do
		keyboardtestmenu 2> $TMP/test_clavier
		
		# On sort de la boucle en cas de problème :
		if [ $? = 1 ]; then
			break;
		fi
		
		# Un "1" valide le clavier, un "2" le refuse
		REPONSE="`cat $TMP/test_clavier`"
		rm -f $TMP/test_clavier
		
		if [ "$REPONSE" = "1" -o "$REPONSE" = "2" ]; then
			break;
		fi
		
	done
	
	# Si le choix est validé, on sort de la boucle (et du script) :
	if [ "$REPONSE" = "1" ]; then
		break;
	# Sinon, on retourne au choix du clavier :
	else
		rm -f $TMP/choix_clavier
		# On recharge le clavier US par défaut :
		loadkmap `zcat /lib/kbd/keymaps/i386/qwerty/us.map.gz`
		continue;
	fi
	
done

# C'est fini !
