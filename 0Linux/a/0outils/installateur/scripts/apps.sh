#!/usr/bin/env bash

# On nettoie :
unset BLURB

if [ "${INSTALLDEBUG}" = "" ]; then
	clear
fi
echo -e "\033[1;32mMise à jour et dépôts supplémentaires de 0Linux\033[0;0m"
echo ""
echo "Il est temps d'installer les dépôts de votre choix. Vous allez pour cela"
echo "utiliser l'outil '0g' dans la console n°2."
echo "Une bonne chose à faire d'emblée est de mettre à jour l'ensemble de"
echo "la distribution en la synchronisant avec les serveurs officiels (une connexion"
echo "à Internet est nécessaire) puis d'installer de nouveaux dépôts (par exemple,"
echo "un bureau graphique et un navigateur Web). Les dépôt sont tous précédés"
echo "d'un arobase (« @firefox ») pour les distinguer des paquets individuels."
echo "Vous utiliserez souvent '0g', familiarisez-vous avec, il est très simple."
echo "Consultez '0g --aide' ou 'man 0g' pour en savoir plus."
echo ""
echo "Mini-guide :"
echo "-1- Passer sur votre nouveau système 0Linux :    chroot ${SETUPROOT}"
echo "-2- Mettre à jour 0Linux :                       0g"
echo "-3- Consulter la liste des dépôts disponibles :  0g --liste"
echo "-4- Voir la description d'un dépôt (ici KDE) :   0g --info @kde"
echo "-5- Installer des dépôts (ici KDE et Firefox) :  0g @kde @firefox"
echo "-6- Quitter pour revenir à l'installateur :      exit"
echo ""
echo "Quand vous avez terminé (pas avant), revenez sur cette console et apppuyez"
echo "sur ENTRÉE pour commencer la configuration de votre nouveau système Linux."
echo ""
echo "Appuyez sur ENTRÉE quand vous avez terminé avec '0g' sur une autre console."
read BLURB;

# C'est fini.
