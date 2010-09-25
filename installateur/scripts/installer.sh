#!/bin/env bash

clear
echo -e "\033[1;32mInstallation des paquets.\033[0;0m"
echo ""
echo "Les paquets du système 0 vont maintenant être installés sur votre"
echo "disque dur."
echo ""
echo -n "Appuyez sur ENTRÉE pour continuer."
read BLURB;

# Boucle d'installation des paquets :
for paq in base-systeme* etc* eglibc* sgml*; do
	spkman -i --quiet --root=${LIVEOS} ${PAQUETS}/base/${paq} 2> /dev/null
done

for paquet in ${TMPMOUNT}/0/paquets/*/*.* ; do
	spkman -i --quiet --root=${SETUPROOT} ${paquet} 2> /dev/null
done

# C'est fini !
