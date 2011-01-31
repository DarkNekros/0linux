#!/usr/bin/env bash

# On nettoie :
rm -f $TMP/choix_media
unset DETECTEDREPO DETECTSELECT DIRSELECT

# On cherche un répertoire 'paquets' :
DETECTEDREPO="$(find / -type d -name "paquets" -print)"

demander_choix_dir() {
	while [ 0 ]; do
		clear
		echo -e "\033[1;32mSaisie du répertoire contenant les paquets.\033[0;0m"
		echo ""
		echo "Veuillez entrer ci-dessous le chemin du répertoire (préalablement monté)"
		echo "contenant le dépôt de paquets (contenant donc base/, opt/, xorg/, etc.)"
		echo "Le répertoire spécifié doit contenir le sous-répertoire 'paquets'."
		echo ""
		echo "Exemples : /mnt/tmp/mes_fichiers/paquets"
		echo "           /sauvegarde/0/paquets"
		echo "           /paquets"
		echo ""
		echo -n "Votre choix : "
		read DIRSELECT;
		if [ "${DIRSELECT}" = "" ]; then
			echo "Veuillez entrer un emplacement valide."
			sleep 2
			unset DIRSELECT
			continue
		elif [ "$(echo ${DIRSELECT} | grep paquets)" = "" ]; then
			echo "Veuillez entrer un emplacement contenant le répertoire 'paquets'."
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
if [ "$(echo ${DETECTEDREPO} | wc -l)" -eq 1 ]; then
	clear
	echo -e "\033[1;32mUn dépôt de paquets a été détecté !\033[0;0m"
	echo ""
	echo "Un unique dépôt de paquets a été détecté à cet emplacement :"
	echo ""
	echo ${DETECTEDREPO}
	echo ""
	echo "Si ce dépôt vous convient, tapez « oui », sinon appuyez sur ENTRÉE pour"
	echo "ignorer cette étape."
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
