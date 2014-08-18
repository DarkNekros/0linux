#!/usr/bin/env bash

# On nettoie  :
unset BOOTERINST BLAHH PARTTABLE BOOTDEVICE BOOTPART PARTNAME BOOTPTTYPE MBRBIN WINBOOT WHICHDISK WINDISK

# Cette fonction supprime les espaces superflus via 'echo' :
crunch() {
	read STRING;
	echo $STRING;
}

# Boucle d'affichage pour l'installation du chargeur d'amorçage :
while [ 0 ]; do
	if [ "${INSTALLDEBUG}" = "" ]; then
		clear
	fi
	echo -e "\033[1;32mInstallation du chargeur d'amorçage Extlinux.\033[0;0m"
	echo ""
	echo "Voulez-vous installer le chargeur d'amorçage Extlinux sur votre"
	echo "partition racine '$(cat $TMP/partition_racine)' ?"
	echo ""
	echo "1 : Installer Extlinux sur la partition racine $(cat $TMP/partition_racine)"
	echo "2 : Voir comment configurer d'autres chargeurs d'amorçage pour amorcer 0Linux"
	echo "3 : Ignorer l'installation d'Extlinux et revenir au menu principal"
	echo ""
	echo -n "Votre choix : "
	read BOOTERINST;
	if [ "$BOOTERINST" = "3" ]; then
		break
	elif [ "$BOOTERINST" = "2" ]; then
		if [ "${INSTALLDEBUG}" = "" ]; then
			clear
		fi
		echo -e "\033[1;32mInformations pour la configuration de l'amorçage de 0Linux.\033[0;0m"
		echo ""
		echo "Voici les informations qui vous permettront de configurer d'autres chargeurs"
		echo "d'amorçage (GRUB, LILO, etc.) pour pouvoir amorcer 0Linux :"
		echo ""
		echo "Votre installation de 0Linux se trouve sur la partition '$(cat $TMP/partition_racine)'."
		echo ""
		echo "Le noyau par défaut de 0Linux est le fichier '/boot/noyau-$(uname -r)'."
		echo "Vous pouvez spécifier le lien générique '/boot/vmlinuz' mais vérifiez"
		echo "qu'il pointe bien sur le noyau de 0Linux."
		echo ""
		echo "Le système peut être lancé en lecture seule (read-only, ro, etc.) ou pas et"
		echo "l'initrd '/boot/initrd' est nécessaire pour amorcer la racine via son"
		echo "LABEL ou son identifiant UUID. Dans le doute, spécifiez cet initrd au"
		echo "démarrage systématiquement."
		echo ""
		echo "Notez ces informations et appuyez sur ENTRÉE pour continuer."
		read BLAHH;
		continue
	elif [ "$BOOTERINST" = "1" ]; then
		
		# On va tout de suite s'occuper de l'attribut « amorçable » de la partition racine,
		# qui doit être dans le top 5 des problèmes les plus fréquents. Mais on ignore tout
		# échec :
		
		# On déduit le périphérique à amorcer.
		# Si '/boot' est sur une partition séparée, c'est elle qu'on doit activer :
		if grep '/boot' ${SETUPROOT}/etc/fstab; then
			BOOTPART="$(mount | grep '/boot' | crunch | cut -d' ' -f1)"
		
		# Sinon, on en déduit que c'est la partition racine qu'on doit activer :
		else
			BOOTPART="$(cat $TMP/partition_racine)"
		fi
		
		# On rend la partition '/' ou '/boot' active/bootable/amorçable en GPT ou MBR :
		parted ${BOOTPART} set boot on 2>/dev/null || true
		
		# On déduit l'UUID de la racine :
		ROOTFSUUID=$(blkid -p -s UUID -o value $(cat $TMP/partition_racine))
		
		# On remplace le marqueur « ROOTPART » dans 'extlinux.conf' par l'UUID :
		sed -i "s@ROOTPART@UUID=${ROOTFSUUID}@" ${SETUPROOT}/boot/extlinux/extlinux.conf
		
		# On demande si l'on doit écraser le MBR :
		if [ "${INSTALLDEBUG}" = "" ]; then
			clear
		fi
		echo -e "\033[1;32mÉcrasement du bloc d'amorçage principal.\033[0;0m"
		echo ""
		echo "Voulez-vous écraser le bloc d'amorçage principal du disque dur"
		echo "contenant 0Linux afin qu'Extlinux prenne en charge vos différents"
		echo "systèmes ?"
		echo "N.B. : ceci écrasera votre ancienne amorce de façon irréversible !"
		echo ""
		echo "Entrez « oui » pour confirmer l'écrasement ou bien appuyez sur"
		echo "ENTRÉE pour ignorer cette étape."
		echo ""
		echo -n "Votre choix (oui/non/ENTRÉE) : "
		read MBRINSTALL;
		if [ ! "${MBRINSTALL}" = "oui" ]; then
			break
		else
			
			# Le périphérique à amorcer : :
			BOOTDEVICE="$(cat $TMP/partition_racine | crunch | tr -d [0-9])"
			
			# Le type de la table de partition :
			BOOTPTTYPE=$(blkid -p -s PTTYPE -o value ${BOOTDEVICE})
			
			# On écrase le MBR sans aucun scrupule, selon la table de partitions trouvé :
			if [ "${BOOTPTTYPE}" = "gpt" ]; then
				MBRBIN=gptmbr.bin
			else
				MBRBIN=mbr.bin
			fi
			cat /usr/share/syslinux/${MBRBIN} > ${BOOTDEVICE}
			
			# Comme le MBR est occupé par Extlinux, on en profite pour ajouter d'autres « OS ».
			
			# On ajoute un éventuel système Windows :
			if [ "$(fdisk -l | grep -i -E 'Win9|NTFS|W95 F|FAT' | grep -v tendue | \
				grep -v $(cat $TMP/choix_media) 2>/dev/null | wc -l)" -gt "0" ]; then
				if [ "${INSTALLDEBUG}" = "" ]; then
					clear
				fi
				echo -e "\033[1;32mPartitions DOS/Windows détectées.\033[0;0m"
				echo ""
				echo "Vous disposez de partitions de type DOS/Windows."
				echo "Voulez-vous ajouter les informations concernant DOS/Windows à Extlinux"
				echo "afin de pouvoir amorcer ce type de système ? Entrez la partition DOS/Windows"
				echo "souhaitée figurant dans la liste suivante ou appuyez sur ENTRÉE pour ignorer :"
				echo "Exemples : /dev/sda2 ; /dev/sdb4 : /dev/sdf5 ; etc."
				echo ""
				
				# On affiche les partitions FAT/NTFS sauf l'éventuelle clé USB montée pour
				# l'installation :
				fdisk -l | grep -i -E 'Win9|NTFS|W95 F|FAT' | grep -v tendue | crunch | cut -d' ' -f1 | grep -v $(cat $TMP/choix_media) 2>/dev/null
				echo ""
				echo -n "Votre choix : "
				read WINBOOT;
				if [ "${WINBOOT}" = "" ]; then
					
					# On ne fait rien :
					break
				else
					
					# On fait confiance à la réponse de l'utilisateur et on détecte quel disque est
					# utilisé. On en teste 6 :
					WHICHDISK="$(echo ${WINBOOT} | crunch | tr -d '/dev/sd' | tr -d [0-9])"
					
					if [ "${WHICHDISK}" = "a" ]; then
						WINDISK="0"
					elif [ "${WHICHDISK}" = "b" ]; then
						WINDISK="1"
					elif [ "${WHICHDISK}" = "c" ]; then
						WINDISK="2"
					elif [ "${WHICHDISK}" = "d" ]; then
						WINDISK="3"
					elif [ "${WHICHDISK}" = "e" ]; then
						WINDISK="4"
					elif [ "${WHICHDISK}" = "f" ]; then
						WINDISK="5"
					else
						WINDISK=""
						echo "Erreur : impossible d'identifier la partition ou réponse"
						echo "erronée. La prise en charge de DOS/Windows sera ignorée."
						sleep 2
					fi
						
					# On remplit le fichier de config' pour Windows:
					if [ ! "${WINDISK}" = "" ]; then
						echo "" >> ${SETUPROOT}/boot/extlinux/extlinux.conf
						echo "# Windows :" >> ${SETUPROOT}/boot/extlinux/extlinux.conf
						echo "LABEL windows" >> ${SETUPROOT}/boot/extlinux/extlinux.conf
						echo "	MENU LABEL Windows" >> ${SETUPROOT}/boot/extlinux/extlinux.conf
						echo "	KERNEL chain.c32" >> ${SETUPROOT}/boot/extlinux/extlinux.conf
						echo "	APPEND hd${WINDISK} $(echo ${WINBOOT} | crunch | sed 's/\/dev\/sd.//')" >> ${SETUPROOT}/boot/extlinux/extlinux.conf
						echo "" >> ${SETUPROOT}/boot/extlinux/extlinux.conf
					fi
				fi
			fi
			
			# Il est temps d'installer Extlinux :
			echo "Installation de Extlinux... "
			echo "	extlinux --install ${SETUPROOT}/boot/extlinux"
			extlinux --install ${SETUPROOT}/boot/extlinux
			sleep 2
			
			# Vraiment pour être sûr... :) :
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
