#!/bin/env bash
while [ "`cat ${SETUPROOT}/etc/shadow | grep 'root:' | cut -f 2 -d :`" = "" ]; do
	# Si aucun mot de passe root n'est défini :
	definerootpassword
	
	# Si l'utilisateur veut définir un mot de passe pour root :
	if [ $? = 0 ] ; then
		# On passe en terminal :
		clear
		chroot ${SETUPROOT} /usr/bin/passwd root
		pressentertocontinue
		
		read poop;
	# Si l'utilisateur ne veut pas de mot de passe root (ha ha !) :
	else
		break;
	fi
done

# C'est fini !
