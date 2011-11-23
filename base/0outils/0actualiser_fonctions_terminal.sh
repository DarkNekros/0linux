#!/usr/bin/env bash

# Toutes les fonctions de l'interface utilisateur de '0actualiser' pour
# la console ou le terminal (comportement par défaut).

set -e

utilisation () {
	echo "'0actualiser' permet de synchroniser les paquets installés avec les"
	echo "dépôts de 0 pour permettre facilement leur mise à niveau."
	echo "Il s'invoque sans aucun paramètre (pour l'instant)."
	echo ""
	echo "Utilisation : '0actualiser'"
}

patienter () {
	echo "Merci de patienter quelques instants, je suis assez lent..."
}

depot_corrompu () {
	echo "Erreur fatale : plusieurs versions d'un même paquet ont été détectées."
	echo "Veuillez désinstaller les paquets redondants. '0actualiser' va s'arrêter."
}

architectures_corrompues () {
	echo "Erreur fatale : les architectures ne correspondent pas !"
	echo "'0actualiser' va s'arrêter."
}

eglibc_detecte () {
	echo "* ATTENTION *"
	echo ""
	echo "Le paquet critique 'eglibc' a été mis à niveau : cela signifie qu'une"
	echo "nouvelle version de 0 vient de sortir (oui, c'est rare) !"
	echo ""
	echo "Vous devez installer cette nouvelle version de la distribution"
	echo "via l'OS autonome (clé USB, DVD, etc.). '0actualiser' va s'arrêter."
}

recapitulatif_a_installer () {
	echo "Il y a ${NBINSTALLPKG} paquets à mettre à niveau :"
	echo ""
	cat $TMP/messages_a_installer.log
	echo ""
	echo "Procéder aux mises à niveau ? Tapez « oui » pour confirmer ou"
	echo "appuyez sur ENTRÉE pour annuler."
	echo ""
	echo -n "Votre choix (oui/ENTRÉE) : "
}

paquet_description () {
	spackadd --about /0/paquets/$(basename ${paq}).spack
}

systeme_a_jour () {
	echo "Le système est à jour !"
}
