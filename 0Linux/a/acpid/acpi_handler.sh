#!/usr/bin/env bash

# Liste des commandes à exécuter selon les évènements ACPI émis. La plupart
# émettent seulement un message système journalisé. À adapter à ses besoins.
# Ce fichier ne sera jamais écrasé par une mise à jour du paquet 'acpid'.

IFS=${IFS}/
set $@

case "$1" in
	button/power)
		case "$2" in
			PBTN|PWRF)
				logger "Bouton d'alimentation enfoncé."
				/sbin/init 0
			 ;;
			*)
				logger "L'action '$2' pour l'évènement ACPI '$1' n'est pas définie."
			;;
		esac
	;;
	button/sleep)
		case "$2" in
			SLPB|SBTN)
				logger "Bouton de mise en veille enfoncé."
			 ;;
			*)
				logger "L'action '$2' pour l'évènement ACPI '$1' n'est pas définie."
			;;
		esac
	;;
	ac_adapter)
		case "$2" in
			AC|ACAD|ADP0)
				case "$4" in
					00000000)
						logger "Cordon d'alimentation débranché."
					;;
					00000001)
						logger "Cordon d'alimentation branché."
					;;
				esac
			 ;;
			*)
				logger "L'action '$2' pour l'évènement ACPI '$1' n'est pas définie."
			;;
		esac
	;;
	battery)
		case "$2" in
			BAT0)
				case "$4" in
					00000000)
						logger "Batterie attachée."
					;;
					00000001)
						logger "Batterie détachée."
					;;
				esac
			 ;;
			CPU0)
				# Ajouter ici des actions pour cet évènement.
			;;
			*)
				logger "L'action '$2' pour l'évènement ACPI '$1' n'est pas définie."
			;;
		esac
	;;
	button/lid)
		case "$3" in
			close)
				logger "Écran/couvercle replié."
			;;
			open)
				logger "Écran/couvercle déplié."
			;;
			*)
				logger "L'action '$3' pour l'évènement ACPI '$1' n'est pas définie."
			;;
		esac
		;;
		*)
			logger "L'action '$2' pour l'évènement ACPI '$1' n'est pas définie."
		;;
	esac
	;;
	*)
		logger "L'action '$2' pour l'évènement ACPI '$1' n'est pas définie."
	;;
esac
