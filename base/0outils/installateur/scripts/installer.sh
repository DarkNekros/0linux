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
	echo "partition '$(cat $TMP/partition_racine)'."
	echo ""
	echo -n "Appuyez sur ENTRÉE pour continuer."
	read BLURB;
	
	# On installe d'abord les paquets vitaux de 'base/':
	for paq in busybox-* \
	base-systeme-* \
	glibc-* \
	readline-* \
	ncurses-* \
	bash-* \
	sgml-*; do
		spackadd --root=${SETUPROOT} ${MEDIACHOISI}/base/${paq}.spack 2>/dev/null
	done
	
	# On installe tout le reste de 'base/' 'opt/' et xorg/  sauf linux* et les paquets
	# contenant des modules noyau, qu'on installera en dernier :
	for subdir in base opt xorg; do
		for paquet in $(find ${MEDIACHOISI}/${subdir} -type f \( \
		-name "*.spack" \
		\! -name "base-systeme-*" \
		\! -name "bash-*" \
		\! -name "busybox-*" \
		\! -name "glibc-*" \
		\! -name "linux-*" \
		\! -name "ncurses-*" \
		\! -name "ndiswrapper-*" \
		\! -name "readline-*" \
		\! -name "sgml-*" \) | sort) ; do
			spackadd --root=${SETUPROOT} ${paquet} 2>/dev/null
		done
	done
	
	# Linux (appel à 'make' en post-installation, donc de
	# nombreuses dépendances) :
	spackadd --root=${SETUPROOT} ${MEDIACHOISI}/base/linux-*.spack 2>/dev/null

	# ndiswrapper (contient un module noyau et un appel à 'depmod'). "|| true" sert au cas
	# où 'ndiswrapper' serait absent (ça arrive si l'hôte n'a pas la même version du noyau
	# et que le paquet n'est donc pas encore compilé) :
	spackadd --root=${SETUPROOT} ${MEDIACHOISI}/base/ndiswrapper-*.spack 2>/dev/null || true
	
	# On nettoie tous les fichiers '*.0nouveau' :
	for f in $(find ${SETUPROOT}/etc -type f -name "*.0nouveau"); do
		mv ${f} $(dirname ${f})/$(basename ${f} .0nouveau)
	done
fi

# C'est fini.
