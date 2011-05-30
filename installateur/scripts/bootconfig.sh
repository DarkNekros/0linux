#!/usr/bin/env bash

# On nettoie  :
unset BOOTERINST BLAHH PARTTABLE WINBOOT WINDISK

# Cette fonction supprime les espaces superflus via 'echo' :
crunch() {
	read STRING;
	echo $STRING;
}

# Boucle d'affichage pour l'installation du chargeur d'amorçage :
while [ 0 ]; do
	clear
	echo -e "\033[1;32mInstallation du chargeur d'amorçage Extlinux.\033[0;0m"
	echo ""
	echo "Voulez-vous installer le chargeur d'amorçage Extlinux sur votre"
	echo "partition racine $(cat $TMP/partition_racine) ?"
	echo "N.B.: ceci n'altèrera pas votre bloc d'amorçage principal (MBR)."
	echo ""
	echo "1 : Installer Extlinux sur la partition racine  $(cat $TMP/partition_racine)"
	echo "2 : Voir comment configurer d'autres chargeurs d'amorçage pour amorcer 0"
	echo "3 : Ignorer l'installation d'Extlinux et revenir au menu principal"
	echo ""
	echo -n "Votre choix : "
	read BOOTERINST;
	if [ "$BOOTERINST" = "3" ]; then
		break
	elif [ "$BOOTERINST" = "2" ]; then
		clear
		echo -e "\033[1;32mInformations pour la configuration de l'amorçage de 0.\033[0;0m"
		echo ""
		echo "Voici les informations qui vous permettront de configurer d'autres chargeurs"
		echo "d'amorçage (GRUB, GRUB2, LILO, etc.) pour pouvoir amorcer 0 :"
		echo ""
		echo "Votre installation de 0 se trouve sur la partition $(cat $TMP/partition_racine)."
		echo "Le noyau par défaut de 0 est le fichier '/boot/vmlinuz'."
		echo "Les paramètres obligatoires à passer au noyau sont 'vt.default_utf8=1'."
		echo "Il n'y a aucun disque mémoire initial ou image « initrd » à lancer."
		echo "Le système doit être lancé en lecture seule (read-only, ro, etc.)"
		echo ""
		echo "Notez ces informations et appuyez sur ENTRÉE pour continuer."
		read BLAHH;
		continue
	elif [ "$BOOTERINST" = "1" ]; then
		# On remplace le marqueur « ROOTPART » dans 'extlinux.conf' par la racine  :
		sed -i "s@ROOTPART@$(cat $TMP/partition_racine | crunch)@" ${SETUPROOT}/boot/extlinux/extlinux.conf
		
		# On demande si l'on doit écraser le MBR :
		clear
		echo -e "\033[1;32mÉcrasement du bloc d'amorçage principal.\033[0;0m"
		echo ""
		echo "Voulez-vous écraser le bloc d'amorçage principal (ou « MBR »)"
		echo "de votre premier disque dur afin qu'Extlinux prenne en charge"
		echo "vos différents systèmes ?"
		echo "N.B.: ceci écrasera votre ancien MBR de façon irréversible."
		echo "Appuyez sur ENTRÉE pour ignorer cette étape."
		echo ""
		echo -n "Votre choix (oui/non) : "
		read MBRINSTALL;
		if [ ! "${MBRINSTALL}" = "oui" ]; then
			break
		else
			# On écrase le MBR sans aucun scrupule :
			cat /usr/share/syslinux/mbr.bin > $(cat $TMP/partition_racine | crunch | cut -b1-8)
			
			# Si le MBR est occupé par Extlinux, alors on en profite pour ajouter d'autres « OS » :
			
			# On ajoute un éventuel système Windows :
			if [ "$(fdisk -l | grep -i -E 'Win9|NTFS|W95 F|FAT' | grep -v tendue | grep '*' | \
				grep -v $(cat $TMP/choix_media) 2> /dev/null | wc -l)" -gt "0" ]; then
				clear
				echo -e "\033[1;32mPartitions DOS/Windows amorçables détectées.\033[0;0m"
				echo ""
				echo "Vous disposez de partitions amorçables de type DOS/Windows."
				echo "Voulez-vous ajouter les informations concernant DOS/Windows à Extlinux"
				echo "afin de pouvoir amorcer ce type de système ? Tapez la partition souhaitée"
				echo "figurant dans la liste suivante ou appuyez sur ENTRÉE pour ignorer :"
				echo "Exemples : /dev/sda2 ; /dev/sdb4 : /dev/sdf5 ; etc."
				echo ""
				# On affiche les partitions FAT/NTFS sauf l'éventuelle clé USB montée pour
				# l'installation (donc amorçable) :
				fdisk -l | grep -i -E 'Win9|NTFS|W95 F|FAT' | grep -v tendue | grep '*' \
					| crunch | cut -d' ' -f1 | grep -v $(cat $TMP/choix_media) 2> /dev/null
				echo ""
				echo -n "Votre choix : "
				read WINBOOT;
				if [ "${WINBOOT}" = "" ]; then
					# On ne fait rien
					break
				else
					# On fait confiance à la réponse de l'utilisateur et on détecte quel disque est
					# utilisé. On en teste 6 :
					if [ "$(echo WINBOOT | cut -b8)" = "a" ]; then
						WINDISK="0"
					elif [ "$(echo ${WINBOOT} | cut -b8)" = "b" ]; then
						WINDISK="1"
					elif [ "$(echo ${WINBOOT} | cut -b8)" = "c" ]; then
						WINDISK="2"
					elif [ "$(echo ${WINBOOT} | cut -b8)" = "d" ]; then
						WINDISK="3"
					elif [ "$(echo ${WINBOOT} | cut -b8)" = "e" ]; then
						WINDISK="4"
					elif [ "$(echo ${WINBOOT} | cut -b8)" = "f" ]; then
						WINDISK="5"
					else
						WINDISK=""
						echo "Réponse probablement erronée. La prise en charge de DOS/Windows sera ignorée."
						sleep 2
					fi
						
					# On remplit le fichier de config' pour Windows:
					if [ ! "${WINDISK}" = "" ]; then
						echo "# Entrée pour Windows :" >> ${SETUPROOT}/boot/extlinux/extlinux.conf
						echo "LABEL windows" >> ${SETUPROOT}/boot/extlinux/extlinux.conf
						echo "	MENU LABEL Windows" >> ${SETUPROOT}/boot/extlinux/extlinux.conf
						echo "	KERNEL chain.c32" >> ${SETUPROOT}/boot/extlinux/extlinux.conf
						echo "	APPEND hd${WINDISK} $(echo ${WINBOOT} | cut -b9)" >> ${SETUPROOT}/boot/extlinux/extlinux.conf
						echo "" >> ${SETUPROOT}/boot/extlinux/extlinux.conf
					fi
				fi
			fi
			
			# Il est temps d'installer Extlinux :
			echo "Installation de Extlinux..."
			chmod +x ${SETUPROOT}/boot/extlinux/*.c32
			extlinux --install ${SETUPROOT}/boot/extlinux
			break
		fi
	else
		echo "Veuillez entrer un chiffre entre 1 et 3 uniquement"
		sleep 2
		unset BOOTERINST
		continue
	fi
done

# C'est fini !
