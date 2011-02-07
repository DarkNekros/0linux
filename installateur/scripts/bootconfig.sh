#!/usr/bin/env bash

# On nettoie  :
unset GRUBINST BLAHH GRUBTABLE WINBOOT WINDISK

# Cette fonction supprime les espaces superflus via 'echo' :
crunch() {
	read STRING;
	echo $STRING;
}

# Boucle d'affichage pour les formatages et montages des partitions choisies : :
while [ 0 ]; do
	clear
	echo -e "\033[1;32mInstallation du chargeur d'amorçage GRUB.\033[0;0m"
	echo ""
	echo "Voulez-vous installer le chargeur d'amorçage GRUB2 sur le bloc"
	echo "d'amorçage principal (ou « MBR ») de votre premier disque dur ?"
	echo "N.B.: Tout ancien MBR sera écrasé !"
	echo ""
	echo "1 : Installer GRUB2 sur le MBR de $(cat $TMP/partition_racine | crunch | cut -b1-8)"
	echo "2 : Voir comment configurer d'autres chargeurs d'amorçage pour amorcer 0"
	echo "3 : Ignorer l'installation de GRUB2 et revenir au menu principal"
	echo ""
	echo -n "Votre choix : "
	read GRUBINST;
	if [ "$GRUBINST" = "3" ]; then
		break
	elif [ "$GRUBINST" = "2" ]; then
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
		break
	elif [ "$GRUBINST" = "1" ]; then
		# On remplace le '/dev/sda1' pour 0 par la racine dans le fichier de config' :
		sed -i "s@/dev/sda1 ro vt.default_utf8=1@$(cat $TMP/partition_racine | crunch) ro vt.default_utf8=1@" ${SETUPROOT}/etc/grub.d/40_custom
		
		# On ajoute un éventuel système Windows :
		if [ "$(fdisk -l | grep -E 'Win9|NTFS|W95 F|FAT' | grep -v tendue | grep '*' 2> /dev/null | wc -l)" -gt "0" ]; then
			clear
			echo -e "\033[1;32mPartitions DOS/Windows amorçables détectées.\033[0;0m"
			echo ""
			echo "Vous disposez de partitions amorçables de type DOS/Windows."
			echo "Voulez-vous ajouter les informations concernant DOS/Windows à GRUB2"
			echo "afin de pouvoir amorcer ce type de système ? Tapez la partition souhaitée"
			echo "figurant dans la liste suivante ou appuyez sur ENTRÉE pour ignorer :"
			echo ""
			fdisk -l | grep -E 'Win9|NTFS|W95 F|FAT' | grep -v tendue | grep '*' | crunch | cut -d' ' -f1 2> /dev/null
			echo ""
			echo -n "Votre choix : "
			read WINBOOT;
			if [ "$WINBOOT" = "" ]; then
				# On ne fait rien
				break
			else
				# On fait confiance à la réponse de l'utilisateur et on détecte quel disque est
				# utilisé. On en teste 6 :
				if [ "$(echo WINBOOT | cut -b8)" = "a" ]; then
					WINDISK="0"
				elif [ "$(echo WINBOOT | cut -b8)" = "b" ]; then
					WINDISK="1"
				elif [ "$(echo WINBOOT | cut -b8)" = "c" ]; then
					WINDISK="2"
				elif [ "$(echo WINBOOT | cut -b8)" = "d" ]; then
					WINDISK="3"
				elif [ "$(echo WINBOOT | cut -b8)" = "e" ]; then
					WINDISK="4"
				elif [ "$(echo WINBOOT | cut -b8)" = "f" ]; then
					WINDISK="5"
				else
					echo "Erreur. Réponse probablement erronée."
					break
				fi
				
				# On remplit le fichier de config' pour Windows:
				echo "# Entrée pour Windows :" >> ${SETUPROOT}/etc/grub.d/40_custom
				echo "menuentry \"Windows\" {" >> ${SETUPROOT}/etc/grub.d/40_custom
				echo "	set root=(hd${WINDISK},$(echo WINBOOT | cut -b9))" >> ${SETUPROOT}/etc/grub.d/40_custom
				echo "	chainloader +1" >> ${SETUPROOT}/etc/grub.d/40_custom
				echo "}" >> ${SETUPROOT}/etc/grub.d/40_custom
				echo "" >> ${SETUPROOT}/etc/grub.d/40_custom
			fi
		fi
		
		# Il est temps d'installer GRUB2 en chrootant sur la racine :
		echo "Installation de GRUB2..."
		chroot ${SETUPROOT} grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null
		sleep 1
		chroot ${SETUPROOT} grub-install $(cat $TMP/partition_racine | crunch | cut -b1-8) &>/dev/null 2>&1
		sleep 1
		chroot ${SETUPROOT} grub-setup $(cat $TMP/partition_racine | crunch | cut -b1-8) &>/dev/null 2>&1
		sleep 1
		break
	else
		echo "Veuillez entrer un chiffre entre 1 et 3 uniquement"
		sleep 2
		unset GRUBINST
		continue
	fi
done

# C'est fini !
