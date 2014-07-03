#!/usr/bin/env bash

# On nettoie :
unset BLURB BLURB2 BLURB3 BLURB4 CHOIXMENUABO BUROABO

# Confirmation :
if [ "${INSTALLDEBUG}" = "" ]; then
	clear
fi
echo -e "\033[1;32mInstallation imminente des paquets.\033[0;0m"
echo ""
echo "Les paquets de base du système 0Linux vont maintenant être installés sur votre"
echo "partition '$(cat $TMP/partition_racine)'."
echo ""
echo -n "Appuyez sur ENTRÉE pour confirmer ou CTRL+C pour quitter."
read BLURB;

if [ "${SETUPROOT}" = "" ]; then
	echo "Erreur fatale : la racine système n'est pas positionnée !"
	echo "Retour au menu principal..."
	sleep 3
elif [ ! -d ${SETUPROOT} ]; then
	echo "Erreur fatale : le répertoire accueillant la future racine système,"
	echo "'${SETUPROOT}', est introuvable !"
	echo "Ce répertoire devrait normalement exister. Retour au menu principal..."
	sleep 3
else
	
	# On installe d'abord les paquets vitaux :
	if [ "${INSTALLDEBUG}" = "" ]; then
		clear
	fi
	echo -e "\033[1;32mInstallation des paquets critiques...\033[0;0m"
	echo ""
	echo "Exécution de :"
	echo "	0g busybox base-systeme glibc ncurses readline bash sgml-common 0outils"
	sleep 3
	
	# On ajoute le protocole 'file://' si le dépôt est local :
	MEDIACHOISI="$(cat $TMP/choix_media)"
	if [ "$(echo ${MEDIACHOISI} | grep -E '^ftp:|^http:')" = "" ]; then
		PROTOCOLE="file://"
	else
		PROTOCOLE=""
	fi

	# On ajoute à la configuration de 0g la source des paquets ainsi que la racine cible :
	echo "Source=\"${PROTOCOLE}${MEDIACHOISI}\"" >> /etc/0outils/0g.conf
	echo "ROOT=\"${SETUPROOT}\""                 >> /etc/0outils/0g.conf
	
	# On installe avec '0g' :
	0g busybox
	0g base-systeme
	0g glibc
	0g ncurses
	0g readline
	0g bash
	0g sgml-common
	0g 0outils
	
	# La config' de 0g sur $SETUPROOT n'a pas besoin de "ROOT=" :
	echo "Source=\"${PROTOCOLE}${MEDIACHOISI}\"" >> ${SETUPROOT}/etc/0outils/0g.conf
	
	# $SETUPROOT a aussi besoin du cache de 0g :
	mkdir -p ${SETUPROOT}/var/cache/0g
	mount --bind /var/cache/0g ${SETUPROOT}/var/cache/0g 1>/dev/null 2>/dev/null
	
	# On installe la base :
	if [ "${INSTALLDEBUG}" = "" ]; then
		clear
	fi
	echo -e "\033[1;32mInstallation de 'base-abonnement'...\033[0;0m"
	echo ""
	echo "Exécution de :"
	echo "	0g base-abonnement"
	sleep 3
	
	0g base-abonnement
	
	# On réinstalle 'base-systeme' par sécurité (utilisateurs/groupes possiblement manquants) :
	spackadd -f --root=${SETUPROOT} /var/cache/0g/${VERSION}/$(uname -m)/a/base-systeme/*.spack 2>/dev/null 1>/dev/null || true
	
	if [ "${INSTALLDEBUG}" = "" ]; then
		clear
	fi
	echo -e "\033[1;32mChoix des abonnements logiciels supplémentaires.\033[0;0m"
	echo ""
	echo "Il est temps de faire votre choix parmi les abonnements de 0Linux."
	echo "Vous allez pour cela utiliser l'outil '0g' dans la console n°2."
	echo "Les paquets-abonnements (dans 'z/') sont des ensembles cohérents de logiciels"
	echo "qui simplifient leur installation."
	echo ""
	echo "'base-abonnement' a déjà été installé d'office et forme la base du système."
	echo "Si vous désirez utiliser un environnement ou un bureau graphique, installez"
	echo "'xorg-abonnement'."
	echo ""
	echo "L'abonnement 'opt-abonnement', quant à lui, permet de disposer de la"
	echo "plupart des bibliothèques et outils système dans une sélection très complète"
	echo "de logiciels. Installez-le si vous débutez."
	echo ""
	echo "Ainsi, pour installer les abonnements recommandés, vous taperez :"
	echo "	0g xorg-abonnement opt-abonnement"
	echo ""
	echo -n "Appuyez sur ENTRÉE quand vous en avez terminé avec ces abonnements."
	read BLURB2;
	
	if [ "${INSTALLDEBUG}" = "" ]; then
		clear
	fi
	echo -e "\033[1;32mChoix des paquets logiciels supplémentaires.\033[0;0m"
	echo ""
	echo "Il est temps de faire votre choix parmi les paquets de 0Linux."
	echo "Vous allez pour cela utiliser l'outil '0g' dans la console n°2."
	echo ""
	echo "'0g' ne permet pas encore de lister les paquets disponibles ou d'en avoir"
	echo "une description ; consultez donc directement le dépôt de paquets pour en"
	echo "savoir plus sur son contenu. Des fichiers '*.txt' contiennent une"
	echo "description pour chaque paquet. "
	echo "Utilisez les abonnements de 'z/' pour vous faciliter la tâche !"
	echo ""
	echo "Pour installer un environnement graphique, vous ferez par exemple :"
	echo "	0g kde-abonnement"
	echo "	0g xfce-abonnement"
	echo "	0g enlightenment-abonnement"
	echo ""
	echo "Puis par exemple, pour installer le navigateur Firefox :"
	echo "	0g firefox"
	echo ""
	echo "Nous faciliterons l'accès aux listings et aux descriptions très prochainement."
	echo "Vous utiliserez souvent '0g', familiarisez-vous avec, il est très simple."
	echo "Consultez '0g -h' ou 'man 0g' pour en savoir plus."
	echo ""
	echo -n "Appuyez sur ENTRÉE quand vous avez terminé avec l'installation des paquets."
	read BLURB3;
	
	if [ "${INSTALLDEBUG}" = "" ]; then
		clear
	fi
	echo -e "\033[1;32mConfiguration de votre système Linux.\033[0;0m"
	echo ""
	echo "Si vous en avez terminé avec '0g', appuyez sur ENTRÉE pour passer à la"
	echo "configuration du système. N'utilisez plus '0g' car il ne pointera plus"
	echo "sur votre partition racine '$(cat $TMP/partition_racine)' dorénavant."
	echo "Vous pourrez l'utiliser à nouveau après le redémarrage."
	echo ""
	echo -n "Appuyez sur ENTRÉE pour passer à la configuration de votre système."
	read BLURB4;
	
	# On nettoie tous les fichiers '*.0nouveau' au cas où :
	for f in $(find ${SETUPROOT}/{etc,var} -type f -name "*.0nouveau" 2>/dev/null); do
		mv ${f} $(dirname ${f})/$(basename ${f} .0nouveau) 2>/dev/null || true
	done
	
	# Astuce sed : on peut supprimer des lignes (commande '//d)' avec d'autres
	# délimiteurs que le « slash » en échappant le premier délimiteur ;) :
	
	# On supprime la configuration de 0g :
	sed -i "\@^Source=\"${PROTOCOLE}${MEDIACHOISI}\"@d" /etc/0outils/0g.conf
	sed -i "\@^ROOT=\"${SETUPROOT}\"@d"                 /etc/0outils/0g.conf

	# On supprime la configuration de 0g sur $SETUPROOT :
	sed -i "\@^Source=\"${PROTOCOLE}${MEDIACHOISI}\"@d" ${SETUPROOT}/etc/0outils/0g.conf
	
	# On place la config' standard par défaut sur $SETUPROOT :
	sed -i '
/# Source=file:\/\/${Cache}.*$/ i\
Source="ftp://ftp.igh.cnrs.fr/pub/os/linux/0linux/paquets"
' ${SETUPROOT}/etc/0outils/0g.conf
	
	# On démonte le cache de 0g sur $SETUPROOT :
	umount -f ${SETUPROOT}/var/cache/0g 1>/dev/null 2>/dev/null || true
fi

# C'est fini.
