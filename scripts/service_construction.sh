#!/usr/bin/env bash
# Service de construction automatisé des paquets de 0Linux.

# Ce script automatise plusieurs tâches :
#
#   - il évalue les derniers commmits du dépôt git  et lance la ocnstruction
#     des paquets correspondants avec 'construction.sh'
#   - il régénère une image ISO avec '0creation_live' si l'installateur a subi
#   - des modifications
#   - il lance ensuite 'trouver_binaires_casses.sh' pour vérifier l'intégrité
#     de l'ensemble du système
#   - il génère le catalogue en ligne via '../catalogue/catalogue.sh' des
#     paquets fraîchement construits ainsi que leurs dépendances
#   - il génère enfin la base de données des paquets 'paquets.db' et envoie le
#     tout sur le serveur spécifié avec le script '0mir'.
#
# On peut « nourrir » soi-même la file d'attente pour forcer des constructions
# de paquets en ajoutant du contenu à la file d'attente (1 paquet par ligne).

# Le fichier du processus :
PIDFILE="/var/lock/service_construction.pid"

# La file d'attente :
FILEDATTENTE="/tmp/en_attente.tmp"

# Emplacement du dépôt des paquets résultant de la construction. À définir en
# tant que variable d'environnement car utilisée aussi dans 'construction.sh'
# entre autres.
PKGREPO=${PKGREPO:-/usr/local/paquets}

# On supprime un éventuel déchet '.pid' restant :
if ! ps axc | grep 'service_construction' 1>/dev/null 2>/dev/null ; then
	rm -f ${PIDFILE}
fi

# On vérifie si un '.pid' existe (le script tourne déjà) :
[ -r ${PIDFILE} ] && exit 0

# On est toujours là ? OK, on crée donc le fichier du processus : 
echo "$$" > ${PIDFILE}

# On s'assure que l'environnement est correctement configuré :
source /etc/profile

# On identifie la version du système :
source /etc/os-release

# La fonction de traitement de la file d'attente :
# $f
traiter_filedattente() {
	
	# On s'assure que la file d'attente existe :
	touch ${FILEDATTENTE}
	
	# On traite la file d'attente (qu'on peut remplir aussi manuellement au besoin) :
	cat ${FILEDATTENTE} | while read recette_demandee; do
		if [ ! "${recette_demandee}" = "" ]; then
			
			# On compile/installe (nvidia est ignoré automatiquement à l'installation) :
			./construction.sh ${recette_demandee}
			
			# On nettoie le(s) paquet(s) demandé(s) (première ligne) de la file d'attente :
			sed -i '1d' ${FILEDATTENTE}
			
			# On génère le catalogue du paquet et son index :
			FORCECATALOGUE=oui ../catalogue/catalogue.sh ${recette_demandee}
			
			# Et le catalogue de chaque dépendance et chacun de leur index :
			cat /usr/doc/${recette_demandee}/0linux/*.dep | while read deppp; do
				( cd ../catalogue ; FORCECATALOGUE=oui ../catalogue/catalogue.sh ${deppp} )
			done
			
			# On nettoie le(s) paquet(s) demandé(s) (première ligne) de la file d'attente :
			sed -i '1d' ${FILEDATTENTE}
		fi
	done
}

### Étape 1 : on vérifie si un commit a eu lieu dans les recettes :

# On note le hash du dernier commit :
OLD_HEAD="$(git rev-parse HEAD)"

# On rapatrie les éventuelles modifications :
git pull origin master

# On note l'éventuel nouveau hash :
NEW_HEAD="$(git rev-parse HEAD)"

# Si ça a changé, on ajoute les recettes changées à notre file d'attente :
if [ ! $OLD_HEAD = $NEW_HEAD ]; then
	
	# On extrait les recettes modifiées en supprimant les lignes vides et tout 
	# espace rencontré et on ajoute le résultat à la file d'attente :
	git --no-pager diff --name-only $OLD_HEAD $NEW_HEAD | \
		xargs basename -a | \
		grep -E '\.recette' | \
		sed -e 's@\.recette@@' -e '/^$/d' -e '/[[:space:]]/d' >> ${FILEDATTENTE}
	
	# Si l'installateur a changé, on va devoir régénérer une image ISO :
	unset ISOGEN
	if [ ! "$(git --no-pager diff --name-only $OLD_HEAD $NEW_HEAD | grep installateur)" = "" ]; then
		ISOGEN="oui"
	fi
fi

### Étape 2 : on compile/installe le contenu de la file d'attente :

# Doit-on vérifier les binaires du système ?
CHECKBINAIRES="non"

# ... Oui, si la file d'attente contient des paquets à construire :
if [ $(cat ${FILEDATTENTE} | wc -l) -gt 0 ]; then
	CHECKBINAIRES="oui"
fi

# On traite la file d'attente pour la vider :
traiter_filedattente

# On doit vérifier les binaires du système. Si des paquets sont retournés, on les ajoute
# à la file d'attente pour construction immédiate :
if [ "${CHECKBINAIRES}" = "oui" ]; then
	sudo ./trouver_binaires_casses.sh /usr/bin /usr/sbin /usr/lib* /usr/share >> ${FILEDATTENTE}
	
	# On traite à nouveau la file d'attente pour la vider :
	traiter_filedattente
fi

# Si l'on doit régénérer une image ISO :
if [ -n ${ISOGEN} = "oui" ]; then
	
	# On nettoie et on génère l'iso dans '/usr/local/temp' (par défaut, mais sait-on jamais) :
	rm -rf /usr/local/temp/iso
	TMP=/usr/local/temp 0creation_live --mini $(pwd)/../../../pub/${VERSION}/$(uname -m)/
	
	# On déduit le nome de l'image ISO :
	NOMISO=$(ls -1 /usr/local/temp/iso/)
	
	# On copie l'image et on génère la somme de contrôle MD5 :
	cp /usr/local/temp/iso/${NOMISO} $(pwd)/../../../pub/iso/
	cd $(pwd)/../../../pub/iso/
	md5sum ${NOMISO} > ${NOMISO}.md5
	cd -
fi

### Étape 3 : on génère le catalogue des paquets et de leurs dépendances ainsi
### que l'index correspondant à la catégorie pour envoyer sur le wiki :
FORCECATALOGUE=oui ../catalogue/catalogue.sh

### Étape 4 : on vérifie le dépôt + génère les descriptions + synchronise le serveur distant :
./0mir

# On peut supprimer le fichier du processus pour les prochaines fois :
rm -f ${PIDFILE}

# C'est fini.
