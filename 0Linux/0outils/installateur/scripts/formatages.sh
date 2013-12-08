#!/usr/bin/env bash

# On nettoie avant toute chose :
rm -f $TMP/fstab
unset FORMATALL

# Cette fonction supprime les espaces superflus via 'echo' :
crunch() {
	read STRING;
	echo $STRING;
}

# Boucle d'affichage pour les formatages des partitions choisies : :
while [ 0 ]; do
	# Si aucun formatage n'est prévu, on quitte :
	if [ "$(cat $TMP/formatages | crunch)" = "" ]; then
		break
	fi
	if [ "${INSTALLDEBUG}" = "" ]; then
		clear
	fi
	echo -e "\033[1;32mConfirmation des formatages des partitions.\033[0;0m"
	echo ""
	echo "L'installateur s'apprête à exécuter les commandes de formatage suivantes."
	echo "N.B.: toutes les données se trouvant sur ces partitions seront perdues !"
	echo ""
	cat $TMP/formatages | sed 's@2> /dev/null@@'
	echo ""
	echo "Pour confirmer les formatages, tapez « oui »."
	echo "Pour annuler et revenir au menu principal, appuyez sur ENTRÉE."
	echo ""
	echo -n "Votre choix : "
	read FORMATALL;
	if [ "$FORMATALL" = "" ]; then
		break
	elif [ "$FORMATALL" = "oui" ]; then
		# On a confirmation du formatage :
		sync
		chmod +x $TMP/formatages
		echo -n "Formatages en cours... "
		# On lance tous les formatages présents dans le fichier temporaire :
		sh $TMP/formatages
		echo "Terminés."
		break
	else
		echo "Veuillez entrer « oui » ou appuyer sur ENTRÉE uniquement."
		sleep 2
		unset FORMATALL
		continue
	fi
done

# C'est fini !
