#!/usr/bin/env bash

unset ENTERPASSWD

# Si aucun mot de passe root n'est défini :
if [ "$(cat ${SETUPROOT}/etc/shadow | grep 'root:' | cut -d':' -f2)" = "" ]; then
	if [ "${INSTALLDEBUG}" = "" ]; then
		clear
	fi
	echo -e "\033[1;32mAucun mot de passe n'est défini pour « root »\033[0;0m"
	echo ""
	echo "Il n'y a actuellement aucun mot de passe défini pour le compte"
	echo "de l'administrateur « root ». Il vous faut en définir un"
	echo "maintenant afin qu'il soit actif dès le premier démarrage"
	echo "de la machine."
	echo ""
	echo -n "Appuyez sur ENTRÉE pour continuer."
	read ENTERPASSWD;
	
	# On appelle 'passwd' :
	chroot ${SETUPROOT} passwd root
fi

# C'est fini !
