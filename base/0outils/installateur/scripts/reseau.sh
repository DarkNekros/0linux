#!/usr/bin/env bash

# On nettoie :
unset REPONSEREZO ETHOK

while [ 0 ]; do
	if [ "${INSTALLDEBUG}" = "" ]; then
		clear
	fi
	echo -e "\033[1;32mConnexion au réseau.\033[0;0m"
	echo ""
	echo "L'installateur va tenter de se connecter à Internet automatiquement."
	echo "Il ne testera qu'une connexion filaire de type Ethernet, avec une IP"
	echo "attribuée automatiquement par DHCP."
	echo "S'il échoue, vous pouvez tenter de vous connecter manuellement via un"
	echo "autre terminal à l'aide des commandes 'ifconfig', 'dhcpcd', iwconfig, etc."
	echo ""
	echo "Tapez « oui » pour continuer ou appuyez sur ENTRÉE pour revenir au"
	echo "menu principal."
	echo ""
	echo -n "Votre choix : "
	read REPONSEREZO;
	if [ "${REPONSEREZO}" = "" ]; then
		break
	elif [ "${REPONSEREZO}" = "oui" ]; then
		
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
			# Sinon, on passe à l'interface suivante et on ferme celle-ci en libérant le bail DHCP :
			else
				ifconfig ${ethx} down || true
				dhcpcd -r ${ethx} || true
			fi
		done
		
		# On informe de l'état de la connexion :
		if [ ! "${ETHOK}" = "" ]; then
			echo "Connexion réseau activée sur ${ethx}."
			sleep 2
			break
		else
			echo "Aucune connexion réseau n'a pu être activée. Retour au menu principal..."
			sleep 2
			break
		fi
	else
		echo "Veuillez taper « oui » ou appuyer sur ENTRÉE uniquement."
		sleep 2
		continue
	fi
done

# C'est fini !
