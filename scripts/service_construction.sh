#!/usr/bin/env bash

# Le fichier du processus (on n'est pas root) :
PIDFILE="/tmp/service_construction.pid"

# La file d'attente :
FILEDATTENTE="/tmp/en_attente.tmp"

# La fichier journal :
SVCLOG="/tmp/service_construction.log"

# Cette fonction supprime les espaces superflus via 'echo' :
crunch() {
	read STRING;
	echo $STRING;
}

# On supprime un éventuel déchet '.pid' restant :
if ! ps axc | grep 'service_construction' 1> /dev/null 2> /dev/null ; then
	rm -f ${PIDFILE}
fi

# On vérifie si un '.pid' existe (le script tourne déjà) :
[ -r ${PIDFILE} ] && exit 0

# On est toujours là ? OK, on crée donc le fichier du processus : 
echo "$$" > ${PIDFILE}

# On s'assure que la file d'attente existe :
touch ${FILEDATTENTE}

# On s'assure que l'environnement est correctement configuré (ça saute souvent, d'ailleurs) :
source /etc/profile

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
fi

### Étape 2 : on compile/installe le contenu de la file d'attente :

# On traite la file d'attente (qu'on peut remplir aussi manuellement au besoin) :
cat ${FILEDATTENTE} | while read recette_demandee; do
	if [ ! "${recette_demandee}" = "" ]; then
		
		# On compile/installe (nvidia est ignoré automatiquement à l'installation) :
		./construction.sh ${recette_demandee}
		
		# On nettoie le(s) paquet(s) demandé(s) (première ligne) de la file d'attente :
		sed -i '1d' ${FILEDATTENTE}
	fi
done

### Étape 3 : on vérifie qu'aucun binaire n'est cassé. Sur tous les binaires
# apparaissant comme cassés, on considère réllement cassé tout binaire dont
# on ne trouve nulle part ailleurs la bibliothèque liée marqué comme manquante,
# ce afin d'ignorer tous les binaires possédant leur propre système de
# chargement d'objet partagé (Samba, les softs de Mozilla, Java, Ardour,
# LibreOffice, etc.) :

# On vide le'éventuel journal :
echo "" > ${SVCLOG}

# On remplit le journal avec tout fichier lié réellement introuvable :
sudo ./trouver_binaires_casses.sh \
	/usr/bin \
	/usr/sbin \
	/usr/lib* \
	/usr/share | \
	while read missinglib; do
		[ $(find /usr -name "$(echo ${missinglib} | cut -d':' -f3 | tr -d '[[:blank:]]')" 2>/dev/null | wc -l) -eq 0 ] && \
		echo "Cassé : $(echo \"${missinglib}\" | cut -d':' -f1,3) manquant" >> ${SVCLOG}
	done

# Si le journal contient des binaires pétés, on quitte :
if [ $(cat ${SVCLOG} | wc -l) -gt 0 ]; then
	echo "Des binaires sont cassés ! Cf. '${SVCLOG}'"
	exit 1
fi

### Étape 4 : on vérifie le dépôt + génère les descriptions + synchronise le serveur distant :
./0mir

# On peut supprimer le fichier du processus pour les prochaines fois :
rm -f ${PIDFILE}

# C'est fini.
