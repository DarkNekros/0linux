#!/usr/bin/env bash
# Trouver les paquets dont un paquet défini dépend.

# Utilisation :
#	trouver_paquets_dependants.sh gnu-ghostscript libpng wicd

cflags() {
	PKGARCH="$(uname -m)"
		
	if [ ${PKGARCH} = "i686" ]; then
		LIBDIRSUFFIX=""
	
	# x86 64 bits :
	elif [ ${PKGARCH} = "x86_64" ]; then
		LIBDIRSUFFIX="64"
	
	# ARM v7-a :
	elif [ ${PKGARCH} = "arm" ]; then
		LIBDIRSUFFIX=""
	
	# Tout le reste :
	else
		LIBDIRSUFFIX=""
	fi
}

chercher_dep() {
	for paquet in $@; do
		
		# « sed -e '/^not$/d' » concerne une erreur qui s'est glissé dans extraire_dependances().
		# Pour chaque dépendance trouvée dans 'deps.xz' :
		for d in $(find /usr/doc/${paquet}-* -type d); do
			if [ -f ${d}/deps.xz ]; then
				xzcat ${d}/deps.xz | sed -e '/^not$/d' | while read l; do
					
					# On recherche chaque fichier dans la liste des paquets installés et on remplace les chemins du type
					# '/usr/lib64/../lib64' par '/usr/lib64'. On pense aussi à enlever le slash du début :
					grep $(echo $l | sed -e 's@^/@@' -e "s@/lib${LIBDIRSUFFIX}/../lib${LIBDIRSUFFIX}/@/lib${LIBDIRSUFFIX}/@" ) /var/log/paquets/* 2>/dev/null;
				
				# On supprime le champ ajouté par 'grep', le répertoire des listes, ainsi que 'version-arch-compteur' pour
				# ne garder que le nom des paquets, qu'on trie dans l'ordre alphabétique et sans doublon, dont on supprime
				# le paquet concerné :
				done | sed -e 's@:.*$@@' -e 's@/var/log/paquets/@@' -e 's/\(^.*\)-\(.*\)-\(.*\)-\(.*\)$/\1/p' -n | sed -e "/^${paquet}$/d"
			fi
		done | sort -u
	done
}

cflags

for paq in $@; do
	chercher_dep $paq
done
