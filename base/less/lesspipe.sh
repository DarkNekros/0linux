#!/bin/env bash
# Ce fichier est un préprocesseur pour 'less' afin de pouvoir visualiser sans
# action préalable différents types de contenus (compressés, par exemple).
# Ce préprocesseur est utilisé lorsque la variable d'environnement suivante est
# positionnée :
#	LESSOPEN="|lesspipe.sh %s"

lesspipe() {
	
	case "$1" in
		
		*.tar)
			tar tvvf "$1" 2>/dev/null
		;;
		*.tgz | *.tar.gz | *.tar.Z | *.tar.z | *.tar.bz2 | *.tbz )
			tar tvvf "$1" 2>/dev/null
		;;
		*.tlz | *.tar.lzma )
			lzma -dc "$1" 2> /dev/null | tar tvvf - 2> /dev/null
		;;
		*.txz | *.tar.xz )
			xz -dc "$1" 2> /dev/null | tar tvvf - 2> /dev/null
		;;
		*.zip)
			unzip -l "$1" 2>/dev/null
		;;
		*.rpm)
			rpm -qpvl "$1" 2>/dev/null
		;;
		*.rar)
			if which rar 1> /dev/null ; then
				`which rar` t "$1" 
			fi
		;;
		*.1|*.2|*.3|*.4|*.5|*.6|*.7|*.8|*.9|*.n|*.man)
			if file -L "$1" | grep roff 1> /dev/null ; then
				nroff -S -mandoc "$1"
			fi
		;;
		*.1.gz|*.2.gz|*.3.gz|*.4.gz|*.5.gz|*.6.gz|*.7.gz|*.8.gz|*.9.gz|*.n.gz|*.man.gz)
			if gzip -dc "$1" | file - | grep roff 1> /dev/null ; then
				gzip -dc "$1" | nroff -S -mandoc -
			fi
		;;
		*.1.bz2|*.2.bz2|*.3.bz2|*.4.bz2|*.5.bz2|*.6.bz2|*.7.bz2|*.8.bz2|*.9.bz2|*.n.bz2|*.man.bz2)
			if bzip2 -dc "$1" | file - | grep roff 1> /dev/null ; then
				bzip2 -dc "$1" | nroff -S -mandoc -
			fi
		;;
		*.gz)
			gzip -dc "$1"  2>/dev/null
		;;
		*.bz2)
			bzip2 -dc "$1" 2>/dev/null
		;;
		*.lzma)
			lzma -dc "$1" 2>/dev/null
		;;
		*.xz)
			xz -dc "$1" 2>/dev/null
		;;
		*.cpio) 
			zip=$(cpio --quiet --list "files.?z" < "$1" | sed 's/.*xz$/xz/;s/.*gz/gzip/;/^\(gzip\|xz\)$/!d')
			if [ "$zip" ]; then
				cpio --quiet -i --to-stdout "files.?z"  < "$1" | $zip -d -c | cpio --quiet --list
			else
				cpio --quiet --list <"$1"
			fi
		;;
	
	esac

}

lesspipe "$1"
