#!/bin/env bash
mkdir -p ${PKG}/var/log/deps

echo "Calcul des dépendances en cours..."
# Pour chaque fichier exécutable :
for x in $(find ${PKG} -type f -executable); do
	# On extrait chaque nom de bibliothèque en dépendance :
	ldd ${x} 2>/dev/null | grep "=>" | cut -d' ' -f3 | while read plop; do
		# On se débarrasse de libc puis on découpe pour ne retirer que le nom du paquet
		# sans sa version :
		grep $(echo ${plop} | sed -e 's/^\///' -e 's/^lib.*\/libc.*$//') /var/log/paquets/* \
			| sed -e 's@/var/log/paquets/@@' \
			      -e 's@:.*$@@' \
			      -e 's/\(.*\)-[^-][^-]*-[^-][^-]*-[^-][^-]*$/\1/p' -n
	done
# On supprime le paquet courant et la glibc ainsi que les doublons, puis on enregistre :
done | grep -v "$NAMETGZ" | grep -v "eglibc"  | sort -u -t ' ' > ${PKG}/var/log/deps/${NAMETGZ}-${VERSION}-${ARCH}-$BUILD

