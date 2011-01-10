#!/usr/bin/env bash
# Interfaces utilisateur pour l'installateur.

nolinuxpart() {
	dialog --title "${NOLINUXPART_TITLE}" --msgbox "${NOLINUXPART_MSG}" 12 80
}

cannotunmountvarlogmount () {
	echo "${CANNOTUMOUNTVARLOGMOUNT}"
}

mounttablecorrupted () {
	echo "${MOUNTTABLECORRUPTED}"
}

mainmenu () {
	dialog --backtitle "${MAINMENU_BACKTITLE}" --title "${MAINMENU_TITLE}" \
		--menu "${MAINMENU_MSG}" 22 80 8 \
		"${HELPMENU_LABEL}" "${HELPMENU_MSG}" \
		"${KEYBOARDMENU_LABEL}" "${KEYBOARDMENU_MSG}" \
		"${SWAPMENU_LABEL}" "${SWAPMENU_MSG}" \
		"${TARGETMENU_LABEL}" "${TARGETMENU_MSG}" \
		"${SOURCEMENU_LABEL}" "${SOURCEMENU_MSG}" \
		"${INSTALLMENU_LABEL}" "${INSTALLMENU_MSG}" \
		"${CONFIGMENU_LABEL}" "${CONFIGMENU_MSG}" \
		"${QUITMENU_LABEL}" "${QUITMENU_MSG}"
}

helpmenu () {
	dialog --title "${INSTALLHELP_TITLE}" --exit-label "${CLOSE_BUTTON}" --textbox "./aide.txt" 22 80
}

systemnotready () {
	dialog --title "${SYSTEMNOTREADY_TITLE}" --msgbox "${SYSTEMNOTREADY_MSG}" 25 80
}

installsuccessful () {
	echo "${INSTALLSUCCESSFUL}"
}

removemediaandrebootnow () {
	echo "${REMOVEMEDIAANDREBOOTNOW}"
}

rebootnow () {
	echo "${REBOOTNOW}"
}

finishedinstall () {
	dialog --title "${FINISHEDINSTALL_TITLE}" --msgbox "${FINISHEDINSTALL_MSG}" 8 80
}

keymapmenu () {
	dialog --title "${KEYMAPMENU_TITLE}" --menu "${KEYMAPMENU_MSG}" 25 80 14 \
		"qwerty/cf" "${CFKEYMAP_DESC}" \
		"qwertz/fr_CH-latin1" "${FRCHLATIN1KEYMAP_DESC}" \
		"qwertz/fr_CH" "${FRCHKEYMAP_DESC}" \
		"azerty/be-latin1" "${BEKEYMAP_DESC}" \
		"azerty/fr-latin9" "${FRLATIN9KEYMAP_DESC}" \
		"azerty/fr-latin1" "${FRLATIN1KEYMAP_DESC}" \
		"azerty/fr-pc" "${FRPCKEYMAP_DESC}" \
		"azerty/fr" "${FRKEYMAP_DESC}" \
		"azerty/azerty" "${AZERTYKEYMAP_DESC}" \
		"dvorak/fr-dvorak-bepo-utf8" "${BEPOUTF8KEYMAP_DESC}" \
		"dvorak/fr-dvorak-bepo" "${BEPOKEYMAP_DESC}" \
		"dvorak/dvorak-fr" "${DVORAKFRKEYMAP_DESC}" \
		"qwerty/us" "${USKEYMAP_DESC}" \
		"azerty/wangbe" " " \
		"azerty/wangbe2" " " \
		"dvorak/ANSI-dvorak" " " \
		"dvorak/dvorak-l" " " \
		"dvorak/dvorak-r" " " \
		"dvorak/dvorak" " " \
		"fgGIod/tr_f-latin5" " " \
		"fgGIod/trf" " " \
		"qwerty/bg-cp1251" " " \
		"qwerty/bg-cp855" " " \
		"qwerty/bg_bds-cp1251" " " \
		"qwerty/bg_bds-utf8" " " \
		"qwerty/bg_pho-cp1251" " " \
		"qwerty/bg_pho-utf8" " " \
		"qwerty/br-abnt" " " \
		"qwerty/br-abnt2" " " \
		"qwerty/br-latin1-abnt2" " " \
		"qwerty/br-latin1-us" " " \
		"qwerty/by" " " \
		"qwerty/cz-cp1250" " " \
		"qwerty/cz-lat2-prog" " " \
		"qwerty/cz-lat2" " " \
		"qwerty/cz" "" \
		"qwerty/defkeymap" " " \
		"qwerty/defkeymap_V1.0" " " \
		"qwerty/dk-latin1" " " \
		"qwerty/dk" " " \
		"qwerty/emacs" " " \
		"qwerty/emacs2" " " \
		"qwerty/es-cp850" " " \
		"qwerty/es" " " \
		"qwerty/et-nodeadkeys" " " \
		"qwerty/et" " " \
		"qwerty/fi-latin1" " " \
		"qwerty/fi-latin9" " " \
		"qwerty/fi" " " \
		"qwerty/gr-pc" " " \
		"qwerty/gr" " " \
		"qwerty/hu101" " " \
		"qwerty/il-heb" " " \
		"qwerty/il-phonetic" " " \
		"qwerty/il" " " \
		"qwerty/is-latin1-us" " " \
		"qwerty/is-latin1" " " \
		"qwerty/it-ibm" " " \
		"qwerty/it" " " \
		"qwerty/it2" " " \
		"qwerty/jp106" " " \
		"qwerty/la-latin1" " " \
		"qwerty/lt.baltic" " " \
		"qwerty/lt.l4" " " \
		"qwerty/lt" " " \
		"qwerty/mk-cp1251" " " \
		"qwerty/mk-utf" " " \
		"qwerty/mk" " " \
		"qwerty/mk0" " " \
		"qwerty/nl" " " \
		"qwerty/nl2" " " \
		"qwerty/no-latin1" " " \
		"qwerty/no" " " \
		"qwerty/pc110" " " \
		"qwerty/pl" " " \
		"qwerty/pl2" " " \
		"qwerty/pt-latin1" " " \
		"qwerty/pt-latin9" " " \
		"qwerty/ro_win" " " \
		"qwerty/ru-cp1251" " " \
		"qwerty/ru-ms" " " \
		"qwerty/ru-yawerty" " " \
		"qwerty/ru" " " \
		"qwerty/ru1" " " \
		"qwerty/ru2" " " \
		"qwerty/ru3" " " \
		"qwerty/ru4" " " \
		"qwerty/ru_win" " " \
		"qwerty/se-fi-ir209" " " \
		"qwerty/se-fi-lat6" " " \
		"qwerty/se-ir209" " " \
		"qwerty/se-lat6" " " \
		"qwerty/sk-prog-qwerty" " " \
		"qwerty/sk-qwerty" " " \
		"qwerty/speakup-jfw" " " \
		"qwerty/speakupmap" " " \
		"qwerty/sr-cy" " " \
		"qwerty/sv-latin1" " " \
		"qwerty/tr_q-latin5" " " \
		"qwerty/tralt" " " \
		"qwerty/trq" " " \
		"qwerty/ua-utf-ws" " " \
		"qwerty/ua-utf" " " \
		"qwerty/ua-ws" " " \
		"qwerty/ua" " " \
		"qwerty/uk" " " \
		"qwerty/us-acentos" " " \
		"qwerty/us" " " \
		"qwertz/croat" " " \
		"qwertz/cz-us-qwertz" " " \
		"qwertz/de-latin1-nodeadkeys" " " \
		"qwertz/de-latin1" " " \
		"qwertz/de" " " \
		"qwertz/de_CH-latin1" " " \
		"qwertz/hu" " " \
		"qwertz/sg-latin1-lk450" " " \
		"qwertz/sg-latin1" " " \
		"qwertz/sg" " " \
		"qwertz/sk-prog-qwertz" " " \
		"qwertz/sk-qwertz" " " \
		"qwertz/slovene" " "
}

keyboardtestmenu () {
	dialog --title "${KEYBOARDTESTMENU_TITLE}" --inputbox "${KEYBOARDTESTMENU_MSG}" 12 80
}

noswapfound () {
	dialog --title "${NOSWAPFOUND_TITLE}" --yesno "${NOSWAPFOUND_MSG}" 8 80
}

abortswap () {
	dialog --title "${ABORTSWAP_TITLE}" --msgbox "${ABORTSWAP_MSG}" 8 80
}

tempswap () {
	echo "\"$partitionswap\" \"${SIZEOFSWAPPARTITION} ${TAILLEPART}\" \"on\" "
}

swapselect () {
	dialog --backtitle "${SWAPSELECT_BACKTITLE}" --title "${SWAPSELECT_TITLE}" \
		--checklist "${SWAPSELECT_MSG}" 0 0 0 $TMP/temp_swap
}

swapconfigured () {
	dialog --title "${SWAPCONFIGURED_TITLE}" --exit-label "${CLOSE_BUTTON}" \
		--textbox "${SWAPCONFIGURED_MSG} `cat $TMP/choix_swap`" 12 80
}

# Fonction qui formate l'affichage pour 'dialog' pour lister les partitions Linux :
lister_partitions_linux() {
	
	cat $TMP/liste_partitions_linux | while [ 0 ]; do
		read PARTITION;
		
		if [ "$PARTITION" = "" ]; then
			break;
		fi
		
		NOMPARTITION=`echo $PARTITION | crunch | cut -d' ' -f1`
		TAILLEPARTITION=`taille_partition $NOMPARTITION`
		DESCMONTAGE=""
		
		# On scanne le fichier temporaire pour savoir si la partition est déjà utilisée :
		if grep "${NOMPARTITION} " $TMP/choix_partitions 1> /dev/null; then
			# On extrait le point de montage choisi :
			POINTMONTAGE=`grep "$NOMPARTITION " $TMP/choix_partitions | crunch | cut -d' ' -f2`
			DESCMONTAGE="${NOMPARTITION} ${MOUNTEDON_MSG} ${POINTMONTAGE}, Linux, ${TAILLEPARTITION}"
		fi
		
		if [ "${POINTMONTAGE}" = "" ]; then
			echo "\"${NOMPARTITION}\" \"Linux, ${TAILLEPARTITION}\" \\"
		else
			echo "\"${CONFIGURED_MSG}\" \"${DESCMONTAGE}\" \\"
		fi
	done
	# Ces lignes sont obligatoires, vu les 5 lignes minimum passées en paramètre à 'dialog' :
	echo "\"---\" \"${NOMOREPARTITIONS_MSG}\" \\"
	echo "\"---\" \"${NOMOREPARTITIONS_MSG}\" \\"
	echo "\"---\" \"${NOMOREPARTITIONS_MSG}\" \\"
	echo "\"---\" \"${NOMOREPARTITIONS_MSG}\" \\"
	echo "\"---\" \"${NOMOREPARTITIONS_MSG}\" \\"
	echo "2> $TMP/reponse"
}

selectrootdev () {
	dialog --backtitle "${SELECTROOTDEV_BACKTITLE}" --title "${SELECTROOTDEV_TITLE}" \
		--ok-label "${SELECT_BUTTON}" --cancel-label "${CONTINUE_BUTTON}" \
		--menu "${SELECTROOTDEV_MSG}" 14 80 5 \
		lister_partitions_linux
}

addanotherlinux () {
	dialog --backtitle "${ADDOTHERLINUX_BACKTITLE}" --title "${ADDOTHERLINUX_BACKTITLE}" \
		--ok-label "${SELECT_BUTTON}" --cancel-label "${CONTINUE_BUTTON}" \
		--menu "${ADDOTHERLINUX_MSG}" 25 80 4 \
		lister_partitions_linux
}

selectmountpoint () {
	dialog --backtitle "${SELECTMOUNTPOINT_BACKTITLE}" --title "${SELECTMOUNTPOINT_TITLE}" \
		--inputbox "${SELECTMOUNTPOINT_MSG}" 12 80
}

partitionscreated () {
	dialog --backtitle "${PARTITIONSCREATED_BACKTITLE}" --title  "${PARTITIONSCREATED_TITLE}" \
		--exit-label "${CLOSE_BUTTON}" --textbox "${PARTITIONSCREATED_MSG}" 16 80 \
		`cat $TMP/choix_partitions`
}

addfat () {
	dialog --backtitle "${ADDFAT_BACKTITLE}" --title "${ADDFAT_TITLE}" \
		--yesno "${ADDFAT_MSG}" 10 80
}

lister_partitions_fat () {
	echo ${LISTEFAT} | while read PARTITION_FAT ; do
		
		NOM_FAT=`echo ${PARTITION_FAT} | crunch | cut -d' ' -f1`
		TAILLE_FAT=taille_partition ${NOM_FAT}
		
		if echo ${PARTITION_FAT} | grep Win9 1> /dev/null 2> /dev/null; then
			TYPE_FAT="FAT32"
		elif echo ${PARTITION_FAT} | grep "W95 F" 1> /dev/null 2> /dev/null; then
			TYPE_FAT="FAT32"
		elif echo ${PARTITION_FAT} | grep FAT 1> /dev/null 2> /dev/null; then
			TYPE_FAT="FAT16"
		elif echo ${PARTITION_FAT} | grep NTFS 1> /dev/null 2> /dev/null; then
			TYPE_FAT="NTFS"
		fi
		
		# On scanne le fichier temporaire pour savoir si la partition est déjà utilisée :
		if grep "${NOM_FAT} " $TMP/choix_partitions 1> /dev/null; then
			# On extrait le point de montage choisi :
			POINTMONTAGE_FAT=`grep "$NOM_FAT " $TMP/choix_partitions | crunch | cut -d' ' -f2`
			DESCMONTAGE_FAT="${NOM_FAT} ${MOUNTEDON_MSG} ${POINTMONTAGE_FAT}, TYPE_FAT}, ${TAILLE_FAT}"
		fi
		
		if [ "${POINTMONTAGE_FAT}" = "" ]; then
			echo "\"${NOM_FAT}\" \"${TYPE_FAT}, ${TAILLE_FAT}\" \\"
		else
			echo "\"${CONFIGURED_MSG}\" \"${DESCMONTAGE_FAT}\" \\"
		fi
		
	done
	# Ces lignes sont obligatoires, vu les 5 lignes minimum passées en paramètre à 'dialog' :
	echo "\"---\" \"${NOMOREPARTITIONS_MSG}\" \\"
	echo "\"---\" \"${NOMOREPARTITIONS_MSG}\" \\"
	echo "\"---\" \"${NOMOREPARTITIONS_MSG}\" \\"
	echo "\"---\" \"${NOMOREPARTITIONS_MSG}\" \\"
	echo "\"---\" \"${NOMOREPARTITIONS_MSG}\" \\"
	echo "2> $TMP/reponse"
}

selectfat () {
	dialog --backtitle "${SELECTFAT_BACKTITLE}" --title "${SELECTFAT_TITLE}" \
		--ok-label "${SELECT_BUTTON}" --cancel-label "${CONTINUE_BUTTON}" \
		--menu "${SELECTFAT_MSG}" 17 80 5 \
		lister_partitions_fat
}

ntfssecu () {
	dialog --backtitle "${NTFSSECU_BACKTITLE}" --title "${NTFSSECU_TITLE}" \
		--default-item "${UMASK077_LABEL}" --menu "${NTFSSECU_MSG}" 18 80 4 \
		"${UMASK077_LABEL}" "${UMASK077_MSG}" \
		"${UMASK222_LABEL}" "${UMASK222_MSG}" \
		"${UMASK022_LABEL}" "${UMASK022_MSG}" \
		"${UMASK000_LABEL}" "${UMASK000_MSG}"
}

selectfatmountpoint () {
	dialog --backtitle "${SELECTFATMOUNTPOINT_BACKTITLE}" --title "${SELECTFATMOUNTPOINT_TITLE}" \
		--inputbox "${SELECTFATMOUNTPOINT_MSG}" 15 80
}

fatpartitionscreated () {
	dialog --backtitle "${PARTITIONSCREATED_BACKTITLE}" --title  "${PARTITIONSCREATED_TITLE}" \
		--exit-label "${CLOSE_BUTTON}" --textbox "${PARTITIONSCREATED_MSG}" 16 80 \
		`cat $TMP/choix_partitions_fat`
}

selectmedia () {
	dialog --backtitle "${SELECTMEDIA_BACKTITLE}" --title "${SELECTMEDIA_TITLE}" \
		--menu "${SELECTMEDIA_MSG}" 25 80 5 \
		"${SELECTDVD_LABEL}" "${SELECTDVD_MSG}" \
		"${SELECTUSB_LABEL}" "${SELECTUSB_MSG}" \
		"${SELECTHDD_LABEL}" "${SELECTHDD_MSG}" \
		#"${SELECTNFS_LABEL}" "${SELECTNFS_MSG}"
		#"${SELECTFTP_LABEL}" "${SELECTFTP_MSG}"
}

detectdvd () {
	dialog --backtitle "${DETECTDVD_BACKTITLE}" --title "${DETECTDVD_TITLE}" \
		--menu "${DETECTDVD_MSG}" 12 80 2 \
		"${AUTODETECTDVD_LABEL}" "${AUTODETECTDVD_MSG}" \
		"${MANUALDETECTDVD_LABEL}" "${MANUALDETECTDVD_MSG}"
}

enterdvddev () {
	dialog --backtitle "${ENTERDVDDEV_BACKTITLE}" --title "${ENTERDVDDEV_TITLE}" \
		--inputbox "${ENTERDVDDEV_MSG}" 10 80
}

ideautodetecting () {
	dialog --title "${IDEAUTODETECTING_TITLE}" --infobox "${IDEAUTODETECTING_MSG}" 5 80
}

scsiautodetecting () {
	dialog --title "${SCSIAUTODETECTING_TITLE}" --infobox "${SCSIAUTODETECTING_MSG}" 5 80
}

cantfinddvd () {
	dialog --title "${CANTFINDDVD_TITLE}" --msgbox "${CANTFINDDVD_MSG}" 0 0
}

dvdfound () {
	dialog --title "${DVDFOUND_TITLE}" --sleep 2 --infobox "${DVDFOUND_MSG}" 4 80
}

dvdmountfailed () {
	dialog --title "${DVDMOUNTFAILED_TITLE}" --msgbox "${DVDMOUNTFAILED_MSG}" 0 0
}

detectusb () {
	dialog --backtitle "${DETECTUSB_BACKTITLE}" --title "${DETECTUSB_TITLE}" \
		--menu "${DETECTUSB_MSG}" 12 80 2 \
		"${AUTODETECTUSB_LABEL}" "${AUTODETECTUSB_MSG}" \
		"${MANUALDETECTUSB_LABEL}" "${MANUALDETECTUSB_MSG}"
}

enterusbdev () {
	dialog --backtitle "${ENTERUSBDEV_BACKTITLE}" --title "${ENTERUSBDEV_TITLE}" \
		--inputbox "${ENTERUSBDEV_MSG}" 10 80
}

usbautodetecting () {
	dialog --title "${USBAUTODETECTING_TITLE}" --infobox "${USBAUTODETECTING_MSG}" 5 80
}

cantfindusb () {
	dialog --title "${CANTFINDUSB_TITLE}" --msgbox "${CANTFINDUSB_MSG}" 0 0
}

usbfound () {
	dialog --title "${USBFOUND_TITLE}" --sleep 2 --infobox "${USBFOUND_MSG}" 4 80
}

usbmountfailed () {
	dialog --title "${USBMOUNTFAILED_TITLE}" --msgbox "${USBMOUNTFAILED_MSG}" 0 0
}

installfromhdd () {
	dialog --backtitle "${INSTALLFROMHDD_BACKTITLE}" --title "${INSTALLFROMHDD_TITLE}" \
	--inputbox "${INSTALLFROMHDD_MSG}" 20 80
}

hddpartitionlist () {
	dialog --title "${PARTITIONLIST_TITLE}" --no-collapse --msgbox \
		`fdisk -l | grep /dev | egrep "Linux|NTFS|FAT|XFS" 2> /dev/null` 22 80
}

selectsourcedir () {
	dialog --backtitle "${SELECTSOURCEDIR_BACKTITLE}" --title "${SELECTSOURCEDIR_TITLE}" \
		--inputbox "${SELECTSOURCEDIR_MSG}" 21 80
}

hddmountfailed () {
	dialog --title "${HDDMOUNTFAILED_TITLE}" --menu "${HDDMOUNTFAILED_MSG}" 12 80 2 \
		"${HDDMOUNTRETRY_LABEL}" "${HDDMOUNTRETRY_MSG}" \
		"${HDDMOUNTABORT_LABEL}" "${HDDMOUNTABORT_MSG}"
}

pkgdirfound () {
	dialog --title "${PKGDIRFOUND_TITLE}" --sleep 2 --infobox "${PKGDIRFOUND_MSG}" 4 80
}

pkgdirnotfound () {
	dialog --title "${PKGDIRNOTFOUND_TITLE}" --sleep 2 --infobox "${PKGDIRNOTFOUND_MSG}" 4 80
}

pkgtobeinstalled () {
	dialog --infobox "${PKGTOBEINSTALLED}" 5 45
}

pkginstalldesc () {
	dialog --title "${PKGINSTALLDESC_TITLE}" --infobox "${paquet}" 5 80
}

preparingtoconfig () {
	dialog --title "${PREPARINGTOCONFIG_TITLE}" --infobox "${PREPARINGTOCONFIG_MSG}" 4 80
}

definerootpassword () {
	dialog --title "${DEFINEROOTPASSWORD_TITLE}" --yesno "${DEFINEROOTPASSWORD_MSG}" 12 80
}

pressentertocontinue () {
	echo -n "Appuyez sur 'Entrée' pour continuer."
}
