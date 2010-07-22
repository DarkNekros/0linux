#!/bin/env bash
# On affecte les variables localisées des messages à l'écran grâce au
# fichier 'messages.sh', lequel est un lien vers messages_langue-PAYS.sh
. /usr/lib/installateur/messages.sh

# On stocke en mémoire nos interfaces utilisateur :
. /usr/lib/installateur/interfaces.sh

# On s'assure de notre $PATH :
PATH="/bin:/sbin:/usr/lib/installateur:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
export PATH

# On crée le répertoire temporaire s'il n'existe pas :
TMP=${TMP:-/var/log/setup/tmp}

if [ ! -d ${TMP} ]; then
	mkdir -p ${TMP}
fi

# On redirige certains messages importants sur la console 4 :
REDIR=${REDIR:-/dev/tty4}

# Cette fonction supprime les espaces superflus via 'echo' :
crunch() {
	read STRING;
	echo $STRING;
}

# taille_partition(périphérique) :
taille_partition() {
	Taille=`fdisk -l | grep $1 | crunch | tr -d "*" | tr -d "+" | cut -d' ' -f4`
	echo "$Taille ${BLOCKS}"
}

# On tente de détecter une ou plusieurs partitions Linux, swap exceptée.
# On retire l'astérisque "*" des partitions amorçables pour avoir 6 champs partout :
listelinux() {
	LISTELINUX=`fdisk -l 2> /dev/null | grep Linux 2> /dev/null | grep -v swap 2> /dev/null | tr -d "*" 2> /dev/null`
	echo "${LISTELINUX}"
}

# On tente de détecter une ou plusieurs partitions swap existantes :
listeswap() {
	LISTESWAP=`fdisk -l 2> /dev/null | grep swap 2> /dev/null`
	echo "${LISTESWAP}"
}

# formateroupas(périphérique)
formateroupas() {
	dialog --backtitle "${LINUXFORMAT_BACKTITLE} ${1} ?" \
		--title "${LINUXFORMAT_TITLE} $1" --menu "${LINUXFORMAT_MSG}" 13 80 3 \
		"${LINUXFORMAT_LABEL}" "${LINUXFORMAT_MSG}" \
		"${LINUXCHECKFORMAT_LABEL}" "${LINUXCHECKFORMAT_MSG}" \
		"${LINUXDONTFORMAT_LABEL}" "${LINUXDONTFORMAT_MSG}" 2> $TMP/reponse
	
	# En cas de problème, on quitte :
	if [ ! $? = 0 ]; then
		rm -f $TMP/reponse
		exit
	fi
}

# quel_format(périphérique) {
quel_format() {
	dialog --title "${SELECTFS_TITLE}" --backtitle "${SELECTFS_TITLE}" \
		--default-item "${EXT3_LABEL}" --menu "${SELECTFS_MSG}" 0 0 0 \
		"${EXT2_LABEL}" "${EXT2_MSG}" \
		"${EXT3_LABEL}" "${EXT3_MSG}" \
		"${EXT4_LABEL}" "${EXT4_MSG}" \
		"${JFS_LABEL}" "${JFS_MSG}" \
		"${REISERFS_LABEL}" "${REISERFS_MSG}" \
		"${XFS_LABEL}" "${XFS_MSG}" 2> $TMP/reponse
	
	# En cas de problème, on quitte :
	if [ ! $? = 0 ]; then
		rm -f $TMP/reponse
		exit
	fi
}

# formater(type,périphérique,vérifier)
# Paramètres : type : système de fichiers (ext{2,3,4},reiserfs,jfs,xfs)
#              périphérique : nom du périphérique (/dev/*)
#              vérifier : vérifier le système de fichiers (oui,non)
formater() {
	
	TAILLEPART=`taille_partition $1`
	
	# On affiche ce qui se passe :
	dialog --title "${FORMATTING_TITLE}" --backtitle "${FORMATTING_BACKTITLE}" \
		--infobox "${FORMATTING_MSG}" 0 0
	
	# On s'assure de démonter le volume :
	if mount | grep "$2 " 1> /dev/null 2> /dev/null; then
		umount $2 2> /dev/null
	fi
	
	# Vérifier le système de fichiers créé ?
	if [ "$3" = "oui" ]; then
		VERIF="-c"
	else
		VERIF=" "
	fi
		
	# On formate avec les bonnes options :
	case "$1" in
		ext2)
			mkfs.ext2 $VERIF $2 /dev/null 2> /dev/null
		;;
		ext3)
			mkfs.ext3 $VERIF -j $2 /dev/null 2> /dev/null
		;;
		ext4)
			mkfs.ext4 -f $2 1> /dev/null 2> /dev/null
		;;
		reiserfs)
			echo "y" | mkreiserfs $2 1> /dev/null 2> /dev/null
		;;
		jfs)
			mkfs.jfs $VERIF -q $2 1> /dev/null 2> /dev/null
		;;
		xfs)
			mkfs.xfs -f $2 1> /dev/null 2> /dev/null
	esac

}

