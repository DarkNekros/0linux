#!/usr/bin/env bash

# On nettoie :
unset DISPOCLAVIER

# L'emplacement des fichiers de configuration :
KEYBOARDCONFIGFILE=${SETUPROOT}/etc/0linux/clavier
XORGKEYBOARDCONFIGFILE=${SETUPROOT}/etc/X11/xorg.conf.d/90-keyboard.conf

# On définit le clavier à charger à chaque démarrage :
DISPOCLAVIER="$(cat $TMP/choix_clavier)"
if [ ! "${DISPOCLAVIER}" = "" ]; then
	# On crée le fichier de configuration au cas où :
	if [ ! -r ${KEYBOARDCONFIGFILE} ]; then
		echo "# Ce fichier détermine la disposition des touches du clavier en" >> ${KEYBOARDCONFIGFILE}
		echo "# mode console parmi celles disponibles dans le répertoire" >> ${KEYBOARDCONFIGFILE}
		echo "# '/usr/share/kbd/keymaps/i386'." >> ${KEYBOARDCONFIGFILE}
		echo "CLAVIER=" >> ${KEYBOARDCONFIGFILE}
	fi
	
	# On le met à jour selon ce qu'on y trouve :
	if [ ! "$(grep -E '^CLAVIER=' ${KEYBOARDCONFIGFILE})" = "" ]; then
		sed -i -e "s@^CLAVIER=.*@CLAVIER=${CHOIXCLAVIER}@" ${KEYBOARDCONFIGFILE}
	else
		echo "CLAVIER=${CHOIXCLAVIER}" >> ${KEYBOARDCONFIGFILE}
	fi
fi

# On modifie la configuration pour y insérer le clavier à charger sous X :
if [ -r ${XORGKEYBOARDCONFIGFILE} ]; then
	DISPOCLAVIERXORG="$(cat $TMP/choix_clavier_xorg)"
	if [ ! "${DISPOCLAVIERXORG}" = "" ]; then
		sed -i "s@Option \"xkb_layout\" \"us\"@Option \"xkb_layout\" \"${DISPOCLAVIERXORG}\"@" ${XORGKEYBOARDCONFIGFILE}
	fi
fi

# On lance un à un les scripts de configuration pour finaliser l'installation :

# Paramétrage de l"horloge système :
echo "Exécution de :"
echo "	chroot ${SETUPROOT} 0horloge"
sleep 2
chroot ${SETUPROOT} 0horloge

# Paramétrage de la « locale » :
echo "Exécution de :"
echo "	chroot ${SETUPROOT} 0locale"
sleep 2
chroot ${SETUPROOT} 0locale

# Paramétrage de la police console :
echo "Exécution de :"
echo "chroot ${SETUPROOT} 0police"
sleep 2
chroot ${SETUPROOT} 0police

# Paramétrage du réseau :
echo "Exécution de :"
echo "	chroot ${SETUPROOT} 0reseau"
sleep 2
chroot ${SETUPROOT} 0reseau

# Configuration du chargeur d'amorçage :
. bootconfig.sh

# On demande à configurer le démarrage graphique et le bureau :
echo "Exécution de :"
echo "	chroot ${SETUPROOT} 0bureau"
sleep 2
chroot ${SETUPROOT} 0bureau

# On définit un mot de passe pour root :
. motdepasseroot.sh

# On crée un nouvel utilisateur :
echo "Exécution de :"
echo "	chroot ${SETUPROOT} 0nouvel_utilisateur"
sleep 2
chroot ${SETUPROOT} 0nouvel_utilisateur

# C'est fini.
