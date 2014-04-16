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
findelves "$@" 2>&1
