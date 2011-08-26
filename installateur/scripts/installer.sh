#!/usr/bin/env bash

# On nettoie :
unset BLURB BASEDIR DIR0

# Quelques vérif' avant l'installation des paquets. '/var/log/mount' doit
# à ce stade contenir les paquets résidents : 
BASEDIR=$(find /var/log/mount -type d -name "base" 2>/dev/null)
if [ "${BASEDIR}" = "" ]; then
	echo "Erreur fatale : '/var/log/mount' ne contient pas les paquets !"
	echo "Ce répertoire doit contenir les répertoires 'base', 'opt', 'xorg',"
	echo "etc. peuplés des paquets logiciels."
	sleep 3
	touch $TMP/mediapasok
elif [ "${SETUPROOT}" = "" ]; then
	echo "Erreur fatale : la racine système n'est pas positionnée !"
	echo "Retour au menu principal..."
	sleep 3
	touch $TMP/mediapasok
elif [ ! -d ${SETUPROOT} ]; then
	echo "Erreur fatale : le répertoire accueillant la future racine système,"
	echo "'${SETUPROOT}', est introuvable !"
	echo "Ce répertoire devrait normalement exister. Retour au menu principal..."
	sleep 3
	touch $TMP/mediapasok
else
	DIR0=$(dirname ${BASEDIR})

	clear
	echo -e "\033[1;32mInstallation des paquets.\033[0;0m"
	echo ""
	echo "Les paquets du système 0 vont maintenant être installés sur votre"
	echo "disque dur."
	echo ""
	echo -n "Appuyez sur ENTRÉE pour continuer."
	read BLURB;

	# On installe d'abord les paquets vitaux :
	for paq in base-systeme* etc* eglibc* sgml* ; do
		spackadd --about ${DIR0}/base/${paq}
		spackadd --root=${SETUPROOT} ${DIR0}/base/${paq} &>/dev/null 2>&1
	done

	# On installe tout le reste sauf linux-source-*, qu'on installe en dernier,
	# tout en ignorant le répertoire 'extra' :
	for subdir0 in base opt xorg xfce; do
		for paquet in $(find ${DIR0}/${subdir0} -type f \( \
			-name "*.spack" \
			-a \! -name "base-systeme*" \
			-a \! -name "etc*" \
			-a \! -name "eglibc*" \
			-a \! -name "sgml*" \
			-a \! -name "linux-source*" \) | sort) ; do
			spackadd --about ${paquet}
			spackadd --root=${SETUPROOT} ${paquet} &>/dev/null 2>&1
		done
	done

	# Les sources de Linux (appel à 'make' en post-installation, donc de
	# nombreuses dépendances) :
	spackadd --about ${DIR0}/base/linux-source-*
	spackadd --root=${SETUPROOT} ${DIR0}/base/linux-source* &>/dev/null 2>&1

fi
# C'est fini !
