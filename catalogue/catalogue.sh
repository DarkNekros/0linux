#!/usr/bin/env bash
# Création/mise à jour du catalogue en ligne des paquets de 0Linux.

# Emplacement du dépôt des paquets :
PKGREPO=${PKGREPO:-/usr/local/paquets}

# Liste les fichiers du paquet demandé.
# $f PAQUET
lister_fichiers() {
	cpio --quiet -i --to-stdout "files.xz"  < "$1" | xz -d -c | cpio --quiet --list
}

humansize () {
# Affiche les tailles de manière lisible.
# $f TAILLE EN KILO-OCTETS
POSIXLY_CORRECT=Y awk 'BEGIN{split("G M K", u); x=1048576
                                 while (++i && x >= '$1')
                                     x/=1024
                                 printf("%.2f %sio\n", '$1'/x, u[i])}'
}

humansize 2913

exit 1
# Pour chaque archi et chaque catégorie, on scanne chaque paquet :
for archi in arm i686 x86_64; do
	for categ in a b d e g j r x z; do
		
		# On ignore si le répertoire demandé n'existe pas :
		if [ ! -d ${PKGREPO}/${archi}/${categ} ]; then
			continue
		else
			for paq in $(find ${PKGREPO}/${archi}/${categ} -type f -name "*.spack" | sort); do
				lister_fichiers ${paq}
			done
		fi
	done
done






humansize () {
    # Affiche les tailles de manière lisible.
    # $f TAILLE EN KILO-OCTETS
    POSIXLY_CORRECT=Y awk 'BEGIN{split("G M K", u); x=1048576
                                 while (++i && x >= '$1')
                                     x/=1024
                                 printf("%.1f %sio\n", '$1'/x, u[i])}'
}

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
