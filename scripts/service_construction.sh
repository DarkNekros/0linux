#!/usr/bin/env bash
while [ 0 ]; do
	
	# Notre répertoire courant :
	CWD="$(pwd)"
	
	# On crée la file d'attente : 
	FILEDATTENTE=/tmp/en_attente.tmp
	touch ${FILEDATTENTE}
	
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
			
			# On nettoie le paquet demandé (première ligne) de la file d'attente :
			sed -i '1d' ${FILEDATTENTE}
		fi
	done
	
	# On se repose 20 secondes avant de recommencer :
	sleep 20
done

# C'est fini.

