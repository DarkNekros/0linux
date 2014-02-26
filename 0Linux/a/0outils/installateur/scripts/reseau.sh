#!/usr/bin/env bash

# On nettoie :
unset REPONSEREZO ETHOK
while [ 0 ]; do
	# Pour les quatre premières interfaces Ethernet :
	for ethx in eth0 eth1 eth2 eth3; do
		
		# On tente de se connecter de façon rudimentaire :
		ifconfig ${ethx} || true
		ifconfig ${ethx} up || true
		dhcpcd ${ethx} || true
		
		# On sort de la boucle si une IP est présente :
		if [ ! "$(ifconfig ${ethx} | grep 'inet addr')" = "" ]; then
			ETHOK=${ethx}
			break
			
		# Sinon, on passe à l'interface suivante en fermant l'actuelle :
		else
			ifconfig ${ethx} down || true
		fi
	done
	
	# On informe de l'état de la connexion :
	if [ ! "${ETHOK}" = "" ]; then
		echo "Connexion réseau activée sur ${ethx}."
		
		# On note le dépôt dans 'choix_media' :
		echo "ftp://ftp.igh.cnrs.fr/pub/os/linux/0linux/paquets" > $TMP/choix_media
		sleep 2
		break
	else
		echo "Aucune connexion réseau Ethernet n'a pu être détectée."
		echo "L'installateur n'a testé qu'une connexion filaire de type Ethernet, avec"
		echo "une IP attribuée automatiquement par DHCP."
		echo "Vous pouvez tenter de vous connecter manuellement via un autre"
		echo "terminal à l'aide des commandes 'ifconfig', 'dhcpcd', 'iwconfig', etc."
		echo ""
		echo "Appuyez sur ENTRÉE pour revenir au menu principal."
		read REPONSEREZO;
		break
	fi
done

# C'est fini !
