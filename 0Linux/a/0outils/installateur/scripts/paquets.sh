#!/usr/bin/env bash

# On nettoie :
unset CHOIXMENUABO BUROABO

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

# Quelques vérif' avant l'installation des paquets :
MEDIACHOISI="$(cat $TMP/choix_media)"

# On ajoute le protocole 'file://' si le dépôt est local :
if [ "$(echo ${MEDIACHOISI} | grep -E '^ftp:')" = "" ]; then
	PROTOCOLE="file://"
else
	PROTOCOLE=""
fi

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
	
	Source="${PROTOCOLE}${MEDIACHOISI}" ROOT="${SETUPROOT}" 0g \
		busybox \
		base-systeme \
		glibc \
		ncurses \
		readline \
		bash \
		sgml-common \
		2>/dev/null
	
	# On installe la base :
	if [ "${INSTALLDEBUG}" = "" ]; then
		clear
	fi
	echo -e "\033[1;32mInstallation de 'base-abonnement'...\033[0;0m"
	echo ""
	
	Source="${PROTOCOLE}${MEDIACHOISI}" ROOT="${SETUPROOT}" 0g base-abonnement
	
	# On réinstalle 'base-systeme' par sécurité (utilisateurs/groupes possiblement manquants) :
	spackadd -f --root=${SETUPROOT} /var/cache/0g/${VERSION}/$(uname -m)/a/base-systeme/*.spack 2>/dev/null 1>/dev/null || true
	
	# On propose la suite :
	while [ 0 ]; do
		if [ "${INSTALLDEBUG}" = "" ]; then
			clear
		fi
		echo -e "\033[1;32mChoix des abonnements logiciels supplémentaires.\033[0;0m"
		echo ""
		echo "Il est temps de faire votre choix parmi les abonnements proposés par 0Linux."
		echo "Les abonnements sont des ensembles cohérents de logiciels qui simplifient leur"
		echo "installation."
		echo "Si vous désirez utiliser un environnement ou un bureau graphique, il est"
		echo "recommandé d'installer les abonnements 'opt' et 'xorg' afin de disposer d'un"
		echo "complet et exploitable. L'installateur vous proposera ensuite une liste"
		echo "d'environnements graphiques."
		echo ""
		echo "Entrez ci-après le code de la rubrique souhaitée et appuyez sur ENTRÉE."
		echo "En cas de doute, choisissez ASSISTANT."
		echo ""
		echo "1 : ASSISTANT - installer 'opt', 'xorg' puis un env. graphique (recommandé)"
		echo "2 : MANUEL    - installer manuellement (pour utilisateurs avertis)"
		echo ""
		echo -n "Votre choix : "
		read CHOIXMENUABO;
		case "$CHOIXMENUABO" in
			"1")
				# On installe opt et xorg : :
				if [ "${INSTALLDEBUG}" = "" ]; then
					clear
				fi
				echo -e "\033[1;32mInstallation des abonnements...\033[0;0m"
				echo ""
				
				Source="${PROTOCOLE}${MEDIACHOISI}" ROOT="${SETUPROOT}" 0g \
					opt-abonnement \
					xorg-abonnement
				
				# On passe aux environnements graphiques :
				while [ 0 ]; do
					if [ "${INSTALLDEBUG}" = "" ]; then
						clear
					fi
					echo -e "\033[1;32mChoix de l'environnement graphique.\033[0;0m"
					echo ""
					echo "Il est temps de choisir un environnement graphique parmi les abonnements"
					echo "proposés par 0Linux. Vous pouerrez en installer d'autres plus tard"
					echo "en utilisant l'outil '0g'."
					echo ""
					echo "Entrez ci-après le code de la rubrique souhaitée et appuyez sur ENTRÉE."
					echo ""
					
					echo "1 : E     - (Très) Épuré et élégant"
					echo "2 : KDE   - Complet, moderne et facile d'utilisation"
					echo "3 : XFCE  - Classique, léger et complet"
					echo "4 : AUCUN - TWM sera le gestionnaire de fenêtres par défaut (rudimentaire)."
					echo ""
					echo -n "Votre choix : "
					read BUROABO;
					case BUROABO in
					"1")
						BUREAUCHOISI="enlightenment-abonnement"
					;;
					"2")
						BUREAUCHOISI="kde-abonnement"
					;;
					"3")
						BUREAUCHOISI="xfce-abonnement"
					;;
					"4")
						BUREAUCHOISI=""
					;;
					*)
						echo "Veuillez entrer un numéro valide (entre 1 et 4)."
						sleep 2
						continue
					esac
					
					# On installe l'abonnement demandé :
					if [ ! "${BUREAUCHOISI}" = "" ]; then
						Source="${PROTOCOLE}${MEDIACHOISI}" ROOT="${SETUPROOT}" 0g ${BUREAUCHOISI}
					fi
					break
				done
			;;
			"2")
				break
			;;
			*)
				echo "Veuillez entrer un numéro valide (entre 1 et 2)."
				sleep 2
				continue
		esac
	done
	
	# On nettoie tous les fichiers '*.0nouveau' au cas où :
	for f in $(find ${SETUPROOT}/etc -type f -name "*.0nouveau"); do
		mv ${f} $(dirname ${f})/$(basename ${f} .0nouveau)
	done
fi

# C'est fini.
