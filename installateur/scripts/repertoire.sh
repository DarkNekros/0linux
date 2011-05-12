#!/usr/bin/env bash

# On nettoie :
rm -f $TMP/choix_media
unset DETECTEDREPO NBDETECTEDREPO DETECTSELECT DIRSELECT

# On cherche un répertoire 'paquets' :
DETECTEDREPO=$(find / -type d -name "paquets" \! -name "/usr/local/paquets")
NBDETECTEDREPO=$(find / -type d -name "paquets" \! -name "/usr/local/paquets" | wc -l)

demander_choix_dir() {
	while [ 0 ]; do
		clear
		echo -e "\033[1;32mSaisie du répertoire contenant les paquets.\033[0;0m"
		echo ""
		echo "Veuillez entrer ci-dessous le chemin du répertoire (préalablement monté)"
		echo "contenant un dépôt de paquets (contenant donc base/, opt/, xorg/, etc.)"
		echo ""
		echo "Exemples : /mnt/tmp/mes_fichiers/paquets"
		echo "           /sauvegarde/0/paquets"
		echo "           /mes_paquets"
		echo ""
		echo -n "Votre choix : "
		read DIRSELECT;
		if [ "${DIRSELECT}" = "" ]; then
			echo "Veuillez entrer un emplacement valide."
			sleep 2
			unset DIRSELECT
			continue
		elif [ ! -d ${DIRSELECT} ]; then
			echo "Veuillez entrer un emplacement valide."
			sleep 2
			unset DIRSELECT
			continue
		else
			# On crée un lien et un fichier 'choix_media' vide si le choix est accepté :
			ln -sf ${DIRSELECT} /var/log/mount
			touch $TMP/choix_media
			break
		fi
	done
}

# Si l'on trouve un seul répertoire 'paquets' :
if [ "${NBDETECTEDREPO}" = "1" ]; then
	clear
	echo -e "\033[1;32mUn dépôt de paquets a été détecté !\033[0;0m"
	echo ""
	echo "Un unique dépôt de paquets a été détecté à cet emplacement :"
	echo ""
	echo ${DETECTEDREPO}
	echo ""
	echo "Si ce dépôt vous convient, tapez « oui », sinon appuyez sur ENTRÉE pour"
	echo "ignorer cette étape et le spécifier vous-même."
	echo ""
	echo -n "Votre choix : "
	read DETECTSELECT;
	# On crée un lien et un fichier 'choix_media' vide si le choix est accepté :
	if [ "${DETECTSELECT}" = "oui" ]; then
		ln -sf ${DETECTEDREPO} /var/log/mount
		touch $TMP/choix_media
	else
		demander_choix_dir
	fi
# Sinon :
else
	demander_choix_dir
fi

# C'est fini !
