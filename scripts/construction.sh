#!/usr/bin/env bash
# Voyez le fichier LICENCES pour connaître la licence de ce script.
# Compilation/installation des paquets spécifiés sur la ligne de commande.
#
# ./construction.sh @kde libpng ../base/0outils
#
# Un arobase « @ » désigne une liste de paquets à compiler/installer dans 
# l'ordre, présente dans le même répertoire que ce script et nommée 
# 'construction-nom' (contenant un paquet par ligne). Les paquets individuels 
# sont spécifiés par leur simple nom. 
#
# 	$ ls scripts
# 	construction.sh
# 	construction-gimp
# 	construction-xorg
#
# Exemple : construire et installer les listes 'construction-kde' et 
# 'construction-gimp', le paquet 'libpng' ainsi que tous les paquets commençant 
# par « alsa » :
#
# 	./construction.sh @kde @gimp libpng alsa*
#
# Deux options spéciales existent :
#
# ./construction.sh tout            : compile/installe TOUTES les recettes.
# ./construction.sh tout-completer  : compile/installe TOUTES les recettes mais
#                                     ignore les paquets déjà compilés et 
#                                     installés dans '/usr/local/paquets' 
#                                     (permet de s'assurer que le système est 
#                                     complet).
#
# On peut installer chaque paquet dans une racine spécifique en spécifiant la
# variable DESTDIR sur la ligne de commande :
#
#	DESTDIR=/mon/chroot ./construction.sh blah

# Emplacement du dépôt des paquets résultant de la construction. À définir en
# tant que variable d'environnement car utilisée aussi dans 'service_construction.sh'
# entre autres.
PKGREPO=${PKGREPO:-/usr/local/paquets}

# Emplacement de la racine des paquets invasifs ('nvidia', 'catalyst'...) installés
# ailleurs pour ne pas polluer le système. À définir en
# tant que variable d'environnement car utilisée aussi dans 'catalogue.sh'
# entre autres.
UGLYPKGROOT=${UGLYPKGROOT:-/tmp/paquets_invasifs}

# La fonction de construction/installation de chaque paquet :
# $f RECETTE
compiler_installer() {
	
	# On compile chaque recette dans un sous-shell pour éviter de quitter
	# la boucle à la moindre erreur :
	(
		# On construit et on installe le paquet, avec ou sans 'sudo' :
		SUDOBINAIRE=""
		[ -x /usr/bin/sudo ] && SUDOBINAIRE="sudo"
		
		# On se place dans le répertoire de la recette en paramètre :
		cd $(dirname ${1})
		
		# Si DESTDIR est positionnée :
		if [ ! "${DESTDIR}" = "" ]; then
			ROOTCMD="--root=${DESTDIR}"
		else
			ROOTCMD=""
		fi
		
		# On désinstalle au préalable ces paquets récalcitrants en attendant mieux.
		# On désinstalle aussi les pages de manuels car les paquets vérifient si des
		# doublons existent sur le système et suprrime leurs propres manuels :
		for paquet_recalcitrant in evolution-data-server \
		gnome-shell \
		jack \
		lvm2 \
		man-pages \
		man-pages-fr \
		mlt \
		nspr \
		nss \
		samba \
		talloc; do
			if [ "$(basename ${1} .recette)" = "${paquet_recalcitrant}" ]; then
				
				# N'oublions pas que le compteur de révisions sera forcément à 1 si le paquet est désinstallé !
				# Récupérons-le de suite, ques DESTDIR soit spécifiée ou non :
				for f in $(find ${DESTDIR}/var/log/paquets/* -type f -name "$(basename ${1} .recette)*"); do
					if [ "$(echo $(basename ${f}) | sed 's/\(^.*\)-\(.*\)-\(.*\)-\(.*\)$/\1/p' -n)" = "$(basename ${1} .recette)" ]; then
						NOWBUILD=$(( $(echo $(basename ${f}) | sed 's/\(^.*\)-\(.*\)-\(.*\)-\(.*\)$/\4/p' -n) +1 ))
						export BUILD=${NOWBUILD}
					fi
				done
				
				# On scanne la racine si elle est spécifiée :
				if [ ! "${DESTDIR}" = "" ]; then
					for f in $(find ${DESTDIR}/var/log/paquets/* -type f -name "$(basename ${1} .recette)*"); do
						if [ "$(echo $(basename ${f}) | sed 's/\(^.*\)-\(.*\)-\(.*\)-\(.*\)$/\1/p' -n)" = "$(basename ${1} .recette)" ]; then
							${SUDOBINAIRE} spackrm ${f} || true
						fi
					done
				
				# Sinon, c'est bien plus simple, 'spackrm' sait déjà le faire :
				else
					${SUDOBINAIRE} spackrm "$(basename ${1} .recette)" || true
				fi
			fi
		done
		
		# On installe 'nvidia' et 'catalyst' dans une racine isolée, vu qu'ils écrasent
		# des fichiers de Mesa. Les installer ailleurs permet à 'catalogue.sh' de générer
		# le catalogue pour ces paquets sans qu'ils polluent le système :
		if [ "$(basename ${1} .recette)" = "nvidia" -o "$(basename ${1} .recette)" = "catalyst" ]; then
			bash -ex $(basename ${1}) && ${SUDOBINAIRE} /usr/sbin/spackadd --root=${UGLYPKGROOT} $(find ${PKGREPO}/${PKGARCH:-$(uname -m)}/*/ -mindepth 1 -type d -name "$(basename ${1} .recette)")/*.spack
		else
			bash -ex $(basename ${1}) && ${SUDOBINAIRE} /usr/sbin/spackadd ${ROOTCMD} $(find ${PKGREPO}/${PKGARCH:-$(uname -m)}/*/ -mindepth 1 -type d -name "$(basename ${1} .recette)")/*.spack
		fi
	)
}

for param in $@; do
	
	if [ -n ${param} ]; then
		
		# Si on doit tout compiler :
		if [ "${param}" = "tout" ]; then
			for recette in $(find ../0Linux -type f -name "*.recette" | sort); do
				compiler_installer ${recette}
			done 
		
		# Si on doit tout compiler mais qu'on doit ignorer tout paquet déjà compilé :
		elif [ "${param}" = "tout-completer" ]; then
			for recette in $(find ../0Linux -type f -name "*.recette" | sort); do
				CHECKPKGDIR="$(find ${PKGREPO}/${PKGARCH:-$(uname -m)}/ -type d -name "$(echo $(basename ${recette} .recette))")"
				if [ "$(find ${CHECKPKGDIR} -type f -name *.spack)" = "" ]; then
					compiler_installer ${recette}
				fi
			done 
		
		# Si on doit régénérer une image ISO :
		elif [ ! "$(echo '${param}' | grep 'generer-iso')" = "" ]; then
			
			# On découpe le paramètre pour savoir quel type d'ISO on doit générer (mini, maxi, etc.) :
			ISOTYPE="$(echo ${param} | cut -d'-' -f3)"
			
			# On nettoie et on génère l'iso dans '/usr/local/temp' (par défaut, mais sait-on jamais) :
			rm -rf /usr/local/temp/iso
			sudo TMP=/usr/local/temp 0creation_live --${ISOTYPE} ${PKGREPO}/$(uname -m)/

			# On déduit le nom de l'image ISO :
			NOMISO=$(ls -1 /usr/local/temp/iso/)
			
			# On copie l'image et on génère la somme de contrôle MD5 :
			cp /usr/local/temp/iso/${NOMISO} $(pwd)/../../../pub/iso/${VERSION}/
			cd $(pwd)/../../../pub/iso/${VERSION}/
			md5sum ${NOMISO} > ${NOMISO}.md5
			cd -
			
		else
			
			# Si le paramètre est un fichier existant :
			if [ -f ${param} ]; then
				compiler_installer ${param}
				
			# Si le paramètre commence par un « @ », on recherche une liste :
			elif [ ! "$(echo ${param} | grep -E '^@' )" = "" ]; then
				if [ -f construction-$(echo ${param} | sed s/@//) ]; then
					for fichier_liste in $(cat construction-$(echo ${param} | sed s/@//)); do
						for recette_trouvee in $(find ../0Linux -type f -name "$(basename ${fichier_liste}).recette"); do
							compiler_installer ${recette_trouvee}
						done
					done
				fi
				
			# Si on a autre chose (un paquet individuel ou un paramètre invalide) :
			else
				for recette in $(find ../0Linux -type f -name "${param}.recette"); do
					compiler_installer ${recette}
				done
			fi
		fi
	fi
done

# C'est fini.
