#!/bin/sh
findelves () {
    # Print the dynamic library list the given stuff is linked to.
    # $f FILE OR DIRECTORY
    local x="( -perm -100 -o -perm -010 -o -perm -001 )" # POSIX -perm /111
    find "$@" -type f $x | awk 'BEGIN{sh="/bin/sh -s"}
                                     {gsub(/[ "(){}\[\]$`\047]/,"\\\\&")
                                      '"$LDDAWK"' | sh }
                                END{close(sh)}'
}

makeldd () {
    # Récupère les ld* sous forme de disjonctions imprimées via awk.
    # $f
    local ldd=$(which ldd 2>/dev/null)
    [ "$ldd" ] || growl 1 "Ne peut trouver ldd."
    awk '/^RTLDLIST=/{gsub(/^[^=]+=|"|[\t ]+$/,"");
                      gsub(/[\t ]+/," --list \"$0\" || ");
                      print "print \""$0" --list \"$0"; exit OK=1}
                      END {exit OK ? 0 : 1}' "$ldd" || \
                          growl 1 "$ldd: variable RTLDLIST inexploitable!"
}

# === Main =====================================================================
export LC_ALL="C"
LDDAWK="$(makeldd)" || exit 1

# On vérifie qu'aucun binaire n'est cassé. Sur tous les binaires
# apparaissant comme cassés, on considère réllement cassé tout binaire dont
# on ne trouve nulle part ailleurs la bibliothèque liée marqué comme manquante,
# ce afin d'ignorer tous les binaires possédant leur propre système de
# chargement d'objet partagé (Samba, les softs de Mozilla, Java, Ardour,
# LibreOffice, etc.) :
findelves "$@" 2>&1 | grep 'cannot open shared object file: No such file or directory' | \
	while read missinglib; do
		[ $(find /usr -name "$(echo ${missinglib} | cut -d':' -f3 | tr -d '[[:blank:]]')" 2>/dev/null | wc -l) -eq 0 ] && \
		echo "Cassé : $(echo \"${missinglib}\" | cut -d':' -f1,3) manquant"
	done
