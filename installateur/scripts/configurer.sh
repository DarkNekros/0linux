#!/usr/bin/env bash
# Certains scripts ont besoin de /proc, /sys et /dev :
if [ ! "${SETUPROOT}" = "/" ]; then
	mkdir -p ${SETUPROOT}/{proc,sys}
	mount --bind /proc ${SETUPROOT}/proc 1> /dev/null 2> /dev/null
	mount --bind /sys ${SETUPROOT}/sys 1> /dev/null 2> /dev/null
	mount --bind /dev ${SETUPROOT}/dev 1> /dev/null 2> /dev/null
fi

# On définit le clavier à charger à chaque démarrage :
DISPOCLAVIER="$(cat $TMP/choix_clavier)"
if [ ! "${DISPOCLAVIER}" = "" ]; then
	mkdir -p ${SETUPROOT}/etc/rc.d
	touch ${SETUPROOT}/etc/rc.d/rc.keymap
	echo "#!/usr/bin/env bash" >> ${SETUPROOT}/etc/rc.d/rc.keymap
	echo "# Chargement de la disposition des touches du clavier." >> ${SETUPROOT}/etc/rc.d/rc.keymap
	echo "# Les dispositions se trouvent dans '/lib/kbd/keymaps'." >> ${SETUPROOT}/etc/rc.d/rc.keymap
	echo "loadkeys --quiet ${DISPOCLAVIER}" >> ${SETUPROOT}/etc/rc.d/rc.keymap
	echo "" >> ${SETUPROOT}/etc/rc.d/rc.keymap
	chmod 755 ${SETUPROOT}/etc/rc.d/rc.keymap
fi

# On modifie 'evdev.conf' pour y insérer le clavier à charger sous X :
DISPOCLAVIERXORG="$(cat $TMP/choix_clavier_xorg)"
if [ ! "${DISPOCLAVIERXORG}" = "" ]; then
	sed -i "s@Option \"xkb_layout\" \"\"@Option \"xkb_layout\" \"${DISPOCLAVIERXORG}\"@" ${SETUPROOT}/etc/X11/xorg.conf.d/evdev.conf
fi

# On lance un à un les scripts de configuration pour finaliser l'installation :

# '0horloge' gère seul la racine et $SETUPROOT :
. 0horloge

# Paramétrage de la « locale » :
chroot ${SETUPROOT} 0locale

# Paramétrage de la police console :
chroot ${SETUPROOT} 0police

# Configuration du réseau :
chroot ${SETUPROOT} 0reseau

# Configuration du chargeur d'amorçage :
. bootconfig.sh 

# On demande à configurer le démrrage graphique et le bureau :
chroot ${SETUPROOT} 0bureau

# On définit un mot de passe pour root :
. motdepasseroot.sh

# On crée un nouvel utilisateur :
chroot ${SETUPROOT} 0nouvel_utilisateur

# C'est fini !

