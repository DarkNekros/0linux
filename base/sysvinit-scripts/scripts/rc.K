#!/bin/sh
#
# /etc/rc.d/rc.K : ce fichier est exécuté lors du passage en mode mono-
# utilisateur par init(8) (donc dans le niveau d'exécution 1).
# Très lourdement inspiré de Slackware.

# On spécifie le PATH :
PATH=/sbin:/bin:/usr/bin:/usr/sbin

# Chargement de la disposition de touches du clavier :
if [ -x /etc/rc.d/rc.keymap ]; then
	. /etc/rc.d/rc.keymap
fi

# Lancement des scripts SystemV s'il y en a pour ce niveau d'exécution :
if [ -x /etc/rc.d/rc.sysvinit ]; then
	. /etc/rc.d/rc.sysvinit
fi

# Lancement des scripts locaux d'arrêt :
if [ -x /etc/rc.d/rc.local_shutdown ]; then
	/etc/rc.d/rc.local_shutdown
fi

# Démontage des systèmes de fichiers distants :
echo "Démontage des systèmes de fichiers distants."
umount -a -r -t nfs,smbfs,cifs

# On tue tous les processus :
echo "Envoi du signal SIGHUP aux processus..."
killall5 -1
sleep 3
echo "Envoi du signal SIGTERM aux processus..."
killall5 -15
sleep 3
echo "Envoi du signal SIGKILL aux processus..."
killall5 -9
sleep 2

# On passe maintenant au mode mono-utilisateur :
echo "Passage en mode mono-utilisateur..."
telinit -t 1 1

# C'est fini !
