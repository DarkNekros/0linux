#!/bin/env bash
# On nettoie :
rm -f $TMP/choix_media

# Détection automatique ou manuelle de la clé ?
detectusb 2> $TMP/reponse

# En cas de problème, on quitte :
if [ ! -r $TMP/reponse ]; then
	exit
fi

DETECTION="`cat $TMP/reponse`"
rm -f $TMP/reponse

# Saisie manuelle du lecteur optique :
if [ "$DETECTION" = "${MANUALDETECTUSB_LABEL}" ]; then
	enterusbdev 2> $TMP/reponse
	
	# En cas de problème, on quitte :
	if [ ! -r $TMP/reponse ]; then
		exit
	fi
	
	LECTEUR_USB="`cat $TMP/reponse`"
	rm -f $TMP/reponse
else
	# On recherche les lecteurs USB :
	usbautodetecting
	
	sleep 2
	
	for usb in /dev/sd*; do
		USBDEVDIR="`echo $usb | cut -d'/' -f2`"
		mount -o ro -t vfat $usb /var/log/mount$USBDEVDIR 1> /dev/null 2> /dev/null
		
		# Périphérique trouvé :
		if [ $? = 0 ]; then
			# Si le volume contient le répertoire '0/paquets', alors on tient notre support d'installation :
			if [ -d /var/log/mount$USBDEVDIR/0/paquets ]; then
				LECTEUR_USB=$usb
				umount /var/log/mount$USBDEVDIR 1> /dev/null 2> /dev/null
				break;
			# Sinon, on a affaire à une simple partition VFAT :
			else
				umount /var/log/mount$USBDEVDIR 1> /dev/null 2> /dev/null
				continue;
			fi
		fi
	done
	
fi

# Si le lecteur est introuvable :
if [ "$LECTEUR_USB" = "" ]; then
	cantfindusb
	exit
fi

# On monte le lecteur :
while [ 0 ]; do
	mount -t vfat ${LECTEUR_USB} /var/log/mount 1> /dev/null 2> /dev/null
	
	# Si le montage se passe bien :
	if [ $? = 0 ]; then
		usbfound
		# Le choix du média est fait, on écrit le fichier temporaire et on quitte :
		echo ${LECTEUR_USB} > $TMP/choix_media
		break;
	# Si le montage échoue :
	else
		usbmountfailed
		break;
	fi
	
done

# C'est fini !
