#!/bin/env bash
unset BLURB

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
	spkadd --about ${TMPMOUNT}/0/paquets/base/${paq}
	spkadd --root=${SETUPROOT} ${TMPMOUNT}/0/paquets/base/${paq} &>/dev/null 2>&1
done

# On installe tout le reste sauf linux-source-* :
for paquet in $(find ${TMPMOUNT}/0/paquets -type f \( -name "*.cpio" -a \! -name "linux-source-*" \) | sort) ; do
	spkadd --about ${paquet}
	spkadd --root=${SETUPROOT} ${paquet} &>/dev/null 2>&1
done

# Les sources de Linux en dernier (appel à 'make' en post-installation, donc
# de nombreuses dépendances) :
spkadd --about ${TMPMOUNT}/0/paquets/base/linux-source-*
spkadd --root=${SETUPROOT} ${TMPMOUNT}/0/paquets/base/linux-source-* &>/dev/null 2>&1

# C'est fini !
