#!/usr/bin/env bash
# lancer-taches: Exécute les scripts trouvés dans un répertoire donné.

set +e

if [ $# -lt 1 ]; then
	echo "Utilisation : lancer-taches <répertoire>"
	exit 1
fi

if [ ! -d $1 ]; then
	echo "'$1' n'est pas un répertoire !"
	echo "Utilisation : lancer-taches <répertoire>"
	exit 1
fi

# On ignore certains sufixes de fichiers :
IGNORE_SUFFIXES="~ ^ , .bak .0nouveau .swp"

for SCRIPT in $1/* ; do
	
	if [ ! -f $SCRIPT ]; then
		continue
	fi
	
	SKIP=false
	
	for SUFFIX in $IGNORE_SUFFIXES ; do
		if [ ! "$(basename $SCRIPT $SUFFIX)" = "$(basename $SCRIPT)" ]; then
			SKIP=true
			break
		fi
	done
	
	if [ "$SKIP" = "true" ]; then
		continue
	fi
	
	if [ -x $SCRIPT ]; then
		$SCRIPT 2>&1
	fi

done

exit 0
