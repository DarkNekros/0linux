#!/bin/env bash

clear
echo -e "\033[1;32mInstallation des paquets.\033[0;0m"
echo ""
echo "Les paquets du système 0 vont maintenant être installés sur votre"
echo "disque dur."
echo ""
echo -n "Appuyez sur ENTRÉE pour continuer."
read BLURB;

# On installe d'abord les paquets vitaux :
for paq in base-systeme-* etc-* eglibc-* sgml-common-* ; do
	spkadd --quiet --root=${LIVEOS} ${PAQUETS}/base/${paq} 2> /dev/null
done

# On installe tout le reste sauf linux-source-* :
for paquet in $(find ${TMPMOUNT}/0/paquets -type f \( -name "*.cpio" -a \! -name "linux-source-*" \) | sort) ; do
	spkadd --quiet --root=${SETUPROOT} ${paquet} 2> /dev/null
done

# Les sources de Linux en dernier (appel à 'make' en post-installation, donc
# de nombreuses dépendances) :
spkadd --quiet --root=${SETUPROOT} ${TMPMOUNT}/0/paquets/base/linux-source-* 2> /dev/null

# C'est fini !
