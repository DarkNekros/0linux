#!/usr/bin/env bash
# Création/mise à jour du catalogue en ligne des paquets de 0Linux.
# Ce script crée un document txt2tags, converti en document pour Dokuwiki
# pour chaque paquet demandé et récrée à chaque fois l'index de la catégorie
# correspondante.
#
# Utilisation :
#	catalogue.sh [PAQUETS,JOURNAUX DE PAQUETS]
#
# Variables disponibles : affecter une valeur quelconque aux variables :
#  FORCECATALOGUE pour forcer la génération du catalogue même s'il est déjà présent
#  NOINDEX pour ignorer la génération de l'index correspondant aux paquets demandés

# Emplacement du dépôt des paquets :
PKGREPO=${PKGREPO:-/usr/local/paquets/$(uname -m)}

# Les journaux des paquets :
PKGLOGDIR="/var/log/packages"
PKGPOSTDIR="/var/log/scripts"

# Emplacement de la racine des paquets invasifs ('nvidia', 'catalyst'...) installés
# ailleurs pour ne pas polluer le système :
UGLYPKGROOT=${UGLYPKGROOT:-/tmp/paquets_invasifs}

# Le catalogue qui va accueillir les résultats du scan :
CATALOGDIR=${CATALOGDIR:-/home/appzer0/0/pub/catalogue}

# L'URL du catalogue en ligne (ici, le namespace - en relatif - du wiki de 0Linux) :
CATALOGURL=${CATALOGURL:-paquets/}

# Affiche le nom court ("gcc", "pkg-config"...) du journal demandé.
# $f JOURNAL
nom_court() {
	echo $(basename "${1}" | sed 's/\(^.*\)-\(.*\)-\(.*\)-\(.*\)$/\1/p' -n)
}

# Affiche le champ de la base de données du journal demandé.
# $f (nom|paquet|emplacement|taille|dépendances)
afficher_champ_db() {
	[ "$1" = "" ] && echo "Erreur : Champ de la db non spécifié !" && exit 1
	[ "$1" = "nom" ] && IDCHAMP="1"
	[ "$1" = "paquet" ] && IDCHAMP="2"
	[ "$1" = "emplacement" ] && IDCHAMP="3"
	[ "$1" = "taille" ] && IDCHAMP="4"
	[ "$1" = "deps" ] && IDCHAMP="5-"
	grep -E "^${2}[[:blank:]]" ${PKGREPO}/paquets.db | cut -d' ' -f${IDCHAMP}
}

# Scanne les paquets fournis.
# $f JOURNAUX DE PAQUETS
scan() {
	for arg in "${1}"; do
		unset pkglog
		
		# Les journaux des paquets (variables réinitialisées à chaque boucle) :
		PKGLOGDIR="/var/log/packages"
		PKGPOSTDIR="/var/log/scripts"
		
		# Si l'argument est un journal existant : :
		if [ -f "${arg}" ]; then
			pkglog="${arg}"
		
		# Si l'argument est un nom de paquet :
		else
			for f in "$(find ${PKGLOGDIR} ${UGLYPKGROOT}${PKGLOGDIR} -type f -name "$(basename ${arg})*")"; do
				
				# On tient notre journal, on sort de la boucle :
				if [ "$(nom_court ${f})" = "${arg}" ]; then
					pkglog="${f}"
					break
				fi
			done
		fi
		
		# Rien trouvé ? On quitte :
		if [ -z ${pkglog} ]; then
			echo "Argument invalide : paquet ou journal de paquet inexistant."
			echo ""
			echo "Utilisation :"
			echo "	catalogue.sh [PAQUETS, JOURNAUX DE PAQUETS]"
			echo ""
			echo "Exemples :"
			echo "	$(basename $0) /var/log/paquets/0outils-12-x86_64-1 /var/log/paquets/libpng-1.6-x86_64-1"
			echo "	$(basename $0) 0outils libpng"
			echo "	$(basename $0) /var/log/paquets/a*"
			exit 1
		fi
		
		# On a notre journal à analyser, on démarre :
		echo "Génération du catalogue pour '$(nom_court ${pkglog})'..." 
		
		# On traite différemment les paquets dégueus, installés sur la racine $UGLYPKGROOT :
		if [ ! "$(echo ${arg} | grep -E 'catalyst|nvidia')" = "" ]; then
			PKGLOGDIR="${UGLYPKGROOT}${PKGLOGDIR}"
			PKGPOSTDIR="${UGLYPKGROOT}${PKGPOSTDIR}"
			TARGETROOT="${UGLYPKGROOT}" # Pour scanner les '*.dep' dans '$TARGETROOT/usr/doc'
		else
			PKGLOGDIR="${PKGLOGDIR}"
			PKGPOSTDIR="${PKGPOSTDIR}"
			TARGETROOT=""
		fi
		
		# On déduit le répertoire du paquet selon son emplacement en le découpant.
		# Retourne un chemin du type : "e/kde/kdeartwork/kdeartwork".
		NOM PAQUET EMPLACEMENT TAILLE (DEP DEP DEP DEP...)
		
		categ=$(dirname $(spacklist --directory="${PKGLOGDIR}" -v $(nom_court ${pkglog}) | \
			egrep '^EMPLACEMENT' | cut -d':' -f2) | sed -e "s@^.*$(uname -m)/@@")
		
		if [ "${categ}" = "" ]; then
			echo "Erreur : catégorie introuvable pour '$(nom_court ${pkglog})'."
			exit 1
		fi
		
		# Si le log en .txt est présent et que FORCECATLOGUE est vide, on ignore le scan :
		if [ -z "${FORCECATALOGUE}" ]; then
			if [ -r ${CATALOGDIR}/$(uname -m)/${categ}/$(nom_court ${pkglog}).txt ]; then
				echo "Catalogue '$(nom_court ${pkglog}).txt' ignoré car déjà présent."
				continue
			fi
		fi
			
		# On supprime toute trace, y compris d'un récent déplacement de paquet
		# (ça arrive plutôt souvent en fait) :
		find ${CATALOGDIR}/$(uname -m) -type d -name "$(nom_court ${pkglog})" -exec rm -rf {} \; 2>/dev/null || true
		
		# On crée le répertoire d'accueil :
		mkdir -p ${CATALOGDIR}/$(uname -m)/${categ}
		
		# On va créer des logs temporaires et les assembler plus tard dans un document txt2tags.
		
		# On récupère les entêtes (nom, taille, description...) :
		spacklist --directory="${PKGLOGDIR}" -v $(nom_court ${pkglog}) | sed '/^EMPLACEMENT/d' > ${CATALOGDIR}/$(uname -m)/${categ}/$(nom_court ${pkglog}).header
		
		# On récupère la liste nettoyée des fichiers installés :
		touch ${CATALOGDIR}/$(uname -m)/${categ}/$(nom_court ${pkglog}).list.tmp
		
		spacklist --directory="${PKGLOGDIR}" -V $(nom_court ${pkglog}) | \
			sed -e '/NOM DU PAQUET.*$/,/\.\//d' \
			> ${CATALOGDIR}/$(uname -m)/${categ}/$(nom_court ${pkglog}).list.tmp
		
		# On ajoute la liste nettoyée des liens symboliques traités en post-installation :
		spacklist --directory="${PKGPOSTDIR}" -v -p $(nom_court ${pkglog}) | \
			sed -e 's@^/@@' -e '/------/d' -e '/^> /d' -e '/^\.\/$/d' \
			>> ${CATALOGDIR}/$(uname -m)/${categ}/$(nom_court ${pkglog}).list.tmp
		
		# On réunit le tout, qu'on trie dans l'ordre :
		sort ${CATALOGDIR}/$(uname -m)/${categ}/$(nom_court ${pkglog}).list.tmp > ${CATALOGDIR}/$(uname -m)/${categ}/$(nom_court ${pkglog}).list
		rm -f ${CATALOGDIR}/$(uname -m)/${categ}/$(nom_court ${pkglog}).list.tmp
		
		# On récupère les dépendances en nettoyant le paquet concerné.
		# Pour chaque dépendance :
		cat ${TARGETROOT}/usr/doc/$(nom_court ${pkglog})/0linux/$(basename ${pkglog}).dep | sort | while read linedep; do
			
			# On déduit le répertoire du paquet en dépendance selon son emplacement en le découpant.
			# Retourne un chemin du type : "e/kde/kdeartwork/kdeartwork".
			depcateg=$(dirname $(spacklist -v ${linedep} | \
				egrep '^EMPLACEMENT' | cut -d':' -f2) | sed -e "s@^.*$(uname -m)/@@")
			
			# On crée le champ "paquet url" pour créer chaque lien hypertexte :
			echo "${linedep} ${CATALOGURL}/$(uname -m)/${depcateg}/${linedep}"
			
		done | sed "/$(nom_court ${pkglog})\.txt$/d" > ${CATALOGDIR}/$(uname -m)/${categ}/$(nom_court ${pkglog}).dep
		
		# On récupère les dépendants en scannant les autres journaux '*.dep' (on ignore
		# le scan pour les paquets dégueus isolés comme 'nvidia' et 'catalyst') :
		if [ ! "${PKGLOGDIR}" = "${UGLYPKGROOT}/${PKGLOGDIR}" ]; then
			touch ${CATALOGDIR}/$(uname -m)/${categ}/$(nom_court ${pkglog}).reqby.tmp
			
			for reqlog in /usr/doc/*/0linux/*.dep; do
				if grep -E -q "^$(nom_court ${pkglog})$" ${reqlog}; then
					
					# On déduit le répertoire du paquet en dépendance selon son emplacement en le découpant.
					# Retourne un chemin du type : "e/kde/kdeartwork/kdeartwork".
					reqcateg=$(dirname $(spacklist --directory="${PKGLOGDIR}" -v $(nom_court $(echo ${reqlog} | sed 's@\.dep$@@')) | \
						egrep '^EMPLACEMENT' | cut -d':' -f2) | sed -e "s@^.*$(uname -m)/@@")
					
					echo "$(nom_court $(echo ${reqlog} | sed 's@\.dep$@@')) ${CATALOGURL}/$(uname -m)/${reqcateg}/$(nom_court $(echo ${reqlog} | sed 's@\.dep$@@'))" >> ${CATALOGDIR}/$(uname -m)/${categ}/$(nom_court ${pkglog}).reqby.tmp
				fi
			done
			
			# On trie :
			sort -u ${CATALOGDIR}/$(uname -m)/${categ}/$(nom_court ${pkglog}).reqby.tmp | sed "/$(nom_court ${pkglog})\.txt$/d" > ${CATALOGDIR}/$(uname -m)/${categ}/$(nom_court ${pkglog}).reqby
			rm -f ${CATALOGDIR}/$(uname -m)/${categ}/$(nom_court ${pkglog}).reqby.tmp
		fi
	
		# On génère le document txt2tags :
		cat > ${CATALOGDIR}/$(uname -m)/${categ}/$(nom_court ${pkglog}).t2t << EOF
Détails du paquet ${categ}/$(basename ${pkglog}) pour 0Linux $(uname -m)
Équipe 0Linux <contact@0linux.org>
Généré le %%mtime(%d/%m/%Y)

%!encoding: UTF-8

= $(echo $(basename ${pkglog}) | sed 's/\(^.*\)-\(.*\)-\(.*\)-\(.*\)$/\1 \2/p' -n) =

== Informations ==

$(cat ${CATALOGDIR}/$(uname -m)/${categ}/$(nom_court ${pkglog}).header | sed -e 's@^@  - @' -e '/DESCRIPTION DU PAQUET/d' -e "s@^$(nom_court ${pkglog}):@@g")


== Installation ==

"""
<code bash>
0g $(nom_court ${pkglog})
</code>
"""

== Ressources ==

  - Télécharger le paquet : [HTTP http://marmite.0linux.org/ftp/paquets/$(uname -m)/${categ}/$(basename ${pkglog}).spack] [FTP ftp://marmite.0linux.org/ftp/paquets/$(uname -m)/${categ}/$(basename ${pkglog}).spack]
  - Sources : [Recette 0Linux http://git.tuxfamily.org/0linux/0linux.git?p=0linux/0linux.git;a=tree;f=0Linux/${categ}] | [Archives sources http://marmite.0linux.org/ftp/archives_sources/$(basename ${categ})]


== Interactions inter-paquets ==

|| Dépendances |
$(cat ${CATALOGDIR}/$(uname -m)/${categ}/$(nom_court ${pkglog}).dep | sed -e "s@\(^\).*\($\)@| [\1&\2]  |@" -e '/| \[.*/s/\+/_/2g')
  
|| Dépendants |
$(cat ${CATALOGDIR}/$(uname -m)/${categ}/$(nom_court ${pkglog}).reqby 2>/dev/null | sed -e "s@\(^\).*\($\)@| [\1&\2]  |@" -e '/| \[.*/s/\+/_/2g')

== Contenu ==

|| Fichiers installés  |
$(cat ${CATALOGDIR}/$(uname -m)/${categ}/$(nom_court ${pkglog}).list | sed "s@\(^\).*\($\)@| \\\`\\\`\1&\2\\\`\\\`  |@")

EOF
		
		# On nettoie :
		rm -f ${CATALOGDIR}/$(uname -m)/${categ}/$(nom_court ${pkglog}).{dep*,header,list*,reqby*}
		
		# On génère la sortie finale :
		#txt2tags -q -t xhtml ${CATALOGDIR}/$(uname -m)/${categ}/$(nom_court ${pkglog}).t2t
		txt2tags -q -t doku -o ${CATALOGDIR}/$(uname -m)/${categ}/$(nom_court ${pkglog}).txt ${CATALOGDIR}/$(uname -m)/${categ}/$(nom_court ${pkglog}).t2t
		rm -f ${CATALOGDIR}/$(uname -m)/${categ}/$(nom_court ${pkglog}).t2t
		
		# On passe à la génération des index des catégories si $NOINDEX n'est pas spécifiée :
		if [ -z ${NOINDEX} ]; then
			# L'index concerné :
			INDEXNAME="$(echo ${categ} | cut -d'/' -f1)"
			echo "Génération de l'index pour la catégorie '${INDEXNAME}/'..." 
			
			# On nettoie l'index associé à la catégorie du paquet demandé, qu'on va régénérer :
			rm -f ${CATALOGDIR}/$(uname -m)/${INDEXNAME}/accueil.txt
			
			# On remplit une liste. Pour chaque paquet de la catégorie :
			for categpaquet in $(find ${CATALOGDIR}/$(uname -m)/${INDEXNAME} -type f -name "*.txt" -a \! -name "accueil.txt"); do
				
				# On crée les champs "paquet url" pour créer chaque entrée dans l'index:
				echo "$(echo $(basename ${categpaquet}) | sed 's@\.txt$@@g') ${CATALOGURL}/$(uname -m)/$(echo ${categpaquet} | sed -e  "s@^${CATALOGDIR}/$(uname -m)/@@" -e 's@\.txt$@@g')"
			done | sort > ${CATALOGDIR}/$(uname -m)/${INDEXNAME}/accueil.index
			
			[ "${INDEXNAME}" = "a" ] && CATDESC="a : Applications exécutables en console n'entrant dans aucune autre catégorie."
			[ "${INDEXNAME}" = "b" ] && CATDESC="b : Bibliothèques non rattachées à un environnement particulier."
			[ "${INDEXNAME}" = "d" ] && CATDESC="d : Développement. Compilateurs, débogueurs, interpréteurs, etc."
			[ "${INDEXNAME}" = "e" ] && CATDESC="e : Environnements. KDE, Xfce, GNOME, Enlightenment et autres environnements."
			[ "${INDEXNAME}" = "g" ] && CATDESC="g : applications Graphiques nécessitant X, non rattachées à un environnement."
			[ "${INDEXNAME}" = "j" ] && CATDESC="j : Jeux, graphiques ou en mode texte, non rattachés à un environnement."
			[ "${INDEXNAME}" = "r" ] && CATDESC="r : Réseau. Clients, serveurs gérant ou utilisant le réseau en console."
			[ "${INDEXNAME}" = "x" ] && CATDESC="x : X.org, l'implémentation libre et distribution officielle de X11"
			[ "${INDEXNAME}" = "z" ] && CATDESC="z : Zérolinux : paquets-abonnements, facilitant l'installation d'ensembles."
			
			# On n'a plus qu'à créer le document txt2tags :
			cat > ${CATALOGDIR}/$(uname -m)/${INDEXNAME}/accueil.t2t << EOF
Paquets de la catégorie ${CATDESC}
Équipe 0Linux <contact@0linux.org>
Généré le %%mtime(%d/%m/%Y)

%!encoding: UTF-8

|| Nom  |
$(cat ${CATALOGDIR}/$(uname -m)/${INDEXNAME}/accueil.index  | sed -e 's@\(^.*\)\(.*$\)@| [\1\2]  | @' -e '/| \[.*/s/\+/_/2g')

EOF
			
			# On génère la sortie finale :
			#txt2tags -q -t xhtml ${CATALOGDIR}/$(uname -m)/${INDEXNAME}/accueil.t2t
			txt2tags -q -t doku -o ${CATALOGDIR}/$(uname -m)/${INDEXNAME}/accueil.txt ${CATALOGDIR}/$(uname -m)/${INDEXNAME}/accueil.t2t
			rm -f ${CATALOGDIR}/$(uname -m)/${INDEXNAME}/accueil.t2t
			
			# On nettoie :
			rm -f ${CATALOGDIR}/$(uname -m)/${INDEXNAME}/*.index
		fi
	done
}

# On évite les problèmes de locales, notamment pour 'sort' :
export LC_ALL='C'

for argument in $@; do
	scan "${argument}"
done

exit 0
