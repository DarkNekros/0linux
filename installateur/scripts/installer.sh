#!/usr/bin/env bash
unset BLURB

# Quelques vérif' avant l'installation des paquets. '/var/log/mount' doit
# à ce stade contenir le répertoire '0' et les paquets résidents : 
if [ ! -d /var/log/mount}/0/paquets/base ]; then
	echo "Erreur fatale : '/var/log/mount' ne contient pas les paquets !"
	echo "Ce répertoire doit contenir le sous-répertoire '0/paquets'."
	echo "Je vais devoir abandonner..."
	sleep 3
	exit 1
elif [ ! -d ${SETUPROOT} ]; then
	echo "Erreur fatale : le répertoire accueillant la future racine système,"
	echo "'${SETUPROOT}', est introuvable !"
	echo "Ce répertoire doit exister. Je vais devoir abandonner..."
	sleep 3
	exit 1
fi

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
	spkadd --about /var/log/mount/0/paquets/base/${paq}
	spkadd --root=${SETUPROOT} /var/log/mount/0/paquets/base/${paq} &>/dev/null 2>&1
done

# On installe tout le reste sauf linux-source-*, qu'on installe en dernier :
for paquet in $(find /var/log/mount/0/paquets -type f \( -name "*.cpio" \
	-a \! -name "base-systeme*" \
	-a \! -name "etc*" \
	-a \! -name "eglibc*" \
	-a \! -name "sgml*" \
	-a \! -name "linux-source*" \) | sort) ; do
	spkadd --about ${paquet}
	spkadd --root=${SETUPROOT} ${paquet} &>/dev/null 2>&1
done

# Les sources de Linux (appel à 'make' en post-installation, donc de
# nombreuses dépendances) :
spkadd --about /var/log/mount/0/paquets/base/linux-source-*
spkadd --root=${SETUPROOT} /var/log/mount/0/paquets/base/linux-source-* &>/dev/null 2>&1

# C'est fini !
