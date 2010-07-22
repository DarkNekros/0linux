#!/bin/env bash
# Certains scripts ont besoin de /proc et /sys :
if [ ! "${SETUPROOT}" = "/" ]; then
	mkdir -p ${SETUPROOT}/{proc,sys}
	mount --bind /proc ${SETUPROOT}/proc 1> /dev/null 2> /dev/null
	mount --bind /sys ${SETUPROOT}/sys 1> /dev/null 2> /dev/null
fi

# On définit le clavier à charger à chaque démarrage :
if [ -r $TMP/choix_clavier ]; then
	DISPOCLAVIER="`cat $TMP/choix_clavier`"
	
	echo "#!/bin/env bash" > ${SETUPROOT}/etc/rc.d/rc.keymap
	echo "# Chargement de la disposition des touches du clavier. Les dispositions se trouvent dans /lib/kbd/keymaps." \
		>> ${SETUPROOT}/etc/rc.d/rc.keymap
	echo "if [ -x /usr/bin/loadkeys ]; then" >> ${SETUPROOT}/etc/rc.d/rc.keymap
	echo "	/usr/bin/loadkeys ${DISPOCLAVIER}" >> ${SETUPROOT}/etc/rc.d/rc.keymap
	echo "fi" >> ${SETUPROOT}/etc/rc.d/rc.keymap
	
	chmod 755 ${SETUPROOT}/etc/rc.d/rc.keymap
fi

# Message d'entrée dans la configuration du système :
preparingtoconfig

sleep 1

if [ -d ${SETUPROOT}/var/log/setup ]; then
	
	for postconfig in ${SETUPROOT}/var/log/setup/setup.* ; do
		postconfigscript=$(basename ${postconfig})
		
		# On appelle chaque script nommé '/var/log/setup/setup.*'. En arguments :
		# D'abord la cible, $SETUPROOT, puis le périphérique actuel de la racine
		# stockée dans '$TMP/partition_racine'.
		if [ -x ${SETUPROOT}/var/log/setup/${postconfigscript} ]; then
			. ${SETUPROOT}/var/log/setup/${postconfigscript} ${SETUPROOT} $(cat $TMP/partition_racine)
		fi
	
	done

fi

# On définit un mot de passe pour root le cas échéant :
. motdepasseroot.sh

# C'est fini !

