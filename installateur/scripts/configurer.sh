#!/bin/env bash
# Certains scripts ont besoin de /proc et /sys :
if [ ! "${SETUPROOT}" = "/" ]; then
	mkdir -p ${SETUPROOT}/{proc,sys}
	mount --bind /proc ${SETUPROOT}/proc 1> /dev/null 2> /dev/null
	mount --bind /sys ${SETUPROOT}/sys 1> /dev/null 2> /dev/null
fi

# Message d'introduction :
clear
echo -e "\033[1;32mConfiguration du système.\033[0;0m"
echo ""
echo "L'installation des paquets est terminée. Le système doit maintenant"
echo "être configuré."
echo ""
echo -n "Appuyez sur ENTRÉE pour continuer."
read YOP;

# On définit le clavier à charger à chaque démarrage :
echo "Ajout de « loadkeys ${DISPOCLAVIER} » pour le chargement de la disposition"
echo "du clavier dans votre fichier '/etc/rc.d/rc.keymap'..."

if [ -r $TMP/choix_clavier ]; then
	DISPOCLAVIER="`cat $TMP/choix_clavier`"
	echo "#!/bin/env bash" > ${SETUPROOT}/etc/rc.d/rc.keymap
	echo "# Chargement de la disposition des touches du clavier." >> ${SETUPROOT}/etc/rc.d/rc.keymap
	echo "# Les dispositions se trouvent dans /lib/kbd/keymaps." >> ${SETUPROOT}/etc/rc.d/rc.keymap
	echo "if [ -x /usr/bin/loadkeys ]; then" >> ${SETUPROOT}/etc/rc.d/rc.keymap
	echo "	/usr/bin/loadkeys ${DISPOCLAVIER}" >> ${SETUPROOT}/etc/rc.d/rc.keymap
	echo "fi" >> ${SETUPROOT}/etc/rc.d/rc.keymap
	echo "" >> ${SETUPROOT}/etc/rc.d/rc.keymap
	chmod 755 ${SETUPROOT}/etc/rc.d/rc.keymap
fi

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

# On définit un mot de passe pour root :
. motdepasseroot.sh

# C'est fini !

