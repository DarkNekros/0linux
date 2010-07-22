#!/bin/env bash
selectmedia 2> $TMP/reponse

# En cas de problème, on quitte :
if [ ! $? = 0 ]; then
	rm -f $TMP/reponse
	exit
fi

MEDIASOURCE="`cat $TMP/reponse`"
rm -f $TMP/reponse

# On analyse le choix de l'utilisateur et on exécute le script ad-hoc en conséquence :
case "$MEDIASOURCE" in
	${SELECTDVD_LABEL})
		. $PWD/detection_dvd.sh
	;;
	${SELECTUSB_LABEL})
		. $PWD/detection_usb.sh
	;;
	${SELECTHDD_LABEL})
		. $PWD/detection_hdd.sh
	#;;
	#${SELECTNFS_LABEL})
	#	detection_nfs.sh
	#;;
	#${SELECTFTP_LABEL})
	#	detection_ftp.sh
esac

# C'est fini !
