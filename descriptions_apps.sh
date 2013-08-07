#!/usr/bin/env bash

# Le dépôt public des paquets contenant 'apps' :
pubrepo="/home/appzer0/0/pub/paquets"

# On génère les descriptions des dépôts 'apps' avec 'txt2tags' :
for arch in arm i686 x86_64; do
	for f in apps/*/*.t2t; do
		txt2tags -t txt -o ${pubrepo}/${arch}/apps/$(basename ${f} .t2t)/$(basename ${f} .t2t).txt ${f} 2>/dev/null || echo "Dépôt ${arch}/$(basename ${f} .t2t) inexistant."
	done
done
