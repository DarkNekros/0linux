#!/bin/env bash
# Voyez le fichier LICENCES pour connaître la licence de ce script.
# Ce script compile BusyBox dans $TMP/${NAME}

set -e
umask 022
CWD=$(pwd)

NAMESRC=${NAMESRC:-busybox}
VERSION=${VERSION:-1.17.1}
EXT=${EXT:-tar.bz2}

TMP=${TMP:-/tmp}
WGET=${WGET:-http://busybox.net/downloads/$NAMESRC-$VERSION.$EXT}

# On télécharge les sources :
if [ ! -r ${NAMESRC}-${VERSION}.$EXT ]; then
	wget -vc $WGET -O ${NAMESRC}-${VERSION}.$EXT.part
	mv ${NAMESRC}-${VERSION}.$EXT.part ${NAMESRC}-${VERSION}.$EXT
fi

# On les vérifie :
tar ft ${NAMESRC}-${VERSION}.$EXT 1> /dev/null 2> /dev/null

# On déballe et on se place dans les sources :
NAME=$(tar ft ${NAMESRC}-${VERSION}.$EXT | head -n 1 | awk -F/ '{ print $1 }')
cd $TMP
rm -rf ${NAME}
echo "Extraction en cours..."
tar xf $CWD/${NAMESRC}-${VERSION}.$EXT
cd ${NAME}

cp -a $CWD/busybox-config $TMP/${NAME}/.config
make oldconfig 
make install CONFIG_PREFIX=/tmp/BusyBox-build

exit 0
