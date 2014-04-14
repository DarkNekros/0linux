# On exécute le '.bashrc' s'il est exécutable :
if [ -r ${HOME}/.bashrc ] ; then
	source $HOME/.bashrc
fi
