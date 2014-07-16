#!/usr/bin/env bash
# Création/mise à jour du catalogue en ligne des paquets de 0Linux.

# On affecte les variables du système (notamment $VERSION) :
source /etc/os-release

# Emplacement du dépôt des paquets :
PKGREPO=${PKGREPO:-/usr/local/paquets/${VERSION}/$(uname -m)}

# Emplacement de la racine des paquets invasifs ('nvidia', 'catalyst'...) installés
# ailleurs pour ne pas polluer le système :
UGLYPKGROOT=${UGLYPKGROOT:-/tmp/paquets_invasifs}

# Les journaux des paquets :
PKGLOGDIR=${PKGLOGDIR:-/var/log/packages}
PKGPOSTDIR=${PKGPOSTDIR:-/var/log/scripts}

# Le catalogue qui va accueillir les résultats du scan :
CATALOGDIR=${CATALOGDIR:-/home/appzer0/0/pub/catalogue}

# L'URL du catalogue en ligne (ici, le namespace - en relatif - du wiki de 0Linux) :
CATALOGURL=${CATALOGURL:-paquets:}

# Affiche le nom court ("gcc", "pkg-config"...) du journal demandé.
# $f JOURNAL
nom_court() {
	echo $(basename "${1}" | sed 's/\(^.*\)-\(.*\)-\(.*\)-\(.*\)$/\1/p' -n)
}

# Scanne les paquets fournis.
# $f JOURNAUX DE PAQUETS
scan() {
	for pkglog in "${1}"; do
		
		# On déduit le répertoire du paquet selon son emplacement en le découpant.
		# Retourne un chemin du type : "e/kde/kdeartwork/kdeartwork".
		categ=$(dirname $(spacklist --directory="${PKGLOGDIR}" -v $(nom_court ${pkglog}) | \
			egrep '^EMPLACEMENT' | cut -d':' -f2) | sed -e "s@^.*$(uname -m)/@@")
		
		if [ "${categ}" = "" ]; then
			echo "Erreur : catégorie introuvable."
			exit 1
		fi
		
		# Si le log en txt2tags est présent, on ignore le scan :
		if [ -r ${CATALOGDIR}/${VERSION}/$(uname -m)/${categ}/$(nom_court ${pkglog}).t2t ]; then
			echo "Catalogue pour '$(nom_court ${pkglog})' ignoré car déjà présent."
			continue
		
		# Sinon, on supprime toute trace, y compris d'un récent déplacement de paquet
		# (ça arrive plutôt souvent en fait) :
		else
			echo "Génération du catalogue pour '$(nom_court ${pkglog})'..."
			find ${CATALOGDIR}/${VERSION}/$(uname -m) -type d -name "$(nom_court ${pkglog})" -exec rm -rf {} \; 2>/dev/null || true
		fi
		
		# On traite différemment les paquets dégueus, installés sur la racine $UGLYPKGROOT :
		if [ "$(nom_court ${pkglog})" = "catalyst" -o "$(nom_court ${pkglog})" = "nvidia" ]; then
			PKGLOGDIR="${UGLYPKGROOT}/${PKGLOGDIR}"
			PKGPOSTDIR="${UGLYPKGROOT}/${PKGPOSTDIR}"
			TARGETROOT="${UGLYPKGROOT}" # Pour scanner les '*.dep' dans '$TARGETROOT/usr/doc'
		else
			PKGLOGDIR="${PKGLOGDIR}"
			PKGPOSTDIR="${PKGPOSTDIR}"
			TARGETROOT=""
		fi
		
		# On crée le répertoire d'accueil :
		mkdir -p ${CATALOGDIR}/${VERSION}/$(uname -m)/${categ}
		
		# On va créer des logs temporaires et les assembler plus tard dans un document txt2tags.
		
		# On récupère les entêtes (nom, taille, description...) :
		spacklist --directory="${PKGLOGDIR}" -v $(nom_court ${pkglog}) | sed '/^EMPLACEMENT/d' > ${CATALOGDIR}/${VERSION}/$(uname -m)/${categ}/$(nom_court ${pkglog}).header
		
		# On récupère la liste nettoyée des fichiers installés :
		touch ${CATALOGDIR}/${VERSION}/$(uname -m)/${categ}/$(nom_court ${pkglog}).list.tmp
		
		spacklist --directory="${PKGLOGDIR}" -V $(nom_court ${pkglog}) | \
			sed -e '/NOM DU PAQUET.*$/,/\.\//d' \
			> ${CATALOGDIR}/${VERSION}/$(uname -m)/${categ}/$(nom_court ${pkglog}).list.tmp
		
		# On ajoute la liste nettoyée des liens symboliques traités en post-installation :
		spacklist --directory="${PKGPOSTDIR}" -v -p $(nom_court ${pkglog}) | \
			sed -e 's@^/@@' -e '/------/d' -e '/^> /d' -e '/^\.\/$/d' \
			>> ${CATALOGDIR}/${VERSION}/$(uname -m)/${categ}/$(nom_court ${pkglog}).list.tmp
		
		# On réunit le tout, qu'on trie dans l'ordre :
		sort ${CATALOGDIR}/${VERSION}/$(uname -m)/${categ}/$(nom_court ${pkglog}).list.tmp > ${CATALOGDIR}/${VERSION}/$(uname -m)/${categ}/$(nom_court ${pkglog}).list
		rm -f ${CATALOGDIR}/${VERSION}/$(uname -m)/${categ}/$(nom_court ${pkglog}).list.tmp
		
		# On récupère les dépendances en nettoyant le paquet concerné.
		# Pour chaque dépendance :
		cat ${TARGETROOT}/usr/doc/$(nom_court ${pkglog})/0linux/$(basename ${pkglog}).dep | sort | while read linedep; do
			
			# On déduit le répertoire du paquet en dépendance selon son emplacement en le découpant.
			# Retourne un chemin du type : "e/kde/kdeartwork/kdeartwork".
			depcateg=$(dirname $(spacklist --directory="${PKGLOGDIR}" -v ${linedep} | \
				egrep '^EMPLACEMENT' | cut -d':' -f2) | sed -e "s@^.*$(uname -m)/@@")
			
			# On crée le champ "paquet url" pour créer chaque lien hypertexte :
			echo "${linedep} ${CATALOGURL}/${VERSION}/$(uname -m)/${depcateg}/${linedep}.txt"
			
		done | sed "/$(nom_court ${pkglog})\.txt$/d" > ${CATALOGDIR}/${VERSION}/$(uname -m)/${categ}/$(nom_court ${pkglog}).dep
		
		# On récupère les dépendants en scannant les autres journaux '*.dep' :
		touch ${CATALOGDIR}/${VERSION}/$(uname -m)/${categ}/$(nom_court ${pkglog}).reqby.tmp
		
		for reqlog in /usr/doc/*/0linux/*.dep; do
			if grep -E -q "^$(nom_court ${pkglog})$" ${reqlog}; then
				
				# On déduit le répertoire du paquet en dépendance selon son emplacement en le découpant.
				# Retourne un chemin du type : "e/kde/kdeartwork/kdeartwork".
				reqcateg=$(dirname $(spacklist --directory="${PKGLOGDIR}" -v $(nom_court $(echo ${reqlog} | sed 's@\.dep$@@')) | \
					egrep '^EMPLACEMENT' | cut -d':' -f2) | sed -e "s@^.*$(uname -m)/@@")
				
				echo "$(nom_court $(echo ${reqlog} | sed 's@\.dep$@@')) ${CATALOGURL}/${VERSION}/$(uname -m)/${reqcateg}/$(nom_court $(echo ${reqlog} | sed 's@\.dep$@@')).txt" >> ${CATALOGDIR}/${VERSION}/$(uname -m)/${categ}/$(nom_court ${pkglog}).reqby.tmp
			fi
		done
		
		# On trie :
		sort -u ${CATALOGDIR}/${VERSION}/$(uname -m)/${categ}/$(nom_court ${pkglog}).reqby.tmp | sed "/$(nom_court ${pkglog})\.txt$/d" > ${CATALOGDIR}/${VERSION}/$(uname -m)/${categ}/$(nom_court ${pkglog}).reqby
		rm -f ${CATALOGDIR}/${VERSION}/$(uname -m)/${categ}/$(nom_court ${pkglog}).reqby.tmp
	
		# On génère le document txt2tags :
		cat > ${CATALOGDIR}/${VERSION}/$(uname -m)/${categ}/$(nom_court ${pkglog}).t2t << EOF
Détails du paquet ${categ}/$(basename ${pkglog}) pour 0Linux ${VERSION} $(uname -m)
Équipe 0Linux <contact@0linux.org>
Généré le %%mtime(%d/%m/%Y)

%!encoding: UTF-8

= $(echo $(basename ${pkglog}) | sed 's/\(^.*\)-\(.*\)-\(.*\)-\(.*\)$/\1 \2/p' -n) =

== Informations ==

$(cat ${CATALOGDIR}/${VERSION}/$(uname -m)/${categ}/$(nom_court ${pkglog}).header | sed -e 's@^@  - @' -e '/DESCRIPTION DU PAQUET/d')


== Installation ==

``0g $(nom_court ${pkglog})``

== Ressources ==

  - Télécharger le paquet : [HTTP http://marmite.0linux.org/ftp/paquets/$(uname -m)/${categ}/$(basename ${pkglog}).spack] [FTP ftp://marmite.0linux.org/ftp/paquets/$(uname -m)/${categ}/$(basename ${pkglog}).spack]
  - Sources : [Recette 0Linux http://git.tuxfamily.org/0linux/0linux.git?p=0linux/0linux.git;a=tree;f=0Linux/${categ}] | [Archives sources http://marmite.0linux.org/ftp/archives_sources/$(basename ${categ})]


== Interactions inter-paquets ==

|| Dépendances |
$(cat ${CATALOGDIR}/${VERSION}/$(uname -m)/${categ}/$(nom_court ${pkglog}).dep | sed -e "s@\(^\).*\($\)@| [\1&\2]  |@" -e 's/\+/%2B/g')
  
|| Dépendants |
$(cat ${CATALOGDIR}/${VERSION}/$(uname -m)/${categ}/$(nom_court ${pkglog}).reqby | sed -e "s@\(^\).*\($\)@| [\1&\2]  |@" -e 's/\+/%2B/g')

== Contenu ==

|| Fichiers installés  |
$(cat ${CATALOGDIR}/${VERSION}/$(uname -m)/${categ}/$(nom_court ${pkglog}).list | sed "s@\(^\).*\($\)@| \\\`\\\`\1&\2\\\`\\\`  |@")

EOF
		
		# On nettoie :
		rm -f ${CATALOGDIR}/${VERSION}/$(uname -m)/${categ}/$(nom_court ${pkglog}).{dep*,header,list*,reqby*}
		
		# On génère la sortie finale :
		#txt2tags -t xhtml ${CATALOGDIR}/${VERSION}/$(uname -m)/${categ}/$(nom_court ${pkglog}).t2t
		txt2tags -t doku -o ${CATALOGDIR}/${VERSION}/$(uname -m)/${categ}/$(nom_court ${pkglog}).txt ${CATALOGDIR}/${VERSION}/$(uname -m)/${categ}/$(nom_court ${pkglog}).t2t
		
		### On page à la génération des index des catégories ###
		
		# L'index concerné :
		INDEXNAME="$(echo ${categ} | cut -d'/' -f1)"
		
		# On nettoie l'index associé à la catégorie du paquet demandé, qu'on va régénérer :
		rm -f ${CATALOGDIR}/${VERSION}/$(uname -m)/${INDEXNAME}/accueil.txt
		
		# On remplit une liste. Pour chaque paquet de la catégorie :
		for categpaquet in $(find ${CATALOGDIR}/${VERSION}/$(uname -m)/${INDEXNAME} -type f -name "*.txt" -a \! -name "accueil.txt"); do
			
			# On crée le champ "paquet url" pour créer chaque lien hypertexte dans l'index:
			echo "$(basename ${categpaquet} | sed 's@\.txt$@@') ${CATALOGURL}/${VERSION}/$(uname -m)/$(echo ${categpaquet} | sed "s@^${CATALOGDIR}/${VERSION}/$(uname -m)/@@")"
		done | sort > ${CATALOGDIR}/${VERSION}/$(uname -m)/${INDEXNAME}/accueil.index
		
		[ "${INDEXNAME}" = "a" ] && CATDESC="a : Applications exécutables en console n'entrant dans aucune autre catégorie."
		[ "${INDEXNAME}" = "b" ] && CATDESC="b : Bibliothèques non rattachées à un environnement particulier."
		[ "${INDEXNAME}" = "d" ] && CATDESC="d : Développement. Compilateurs, débogueurs, interpréteurs, etc."
		[ "${INDEXNAME}" = "e" ] && CATDESC="e : Environnements. KDE, Xfce, GNOME, Enlightenment et autres environnements."
		[ "${INDEXNAME}" = "g" ] && CATDESC="g : applications Graphiques nécessitant X, non rattachées à un environnement."
		[ "${INDEXNAME}" = "r" ] && CATDESC="r : Réseau. Clients, serveurs gérant ou utilisant le réseau en console."
		[ "${INDEXNAME}" = "x" ] && CATDESC="x : X.org, l'implémentation libre et distribution officielle de X11"
		[ "${INDEXNAME}" = "z" ] && CATDESC="z : Zérolinux : paquets-abonnements, facilitant l'installation d'ensembles."
		
		# On n'a plus qu'à créer le document txt2tags :
		cat > ${CATALOGDIR}/${VERSION}/$(uname -m)/${INDEXNAME}/accueil.t2t << EOF
Paquets de la catégorie ${CATDESC}
Équipe 0Linux <contact@0linux.org>
Généré le %%mtime(%d/%m/%Y)

%!encoding: UTF-8

$(cat ${CATALOGDIR}/${VERSION}/$(uname -m)/${INDEXNAME}/accueil.index | sed -e "s@\(^\).*\($\)@  - [\1&\2]@" -e 's/\+/%2B/g')

EOF
		
		# On génère la sortie finale :
		#txt2tags -t xhtml ${CATALOGDIR}/${VERSION}/$(uname -m)/${INDEXNAME}/accueil.t2t
		txt2tags -t doku -o ${CATALOGDIR}/${VERSION}/$(uname -m)/${INDEXNAME}/accueil.txt ${CATALOGDIR}/${VERSION}/$(uname -m)/${INDEXNAME}/accueil.t2t
		
		# On nettoie :
		rm -f ${CATALOGDIR}/${VERSION}/$(uname -m)/${INDEXNAME}/*.index
	done
}

# On évite les problèmes de locales, notamment pour 'sort' :
export LC_ALL='C'

for arg in "$@"; do
	scan "${arg}"
done

exit 0
