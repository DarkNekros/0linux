#!/bin/env bash
# Voyez le fichier LICENCES pour connaître la licence de ce script.
# Ordre de compilation/installation de X.
# À LANCER EN ROOT !

set -e
umask 022
CWD=$(pwd)
TMP=${TMP:-/tmp}

RECETTES="x11-proto gccmakedep imake x11-utils x11-cf-files \
	xtrans libXau libXdmcp libpthread-stubs freetype fontconfig \
	xcb-proto libxcb xcb-util libX11 libXext libICE libSM libXt \
	libXmu libXpm libXfixes libXrender libfontenc libXi libXv \
	libXp libXprintutil libxkbfile pixman x11-libs libdrm libtiff lesstif \
	mesa xbitmaps x11-apps xkeyboard-config xorg-server font-util \
	x11-polices x11-pilotes xcursor-themes xterm"

for recette in ${RECETTES}; do
	# On se place dans le répertoire de la recette :
	cd $(find ../$CWD -type d -name "${recette}")
	
	# On construit le paquet :
	bash -ex ${recette}.recette 2>&1 | tee /tmp/logs/${recette}.recette.log
	
	# On installe notre nouveau paquet :
	find /usr/local/paquets/ -name "${sbname}*" -print | xargs spkadd
done

# C'est terminé !
