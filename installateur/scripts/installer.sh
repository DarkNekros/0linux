#!/usr/bin/env bash

# On nettoie :
unset BLURB DIR0

# Tout devrait maintenant être bien en place, '/var/log/mount contenant les paquets.
# On cherche le répertoire contenant tous les paquets et dépôts :
DIR0=$(dirname $(find /var/log/mount -type d -name "base"))

clear
echo -e "\033[1;32mInstallation des paquets.\033[0;0m"
echo ""
echo "Les paquets du système 0 vont maintenant être installés sur votre"
echo "disque dur."
echo ""
echo -n "Appuyez sur ENTRÉE pour continuer."
read BLURB;

# On installe d'abord les paquets vitaux de 'base/':
for paq in base-systeme* etc* eglibc* sgml* ; do
	spackadd --about ${DIR0}/base/${paq}
	spackadd --root=${SETUPROOT} ${DIR0}/base/${paq} &>/dev/null 2>&1
done

# On installe tout le reste de 'base/' 'opt/' et xorg/  sauf linux-source*, qu'on installe en dernier :
for subdir0 in base opt xorg; do
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

# C'est fini !
