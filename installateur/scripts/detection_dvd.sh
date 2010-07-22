#!/bin/env bash
# On nettoie :
rm -f $TMP/choix_media

# Détection automatique ou manuelle du DVD ?
detectdvd 2> $TMP/reponse

# En cas de problème, on quitte :
if [ ! -r $TMP/reponse ]; then
	exit
fi

DETECTION="`cat $TMP/reponse`"
rm -f $TMP/reponse

# Saisie manuelle du lecteur optique :
if [ "$DETECTION" = "${MANUALDETECTDVD_LABEL}" ]; then
	enterdvddev 2> $TMP/reponse
	
	# En cas de problème, on quitte :
	if [ ! -r $TMP/reponse ]; then
		exit
	fi
	
	LECTEUR_OPTIQUE="`cat $TMP/reponse`"
	rm -f $TMP/reponse
else
	# On recherche les lecteurs IDE :
	ideautodetecting
	
	sleep 2
	
	for optique in /dev/hd*; do
		mount -o ro -t iso9660 $optique /var/log/mount 1> /dev/null 2> /dev/null
		
		# Périphérique trouvé :
		if [ $? = 0 ]; then
			LECTEUR_OPTIQUE=$optique
			umount /var/log/mount 1> /dev/null 2> /dev/null
			break;
		fi
	done
	
	# On recherche les lecteurs SCSI/SATA :
	scsiautodetecting
	
	sleep 2
	
	for optique in /dev/sr{0,1,2,3}; do
		mount -o ro -t iso9660 $optique /var/log/mount 1> /dev/null 2> /dev/null
		
		# Périphérique trouvé :
		if [ $? = 0 ]; then
			LECTEUR_OPTIQUE=$optique
			umount /var/log/mount 1> /dev/null 2> /dev/null
			break;
		fi
	done

fi

# Si le lecteur est introuvable :
if [ "$LECTEUR_OPTIQUE" = "" ]; then
	cantfinddvd
	exit
fi

# On monte le lecteur :
while [ 0 ]; do
	mount -o ro -t iso9660 ${LECTEUR_OPTIQUE} /var/log/mount 1> /dev/null 2> /dev/null
	
	# Si le montage se passe bien :
	if [ $? = 0 ]; then
		dvdfound
		# Le choix du média est fait, on écrit le fichier temporaire et on quitte :
		echo ${LECTEUR_OPTIQUE} > $TMP/choix_media
		break
	# Si le montage échoue :
	else
		dvdmountfailed
		break
	fi
	
done

# C'est fini !
