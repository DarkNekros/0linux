# Schéma de coloration pour la sortie de la commande 'ls'.

# On personnalise le formatage avec des colonnes et le support des caractères spéciaux :
# Pour tous les shells compatibles sh sauf zsh:
if [ "$SHELL" != "/bin/zsh" ]; then
	OPTIONS="-b -T 0"
else
	# Pour zsh uniquement :
	OPTIONS=( -b -T 0 )
fi

# COLOR accepte trois paramètres :
# 'auto' colorise tout vers les terminaux, sauf les tubes. Recommandé !
# 'always' colorise tout. À éviter.
# 'never' ne colorise rien. Triste.
COLOR=auto

if [ "$SHELL" = "/bin/zsh" ]; then
	LS_OPTIONS=( $OPTIONS --color=$COLOR );
else
	LS_OPTIONS=" $OPTIONS --color=$COLOR ";
fi

export LS_OPTIONS
unset COLOR
unset OPTIONS

# Les couleurs dans $HOME ont la priorité :
if [ -f $HOME/.dir_colors ]; then
	eval `/bin/dircolors -b $HOME/.dir_colors`
elif [ -f /etc/DIR_COLORS ]; then
	eval `/bin/dircolors -b /etc/DIR_COLORS`
else
	eval `/bin/dircolors -b`
fi

# On définit enfin l'alias pour 'ls' :
alias ls='ls $LS_OPTIONS'
