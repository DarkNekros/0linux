#!/usr/bin/env bash
# Voyez le fichier LICENCES pour connaître la licence de ce script.

set -e

# On définit $TMP :
TMP=/var/log/setup/tmp
mkdir -p $TMP

# On nettoie toutes les variables et le fichier temporaire :
unset CONTINUEINSTALL LILOROOT RACINE KEYTAB RESOFB USERPARAMS LILOINSTALL 
unset CIBLE WINBOOT WINTABLE LINUXBOOT LINUX NOYAU USERKERNEL CONFIRMINSTALL OK BLAH
rm -f $TMP/lilo.conf

# Si un répertoire existant est donné en argument, on en fait notre racine destinataire :
if [ ! "$1" = "" ]; then
	if [ -d "$1" ]; then
		LILOROOT="$1"
	fi
else
	LILOROOT="/"
fi

# La racine destinataire :
RACINE=$(cat $TMP/partition_racine)

# Boucle principale. Tant que $LILOINSTALLED n'est pas à "OK", on continue la boucle :
while [ ! "${LILOINSTALLED}" = "OK" ]; do

	while [ 0 ]; do
		clear
		echo -e "\033[1;32mInstallation du chargeur d'amorçage.\033[0;0m"
		echo ""
		echo "0 utilise LILO pour amorcer les systèmes d'exploitation présents"
		echo "sur la machine. Ce programme va configurer et installer LILO sur"
		echo "votre système."
		echo ""
		echo -n "Souhaitez-vous continuer (oui/non) ? "
		read CONTINUEINSTALL;
		if [ "${CONTINUEINSTALL}" = "oui" ]; then
			break
		elif [ "${CONTINUEINSTALL}" = "non" ]; then
			LILOINSTALLED="OK"
			break
		else
			echo "Veuillez répondre par « oui » ou par « non » uniquement."
			sleep 2
		fi
	done
	
	# Configuration de la disposition de clavier à charger dans LILO :
	while [ 0 ]; do
		clear
		echo -e "\033[1;32mChoix du clavier dans LILO.\033[0;0m"
		echo "Veuillez entrer ci-dessous le fichier de la disposition de clavier"
		echo "francophone que vous désirez charger dans LILO lors de l'amorçage :"
		echo "be.ktl : clavier belge"
		echo "cf.ktl : clavier canadien-français"
		echo "ch.ktl : clavier suisse"
		echo "fr.ktl : clavier francais"
		echo "Appui sur ENTRÉE : aucun ; conserver le clavier QWERTY des États-Unis"
		echo -n "Votre choix : "
		read KEYTAB;
		if [ ! "$KEYTAB"  = "" ]; then
			if [ ! -r ${LILOROOT}/boot/keytables/french/${KEYTAB} ]; then
				echo "Ce fichier n'existe pas ; entrez un des fichiers figurant dans la liste."
				sleep 2
				continue;
			else
				echo "Ajout de la disposition ${KEYTAB} au fichier lilo.conf."
				touch $TMP/lilo.conf
				echo "keytable = /boot/keytables/french/${KEYTAB}" > $TMP/lilo.conf
				sleep 2
				break;
			fi
		fi
	done

	# Configuration du framebuffer  s'il est supporté :
	if cat /proc/devices | grep "29 fb" 1> /dev/null ; then
		clear
		echo -e "\033[1;32mSupport du « framebuffer ».\033[0;0m"
		echo ""
		echo "Selon votre '/proc/devices', il apparait que votre noyau supporte"
		echo "le « framebuffer », permettant d'afficher la console en haute"
		echo "résolution et un super pingouin (ou est-ce un manchot ?) à"
		echo "l'amorçage de la machine."
		echo ""
		echo -n "Appuyez sur ENTRÉE pour continuer."
		read BLAH;
		while [ 0 ]; do
			clear
			echo "Veuillez entrer le code d'affichage correspondant à la résolution"
			echo "souhaitée parmi la liste ci-dessous :"
			echo ""
			echo "799    : 1600 par 1200 pixels, 16 millions de couleurs"
			echo "798    : 1600 par 1200 pixels, 64000 couleurs"
			echo "797    : 1600 par 1200 pixels, 32000 couleurs"
			echo "796    : 1600 par 1200 pixels, 256 couleurs"
			echo "795    : 1280 par 1024 pixels, 16 millions de couleurs"
			echo "794    : 1280 par 1024 pixels, 64000 couleurs"
			echo "793    : 1280 par 1024 pixels, 32000 couleurs"
			echo "775    : 1280 par 1024 pixels, 256 couleurs"
			echo "792    : 1024 par  768 pixels, 16 millions de couleurs"
			echo "791    : 1024 par  768 pixels, 64000 couleurs"
			echo "790    : 1024 par  768 pixels, 32000 couleurs"
			echo "773    : 1024 par  768 pixels, 256 couleurs"
			echo "789    :  800 par  600 pixels, 16 millions de couleurs"
			echo "788    :  800 par  600 pixels, 64000 couleurs"
			echo "787    :  800 par  600 pixels, 32000 couleurs"
			echo "771    :  800 par  600 pixels, 256 couleurs"
			echo "786    :  640 par  480 pixels, 16 millions de couleurs"
			echo "785    :  640 par  480 pixels, 64000 couleurs"
			echo "784    :  640 par  480 pixels, 32000 couleurs"
			echo "769    :  640 par  480 pixels, 256 couleurs"
			echo "ask    : me demander la résolution à chaque amorçage"
			echo "normal : utiliser la console normale, 80 par 25 pixels"
			echo ""
			echo -n "Votre choix : "
			read RESOFB;
			if [ "$(echo ${RESOFB} | grep -E '799|798|797|796|795|794|793|775|792|791|790|773|789|788|787|771|786|785|784|769|ask|normal')" = "" ]; then
				echo "Code inconnu. Veuillez saisir une entrée figurant dans la liste."
				sleep 2
				continue
			else
				echo "Ajout de « vga = ${RESOFB} » au fichier lilo.conf."
				echo "vga = ${RESOFB}" >> $TMP/lilo.conf
				sleep 2
				break
			fi
		done
	# Le framebuffer n'est pas supporté :
	else
		echo "vga = normal" >> $TMP/lilo.conf
	fi

	# Passage de paramètres au noyau via LILO :
	clear
	echo -e "\033[1;32mParamètres du noyau.\033[0;0m"
	echo ""
	echo "Certains systèmes peuvent avoir besoin de passer des paramètres"
	echo "au noyau. C'est le moment de les entrer ci-dessous sur la même ligne"
	echo "en séparant chaque paramètre par un espace. La plupart des systèmes"
	echo "ne nécessitent aucun paramètre supplémentaire. "
	echo "Si c'est aussi votre cas, appuyez simpement sur ENTRÉE pour"
	echo "ignorer cette étape et continuer."
	echo ""
	echo -n "Vos paramètres : "
	read USERPARAMS;
	echo "append=\"${USERPARAMS} vt.default_utf8=1\"" >> $TMP/lilo.conf

	# Destination de l'installation de LILO :
	while [ 0 ]; do
		clear
		echo -e "\033[1;32mEmplacement de LILO.\033[0;0m"
		echo ""
		echo "Nous allons maintenant installer le chargeur d'amorçage LILO"
		echo "sur votre disque dur. LILO peut s'installer à deux emplacements"
		echo "différents : au début de votre partition (dans le « superblock »),"
		echo "ou bien dans le « Master Boot Record » (MBR ou bloc d'amorçage"
		echo "principal) du premier disque dur de votre machine."
		echo "Si vous disposez déjà d'un chargeur d'amorçage et que vous voulez"
		echo "le conserver, vous devrez ignorer cette étape et configurer votre"
		echo "chargeur pour amorcer le système 0."
		echo ""
		echo "1 : MBR - installer dans le MBR du premier disque dur (recommandé)"
		echo "2 : SUPERBLOCK - installer en début de partition (ne pas utiliser avec XFS)"
		echo "3 : IGNORER - ne pas installer LILO"
		echo ""
		echo -n "Votre choix : "
		read LILOINSTALL;
		case "$LILOINSTALL" in
		"1")
			echo "LILO sera installé dans le MBR."
			CIBLE="/dev/sda"
			sleep 2
			break
		;;
		"2")
			echo "LILO sera installé en début de partition."
			CIBLE="${RACINE}"
			sleep 2
			break
		;;
		"3")
			echo "LILO ne sera pas installé sur le disque dur."
			sleep 2
			break
		;;
		*)
			echo "Veuillez entrer un numéro valide (entre 1 et 3)"
			sleep 2
			unset LILOINSTALL
			continue
		;;
		esac
	done

	# On crée le fichier lilo.conf :
	echo "# Emplacement de l'amorce :" >> $TMP/lilo.conf
	echo "boot = $CIBLE" >> $TMP/lilo.conf
	echo "# Protection contre la réécriture de la table de partitions :" >> $TMP/lilo.conf
	echo "change-rules" >> $TMP/lilo.conf
	echo "	reset" >> $TMP/lilo.conf
	echo "# Nom du fichier graphique : " >> $TMP/lilo.conf
	echo "bitmap = /boot/boot-background.bmp" >> $TMP/lilo.conf
	echo "# Couleurs :" >> $TMP/lilo.conf
	echo "bmp-colors = 255,0,255,0,255,0" >> $TMP/lilo.conf
	echo "# Coordonnées du tableau :" >> $TMP/lilo.conf
	echo "bmp-table = 60,6,1,16" >> $TMP/lilo.conf
	echo "# Cooordonnées et couleurs du compte à rebours :" >> $TMP/lilo.conf
	echo "bmp-timer = 65,27,0,255" >> $TMP/lilo.conf
	echo "# Attente du compte à rebours :" >> $TMP/lilo.conf
	echo "prompt" >> $TMP/lilo.conf
	echo "# Compte à rebours en dixièmes de seconde :" >> $TMP/lilo.conf
	echo "timeout = 600" >> $TMP/lilo.conf
	echo "" >> $TMP/lilo.conf
	
	
	# On ajoute maintenant un éventuel système Windows :
	WIN=$(fdisk -l | grep -E 'DOS|FAT12|FAT16|HPFS|W95|Win' | grep -v 'tendue' | grep -v 'W95 Ext' | grep '*' | cut -f1 -d' ')
	if [ ! "$WIN" = "" ]; then
		clear
		echo -e "\033[1;32mPartitions DOS/Windows amorçables détectées.\033[0;0m"
		echo ""
		echo "Vous disposez de partitions amorçables de type DOS/Windows."
		echo "Voulez-vous ajouter les informations concernant DOS/Windows à LILO"
		echo "afin de pouvoir amorcer ce type de système ? Tapez la partition souhaitée"
		echo "figurant dans la liste suivante ou appuyez sur ENTRÉE pour ignorer :"
		echo ""
		echo $WIN
		echo ""
		echo -n "Votre choix : "
		read WINBOOT;
		WINTABLE="$(echo $WINBOOT | cut -b1-8)"
		if [ ! "${WINBOOT}" = ""]; then
			echo "Ajout d'une section Windows à lilo.conf pour la partition ${WINBOOT}."
			echo "# Partition DOS/Windows :" >> $TMP/lilo.conf
			echo "other = $WINTABLE" >> $TMP/lilo.conf
			echo "	label = Windows" >> $TMP/lilo.conf
			echo "	table = $WINBOOT" >> $TMP/lilo.conf
			echo "" >> $TMP/lilo.conf
			sleep 2
		fi
	fi

	# On ajoute maintenant la section pour Linux :
	LINUXBOOT="$(cat $TMP/partition_racine)"
	
	# On cherche l'emplacement du noyau :
	if [ -r ${LILOROOT}/boot/vmlinuz ]; then
		NOYAU="/boot/vmlinuz"
	elif [ -r ${LILOROOT}/boot/noyau ]; then
		NOYAU="/boot/noyau"
	else
		while [ "${USERKERNEL}" = "" ]; do
			echo "Noyau introuvable ou non renseigné. Veuillez entrer son"
			echo "emplacement ci-dessous (ex.: /boot/linux-2.6.34.1)."
			echo -n "Emplacement : "
			read USERKERNEL;
			if [ ! "${USERKERNEL}" = "" ]; then
				if [ -r ${LILOROOT}/${USERKERNEL} ]; then
					NOYAU="$USERKERNEL"
					break
				else
					echo "Le fichier ${USERKERNEL} est introuvable."
					sleep 2
					unset USERKERNEL
					continue
				fi
			fi
		done
	fi
	
	if [ ! "${NOYAU}" = "" -a ! "${LINUXBOOT}" = "" ]; then
		echo "Ajout de la section Linux à lilo.conf pour la partition ${LINUXBOOT}."
		echo "# Partition Linux :" >> $TMP/lilo.conf
		echo "image = $NOYAU" >> $TMP/lilo.conf
		echo "	root = $LINUXBOOT" >> $TMP/lilo.conf
		echo "	label = 0 Linux" >> $TMP/lilo.conf
		echo "	read-only" >> $TMP/lilo.conf
		echo "" >> $TMP/lilo.conf
		sleep 2
	fi
	
	# Il est temps d'installer LILO :
	clear
	echo -e "\033[1;32mConfirmation de l'installation de LILO.\033[0;0m"
	echo ""
	echo "LILO va maintenant être installé. Un aperçu du fichier lilo.conf va"
	echo "suivre, dans lequel vous pouvez naviguer vers le haut ou le bas grâce"
	echo "aux combinaisons de touches « MAJ.+PG.PRÉC. » et « MAJ.+PG.SUIV. ». "
	echo "Je vous demanderai ensuite de me confirmer l'installation de LILO."
	echo "Si vous refusez, le programme retournera au début de la procédure."
	echo ""
	echo -n "Appuyez sur ENTRÉE pour continuer"
	read BLAH;
	echo "\033[1;32mAperçu de votre fichier lilo.conf :\033[0;0m"
	cat $TMP/lilo.conf
	while [ ! "${CONFIRMINSTALL}" = "oui" -a ! "${CONFIRMINSTALL}" = "non" ]; do
		echo -n "Dois-je installer LILO maintenant (oui/non) ? "
		read CONFIRMINSTALL;
		if [ "${CONFIRMINSTALL}" = "non" ]; then
			echo "Refus de l'installation de LILO."
			sleep 2
			break
		elif [ "${CONFIRMINSTALL}" = "oui" ]; then
			echo -n "Installation de LILO..."
			cp $TMP/lilo.conf ${LILOROOT}/etc/lilo.conf
			lilo -r ${LILOROOT} -m /boot/map -C $TMP/lilo.conf 1> /dev/null 2> $TMP/lilo.erreur
			OK=$?
			sleep 2
			if [ ! "$OK" = "0" ]; then
				clear
				echo "LILO a retourné un code d'erreur ! Voyez d'où vient l'erreur"
				echo "en consultant la sortie de LILO ci-dessous. Le programme"
				echo "retournera ensuite au début de la procédure d'installation."
				echo "LILO a retourné :"
				cat $TMP/lilo.erreur
				echo -n "Appuyez sur ENTRÉE pour retourner au début de l'installation."
				read BLAH;
				LILOINSTALLED="NOTOK"
				break
			else
				# On peut quitter la boucle principale :
				LILOINSTALLED="OK"
				break
			fi
		else
			echo "Veuillez répondre par « oui » ou par « non » uniquement."
			sleep 2
			continue
		fi
	done

done

exit 0
