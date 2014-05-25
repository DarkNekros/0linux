#!/usr/bin/env bash

# Configuration de base :
set -e
umask 022

# Fonction qui quitte le processus et émet un message :
# $f "MESSAGE"
argh() {
	echo "${1}"
	exit 1
}

# Le répertoire courant :
CWD=$(pwd)

# Emplacement où on compile et on empaquète :
MARMITE=${MARMITE:-/tmp/0-marmite}

# ...et où on stocke les journaux de compilation :
MARMITELOGS=${MARMITELOGS:-${MARMITE}/logs}

# Emplacement où on stocke les archives sources :
PKGSOURCES=${PKGSOURCES:-${CWD}}

# Emplacement du dépôt des paquets résultant de la construction :
PKGREPO=${PKGREPO:-/usr/local/paquets}

# On crée la marmite :
mkdir -p ${MARMITE}
mkdir -p ${MARMITELOGS}

# On vérifie si on appelle ces fonctions depuis une recette :
if [ "$(echo $(basename $0) | egrep '\.recette$')" = "" ]; then
	# On appelle les 'fonctions_paquets.sh' depuis un script autre qu'une recette.
	# Emplacement où on compile et on empaquète : :
	TMP=${TMP:-${MARMITE}}
else
	# On appelle bien les 'fonctions_paquets.sh' depuis une recette.
	# On définit $NAMETGZ selon le nom de la recette s'il n'est pas déjà défini :
	[ -z ${NAMETGZ} ] && NAMETGZ="$(basename $0 .recette)"
	
	# Les noms ne doivent comporter ni majuscules, ni espaces :
	if [ ! "$(echo ${NAMETGZ} | egrep '[A-Z]|[[:space:]]')" = "" ]; then
		argh "La variable NAMETGZ ne doit comporter ni majuscules ni espaces."
	fi
	
	# On crée un journal complet automatiquement en plus des messages à l'écran.
	# Voir http://stackoverflow.com/a/11886837 - c'est en fait loin d'être
	# évident à faire depuis un script :
	rm -f ${MARMITELOGS}/${NAMETGZ}.log
	exec >  >(tee -a ${MARMITELOGS}/${NAMETGZ}.log)
	exec 2> >(tee -a ${MARMITELOGS}/${NAMETGZ}.log >&2)
	
	# On crée le répertoire des archives sources :
	mkdir -p ${PKGSOURCES}/${NAMETGZ}
	
	# Emplacement où on déballe les sources pour les compiler :
	TMP=${TMP:-${MARMITE}/${NAMETGZ}/sources}
	
	# Emplacement des fichiers finaux à empaqueter :
	PKG=${PKG:-${MARMITE}/${NAMETGZ}/paquet}
	
	# On nettoie tout ancien paquet ou sources qui traînent :
	rm -rf   ${PKG} ${TMP}
	mkdir -p ${PKG} ${TMP}
	
	# Si $NAMESRC n'est pas défini, on lui affecte $NAMETGZ :
	[ -z ${NAMESRC} ] && NAMESRC="${NAMETGZ}"
fi

telecharger_sources() {
	# Inutile de continuer si des dépendances erronées sont indiquées :
	if [ ! "${EXTRADEPS}" = "" ]; then
		for dep in ${EXTRADEPS}; do
			for f in $(find /var/log/packages -type f -name "${dep}*"); do
				if [ $(basename ${f} | sed 's/\(^.*\)-\(.*\)-\(.*\)-\(.*\)$/\1/p' -n) = "${dep}" ]; then
					# OK, on a trouvé la dépendance installée :
					OKDEP=1
					break
				else
					# Toujours rien ? On continue :
					OKDEP=0
				fi
			done
			
			# On n'a rien trouvé, les EXTRADEPS sont erronées, on quitte :
			if [ ${OKDEP} -eq 0 ]; then
				argh "La variable EXTRADEPS est erronée, certaines dépendances sont absentes du système."
			fi
		done
	fi
	
	# On peut ajouter une option à 'wget' en paramètre en cas de besoin (notamment --referer) :
	# Ex. : 'telecharger_sources --referer=http://www.bla.fr?click=ok'
	WGETEXTRAOPTION=${1}
	
	# Pour tout ce qu'on trouve dans $WGET, que ce soit une variable unique ou
	# un tableau contenant plusieurs URL, on télécharge chaque archive source :
	for wgeturl in ${WGET[*]}; do
		
		# On télécharge l'archive source en '.part et on retombe sur le FTP de 0linux
		# si le téléchargement se passe mal (fichier inexistant, erreur du serveur, etc.) :
		if [ ! -r ${PKGSOURCES}/${NAMETGZ}/$(basename ${wgeturl}) ]; then
			wget -vc ${WGETEXTRAOPTION} \
				--no-check-certificate \
				--timeout=20 \
				--tries=3 \
				${wgeturl} \
				-O ${PKGSOURCES}/${NAMETGZ}/$(basename ${wgeturl}).part || \
			wget -vc \
				--timeout=20 \
				--tries=3 \
				ftp://ftp.igh.cnrs.fr/pub/os/linux/0linux/archives_sources/${NAMETGZ}/$(basename ${wgeturl}) \
				-O ${PKGSOURCES}/${NAMETGZ}/$(basename ${wgeturl}).part
			
			# On renomme correctement le fichier téléchargé :
			mv ${PKGSOURCES}/${NAMETGZ}/$(basename ${wgeturl}){.part,}
		fi
		
		# On vérifie l'archive téléchargée :
		case $(basename ${wgeturl}) in
			*.tar.*|*.TAR.*|*.tgz|*.TGZ|*.tbz*|*.TBZ*)
				tar ft ${PKGSOURCES}/${NAMETGZ}/$(basename ${wgeturl}) 1>/dev/null 2>/dev/null || \
					argh "L'archive '$(basename ${wgeturl}) 'semble incorrecte."
			;;
			*.zip|*.ZIP)
				unzip -tq ${PKGSOURCES}/${NAMETGZ}/$(basename ${wgeturl}) 1>/dev/null 2>/dev/null || \
					argh "L'archive '$(basename ${wgeturl}) 'semble incorrecte."
			;;
			*)
				echo "Format d'archive source non pris en charge. Vérification ignorée."
			;;
		esac
	done
}

preparer_sources() {
	# On peut forcer l'archive à préparer en la spécifiant pour les recettes à versions
	# multiples (ex. : 'preparer_sources $NAMESRC-0.10.1.tar.gz').
	# Agit par défaut sur $WGET ou $WGET[0] (censé valoir <url>/$NAMESRC-$VERSION.$EXT).
	
	# On se place tout d'abord dans un endroit neutre et dédié :
	cd $TMP
	
	# on nettoie si plusieurs archives doivent etre compilées :
	if [ -n "${NAME}" ]; then
		if [ -d $TMP/${NAME} ]; then
			rm -rf $TMP/${NAME}
		fi
	fi
	
	unset CURRENTARCHIVE NAME
	if [ -n "$1" ]; then
		CURRENTARCHIVE="$1"
	else
		# Si $WGET est un tableau contenant plusieurs archives sources à télécharger :
		if [ ${#WGET[*]} -gt 1 ]; then
			
			# On tente de sauver les meubles si l'extension $EXT existe :
			if [ -n ${EXT} ]; then
				for wgetline in ${WGET[*]}; do
					if [ "$(basename ${wgetline})" = "$NAMESRC-$VERSION.$EXT" ]; then
						CURRENTARCHIVE="$NAMESRC-$VERSION.$EXT"
						break
					fi
				done
			
			# Sinon, on considère que la première archive nommée "$NAMESRC-$VERSION.*"
			# correspond à l'archive voulue (on peut rêver) :
			else
				for wgetline in ${WGET[*]}; do
					if [ ! "$(echo $(basename ${wgetline}) | egrep \"$NAMESRC-$VERSION\..*$\")" = "" ]; then
						CURRENTARCHIVE="$(basename ${wgetline})"
						break
					fi
				done
			fi
			
			# Si l'on n'a rien trouvé, on plante car on a besoin d'un argument :
			if [ -z ${CURRENTARCHIVE} ]; then
				echo "Erreur : plusieurs archives sources non-standards sont spécifiées dans cette"
				echo "recette. Appelez obligatoirement 'preparer_sources' suivi du nom de l'archive"
				echo "à décompacter, par exemple :"
				echo "	preparer_sources nomdelarchive.tar.gz"
				exit 1
			fi
		
		# Si $WGET est une simple variable, c'est beaucoup plus simple : :
		else
			CURRENTARCHIVE="$(basename ${WGET})"
		fi
	fi
	
	# On nettoie au maximum :
	if [ -n "${NAME}" -a  "${NAME}" != "." ]; then
		rm -rf ${TMP}/${NAME}
	fi
	
	if [ -n "${NAMESRC}" ]; then
		rm -rf ${TMP}/${NAMESRC}-build
	fi
	
	# Si l'archive contient plus d'un élément différent, alors on considère 
	# que tout est en vrac à l'intérieur, on devra donc décompacter dans un
	# répertoire dédié :
	echo "Extraction en cours..."
	case ${CURRENTARCHIVE} in
		*.tar.*|*.TAR.*|*.tgz|*.TGZ|*.tbz*|*.TBZ*|*.txz|*.TXZ)
			if [ $(tar ft ${PKGSOURCES}/${NAMETGZ}/${CURRENTARCHIVE} | cut -d'/' -f1 | uniq | wc -l) -eq 1 ]; then
				NAME="$(tar ft ${PKGSOURCES}/${NAMETGZ}/${CURRENTARCHIVE} | cut -d'/' -f1 | uniq)"
				tar xf ${PKGSOURCES}/${NAMETGZ}/${CURRENTARCHIVE} -C $TMP
			else
				echo "L'archive contient des fichiers en vrac. Extraction dans :"
				echo "	${TMP}/${CURRENTARCHIVE}/"
				NAME="${TMP}/${CURRENTARCHIVE}"
				mkdir -p ${TMP}/${CURRENTARCHIVE}
				tar xf ${PKGSOURCES}/${NAMETGZ}/${CURRENTARCHIVE} -C $TMP/${CURRENTARCHIVE}
			fi
		;;
		*.zip|*.ZIP)
			if [ $(unzip -l ${PKGSOURCES}/${NAMETGZ}/${CURRENTARCHIVE} | egrep '/$' | sed 's/^.* \(.*\/$\)/\1/p' -n | cut -d'/' -f1 | uniq | wc -l) -eq 1 ]; then
				NAME="$(unzip -l ${PKGSOURCES}/${NAMETGZ}/${CURRENTARCHIVE} | egrep '/$' | sed 's/^.* \(.*\/$\)/\1/p' -n | cut -d'/' -f1 | uniq)"
				unzip ${PKGSOURCES}/${NAMETGZ}/${CURRENTARCHIVE} -d $TMP
			else
				echo "L'archive contient des fichiers en vrac. Extraction dans :"
				echo "	${TMP}/${CURRENTARCHIVE}/"
				NAME="${CURRENTARCHIVE}"
				mkdir -p ${TMP}/${CURRENTARCHIVE}
				unzip ${PKGSOURCES}/${NAMETGZ}/${CURRENTARCHIVE} -d $TMP/${CURRENTARCHIVE}
			fi
		;;
		*.deb|*.DEB)
			echo "Extraction de la sous-archive 'data.tar.lzma'/'data.tar.xz' venant de l'archive Debian dans :"
			echo "	${TMP}/${CURRENTARCHIVE}/"
			NAME="${CURRENTARCHIVE}"
			mkdir -p ${TMP}/${CURRENTARCHIVE}
			cd ${TMP}/${CURRENTARCHIVE}
			ar p ${PKGSOURCES}/${NAMETGZ}/${CURRENTARCHIVE} data.tar.lzma | lzma -d | tar x || \
				ar p ${PKGSOURCES}/${NAMETGZ}/${CURRENTARCHIVE} data.tar.xz | xz -d | tar x
			cd -
		;;
		*.rpm|*.RPM)
			echo "Extraction de l'archive RPM dans :"
			echo "	${TMP}/${CURRENTARCHIVE}/"
			NAME="${CURRENTARCHIVE}"
			mkdir -p ${TMP}/${CURRENTARCHIVE}
			cd ${TMP}/${CURRENTARCHIVE}
			rpmunpack ${PKGSOURCES}/${NAMETGZ}/${CURRENTARCHIVE}
			cd -
		;;
		*)
			echo "Format d'archive non géré pour l'instant ; elle ne sera pas extraite."
			sleep 1
		;;
	esac
	
	# On se place dans les sources :
	if [ -n "${NAME}" ]; then
		
		# On définit des permissions correctes pour l'ensemble des sources :
		find ${TMP}/${NAME} \
		\( \
		-perm 777 -o \
		-perm 775 -o \
		-perm 711 -o \
		-perm 555 -o \
		-perm 511 \
		\) \
		-exec chmod 755 {} \; -o \
		\( \
		-perm 666 -o \
		-perm 664 -o \
		-perm 600 -o \
		-perm 444 -o \
		-perm 440 -o \
		-perm 400 \
		\) \
		-exec chmod 644 {} \;
		
		# On se place dans les sources :
		cd ${TMP}/${NAME}
	fi
}

cflags() {
	# On peut forcer l'architecture pour des cas spéciaux (compilation 
	# croisée, etc.) en spécifiant $FORCE_PKGARCH sur la ligne de commande ou en
	# appelant la fonction dans le script, par exemple : 'cflags i686'.
	if [ ! "$1" = "" ]; then
		PKGARCH="$1"
	else
		if [ "${FORCE_PKGARCH}" = "" ]; then
			PKGARCH="$(uname -m)"
		else
			PKGARCH="${FORCE_PKGARCH}"
		fi
	fi
	
	# Parallélisation : 
	# Avec Hyper Threading : (nombre_de_processeurs * 2) + 1
	# Sans Hyper Threading : nombre_de_processeurs + 1
	# 1 par défaut si un problème survient.
	
	# On compare "processor" et "siblings". S'ils sont égaux, HT n'est pas disponible.
	CPU_LOGIQUES="$(grep -E '^siblings' /proc/cpuinfo | wc -l)"
	CPU_PHYSIQUES="$(grep -E '^processor' /proc/cpuinfo | wc -l)"
	
	if [ ${CPU_LOGIQUES} -eq ${CPU_PHYSIQUES} ]; then
		JOBS=$(( $(nproc) + 1 )) || JOBS=1        # HT indisponible
	else
		JOBS=$(( ($(nproc) * 2) + 1 )) || JOBS=1  # HT disponible
	fi
	
	# Les drapeaux d'optimisation globaux pour chaque architecture. 
	# x86 32 bits :
	if [ ${PKGARCH} = "i686" ]; then
		export CC="gcc -m32"
		export CXX="g++ -m32"
		export LDFLAGS="-m32" # Utilisé uniquement en multilib
		FLAGS="-m32 -O2 -march=i686 -pipe"
		LIBDIRSUFFIX=""
		USE_ARCH=32 # Utilisé uniquement en multilib
		export LDFLAGS="-L/usr/lib${LIBDIRSUFFIX}"
		export PKG_CONFIG_PATH=/usr/lib${LIBDIRSUFFIX}/pkgconfig
	
	# x86 64 bits :
	elif [ ${PKGARCH} = "x86_64" ]; then
		export CC="gcc -m64"
		export CXX="g++ -m64"
		FLAGS="-O2 -fPIC -pipe"
		LIBDIRSUFFIX="64"
		USE_ARCH=64 # Utilisé uniquement en multilib
		export LDFLAGS="-L/usr/lib${LIBDIRSUFFIX}"
		export PKG_CONFIG_PATH=/usr/lib${LIBDIRSUFFIX}/pkgconfig
	
	# ARM v7-a :
	elif [ ${PKGARCH} = "arm" ]; then
		export CC="gcc"
		export CXX="g++"
		FLAGS="-O2 -march=armv7-a -mfpu=vfpv3-d16 -pipe"
		LIBDIRSUFFIX=""
		export LDFLAGS="-L/usr/lib${LIBDIRSUFFIX}"
		export PKG_CONFIG_PATH=/usr/lib${LIBDIRSUFFIX}/pkgconfig
	
	# Tout le reste :
	else
		export CC="gcc"
		export CXX="g++"
		FLAGS="-O2 -pipe"
		LIBDIRSUFFIX=""
		export LDFLAGS="-L/usr/lib${LIBDIRSUFFIX}"
		export PKG_CONFIG_PATH=/usr/lib${LIBDIRSUFFIX}/pkgconfig
	fi
}

installer_doc() {
	# On peut forcer un répertoire de doc. non standard pour les recettes multiversion
	# Ex. : installer_doc ${NAMETGZ}-${VERSION}/$NAMETGZ-1.2.3
	if [ -n "$1" ]; then
		mkdir -p ${PKG}/usr/doc/${1}
		CURRENTDOC="$1"
	else
		mkdir -p ${PKG}/usr/doc/${NAMETGZ}-${VERSION}
		CURRENTDOC="${NAMETGZ}-${VERSION}"
	fi
	cp -a AUTHORS BUGS ?hange?og* *CHANGES* CODING* Contents *COPYING* COPYRIGHT* Copyright* \
		compile EXPAT *FAQ* HACKING *INSTALL* KNOWNBUGS *LEGAL* *LICEN?E* MAINTAIN* *NEWS* \
		*README* THANK* TODO TRANSLATORS *license* *readme* \
		${PKG}/usr/doc/${CURRENTDOC} 2>/dev/null || true
}

creer_post_installation() {
	touch ${PKG}/post-install.sh
	
	# On crée la fonction pour traiter les fichiers '*.0nouveau' éventuels
	# en s'appuyant sur BusyBox :
	cat >> ${PKG}/post-install.sh << "EOF"
traiter_nouvelle_config() {
	NEW="$1"
	OLD="$(dirname $NEW)/$(basename $NEW .0nouveau)"
	
	if [ ! -r $OLD ]; then
		mv $NEW $OLD >/dev/null 2>&1 || busybox mv $NEW $OLD >/dev/null 2>&1 || true
	elif [ "$(diff -abBEiw $OLD $NEW)" = "" ]; then
		mv $NEW $OLD >/dev/null 2>&1 || busybox mv $NEW $OLD >/dev/null 2>&1 || true
	fi
}

EOF
	
	# On ajoute en post-installation tous les fichiers '*.0nouveau' qu'on trouve pour les passer à traiter_nouvelle_config() :
	for fichier_post in $(find ${PKG} -type f -name "*.0nouveau"); do
		echo "traiter_nouvelle_config $(echo ${fichier_post} | sed "s@${PKG}/@@")" >> ${PKG}/post-install.sh
	done
	
	# Si on trouve des fichiers services, on doit respecter les permissions choisies par l'utilisateur.
	# On va donc renommer chaque service en '*.0nouveauservice' et traiter ces nouveaux fichiers
	# en post-installation pour récupérer le fichier avec les permissions de l'utilisateur
	# et y injecter le contenu de notre '.0nouveauservice' :
	if [ -d ${PKG}/etc/rc.d ]; then
		cat >> ${PKG}/post-install.sh << "EOF"

traiter_service() {
	NEWSVCFILE="$1"
	OLDSVCFILE="$(dirname $NEWSVCFILE)/$(basename $NEWSVCFILE .0nouveauservice)"
	
	if [ -e ${OLDSVCFILE} ]; then
		
		# On copie temporairement le service déjà installé en préservant les permissions :
		cp -a ${OLDSVCFILE}{,.tmp} || busybox cp -a ${OLDSVCFILE}{,.tmp} || true
		
		# On injecte le contenu du nouveau fichier service dans le temporaire (qui a les bonnes permissions) :
		cat ${NEWSVCFILE} > ${OLDSVCFILE}.tmp || busybox cat ${NEWSVCFILE} > ${OLDSVCFILE}.tmp || true
		
		# On renomme le temporaire pour écraser l'ancien, les permissions sont alors OK :
		mv ${OLDSVCFILE}{.tmp,} >/dev/null 2>&1 || busybox mv ${OLDSVCFILE}{.tmp,} >/dev/null 2>&1 || true
		
		# On supprime le '.0nouveauservice' ('rm -f' dans BusyBox a un comportement parfois différent) :
		rm -f ${NEWSVCFILE} || busybox rm ${NEWSVCFILE} >/dev/null 2>&1 || true
	else
		# Si l'ancien n'existe pas, on renomme d'office le '.0nouveauservice' :
		mv ${NEWSVCFILE} ${OLDSVCFILE}
	fi
}

EOF
		
		# On ajoute le traitement des services à la post-installation.
		# On ignore les fichiers d''initialisation-systeme', qui ne doivent pas changer :
		for fichier_rcd in $(find ${PKG}/etc/rc.d -type f -name "rc.*" -a \
			\! -name "*.0nouveau" -a \
			\! -name "rc.4" -a \
			\! -name "rc.6" -a \
			\! -name "rc.K" -a \
			\! -name "rc.M" -a \
			\! -name "rc.S"); do
			
			# On renomme d'abord chaque service :
			mv ${fichier_rcd}{,.0nouveauservice} >/dev/null 2>&1 || busybox mv ${fichier_rcd}{,.0nouveauservice} >/dev/null 2>&1 || true
			
			# Et on l'ajoute pour traitement en post-installation :
			echo "traiter_service $(echo ${fichier_rcd}.0nouveauservice | sed "s@${PKG}/@@")" >> ${PKG}/post-install.sh
		done
	fi
	
	# Si on trouve des bibliothèques, on actualise l'éditeur de liens :
	if [ -d ${PKG}/usr/lib -o -d ${PKG}/usr/lib${LIBDIRSUFFIX} -o -d ${PKG}/lib -o -d ${PKG}/lib${LIBDIRSUFFIX} ]; then
		echo "usr/sbin/ldconfig -r . 2>/dev/null" >> ${PKG}/post-install.sh
	fi
	
	# On ajoute la mise à jour des dépendances des modules si on en trouve :
	if [ -r ${PKG}/lib/modules -o -r ${PKG}/usr/lib/modules -o -r ${PKG}/lib${LIBDIRSUFFIX}/modules ]; then
		echo "chroot . depmod -a 2>/dev/null" >> ${PKG}/post-install.sh
		EXTRADEPS="${EXTRADEPS} kmod"
	fi
	
	# On réindexe les polices si on en trouve dans le paquet :
	if [ -d ${PKG}/usr/share/fonts -o -d ${PKG}/etc/fonts ]; then
		
		# 'encodings' demande un traitement spécial :
		if [ -d ${PKG}/usr/share/fonts/encodings ]; then
			echo "chroot . mkfontdir -e /usr/share/fonts/encodings -e /usr/share/fonts/encodings/large 1>/dev/null 2>/dev/null" >> ${PKG}/post-install.sh
			echo "chroot . fc-cache -f 2>/dev/null" >> ${PKG}/post-install.sh
		fi
		
		# Pour chaque répertoire trouvé contenant des polices :
		for rep_polices in $(find ${PKG}/usr/share/fonts/* -type d \! -name "encodings" \! -name "util"); do
			echo "chroot . mkfontscale /usr/share/fonts/$(basename ${rep_polices}) 1>/dev/null 2>/dev/null" >> ${PKG}/post-install.sh
			echo "chroot . mkfontdir   /usr/share/fonts/$(basename ${rep_polices}) 1>/dev/null 2>/dev/null" >> ${PKG}/post-install.sh
			echo "chroot . fc-cache -f /usr/share/fonts/$(basename ${rep_polices}) 1>/dev/null 2>/dev/null" >> ${PKG}/post-install.sh
		done
		
		# On ajoute les dépendances :
		EXTRADEPS="${EXTRADEPS} fontconfig mkfontscale mkfontdir"
	fi
	
	# On s'assure que les fichiers dans '/etc/profile.d/' soient exécutés :
	if [ -d ${PKG}/etc/profile.d ]; then
		
		# Pour chaque script rencontré en '.*sh' :
		for fichierprofil in $(find ${PKG}/etc/profile.d -type f -name "*.*sh"); do
			echo "chroot . etc/profile.d/$(basename ${fichierprofil}) >/dev/null 2>&1" >> ${PKG}/post-install.sh
		done
	fi
	
	# On met à jour la base de données des raccourcis bureau et on ajoute la dépendance le cas échéant :
	if [ -d ${PKG}/usr/share/applications ]; then
		echo "chroot . /usr/bin/update-desktop-database &>/dev/null" >> ${PKG}/post-install.sh
		EXTRADEPS="${EXTRADEPS} desktop-file-utils"
	fi
	
	# On met à jour la base des pages 'info' le cas échéant :
	if [ -d ${PKG}/usr/info ]; then
		echo "if [ -x usr/bin/install-info ]; then" >> ${PKG}/post-install.sh
		
		# On installe chaque fichier 'info' rencontré :
		for fichierinfo in $(find ${PKG}/usr/info -type f -name "*.info*"); do
			echo "	chroot . /usr/bin/install-info /usr/info/$(basename ${fichierinfo}) /usr/info/dir 2>/dev/null" >> ${PKG}/post-install.sh
		done
		
		echo "fi" >> ${PKG}/post-install.sh
		echo "" >> ${PKG}/post-install.sh
	fi
	
	# On met à jour la base de données des types MIME et on ajoute la dépendance le cas échéant :
	if [ -d ${PKG}/usr/share/mime ]; then
		echo "chroot . /usr/bin/update-mime-database /usr/share/mime >/dev/null 2>&1" >> ${PKG}/post-install.sh
		EXTRADEPS="${EXTRADEPS} shared-mime-info"
	fi
	
	# On met à jour les modules GIO et on ajoute la dépendance le cas échéant :
	if [ -d ${PKG}/usr/lib${LIBDIRSUFFIX}/gio/modules ]; then
		echo "chroot . /usr/bin/gio-querymodules /usr/lib${LIBDIRSUFFIX}/gio/modules 2>/dev/null" >> ${PKG}/post-install.sh
		EXTRADEPS="${EXTRADEPS} glib"
	fi
	
	# On met à jour cette immonde base de registres GConf et on ajoute la dépendance le cas échéant :
	if [ ! "$(find ${PKG} -type d -name schemas)" = "" ]; then
		echo "chroot . /usr/bin/glib-compile-schemas /usr/share/glib-2.0/schemas/ 1>/dev/null 2>/dev/null" >> ${PKG}/post-install.sh
		EXTRADEPS="${EXTRADEPS} gconf"
	fi
	
	# On met à jour cette immonde base de données DConf et on ajoute la dépendance le cas échéant :
	if [ ! "$(find ${PKG} -type d -name dconf)" = "" ]; then
		echo "chroot . dconf update 1>/dev/null 2>/dev/null" >> ${PKG}/post-install.sh
		EXTRADEPS="${EXTRADEPS} dconf"
	fi
	
	# On met à jour le cache des icônes pour GTK+ et on ajoute la dépendance le cas échéant :
	if [ -d ${PKG}/usr/share/icons ]; then
		echo "chroot . /usr/bin/gtk-update-icon-cache -f -t /usr/share/icons/hicolor >/dev/null 2>&1" >> ${PKG}/post-install.sh
		EXTRADEPS="${EXTRADEPS} gtk+"
	fi
	
	# On met à jour les ressources des icônes pour le thème 'hicolor' parfois fourni par plusieurs paquets et on ajoute la dépendance le cas échéant :
	if [ -d ${PKG}/usr/share/icons ]; then
		echo "chroot . /usr/bin/xdg-icon-resource forceupdate --theme hicolor >/dev/null 2>&1" >> ${PKG}/post-install.sh
		EXTRADEPS="${EXTRADEPS} xdg-utils"
	fi
}

stripper() {
	# On "strippe" tout ce qu'on trouve :
	find ${PKG} -type f | xargs file 2>/dev/null | grep "LSB executable"     | cut -f 1 -d : | xargs strip --strip-unneeded 2>/dev/null || true
	find ${PKG} -type f | xargs file 2>/dev/null | grep "shared object"      | cut -f 1 -d : | xargs strip --strip-unneeded 2>/dev/null || true
	find ${PKG} -type f | xargs file 2>/dev/null | grep "current ar archive" | cut -f 1 -d : | xargs strip -g               2>/dev/null || true
}

empaqueter() {
	# Inutile de continuer si des dépendances erronées sont indiquées :
	if [ -n ${EXTRADEPS} ]; then
		for dep in ${EXTRADEPS}; do
			for f in $(find /var/log/packages -type f -name "${dep}*"); do
				if [ $(basename ${f} | sed 's/\(^.*\)-\(.*\)-\(.*\)-\(.*\)$/\1/p' -n) = "${dep}" ]; then
					# OK, on a trouvé la dépendance installée :
					OKDEP=1
					break
				else
					# Toujours rien ? On continue :
					OKDEP=0
				fi
			done
			
			# On n'a rien trouvé, les EXTRADEPS sont erronées, on quitte :
			if [ ${OKDEP} -eq 0 ]; then
				argh "La variable EXTRADEPS est erronée, certaines dépendances sont absentes du système."
			fi
		done
	fi
	
	# On peut passer des options à 'spackpkg' via par exemple :
	# empaqueter -p -z
	
	# On déplace '/usr/share/pkgconfig' sous '/usr/lib${LIBDIRSUFFIX}' le
	# cas échéant... :
	if [ -d ${PKG}/usr/share/pkgconfig ]; then
		mkdir -p ${PKG}/usr/lib${LIBDIRSUFFIX}/pkgconfig
		cp -ar ${PKG}/usr/share/pkgconfig/* ${PKG}/usr/lib${LIBDIRSUFFIX}/pkgconfig/
		rm -rf ${PKG}/usr/share/pkgconfig
	fi
	
	# On affecte des permissions correctes aux bibliothèques partagées :
	find ${PKG}/lib* ${PKG}/usr/lib* -type f \! -perm 755 -iname "*.so*" 2>/dev/null | xargs file 2>/dev/null | grep "shared object" | cut -f 1 -d : | xargs chmod 755 2>/dev/null || true
	
	# On affecte des permissions correctes aux bibliothèques statiques :
	find ${PKG}/lib* ${PKG}/usr/lib* -type f \! -perm 644 -iname "*.a" -exec chmod 644 {} \; 2>/dev/null || true
	
	# On affecte des permissions aux raccourcis de type '*.desktop' :
	find ${PKG}/usr -type f \! -perm 644 -name "*.desktop" -exec chmod 644 {} \; 2>/dev/null || true
	
	# On affecte la permission à ce répertoire spécial pour 'polkit' :
	if [ -d ${PKG}/etc/polkit-1/localauthority ]; then
		chmod 700 ${PKG}/etc/polkit-1/localauthority
	fi
	
	# On déplace toute doc éventuellement mal placée :
	if [ -d ${PKG}/usr/share/doc ]; then
		cp -ar ${PKG}/usr/share/doc ${PKG}/usr/doc/${NAMETGZ}-${VERSION}/
		rm -rf ${PKG}/usr/share/doc
	fi
	
	# On vérifie les droits de la doc, souvent problématiques :
	find ${PKG}/usr/{doc,man,info} -type d -exec chmod 755 {} \; 2> /dev/null || true
	find ${PKG}/usr/{doc,man,info} -type f -exec chmod 644 {} \; 2> /dev/null || true
	
	# On rend les fichiers profils exécutables :
	find ${PKG}/etc/profile.d -type f -exec chmod 755 {} \; 2>/dev/null || true
	
	# On déplace les fichiers '*-gdb.py' sous une arborescence dédiée à 'gdb', 
	# sinon 'ldconfig' va se plaindre :
	for fichiergdb in $(find ${PKG}/usr/lib* -type f -name "*-gdb.py" 2>/dev/null); do
		mkdir -p ${PKG}/usr/share/gdb/auto-load/$($(echo dirname ${fichiergdb}) | sed "s@${PKG}@@")
		cp -a ${fichiergdb} ${PKG}/usr/share/gdb/auto-load/$($(echo dirname ${fichiergdb}) | sed "s@${PKG}@@")/
		rm -f ${fichiergdb}
	done
	
	# On nettoie ce fichier indésirables des modules Perl :
	if [ ! "${NAMETGZ}" = "perl" ]; then
		find ${PKG} -type f -name "perllocal.pod" -delete 2>/dev/null || true
	fi
	
	# On déduit l'emplacement du paquet selon l'emplacement de la recette elle-même :
	PKGBASEDIR="$(echo ${CWD} | sed 's/^.*0Linux\/\(.*$\)/\1/p' -n)"
	
	# On déduit le répertoire cible du paquet  :
	OUT="${PKGREPO}/${PKGARCH}/${PKGBASEDIR}"
	
	# On nettoie tout paquet/fichier .dep similaire présent dans le dépôt sur l'hôte :
	for paquetpresent in $(find ${PKGREPO}/${PKGARCH} -type f -name "${NAMETGZ}-*.spack" 2>/dev/null); do
		
		# On compare bien le nom du paquet qui doit strictement être "$NAMETGZ" et pas "$NAMETGZ-doc" par exemple :
		if [ "$(echo $(basename ${paquetpresent}) | sed 's/\(^.*\)-\(.*\)-\(.*\)-\(.*\)\.spack$/\1/p' -n)" = "${NAMETGZ}" ]; then
			
			# OK on nettoie le '.spack' et le '.dep' :
			rm -f ${paquetpresent}
			rm -f $(echo ${paquetpresent} | sed 's@\.spack@\.dep@')
			
			# Si le paquet est dans un répertoire dédié (cas normal dans 0Linux eta), 
			# alors on le supprime également pour nettoyer les renommages et autres 
			# déplacements de paquets :
			if [ "$(basename $(dirname ${paquetpresent}))" = "${NAMETGZ}" ]; then
				rm -rf $(dirname ${paquetpresent})
			fi
		fi
	done
	
	# On crée le répertoire de doc pour notre journal et nos dépendances :
	mkdir -p ${PKG}/usr/doc/${NAMETGZ}-${VERSION}/0linux
	
	# On crée un lien générique vers notre répertoire de doc (Xorg en a besoin, notamment) :
	# Si $NAMESRC et $NAMETGZ sont différents, on crée un lien $NAMESRC -> $NAMETGZ -> $NAMETGZ-$VERSION :
	if [ ! "${NAMESRC}" = "${NAMETGZ}" ]; then
		ln -sf ${NAMETGZ} ${PKG}/usr/doc/${NAMESRC}
		ln -sf ${NAMETGZ}-${VERSION} ${PKG}/usr/doc/${NAMETGZ}
	
	# Sinon, on crée un simple lien $NAMETGZ -> $NAMETGZ-$VERSION :
	else
		ln -sf ${NAMETGZ}-${VERSION} ${PKG}/usr/doc/${NAMETGZ}
	fi
	
	# On définit le compteur de compilations $BUILD en se basant sur l'éventuel
	# paquet déjà installé dans le système. On laisse néanmoins la possibilité de
	# spécifier $BUILD sur la ligne de commande (qui reste prioritaire) :
	if [ -z "${BUILD}" ]; then
		
		# On le définit à 1 par défaut :
		BUILD=1
		
		# On scanne les paquets installés :
		for paquetinstalle in $(find /var/log/packages -type f -name "${NAMETGZ}-*" 2>/dev/null); do
		
			# Si on trouve le même paquet déjà installé avec le même $NAMETGZ :
			if [ "$(echo $(basename ${paquetinstalle}) | sed 's/\(^.*\)-\(.*\)-\(.*\)-\(.*\)$/\1/p' -n)" = "${NAMETGZ}" ]; then
				
				# Si on trouve un paquet avec la même $VERSION, on ajoute 1
				# à son compteur $BUILD pour permettre la mise à niveau :
				if [ "$(echo $(basename ${paquetinstalle}) | sed 's/\(^.*\)-\(.*\)-\(.*\)-\(.*\)$/\2/p' -n)" = "${VERSION}" ]; then
					OLDBUILD="$(echo $(basename ${paquetinstalle}) | sed 's/\(^.*\)-\(.*\)-\(.*\)-\(.*\)$/\4/p' -n)"
					BUILD=$(( ${OLDBUILD} +1 ))
					break
				fi
			fi
		done
	fi
	
	# On extrait les dépendances dynamiques (fichiers) grâce à '0ldd_clean', basé sur '0dep' :
	0ldd_clean ${PKG}/* > ${PKG}/usr/doc/${NAMETGZ}-${VERSION}/0linux/ldd.log
	
	# On extrait les dépendances (paquets) grâce à '0dep' (merci Seb) :
	mkdir -p ${OUT}
	0dep ${PKG} > ${OUT}/${NAMETGZ}-${VERSION}-${PKGARCH}-${BUILD}.dep
	
	# On ajoute les dépendances spécifiées manuellement le cas échéant et on trie :
	if [ -n "${EXTRADEPS}" ]; then
		
		# On copie une version tampon des dépendances :
		cp -a ${OUT}/${NAMETGZ}-${VERSION}-${PKGARCH}-${BUILD}.dep{,.tmp}
		
		# On ajoute chaque dépendances manuelle à ce tampon :
		for extradep in ${EXTRADEPS}; do
			echo "${extradep}" >> ${OUT}/${NAMETGZ}-${VERSION}-${PKGARCH}-${BUILD}.dep.tmp
		done
		
		# On supprime les lignes vides, on copie dans le fichier original et on nettoie :
		cat ${OUT}/${NAMETGZ}-${VERSION}-${PKGARCH}-${BUILD}.dep.tmp | sed '/^$/d' > ${OUT}/${NAMETGZ}-${VERSION}-${PKGARCH}-${BUILD}.dep
		rm -f ${OUT}/${NAMETGZ}-${VERSION}-${PKGARCH}-${BUILD}.dep.tmp
	fi
	
	# On stocke également les dépendances dans la doc 0linux :
	cp -a ${OUT}/${NAMETGZ}-${VERSION}-${PKGARCH}-${BUILD}.dep ${PKG}/usr/doc/${NAMETGZ}-${VERSION}/0linux/
	
	# On place la description en la créant via 'spackdesc -' :
	echo "${DESC}" | spackdesc --package="${NAMETGZ}" - > ${PKG}/about.txt
	
	# On décompresse et on recompresse en 'xz' tous les manuels en ignorant les liens matériels :
	if [ -d ${PKG}/usr/man ]; then
		find ${PKG}/usr/man -type f -name "*.gz"  -exec gzip  -d --force {} \;
		find ${PKG}/usr/man -type f -name "*.bz2" -exec bzip2 -d --force {} \;
		find ${PKG}/usr/man -type f -links 1 -name "*.*"   -exec xz      {} \;
		
		# On renomme tous les liens comportant une extension et on renomme 
		# la cible de chaque lien pour y mettre la bonne extension :
		for manext in gz bz2 lzma; do
			for manpage in $(find ${PKG}/usr/man -type l -name "*.${manext}") ; do
				ln -sv $(echo $(readlink ${manpage} | sed "s@\.${manext}@.xz@")) $(echo ${manpage} | sed "s@\.${manext}@.xz@")
				rm -f ${manpage}
			done
		done
	fi
	
	# On compresse toutes les pages 'info' et on nettoie le fichier 'dir' forcément incorrect :
	if [ -d ${PKG}/usr/info ]; then
		rm -f ${PKG}/usr/info/dir
		find ${PKG}/usr/info -type f -name "*.info*" -exec xz {} \;
	fi
	
	# On décompresse et on recompresse en 'xz' tous les modules noyau (et on tire la
	# langue au mainteneur de 'kmod' qui voulait supprimer la prise en charge de 'xz') :
	for d in lib/modules usr/lib/modules usr/lib${LIBDIRSUFFIX}/modules; do
		if [ -d ${PKG}/${d} ]; then
			find ${PKG}/${d} -type f -name "*.ko.gz"  -exec gzip  -d {} \;
			find ${PKG}/${d} -type f -name "*.ko.bz2" -exec bzip2 -d {} \;
			find ${PKG}/${d} -type f -name "*.ko"     -exec xz       {} \;
		fi
	done
	
	# On place le journal - en ajoutant la version - dans la doc sous forme compressée
	# et on supprime le journal, signe que la compilation s'est bien passée :
	if [ -r ${MARMITELOGS}/${NAMETGZ}.log ]; then
		mv ${MARMITELOGS}/${NAMETGZ}{,-${VERSION}}.log
		cp ${MARMITELOGS}/${NAMETGZ}-${VERSION}.log ${PKG}/usr/doc/${NAMETGZ}-${VERSION}/0linux/
		xz ${PKG}/usr/doc/${NAMETGZ}-${VERSION}/0linux/${NAMETGZ}-${VERSION}.log
		rm -f ${MARMITELOGS}/${NAMETGZ}-${VERSION}.log
	fi
	
	# Empaquetage !
	cd ${PKG}
	fakeroot chown root:root . -R
	fakeroot /usr/sbin/spackpkg . ${OUT}/${NAMETGZ}-${VERSION}-${PKGARCH}-${BUILD} $@
	
	# On nettoie :
	rm -rf ${MARMITE}/${NAMETGZ}
	
	if [ -n "${NAME}" ]; then
		if [ -d $TMP/${NAME} ]; then
			rm -rf $TMP/${NAME}
		fi
	fi
}

# C'est fini.
