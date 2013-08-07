#!/usr/bin/env bash
# Voyez le fichier LICENCES pour connaître la licence de ce script.
# Compilation/installation des paquets spécifiés sur la ligne de commande.
#
# ./construction.sh @kde libpng ../base/0outils
#
# Un arobase « @ » désigne un dépôt entier, représenté par une liste d'ordre de
# compilation nommée 'construction-nom_du_dépôt' (contenant un paquet par ligne), devant
# se trouver  dans le même répertoire que ce script. Les paquets individuels sont
# spécifiés par leur simple nom. 
#
# 	$ ls scripts
# 	construction.sh
# 	construction-gimp
# 	construction-xorg
#
# Exemple : construire et installer les dépôts @kde et @gimp, le paquet 'libpng' ainsi
# que tous les paquets se trouvant sous ../opt/ et tous les paquets commençant par « alsa » :
# 	./construction.sh @kde @gimp libpng ../opt/* alsa*

# La fonction de construction/installation de chaque paquet :
# $f RECETTE
compiler_installer() {
	
	# On compile chaque recette dans un sous-shell pour éviter de quitter
	# la boucle à la moindre erreur :
	(
		# On se place dans le répertoire de la recette en paramètre :
		cd $(dirname ${1})
		
		# On construit et on installe le paquet :
		bash -ex $(basename ${1}) && \
			find /usr/local/paquets/$(uname -m)/{apps,base,opt,xorg} -name "$(basename ${1} .recette)-*-*-*.spack" -print | \
			xargs sudo /usr/sbin/spackadd
	)
}

for param in $@; do
	
	if [ -n ${param} ]; then
		# Si le paramètre est un fichier existant :
		if [ -f ${param} ]; then
			compiler_installer ${param}
			
		# Si le paramètre est un répertoire existant dans apps/ (cas des sous-dépôts de kde) :
		elif [ -d ${param} ]; then
			for fichier_recette in $(find .. -type f -name "$(basename ${param}).recette"); do
				compiler_installer ${fichier_recette}
			done
			
		# Si le paramètre commence par un « @ », on recherche une liste :
		elif [ ! "$(echo ${param} | grep -E '^@' )" = "" ]; then
			if [ -f construction-$(echo ${param} | sed s/@//) ]; then
				for fichier_liste in $(cat construction-$(echo ${param} | sed s/@//)); do
					for recette_trouvee in $(find ../{apps,base,opt,xorg} -type f -name "$(basename ${fichier_liste}).recette"); do
						compiler_installer ${recette_trouvee}
					done
				done
			fi
			
		# Si on a autre chose (un paquet individuel ou un paramètre invalide) :
		else
			for recette in $(find ../{apps,base,opt,xorg} -type f -name "${param}.recette"); do
				compiler_installer ${recette}
			done
		fi
	fi
done

# C'est fini.
