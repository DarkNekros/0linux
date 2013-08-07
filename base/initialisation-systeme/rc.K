#!/bin/sh
#
# /etc/rc.d/rc.K : ce fichier est exécuté lors du passage en mode mono-
# utilisateur par init(8) (donc dans le niveau d'exécution 1).

# On spécifie le PATH :
PATH=/sbin:/bin:/usr/bin:/usr/sbin

# Chargement de la disposition des touches du clavier :
if [ -x /etc/rc.d/rc.clavier ]; then
	. /etc/rc.d/rc.clavier start
fi

# Chargement de la police :
if [ -x /etc/rc.d/rc.police ]; then
	. /etc/rc.d/rc.police start
fi

# Lancement des scripts locaux d'arrêt :
if [ -x /etc/rc.d/rc.local_shutdown ]; then
	. /etc/rc.d/rc.local_shutdown
fi

# Démontage des systèmes de fichiers distants :
echo "Démontage des systèmes de fichiers distants."
umount -a -r -t nfs,smbfs,cifs

# On tue tous les processus :
echo "Envoi des signaux d'arrêt aux processus en cours..."
killall5 -1
sleep 1
killall5 -15
sleep 1
killall5 -9
sleep 1

# On passe maintenant au mode mono-utilisateur :
echo "Passage en mode mono-utilisateur..."
telinit 1

# C'est fini !
