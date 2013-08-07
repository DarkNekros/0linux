#!/usr/bin/env bash

# On nettoie :
unset BLURB DIR0

# Quelques vérif' avant l'installation des paquets :
MEDIACHOISI="$(cat $TMP/choix_media)"
if [ ! -d ${MEDIACHOISI}/base ]; then
	echo "Erreur fatale : le média choisi ne contient pas le dépôt 'base' !"
	echo "Le répertoire '${MEDIACHOISI}/base' n'existe pas."
	echo "Retour au menu principal..."
	sleep 3
elif [ "${SETUPROOT}" = "" ]; then
	echo "Erreur fatale : la racine système n'est pas positionnée !"
	echo "Retour au menu principal..."
	sleep 3
elif [ ! -d ${SETUPROOT} ]; then
	echo "Erreur fatale : le répertoire accueillant la future racine système,"
	echo "'${SETUPROOT}', est introuvable !"
	echo "Ce répertoire devrait normalement exister. Retour au menu principal..."
	sleep 3
else
	if [ "${INSTALLDEBUG}" = "" ]; then
		clear
	fi
	echo -e "\033[1;32mInstallation des paquets.\033[0;0m"
	echo ""
	echo "Les paquets du système 0Linux vont maintenant être installés sur votre"
	echo "partition '$(cat $TMP/partition_racine)'"
	echo ""
	echo -n "Appuyez sur ENTRÉE pour continuer."
	read BLURB;

	# On installe d'abord les paquets vitaux de 'base/':
	for paq in busybox* \
	base-systeme* \
	eglibc* \
	readline* \
	ncurses* \
	bash* \
	sgml*; do
		spackadd --about ${MEDIACHOISI}/base/${paq}.spack
		spackadd --root=${SETUPROOT} ${MEDIACHOISI}/base/${paq}.spack &>/dev/null 2>&1
	done
	
	# Un « hack » pour traiter correctement la post-installation de 'base-systeme' : on n'avait
	# pas 'coreutils' installé, la post-install n'était donc pas traitée et des '*.0nouveau'
	# traînaient partout. On réinstalle 'base-systeme', c'est inoffensif :
	spackadd -f --root=${SETUPROOT} ${MEDIACHOISI}/base/base-systeme-*.spack &>/dev/null 2>&1
	
	# On installe tout le reste de 'base/' 'opt/' et xorg/  sauf linux* et les paquets
	# contenant des modules noyau, qu'on installera en dernier :
	for subdir in base opt xorg; do
		for paquet in $(find ${MEDIACHOISI}/${subdir} -type f \( \
		-name "*.spack" \
		\! -name "base-systeme*" \
		\! -name "bash*" \
		\! -name "busybox*" \
		\! -name "linux*" \
		\! -name "ncurses*" \
		\! -name "ndiswrapper*" \
		\! -name "readline*" \
		\! -name "sgml*" \) | sort) ; do
			spackadd --about ${paquet}
			spackadd --root=${SETUPROOT} ${paquet} &>/dev/null 2>&1
		done
	done

	# Linux (appel à 'make' en post-installation, donc de
	# nombreuses dépendances) :
	spackadd --about ${MEDIACHOISI}/base/linux*.spack
	spackadd --root=${SETUPROOT} ${MEDIACHOISI}/base/linux*.spack &>/dev/null 2>&1

	# ndiswrapper (contient un module noyau) :
	spackadd --about ${MEDIACHOISI}/base/ndiswrapper*.spack
	spackadd --root=${SETUPROOT} ${MEDIACHOISI}/base/ndiswrapper*.spack &>/dev/null 2>&1
fi

# C'est fini !
