#!/usr/bin/env bash
# Si aucun mot de passe root n'est défini :
if [ "`cat ${SETUPROOT}/etc/shadow | grep 'root:' | cut -f 2 -d :`" = "" ]; then
	clear
	echo -e "\033[1;32mAucun mot de passe n'est défini pour « root »\033[0;0m"
	echo ""
	echo "Il n'y a actuellement aucun mot de passe défini pour le compte"
	echo "de l'administrateur « root ». Il vous faut en définir un"
	echo "maintenant afin qu'il soit actif dès le premier démarrage"
	echo "de la machine."
	echo ""
	echo -n "Appuyez sur ENTRÉE pour continuer."
	read ENTERPASSWD;
	
	# On passe en terminal :
	clear
	chroot ${SETUPROOT} /usr/bin/passwd root
fi

# C'est fini !
