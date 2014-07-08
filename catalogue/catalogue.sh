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
		#  (ça arrive plutôt souvent en fait) :
		else
			find ${CATALOGDIR} -type d -name "$(nom_court ${pkglog})" -exec rm -rf {} \; 2>/dev/null
		fi
		
		# On traite différemment les paquets dégueus, installés sur la racine $UGLYPKGROOT :
		if [ "$(nom_court ${pkglog})" = "catalyst" -o "$(nom_court ${pkglog})" = "nvidia" ]; then
			PKGLOGDIR="${UGLYPKGROOT}/${PKGLOGDIR}"
		else
			PKGLOGDIR="${PKGLOGDIR}"
		fi
		
		# On crée le répertoire d'accueil :
		mkdir -p ${CATALOGDIR}/${categ}
		
		# On va créer des logs temporaires et les assembler plus tard dans un document txt2tags.
		
		# On récupère les entêtes (nom, taille, description...) :
		spacklist --directory="${PKGLOGDIR}" -v $(nom_court ${pkglog}) | sed '/^EMPLACEMENT/d' > ${CATALOGDIR}/${categ}/$(basename ${pkglog}).header
		
		# On récupère la liste nettoyée des fichiers installés + les liens symboliques placés :
		( spacklist --directory="${PKGLOGDIR}" -V $(nom_court ${pkglog}) | \
			sed -e '/NOM DU PAQUET.*$/,/\.\//d' ; \
			spacklist --directory="${PKGLOGDIR}" -v -p $(nom_court ${pkglog}) | \
			sed -e 's@^/@@' -e '/------/d' -e '/^> /d' -e '/^\/\./d' ) | \
			sort > ${CATALOGDIR}/${categ}/$(basename ${pkglog}).list
		
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
0Linux : détails du paquet ${categ}/$(basename ${pkglog})
Équipe 0Linux <contact@0linux.org>
%%mtime(%d/%m/%Y)

%!encoding: UTF-8

= $(echo $(basename ${pkglog}) | sed 's/\(^.*\)-\(.*\)-\(.*\)-\(.*\)$/\1 \2/p' -n) =

$(cat ${CATALOGDIR}/${categ}/$(basename ${pkglog}).header)

Installation : ``0g $(nom_court ${pkglog})``
Téléchargements : Paquet [HTTP http://marmite.0linux.org/ftp/paquets/$(uname -m)/${categ}/$(basename ${pkglog}).spack ] [FTP ftp://marmite.0linux.org/ftp/paquets/$(uname -m)/${categ}/$(basename ${pkglog}).spack] | [Recette http://git.tuxfamily.org/0linux/0linux.git?p=0linux/0linux.git;a=tree;f=0Linux/${categ}] | Sources http://marmite.0linux.org/ftp/archives_sources/$(basename ${categ})]

  ||  Dépendances  |
$(cat ${CATALOGDIR}/${categ}/$(basename ${pkglog}).dep | sed 's/\(^\).*\($\)/   |  \1&\2  |/')
  
  ||  Dépendants  |
$(cat ${CATALOGDIR}/${categ}/$(basename ${pkglog}).reqby | sed 's/\(^\).*\($\)/   |  \1&\2  |/')

  ||  Fichiers installés  |
$(cat ${CATALOGDIR}/${categ}/$(basename ${pkglog}).list | sed 's/\(^\).*\($\)/   |  \1&\2  |/')

EOF

}

# On évite les problèmes de locales, notamment pour 'sort' :
export LC_ALL='C'

scan "$@"

exit 0

	if [ $(find ${CATALOGDIR} -type f -name ${pkglog}.t2t | wc -l) -gt 0 ]; then
		continue
	else
		break
	fi


spacklist -v ${pkg} :

NOM DU PAQUET : libpng-1.6.9-x86_64-2
TAILLE COMPRESSÉE : 643 Kio
TAILLE DÉCOMPRESSÉE : 2913 Kio
EMPLACEMENT DU PAQUET : /home/appzer0/0/pub/paquets/eta/x86_64/b/libpng/libpng-1.6.9-x86_64-2.spack
DESCRIPTION DU PAQUET :
${pkg}: gnagnagna

Fichiers installés :
( spacklist -V libpng | sed -e '/NOM DU PAQUET.*$/,/\.\//d' ; spacklist -v -p libpng | sed -e 's@^/@@' -e '/------/d' -e '/^> /d' -e '/^\/\./d' ) | LC_ALL=C  sort

cat > ${TMP}/${NAMETGZ}.t2t << EOF
0LINUX
base-systeme
Mars 2014

%!postproc(man): "^(\.TH.*) 1 "  "\1 7 "
%!encoding: UTF-8

= NOM =[nom]

0Linux - Un système Linux francophone, didactique et original

= DESCRIPTION =[description]

Un survol rapide de la configuration de 0Linux.

= OUTILS DE 0LINUX =[outilsde0linux]

0Linux se configure via certains outils dédiés pour éviter d'avoir à chercher quel fichier gère quelle fonction. Tous les outils de 0linux commencent par un « 0 », afin qu'il soit aisé de parcourir tous les outils disponibles via l'auto-complètement de la ligne de commande, en tapant simplement « 0 » suivi de 2 frappes sur la touche TABULATION (ou TAB).

= SYSTÈMES DE FICHIERS ET MONTAGES =[systemesdefichiersetmontages]

Les systèmes de fichiers à monter sont spécifiés dans le fichier __/etc/fstab__.
Les systèmes de fichiers CHIFFRÉS sont spécifiés dans le fichier __/etc/crypttab__.

= SERVICES DU SYSTÈME =[servicesdusysteme]

Les services du système sont gérés par de simples scripts nommés « rc.* » et rangés dans __/etc/rc.d/rc.*__.  On les rend actifs au démarrage de l'ordinateur en les rendant exécutables (chmod +x) et on les appelle en les exécutant, comme de simples scripts.

= PARAMÉTRAGE DU RÉSEAU ET NOM D'HÔTE =[arametragedureseauetnomdhote]

On définit le nom d'hôte ainsi que les paramètres de connexion au réseau en renseignant le fichier __/etc/0linux/reseau__. Un outil dédié existe, **__0reseau__**.

= LANGUE DU SYSTÈME =[languedusysteme]

On définit la langue et la localisation du système en définissant les variables $LANG et $LC_ALL dans le fichier __/etc/0linux/locale__. Un outil dédié existe : **__0locale__**.

= DISPOSITION DES TOUCHES DU CLAVIER POUR LA CONSOLE VIRTUELLE =[dispositiondestouchesduclavierpourlaconsolevirtuelle]

On définit la disposition de touches du clavier dans la console en renseignant le fichier __/etc/0linux/clavier__, contenant une variable $CLAVIER. Le clavier se définit aussi via l'outil dédié **__0clavier__**, lequel permet de tester les dispositions de clavier.

= POLICE DE CARACTÈRES DE LA CONSOLE VIRTUELLE =[policedecaracteresdelaconsolevirtuelle]

On définit la police d ecaractères à charger dans la console virtuelle en renseignant le fichier __/etc/0linux/police__, contenant une variable $POLICE. Le clavier se définit aussi via l'outil dédié **__0police__**, lequel permet de tester les polices de caractères disponibles.

= FUSEAU HORAIRE =[fuseauhoraire]

Le fuseau horaire se définit avec l'outil dédié **__0horloge__**. Ces commandes servent à créer un lien symbolique __/etc/localtime__ pointant sur le fichier de fuseau horaire choisi sous __/usr/share/zoneinfo/__. Par exemple :

/etc/localtime -> /usr/share/zoneinfo/Europe/Paris

= GESTION DES PAQUETS =[gestiondespaquets]

Les paquets sont gérés par **Spack** (en particulier les programmes 'spackadd' et 'spackrm') et l'outil de gestion des dépôts et mises à jour, **0g**. Voyez leur manuel respectif pour en savoir plus.

= AMORÇAGE DU SYSTÈME =[amorcagedusysteme]

Le gestionnaire d'amorçage du système est **extlinux**, un outil du paquet **syslinux**. Sa configuration se trouve dans __/boot/extlinux/extlinux.conf__.

= MODULES DU NOYAU =[modulesdunoyau]

Les modules sont chargés automatiquement selon le matériel. Pour forcer le chargement d'un module donné, ajoutez-le à un fichier dédié sous __/etc/modprobe.d/__. Pour empêcher un module de se charger, ajoutez une commande 'blacklist' adaptée au module dans le fichier __/etc/modprobe.d/blacklist.conf__ ou bien créez dans ce même répertoire un fichier du nom de votre choix, contenant la commande 'blacklist' à invoquer.

= POUR EN SAVOIR PLUS =[pourensavoirplus]

Voyez ces manuels :

tzselect(8), hostname(5),, timezone(3), fstab(5), crypttab(5), modprobe.d(5), 
extlinux(1), 0g(8), 'spackadd --help', 'spackrm --help'.

Et consultez la documentation sur le site de 0linux : [http://0linux.org]

EOF

# On génère la description dans les différents formats :
mkdir -p ${PKG}/var/log/0abonnements
for format in html txt; do
	txt2tags --encoding=UTF-8 -t ${format} -o ${PKG}/var/log/0abonnements/${NAMETGZ}.${format} ${TMP}/${NAMETGZ}.t2t
done
