#!/usr/bin/env bash

# On nettoie :
rm -f $TMP/choix_media
unset DETECTEDREPO NBDETECTEDREPO DETECTSELECT DIRSELECT DIRBASE DIR0

# On cherche un répertoire 'base' contenant le paquet 'eglibc-*' et on ignore '/usr/local' :
DETECTEDREPO=$(find / -type d -name "base" 2>/dev/null | grep -v 'usr/local')
NBDETECTEDREPO=$(find / -type d -name "base" 2>/dev/null | grep -v 'usr/local' | wc -l)

demander_choix_dir() {
	while [ 0 ]; do
		clear
		echo -e "\033[1;32mSaisie de l'emplacement contenant les paquets.\033[0;0m"
		echo ""
		echo "Veuillez entrer ci-dessous le chemin du répertoire (préalablement monté)"
		echo "contenant un dépôt de paquets (contenant donc base/, opt/, xorg/, etc.)"
		echo "ou appuyez sur ENTRÉE pour annuler."
		echo ""
		echo "Exemples : /mnt/tmp/mes_fichiers/paquets"
		echo "           /sauvegarde/0/paquets"
		echo "           /mes_paquets"
		echo ""
		echo -n "Votre choix : "
		read DIRSELECT;
		if [ "${DIRSELECT}" = "" ]; then
			unset DIRSELECT
			break
		elif [ ! -d ${DIRSELECT} ]; then
			echo "Veuillez entrer un emplacement valide."
			sleep 2
			unset DIRSELECT
			continue
		else
			# Si le volume contient un répertoire 'base/', lequel contient un paquet
			# 'eglibc' alors on considère qu'on tient là notre support d'installation :
			DIRBASE=$(find ${DIRSELECT} -type d -name "base" -print 2>/dev/null)
			if [ ! "${DIRBASE}" = "" ]; then
				DIR0=$(basename $(dirname ${DIRBASE}))
				if [ ! "$(find ${DIR0}/base -type f -name 'eglibc-*')" = "" ]; then
					# On crée un lien vers le répertoire spécifié et on crée un fichier vide
					# qui valide le choix du média :
					ln -sf ${DIRSELECT} /var/log/mount
					touch $TMP/choix_media
					echo "Un dépôt de paquets a été trouvé sur ce volume !"
					sleep 2
					break
				else
					echo "Ce périphérique ne contient pas de dépôt des paquets : j'ai recherché"
					echo "le répertoire 'base/' et son paquet 'eglibc-*', en vain. Retour..."
					sleep 4
					continue
				fi
			fi
			
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
