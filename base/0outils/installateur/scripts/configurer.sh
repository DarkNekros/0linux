#!/usr/bin/env bash

# On nettoie :
unset DISPOCLAVIER

# On définit le clavier à charger à chaque démarrage :
DISPOCLAVIER="$(cat $TMP/choix_clavier)"
if [ ! "${DISPOCLAVIER}" = "" ]; then
	if [ ! -r ${SETUPROOT}/etc/vconsole.conf ]; then
		echo "# Ce fichier détermine la police à utiliser en mode console, parmi celles" >> /etc/vconsole.conf
		echo "# disponibles dans '/usr/share/kbd/consolefonts', ainsi que la disposition" >> /etc/vconsole.conf
		echo "des touches du clavier en mode console, parmi celles disponibles dans"
		echo "'/usr/share/kbd/keymaps/i386'."
		echo "FONT=" >> ${SETUPROOT}/etc/vconsole.conf
		echo "KEYMAP=" >> ${SETUPROOT}/etc/vconsole.conf
	fi
	
	# On le met à jour selon ce qu'on y trouve :
	if [ ! "$(grep -E '^KEYMAP=' /etc/vconsole.conf)" = "" ]; then
		sed -i -e "s@^KEYMAP=.*$@KEYMAP=${DISPOCLAVIER}@" ${SETUPROOT}/etc/vconsole.conf
	else
		echo "KEYMAP=${DISPOCLAVIER}" >> ${SETUPROOT}/etc/vconsole.conf
	fi
fi

# On modifie '90-keyboard.conf' pour y insérer le clavier à charger sous X :
if [ -r ${SETUPROOT}/etc/X11/xorg.conf.d/90-keyboard.conf ]; then
	DISPOCLAVIERXORG="$(cat $TMP/choix_clavier_xorg)"
	if [ ! "${DISPOCLAVIERXORG}" = "" ]; then
		sed -i -e "s@Option \"xkb_layout\".*$@Option \"xkb_layout\" \"${DISPOCLAVIERXORG}\"@" ${SETUPROOT}/etc/X11/xorg.conf.d/90-keyboard.conf
	fi
fi

# On lance un à un les scripts de configuration pour finaliser l'installation :

# Paramétrage de l"horloge système :
chroot ${SETUPROOT} 0horloge

# Paramétrage de la « locale » :
chroot ${SETUPROOT} 0locale

# Paramétrage de la police console :
chroot ${SETUPROOT} 0police

# Paramétrage du réseau :
chroot ${SETUPROOT} 0reseau

# Activation des services systemd réseau et système :
chroot ${SETUPROOT} systemctl enable acpid          >/dev/null 2>&1
chroot ${SETUPROOT} systemctl enable avahi-daemon   >/dev/null 2>&1
chroot ${SETUPROOT} systemctl enable avahi-dnsconfd >/dev/null 2>&1
chroot ${SETUPROOT} systemctl enable cups           >/dev/null 2>&1
chroot ${SETUPROOT} systemctl enable dhcpcd         >/dev/null 2>&1
chroot ${SETUPROOT} systemctl enable getty@.service >/dev/null 2>&1
chroot ${SETUPROOT} systemctl enable gpm            >/dev/null 2>&1
chroot ${SETUPROOT} systemctl enable sshd           >/dev/null 2>&1
chroot ${SETUPROOT} systemctl enable syslog-ng      >/dev/null 2>&1
chroot ${SETUPROOT} systemctl enable upower         >/dev/null 2>&1
chroot ${SETUPROOT} systemctl enable udisks         >/dev/null 2>&1
chroot ${SETUPROOT} systemctl enable wicd           >/dev/null 2>&1

# Configuration du chargeur d'amorçage :
. bootconfig.sh 

# On demande à configurer le démarrage graphique et le bureau :
chroot ${SETUPROOT} 0bureau

# On définit un mot de passe pour root :
. motdepasseroot.sh

# On crée un nouvel utilisateur :
chroot ${SETUPROOT} 0nouvel_utilisateur

# C'est fini !
