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
CATALOGDIR=${CATALOGDIR:-/home/appzer0/0/pub/catalogue/${VERSION}/$(uname -m)}

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
		if [ -r ${CATALOGDIR}/${categ}/$(basename ${pkglog}).t2t ]; then
			continue
		
		# Sinon, on supprime toute trace, y compris d'un récent déplacement de paquet
		# (ça arrive plutôt souvent en fait) :
		else
			find ${CATALOGDIR} -type d -name "$(nom_court ${pkglog})" -exec rm -rf {} \; 2>/dev/null
		fi
		
		# On traite différemment les paquets dégueus, installés sur la racine $UGLYPKGROOT :
		if [ "$(nom_court ${pkglog})" = "catalyst" -o "$(nom_court ${pkglog})" = "nvidia" ]; then
			PKGLOGDIR="${UGLYPKGROOT}/${PKGLOGDIR}"
			PKGPOSTDIR="${UGLYPKGROOT}/${PKGPOSTDIR}"
		else
			PKGLOGDIR="${PKGLOGDIR}"
			PKGPOSTDIR="${PKGPOSTDIR}"
		fi
		
		# On crée le répertoire d'accueil :
		mkdir -p ${CATALOGDIR}/${categ}
		
		# On va créer des logs temporaires et les assembler plus tard dans un document txt2tags.
		
		# On récupère les entêtes (nom, taille, description...) :
		spacklist --directory="${PKGLOGDIR}" -v $(nom_court ${pkglog}) | sed '/^EMPLACEMENT/d' > ${CATALOGDIR}/${categ}/$(basename ${pkglog}).header
		
		# On récupère la liste nettoyée des fichiers installés + les liens symboliques placés :
		spacklist --directory="${PKGLOGDIR}" -V $(nom_court ${pkglog}) | \
			sed -e '/NOM DU PAQUET.*$/,/\.\//d' \
			> ${CATALOGDIR}/${categ}/$(basename ${pkglog}).list.tmp
		
		spacklist --directory="${PKGLOGDIR}" -v -p $(nom_court ${pkglog}) | \
			sed -e 's@^/@@' -e '/------/d' -e '/^> /d' -e '/^\.\/$/d' \
			>> ${CATALOGDIR}/${categ}/$(basename ${pkglog}).list.tmp
		
		sort ${CATALOGDIR}/${categ}/$(basename ${pkglog}).list.tmp > ${CATALOGDIR}/${categ}/$(basename ${pkglog}).list
		rm -f ${CATALOGDIR}/${categ}/$(basename ${pkglog}).list.tmp
		
		if [ ! "$(echo ${PKGLOGDIR} | grep ${UGLYPKGROOT})" = "" ]; then
			TARGETROOT="${UGLYPKGROOT}"
		else
			TARGETROOT=""
		fi
		
		# On récupère les dépendances en nettoyant le paquet concerné :
		cat ${TARGETROOT}/usr/doc/$(nom_court ${pkglog})/0linux/$(basename ${pkglog}).dep | \
			sed "/^$(nom_court ${pkglog})$/d" | \
			sort > ${CATALOGDIR}/${categ}/$(basename ${pkglog}).dep
		
		# On récupère les dépendants en scannant les autres journaux '*.dep' :
		touch ${CATALOGDIR}/${categ}/$(basename ${pkglog}).reqby.tmp
		
		for deplog in /usr/doc/*/0linux/*.dep; do
			if egrep -q "^$(nom_court ${pkglog})$" ${deplog}; then
				echo "$(nom_court ${deplog})" >> ${CATALOGDIR}/${categ}/$(basename ${pkglog}).reqby.tmp
			fi
		done
		
		# On trie :
		sort -u ${CATALOGDIR}/${categ}/$(basename ${pkglog}).reqby.tmp | sed '/^$(nom_court ${pkglog})$/d' > ${CATALOGDIR}/${categ}/$(basename ${pkglog}).reqby
		rm -f ${CATALOGDIR}/${categ}/$(basename ${pkglog}).reqby.tmp
	done
	
	# On génère le document txt2tags :
	cat > ${CATALOGDIR}/${categ}/$(basename ${pkglog}).t2t << EOF
Détails du paquet ${categ}/$(basename ${pkglog}) pour 0Linux ${VERSION} $(uname -m)
Équipe 0Linux <contact@0linux.org>
%%mtime(%d/%m/%Y)

%!encoding: UTF-8

= $(echo $(basename ${pkglog}) | sed 's/\(^.*\)-\(.*\)-\(.*\)-\(.*\)$/\1 \2/p' -n) =

== Informations ==

$(cat ${CATALOGDIR}/${categ}/$(basename ${pkglog}).header | sed -e 's@^@  - @' -e '/DESCRIPTION DU PAQUET/d')


== Installation et ressources==

  - ``Installation : 0g $(nom_court ${pkglog})``
  - Télécharger le paquet : [HTTP http://marmite.0linux.org/ftp/paquets/$(uname -m)/${categ}/$(basename ${pkglog}).spack] [FTP ftp://marmite.0linux.org/ftp/paquets/$(uname -m)/${categ}/$(basename ${pkglog}).spack]
  - Sources : [Recette 0Linux http://git.tuxfamily.org/0linux/0linux.git?p=0linux/0linux.git;a=tree;f=0Linux/${categ}] | [Archives sources http://marmite.0linux.org/ftp/archives_sources/$(basename ${categ})]


== Interactions inter-paquets ==

|| Dépendances |
$(cat ${CATALOGDIR}/${categ}/$(basename ${pkglog}).dep | sed 's/\(^\).*\($\)/| \1&\2  |/')
  
|| Dépendants |
$(cat ${CATALOGDIR}/${categ}/$(basename ${pkglog}).reqby | sed 's/\(^\).*\($\)/| \1&\2  |/')

== Contenu ==

|| Fichiers installés  |
$(cat ${CATALOGDIR}/${categ}/$(basename ${pkglog}).list | sed 's/\(^\).*\($\)/| \1&\2  |/')

EOF

}

# On évite les problèmes de locales, notamment pour 'sort' :
export LC_ALL='C'

for arg in "$@"; do
	scan "${arg}"
done

exit 0
