#!/usr/bin/env bash

# Le fichier du processus (on n'est pas root) :
PIDFILE="/tmp/service_construction.pid"

# La file d'attente :
FILEDATTENTE="/tmp/en_attente.tmp"

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

# Puis on vérifie les exécutables pour s'assurer que rien n'a cassé (API ou ABI qui casse) :
SUDOBINAIRE=""
[ -x /usr/bin/sudo ] && SUDOBINAIRE="sudo"

for f in $(find /usr -type f -executable); do
	${SUDOBINAIRE} ldd ${f} 2>/dev/null | grep -q 'not found' && echo "! ${f} est cassé" >> /tmp/binaires_casses.log && NOTOK="1"
done

# On a des cassages, on quitte :
[ "$NOTOK" = "1" ] && exit 1

# On est toujours là ? Aucun cassage, donc. On vide le journal :
echo "" > /tmp/binaires_casses.log

# Puis on vérifie le dépôt + génère les descriptions + synchronise le serveur distant :
./0mir

# On peut supprimer le fichier du processus pour les prochaines fois :
rm -f ${PIDFILE}

# C'est fini.
