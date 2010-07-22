#!/bin/env bash
# On nettoie tous les points de montage :
if mount | grep /var/log/mount 1> /dev/null 2> /dev/null ; then
	umount /var/log/mount
fi

# S'il reste encore un volume monté, alors quelque chose ne va pas :
if mount | grep /var/log/mount 1> /dev/null 2> /dev/null ; then
	cannotunmountvarlogmount
	exit
fi

# On détecte si la table de montage est corrompue :
if [ -d /var/log/mount/lost+found -o -d /var/log/mount/recycled -o -r /var/log/mount/io.sys ]; then
	mounttablecorrupted
	exit
fi

# Boucle pour l'affichage du menu :
while [ 0 ]; do
	
	installfromhdd 2> $TMP/reponse
	
	# En cas de problème, on quitte :
	if [ ! -r $TMP/reponse ]; then
		exit
	fi
	
	PARTITIONHDD="`cat $TMP/reponse`"
	rm -f $TMP/reponse
	
	# Si l'utilisateur a appuyé sur ENTRÉE, alors on affiche une liste des partitions :
	if [ "$PARTITIONHDD" = "" ]; then
		hddpartitionlist
		continue;
	fi
	
	break;

done

# Boucle pour l'affichage du menu suivant :
while [ 0 ]; do
	selectsourcedir 2> $TMP/reponse
	
	# En cas de problème, on quitte :
	if [ ! -r $TMP/reponse ]; then
		exit
	fi
	
	SOURCEDIR="`cat $TMP/reponse`"
	rm -f $TMP/reponse
	
	# On vérifie si la partition est déjà montée ou pas :
	if mount | grep $PARTITIONHDD 1> /dev/null 2> /dev/null ; then
		# Montée :
		MOUNTDIR="`mount | grep $PARTITIONHDD | cut -d' ' -f3`"
		# on lie /var/log/mount au point de montage
		ln -sf ${MOUNTDIR} /var/log/mount 
	else
		# Non montée :
		for type in ext3 ext2 vfat reiserfs hpfs ntfs msdos ; do
			mount -r -t $type $PARTITIONHDD /var/log/mount 1> /dev/null 2> /dev/null
		done
	fi
	
	# Si le montage a échoué :
	if [ ! mount | grep $PARTITIONHDD ]; then
		hddmountfailed 2> $TMP/reponse
		
		# En cas de problème, on quitte :
		if [ ! -r $TMP/reponse ]; then
			exit
		fi
		
		REPONSE="`cat $TMP/reponse`"
		rm -f $TMP/reponse
		
		if [ "$REPONSE" = "${HDDMOUNTRETRY_LABEL}" ]; then
			umount /var/log/mount 2> /dev/null
			continue;
		else
			exit
		fi
	fi
	break;

done

# On scanne la partition montée afin de savoir où se trouve le répertoire 0 et le paquet
# propre au système 'base-systeme-*'. S'il est présent, les autres sûrement aussi :
0DIR="`find /var/log/mount -name "0" -type d -print`"

if [ ! "$0DIR" = "" ]; then
	
	if [ -d $0DIR/paquets ]; then
		BASEPKG="`find $0DIR/paquets -name "base-systeme-*" -type f -print`"
		
		# On a trouvé le paquet 'base-systeme' :
		if [ ! "$BASEPKG" = "" ]; then
			echo ${0DIR}/paquets > choix_media
			pkgdirfound
			exit
		fi
	
else
	pkgdirnotfound
	exit
fi

# C'est fini !
