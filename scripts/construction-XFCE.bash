#!/bin/env bash
# Voyez le fichier LICENCES pour connaître la licence de ce script.
# Ordre de compilation/installation de XFCE.
# À LANCER EN ROOT !

set -e
umask 022
CWD=$(pwd)
TMP=${TMP:-/tmp}

RECETTES="xfce4-dev-tools libxfce4util xfconf \
	libxfcegui4 libxfce4menu exo garcon xfce4-panel thunar thunar-volman \
	xfce4-settings xfce4-session xfwm4 xfdesktop xfce4-utils  \
	xfwm4-themes xfce4-appfinder gtk-xfce-engine orage \
	mousepad terminal"

for recette in ${RECETTES}; do
	# On se place dans le répertoire de la recette :
	cd $(find $CWD/.. -type d -name "${recette}")
	
	# On construit le paquet :
	bash -ex ${recette}.recette 2>&1 | tee /tmp/logs/${recette}.recette.log
	
	# On installe notre nouveau paquet :
	find /usr/local/paquets/ -name "${sbname}*" -print | xargs spkadd
done

# C'est terminé !
