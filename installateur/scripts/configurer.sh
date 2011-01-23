#!/usr/bin/env bash
# Certains scripts ont besoin de /proc et /sys :
if [ ! "${SETUPROOT}" = "/" ]; then
	mkdir -p ${SETUPROOT}/{proc,sys}
	mount --bind /proc ${SETUPROOT}/proc 1> /dev/null 2> /dev/null
	mount --bind /sys ${SETUPROOT}/sys 1> /dev/null 2> /dev/null
fi

if [ -r $TMP/choix_clavier ]; then
	# On définit le clavier à charger à chaque démarrage :
	DISPOCLAVIER="`cat $TMP/choix_clavier`"
	echo "#!/usr/bin/env bash" > ${SETUPROOT}/etc/rc.d/rc.keymap
	echo "# Chargement de la disposition des touches du clavier." >> ${SETUPROOT}/etc/rc.d/rc.keymap
	echo "# Les dispositions se trouvent dans /lib/kbd/keymaps." >> ${SETUPROOT}/etc/rc.d/rc.keymap
	echo "if [ -x /usr/bin/loadkeys ]; then" >> ${SETUPROOT}/etc/rc.d/rc.keymap
	echo "	/usr/bin/loadkeys ${DISPOCLAVIER}" >> ${SETUPROOT}/etc/rc.d/rc.keymap
	echo "fi" >> ${SETUPROOT}/etc/rc.d/rc.keymap
	echo "" >> ${SETUPROOT}/etc/rc.d/rc.keymap
	chmod 755 ${SETUPROOT}/etc/rc.d/rc.keymap
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


# xwmconfig?

# On définit un mot de passe pour root :
. motdepasseroot.sh

# C'est fini !

