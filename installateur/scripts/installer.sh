#!/bin/env bash
pkgtobeinstalled

sleep 2

# Boucle d'installation des paquets :
CHOIXMEDIA="`cat $TMP/choix_media`"
MEDIA0DIR=$(find ${CHOIXMEDIA} -name "0" -type d -print)

for paquet in ${MEDIA0DIR}/paquets/*/*.* ; do

	pkginstalldesc
	spkman -i --quiet --root=${SETUPROOT} ${paquet} 1> /dev/null 2> /dev/null

done

# C'est fini !
