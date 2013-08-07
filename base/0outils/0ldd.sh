#!/bin/env bash

# On extrait les fichiers en dépendances :
mkdir -p ${PKG}/usr/doc/${NAMETGZ}-${VERSION}

for executable in $(find ${PKG} -type f -executable); do
	ldd ${executable} 2>/dev/null | grep '=>' | cut -d' ' -f3 | while read resultat; do
		echo ${resultat} | grep -v -E '^\(0x.*$\)'
	done
done | sort -u -t ' ' | sed '/^$/d' > ${PKG}/usr/doc/${NAMETGZ}-${VERSION}/deps

# Trouver les paquets dépendants à recompiler après une API qui casse par exemple :
for paquet in $@; do
	
	echo "> ${paquet} :"

	xzcat /usr/doc/gnu-ghostscript-9.06/deps.xz | while read f; do
		grep $(echo $f | sed 's@^/@@') /var/log/paquets/* 2>/dev/null;
	done | cut -d':' -f1 | sed 's@/var/log/paquets/@@' | sort -u
	
	echo ""
	
done
