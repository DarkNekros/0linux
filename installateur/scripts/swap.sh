#!/bin/env bash

# On nettoie avant toute chose :
rm -f $TMP/choix_swap $TMP/ignorer_swap
unset NOSWAP

# On tente de détecter une ou plusieurs partitions swap existantes :
listeswap() {
	LISTESWAP=$(fdisk -l 2> /dev/null | grep swap 2> /dev/null)
	echo "${LISTESWAP}"
}

# Cette fonction supprime les espaces superflus via 'echo' :
crunch() {
	read STRING;
	echo $STRING;
}

# taille_partition(périphérique) :
taille_partition() {
	Taille=$(fdisk -l | grep $1 | crunch | tr -d "*" | tr -d "+" | cut -f4 -d' ')
	echo "$Taille blocs"
}

# Si aucune swap n'est détectée :
while [ listeswap = "" ]; do
	clear
	echo -e "\033[1;32mAucune partition d'échange « swap » n'a été trouvée.\033[0;0m"
	echo ""
	echo "Aucune partition d'échange « swap » n'a été trouvée sur cette machine."
	echo "Voulez-vous continuer l'installation sans partition d'échange ?"
	echo -n "Votre choix (oui/non) : "
	read NOSWAP;
	# Si l'utilisateur ne veut pas continuer :
	if [ "$NOSWAP" = "non" ]; then
		echo "Abandon. Créez une partition d'échange « swap » avec 'cfdisk',"
		echo "'fdisk' ou 'parted' puis relancez l'installateur."
		exit 1
	# Si l'utilisateur ne veut pas de swap :
	elif [ "$NOSWAP" = "oui" ]; then
		touch $TMP/ignorer_swap
		exit 0
	else
		echo "Veuillez répondre par « oui » ou par « non » uniquement."
		sleep 2
		continue;
	fi
done

# Si l'on trouve une ou plusieurs swaps :
# On détecte les tailles des swaps et on en retire une liste à afficher :
for partitionswap in "${LISTESWAP}" ; do
	TAILLEPART=$(taille_partition $partitionswap)
done

swapselect 2> $TMP/selection_swap


if [ -r $TMP/selection_swap ]; then
	# On supprime les éventuels guillemets :
	cat $TMP/selection_swap | tr -d \" > $TMP/selection_swap
	
	# Si aucune swap n'a été spécifiée, on ignore l'étape :
	if [ "$(cat $TMP/selection_swap)" = "" -a ! -r $TMP/ignorer_swap ]; then
		rm -f $TMP/temp_swap $TMP/choix_swap $TMP/selection_swap
		touch $TMP/ignorer_swap
	fi
fi

	# On crée et on active la ou les swaps avec 'mkswap' et 'swapon' :
	for partitionswap in $(cat $TMP/selection_swap) ; do
		mkswap -v1 $partitionswap 1> $REDIR 2> $REDIR
		swapon $partitionswap 1> $REDIR 2> $REDIR
	done
	
	# Ce qui suit permet d'éviter à l'écran de clignoter :
	sleep 2
	
	# On ajoute maintenant les infos qui iront dans '/etc/fstab' :
	for pswap in $(cat $TMP/selection_swap) ; do
		echo "$pswap     swap         swap       defaults           0     0" >> $TMP/choix_swap
	done
	
	# On affiche les infos qui iront dans '/etc/fstab' à l'utilisateur :
	swapconfigured
	
fi

# C'est fini !
