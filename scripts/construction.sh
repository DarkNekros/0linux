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
# Exemple : construire et installer les listes construction-kde et 
# construction-gimp, le paquet 'libpng' ainsi que tous les paquets commençant 
# par « alsa » :
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

# Emplacement du dépôt des paquets résultant de la construction :
PKGREPO=${PKGREPO:-/usr/local/paquets}

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
		
		# On désinstalle au préalable ces paquets récalcitrants en attendant mieux :
		if [ "$(basename ${1} .recette)" = "samba" ] || [ "$(basename ${1} .recette)" = "talloc" ] || [ "$(basename ${1} .recette)" = "evolution-data-server" ] || [ "$(basename ${1} .recette)" = "gnome-shell" ]; then
			${SUDOBINAIRE} spackrm "$(basename ${1} .recette)"
		fi
		
		# On n'installe pas nvidia, il écrase des fichiers de Mesa :
		if [ "$(basename ${1} .recette)" = "nvidia" ]; then
			bash -ex $(basename ${1})
		else
			bash -ex $(basename ${1}) && ${SUDOBINAIRE} /usr/sbin/spackadd $(find ${PKGREPO}/$(uname -m)/ -type d -name "$(basename ${1} .recette)")/*.spack
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
		elif [ "${param}" = "tout-completer" ]; then
			
			# Si on doit tout compiler mais qu'on doit ignorer tout paquet déjà compilé :
			for recette in $(find ../0Linux -type f -name "*.recette" | sort); do
				CHECKPKGDIR="$(find ${PKGREPO}/$(uname -m)/ -type d -name "$(echo $(basename ${recette} .recette))")"
				if [ "$(find ${CHECKPKGDIR} -type f -name *.spack)" = "" ]; then
					compiler_installer ${recette}
				fi
			done 
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
