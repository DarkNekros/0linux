#!/usr/bin/env bash

# On nettoie :
rm -f $TMP/choix_media
unset DETECTSELECT DETECTEDISO ISOSELECT

# On cherche un répertoire 'paquets' :
DETECTEDISO="$(find / -type f -name \"*.iso\" -o -name \"*.img\" -o -name \"*.bin\" -print)"

demander_choix_iso() {
	while [ 0 ]; do
		clear
		echo -e "\033[1;32mSaisie de l'emplacement du fichier ISO.\033[0;0m"
		echo ""
		echo "Veuillez entrer ci-dessous le chemin du fichier-image contenant le"
		echo "dépôt de paquets (0/paquets/base/, 0/paquets/opt/, etc.)"
		echo "L'emplacement spécifié doit désigner le chemin absolu du fichier."
		echo ""
		echo "Exemples : /mnt/tmp/mes_fichiers/0linux-beta14-DVD.iso"
		echo "           /sauvegarde/0/iso_dvd/perso-0linux-alpha4-DVD.img"
		echo "           /img/0/0.bin"
		echo ""
		echo -n "Votre choix : "
		read ISOSELECT;
		if [ "${ISOSELECT}" = "" ]; then
			echo "Veuillez entrer un emplacement valide."
			sleep 2
			unset ISOSELECT
			continue
		else
			if [ -r ${ISOSELECT} ]; then
				# On monte l'image et on crée un fichier 'choix_media' vide :
				mount -o loop ${ISOSELECT} /var/log/mount
				touch $TMP/choix_media
				break
			else
				echo "Ce fichier est introuvable. Veuillez recommencer"
				sleep 2
				unset ISOSELECT
				continue
			fi
		fi
	done
}

# Si l'on trouve un seul fichier-image :
if [ "$(echo ${DETECTEDISO} | wc -l)" -eq 1 ]; then
	clear
	echo -e "\033[1;32mUn fichier-image a été détecté !\033[0;0m"
	echo ""
	echo "Un unique fichier-image a été détecté à cet emplacement :"
	echo ""
	echo ${DETECTEDISO}
	echo ""
	echo "Si ce fichier vous convient, tapez « oui », sinon appuyez sur ENTRÉE pour"
	echo "ignorer cette étape."
	echo ""
	echo -n "Votre choix : "
	read DETECTSELECT;
	# On crée un lien et un fichier 'choix_media' vide si le choix est accepté :
	if [ "${DETECTSELECT}" = "oui" ]; then
		mount -o loop ${DETECTEDISO} /var/log/mount
		touch $TMP/choix_media
	else
		demander_choix_iso
	fi
# Sinon :
else
	demander_choix_iso
fi

# C'est fini !
