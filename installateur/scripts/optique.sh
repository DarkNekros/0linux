#!/usr/bin/env bash

# On nettoie :
rm -f $TMP/choix_media
unset METHODE DIR BASE DIR0 DISKSELECT BLAH

# Boucle d'affichage du menu :
while [ ! -r $TMP/choix_media ]; do
	clear
	echo -e "\033[1;32mSaisie du périphérique optique.\033[0;0m"
	echo ""
	echo "Entrez ci-dessous le code de la méthode de détection pour le lecteur"
	echo "optique :"
	echo ""
	echo "1 : AUTOMATIQUE - détecter le lecteur contenant un média d'installation"
	echo "2 : MANUELLE - saisir manuellement le périphérique optique"
	echo "3 : ANNULER - retourner au menu principal"
	echo ""
	echo -n "Votre choix : "
	read METHODE;
	case "$METHODE" in
	"1")
		echo "Recherche d'un lecteur optique contenant un média d'installation..."
		# On recherche les lecteurs IDE :
		for optique in /dev/hd*; do
			mount -o ro -t iso9660 ${optique} /var/log/mount 2> /dev/null
			
			# Périphérique trouvé :
			if [ $? = 0 ]; then
				echo "Un disque a été trouvé dans ${optique} !"
				echo ${optique} > $TMP/choix_media
				sleep 2
				break
			fi
		done
		
			
		# On recherche les lecteurs SCSI/SATA :
		for optique in /dev/sr{0,1,2,3}; do
			mount -o ro -t iso9660 ${optique} /var/log/mount 2> /dev/null
			
			# Périphérique trouvé :
			if [ $? = 0 ]; then
				echo "Un disque a été trouvé dans ${optique} !"
				echo ${optique} > $TMP/choix_media
				sleep 2
				break
			fi
		done
	;;
	"2")
		while [ 0 ]; do
			clear
			echo -e "\033[1;32mSaisie du périphérique optique.\033[0;0m"
			echo ""
			echo "Dans la console n°2, utilisez au choix les outils suivants pour"
			echo "déterminer le périphérique optique contenant les paquets à installer :"
			echo ""
			echo "		# cfdisk"
			echo "		# fdisk -l"
			echo ""
			echo "Puis, entrez ci-dessous le périphérique optique concerné."
			echo "Exemples : /dev/hdc ; /dev/sr0 ; etc."
			echo ""
			echo -n "Votre choix : "
			read DISKSELECT;
			# Si l'utilisateur ne saisit pas un périph' de la forme « /dev/**** » :
			if [ "$(echo ${DISKSELECT} | sed -e 's/\(\/dev\/\).*$/\1/')" = "" ]; then
				echo "Veuillez entrer un périphérique de la forme « /dev/xxxx »."
				sleep 2
				unset DISKSELECT
				continue
			else
				# On monte le périphérique :
				echo "Montage en cours du périphérique ${DISKSELECT} dans /var/log/mount..."
				mount -o ro ${DISKSELECT} /var/log/mount 2> /dev/null
				
				# Si le volume contient un répertoire 'base/', lequel contient un paquet
				# 'eglibc' alors on considère qu'on tient là notre support d'installation :
				DIRBASE=$(find /var/log/mount -type d -name "base" -print 2>/dev/null)
				if [ ! "${DIRBASE}" = "" ]; then
					DIR0=$(basename $(dirname ${DIRBASE}))
					if [ ! "$(find ${DIR0}/base -type f -name 'eglibc-*')" = "" ]; then
						echo ${DISKSELECT} > $TMP/choix_media
						echo "Un dépôt de paquets a été trouvé sur ce volume !"
						sleep 2
						break
					else
						echo "Ce périphérique ne contient pas de dépôt des paquets : j'ai recherché"
						echo "le répertoire 'base/' et son paquet 'eglibc-*', en vain. Démontage..."
						sleep 4
						umount /var/log/mount 1> /dev/null 2> /dev/null
						continue
					fi
				fi
			fi
		done
	;;
	"3")
		break
	;;
	*)
		echo "Veuillez entrer un numéro valide (entre 1 et 2)."
		sleep 2
		continue
	esac
done

# C'est fini !
