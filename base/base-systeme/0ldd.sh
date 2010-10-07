#!/bin/env bash
mkdir -p ${PKG}/var/log/deps

echo "Calcul des dépendances en cours..."
# Pour chaque fichier exécutable :
for x in $(find ${PKG} -type f -executable); do
	# On extrait chaque nom de bibliothèque en dépendance en supprimant la racine :
	ldd ${x} 2>/dev/null | grep "=>" | cut -d' ' -f3 | sed 's/^\///' while read plop; do
		# On cherche les dépendances trouvées dans la base des paquets installés :
		for i in /var/log/paquets/*; do
			# On nettoie tout ce qui se trouve avant "./" avec cet immonde 'grep' :
			CLEANLIST=$(grep -E -A40000 '\.\/' ${i} | sed 's\.\//')
			
			# On découpe pour ne retirer que le nom du paquet sans sa version :
			grep ${plop} ${CLEANLIST} | sed -e 's/\/var\/log\/paquets\/\^(.*\)-[^-][^-]*-[^-][^-]*-[^-][^-]*$/\1/p' -n
		done
	done
# On supprime le paquet courant et la glibc en triant les doublons et on enregistre :
done | grep -v "$NAMETGZ" | grep -v "eglibc"  | sort -u -t ' ' > ${PKG}/var/log/deps/${NAMETGZ}-${VERSION}-${ARCH}-$BUILD
