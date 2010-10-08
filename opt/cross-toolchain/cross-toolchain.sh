#!/bin/env bash

# Construction de la chaine d'outils croisee multilib i686/x86_64.

# 1. Choisissez un repertoire et affectez-le a $CLFS, voir plus bas.

# 2. Il faut avoir cree les repertoires $CLFS/{cross-tools,tools,sources}.

# 3. Il faut avoir cree les liens '/cross-tools' et '/tools' (à la racine,
# donc en root), pointant vers les bons repertoires.

# 4. Executer avec la variable DOWNLOAD positionnee pour telecharger les sources :
#	$ DOWNLOAD=oui ./cross-toolchain.sh

# N.B. : A VOS RISQUES ET PERILS. EVITEZ DE LANCER CECI EN ROOT.

set -e
set +h
umask 022
CWD=$(pwd)
unset CC CXX AR AS RANLIB LD STRIP CFLAGS CXXFLAGS

# Le PATH placant 'cross-tools' en premier :
PATH=/cross-tools/bin:/bin:/usr/bin
export PATH

# La partition separee ou le repertoire ou on va placer les fichiers compiles :
CLFS=${CLFS:-/home/appzer0/cross-toolchain2011}

# L'hote *dinstinct* de l'hote reel :
CLFS_HOST=$(echo ${MACHTYPE} | sed "s/$(echo ${MACHTYPE} | cut -d'-' -f2)/cross/")

# Le systeme cible 32 bits :
CLFS_TARGET32=${CLFS_TARGET32:-i686-0-linux-gnu}

# Le systeme cible 64 bits :
CLFS_TARGET=${CLFS_TARGET:-x86_64-0-linux-gnu}

# La locale (C ou POSIX et pas autre chose) :
export LC_ALL=${LC_ALL:-POSIX}

# Les drapeaux de compilation 32 et 64 bits :
BUILD32=${BUILD32:--m32}
BUILD64=${BUILD64:--m64}

# Emplacement des archives sources et des correctifs :
SOURCES=${SOURCES:-${CLFS}/sources}

# Nom et versions des archives :
LINUX=linux-2.6.35.7
FILE=file-5.03
NCURSES=ncurses-5.7
GMP=gmp-5.0.1
MPFR=mpfr-3.0.0
FINDUTILS=findutils-4.4.2
BINUTILS=binutils-2.20.1
GCC=gcc-4.5.1
EGLIBC=eglibc-2.12_10102010
MPC=mpc-0.8.2
PPL=ppl-0.10.2
CLOOGPPL=cloog-ppl-0.15.9
TCL=tcl8.5.9
EXPECT=expect-5.44.1.15
DEJAGNU=dejagnu-1.4.4
BISON=bison-2.4.3
BASH4=bash-4.1
ZLIB=zlib-1.2.5
BZIP2=bzip2-1.0.6
COREUTILS=coreutils-8.5
DIFFUTILS=diffutils-3.0
FLEX=flex-2.5.35
GAWK=gawk-3.1.8
GETTEXT=gettext-0.18.1.1
GREP=grep-2.7
GZIP=gzip-1.4
M4=m4-1.4.15
MAKE=make-3.82
PATCH=patch-2.6.1
SED=sed-4.2.1
TAR=tar-1.23
TEXINFO=texinfo-4.13a
XZ=xz-4.999.9beta
UTILLINUXNG=util-linux-ng-2.18

# Si $DOWNLOAD n'est pas vide, alors on veut telecharger les sources :
if [ ! "$DOWNLOAD" = "" ]; then

	# URL des archives a telecharger, sources et correctifs :
	URLS="http://www.kernel.org/pub/linux/kernel/v2.6/$LINUX.tar.bz2 \
		ftp://ftp.astron.com/pub/file/$FILE.tar.gz \
		http://patches.cross-lfs.org/dev/file-5.03-cross_compile-1.patch \
		http://ftp.gnu.org/gnu/ncurses/$NCURSES.tar.gz \
		http://ftp.gnu.org/gnu/gmp/$GMP.tar.bz2 \
		http://www.mpfr.org/$MPFR/$MPFR.tar.xz \
		ftp://ftp.gnu.org/gnu/findutils/$FINDUTILS.tar.gz \
		ftp://ftp.gnu.org/gnu/binutils/$BINUTILS.tar.bz2 \
		http://ftp.gnu.org/gnu/gcc/$GCC/$GCC.tar.bz2 \
		http://patches.cross-lfs.org/dev/gcc-4.5.1-specs-1.patch \
		http://patches.cross-lfs.org/dev/eglibc-2.12-20100725-r11059-make382-1.patch \
		http://www.multiprecision.org/mpc/download/$MPC.tar.gz \
		ftp://ftp.cs.unipr.it/pub/ppl/releases/$(echo $PPL | cut -d'-' -f2)/$PPL.tar.bz2 \
		ftp://gcc.gnu.org/pub/gcc/infrastructure/$CLOOGPPL.tar.gz \
		http://prdownloads.sourceforge.net/tcl/$TCL-src.tar.gz \
		http://prdownloads.sourceforge.net/expect/$EXPECT.tar.bz2 \
		ftp://ftp.gnu.org/gnu/dejagnu/$DEJAGNU.tar.gz \
		ftp://ftp.gnu.org/gnu/bison/$BISON.tar.bz2 \
		http://ftp.gnu.org/gnu/bash/$BASH4.tar.gz \
		http://patches.cross-lfs.org/dev/bash-4.1-branch_update-1.patch \
		http://prdownloads.sourceforge.net/libpng/$ZLIB.tar.bz2 \
		http://www.bzip.org/$(echo $BZIP2 | cut -d'-' -f2)/$BZIP2.tar.gz \
		ftp://ftp.gnu.org/gnu/coreutils/$COREUTILS.tar.xz \
		ftp://ftp.gnu.org/gnu/diffutils/$DIFFUTILS.tar.xz \
		http://prdownloads.sourceforge.net/flex/$FLEX.tar.bz2 \
		http://patches.cross-lfs.org/dev/flex-2.5.35-gcc44-1.patch \
		http://ftp.gnu.org/gnu/gawk/$GAWK.tar.bz2 \
		http://ftp.gnu.org/gnu/gettext/$GETTEXT.tar.gz \
		http://ftp.gnu.org/gnu/grep/$GREP.tar.gz \
		http://ftp.gnu.org/gnu/gzip/$GZIP.tar.xz \
		http://ftp.gnu.org/gnu/m4/$M4.tar.xz \
		http://ftp.gnu.org/gnu/make/$MAKE.tar.bz2 \
		http://ftp.gnu.org/gnu/patch/$PATCH.tar.xz \
		http://ftp.gnu.org/gnu/sed/$SED.tar.bz2 \
		http://ftp.gnu.org/gnu/tar/$TAR.tar.bz2 \
		http://www.linuxfromscratch.org/patches/lfs/development/tar-1.23-overflow_fix-1.patch \
		ftp://ftp.gnu.org/gnu/texinfo/$TEXINFO.tar.gz \
		http://tukaani.org/xz/$XZ.tar.xz \
		http://www.kernel.org/pub/linux/utils/util-linux-ng/v2.18/$UTILLINUXNG.tar.bz2 \
	"
	
	for archive in ${URLS}; do
		# On telecharge les sources :
		cd $SOURCES
		if [ ! -r $(basename ${archive}) ]; then
			wget -vc ${archive}
		fi
		cd -
	done
	
	cd $SOURCES
	if [ ! -r $EGLIBC.tar.xz ]; then
		# On synchronise avec le SVN de eglibc :
		svn co svn://svn.eglibc.org/trunk $EGLIBC
		tar cfvJ $EGLIBC.tar.xz $EGLIBC
	fi
	cd -

fi

# linux-headers
cd $SOURCES
rm -rf $LINUX
tar xf $SOURCES/$LINUX.tar.*
cd $LINUX
install -dv /tools/include
make mrproper
make ARCH=x86_64 headers_check
make ARCH=x86_64 INSTALL_HDR_PATH=dest headers_install
cp -rv dest/include/* /tools/include

# file
cd $SOURCES
rm -rf $FILE
tar xf $SOURCES/$FILE.tar.*
cd $SOURCES/$FILE
cat $SOURCES/file-5.03-cross_compile-1.patch | patch -p1
./configure --prefix=/cross-tools
make
make install

# ncurses
cd $SOURCES
rm -rf $NCURSES
tar xf $SOURCES/$NCURSES.tar.*
cd $SOURCES/$NCURSES
./configure --prefix=/cross-tools \
	--without-debug --without-shared
make -C include
make -C progs tic
install -m755 progs/tic /cross-tools/bin

# gmp
cd $SOURCES
rm -rf $GMP
tar xf $SOURCES/$GMP.tar.*
cd $SOURCES/$GMP
CPPFLAGS=-fexceptions ./configure \
	--prefix=/cross-tools --enable-cxx
make
make install

# mpfr
cd $SOURCES
rm -rf $MPFR
tar xf $SOURCES/$MPFR.tar.*
cd $SOURCES/$MPFR
LDFLAGS="-Wl,-rpath,/cross-tools/lib" \
	./configure --prefix=/cross-tools \
	--enable-shared --with-gmp=/cross-tools
make
make install

# mpc
LDFLAGS="-Wl,-rpath,/cross-tools/lib" \
./configure --prefix=/cross-tools \
	--with-gmp=/cross-tools \
	--with-mpfr=/cross-tools
make
make install

# ppl
cd $SOURCES
rm -rf $PPL
tar xf $SOURCES/$PPL.tar.*
cd $SOURCES/$PPL
sed -i -e "s/__GMP_BITS_PER_MP_LIMB/GMP_LIMB_BITS/g" configure
LDFLAGS="-Wl,-rpath,/cross-tools/lib" \
	./configure --prefix=/cross-tools --enable-shared \
	--enable-interfaces="c,cxx" --disable-optimization \
	--with-libgmp-prefix=/cross-tools \
	--with-libgmpxx-prefix=/cross-tools
make
make install

# cloog-ppl
cd $SOURCES
rm -rf $CLOOGPPL
tar xf $SOURCES/$CLOOGPPL.tar.*
cd $SOURCES/$CLOOGPPL
cp configure{,.orig}
sed "/LD_LIBRARY_PATH=/d" configure.orig > configure
LDFLAGS="-Wl,-rpath,/cross-tools/lib" \
	./configure --prefix=/cross-tools --enable-shared --with-bits=gmp \
	--with-gmp=/cross-tools --with-ppl=/cross-tools
make
make install

# binutils
cd $SOURCES
rm -rf $BINUTILS
rm -rf binutils-build
tar xf $SOURCES/$BINUTILS.tar.*
rm -rf $SOURCES/binutils-build
cd $SOURCES/$BINUTILS
mkdir -p $SOURCES/binutils-build
cd $SOURCES/binutils-build
AR=ar AS=as $SOURCES/$BINUTILS/configure --prefix=/cross-tools \
	--host=${CLFS_HOST} --target=${CLFS_TARGET} \
	--with-sysroot=${CLFS} --with-lib-path=/tools/lib --disable-nls \
	--enable-shared --enable-64-bit-bfd
make configure-host
make
make install
cp -v $SOURCES/$BINUTILS/include/libiberty.h /tools/include

# gcc statique
cd $SOURCES
rm -rf $GCC
rm -rf gcc-build
tar xf $SOURCES/$GCC.tar.*
cd $SOURCES/$GCC
cat $SOURCES/gcc-4.5.1-specs-1.patch | patch -p1
echo -en '#undef STANDARD_INCLUDE_DIR\n#define STANDARD_INCLUDE_DIR "/tools/include/"\n\n' >> gcc/config/linux.h
echo -en '\n#undef STANDARD_STARTFILE_PREFIX_1\n#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"\n' >> gcc/config/linux.h
echo -en '\n#undef STANDARD_STARTFILE_PREFIX_2\n#define STANDARD_STARTFILE_PREFIX_2 ""\n' >> gcc/config/linux.h
sed -i -e "s@\(^CROSS_SYSTEM_HEADER_DIR =\).*@\1 /tools/include at g" gcc/Makefile.in
touch /tools/include/limits.h
mkdir -p $SOURCES/gcc-build
cd $SOURCES/gcc-build
AR=ar LDFLAGS="-Wl,-rpath,/cross-tools/lib" \
	$SOURCES/$GCC/configure --prefix=/cross-tools \
	--build=${CLFS_HOST} --host=${CLFS_HOST} --target=${CLFS_TARGET} \
	--with-sysroot=${CLFS} --with-local-prefix=/tools --disable-nls \
	--disable-shared --with-mpfr=/cross-tools --with-gmp=/cross-tools \
	--with-ppl=/cross-tools --with-cloog=/cross-tools --with-mpc=/cross-tools \
	--without-headers --with-newlib --disable-decimal-float \
	--disable-libgomp --disable-libmudflap --disable-libssp \
	--disable-threads --enable-languages=c
make all-gcc all-target-libgcc
make install-gcc install-target-libgcc

# eglibc 32 bits
cd $SOURCES
rm -rf ${EGLIBC}
rm -rf eglibc-build
tar xf $SOURCES/${EGLIBC}.tar.*
cd $SOURCES/${EGLIBC}/libc
cat $SOURCES/eglibc-2.12-20100725-r11059-make382-1.patch | patch -p1
sed -i 's/$libc_cv_gnu89_inline = yes/"$libc_cv_gnu89_inline" != no/' configure.in
cp Makeconfig{,.orig}
sed -e 's/-lgcc_eh//g' Makeconfig.orig > Makeconfig # supression du lien avec libgcc_eh
mkdir -p $SOURCES/eglibc-build
cd $SOURCES/eglibc-build
# Support de NPTL
cat >> config.cache << "EOF"
libc_cv_forced_unwind=yes
libc_cv_c_cleanup=yes
libc_cv_gnu89_inline=yes
libc_cv_ssp=no
EOF
BUILD_CC="gcc" CC="${CLFS_TARGET}-gcc ${BUILD32}" \
	AR="${CLFS_TARGET}-ar" RANLIB="${CLFS_TARGET}-ranlib" \
	CFLAGS="-march=$(cut -d- -f1 <<< $CLFS_TARGET32) -mtune=generic -g -O2" \
	$SOURCES/${EGLIBC}/libc/configure --prefix=/tools \
	--host=${CLFS_TARGET32} --build=${CLFS_HOST} \
	--disable-profile --enable-add-ons \
	--with-tls --enable-kernel=2.6.28 --with-__thread \
	--with-binutils=/cross-tools/bin --with-headers=/tools/include \
	--cache-file=config.cache
make
make install

# eglibc 64 bits
cd $SOURCES
rm -rf ${EGLIBC}
rm -rf eglibc-build
tar xf $SOURCES/${EGLIBC}.tar.*
cd $SOURCES/${EGLIBC}/libc
cat $SOURCES/eglibc-2.12-20100725-r11059-make382-1.patch | patch -p1
sed -i 's/$libc_cv_gnu89_inline = yes/"$libc_cv_gnu89_inline" != no/' configure.in
cp Makeconfig{,.orig}
sed -e 's/-lgcc_eh//g' Makeconfig.orig > Makeconfig # supression du lien avec libgcc_eh
mkdir -p $SOURCES/eglibc-build
cd $SOURCES/eglibc-build
# Support de NPTL
cat >> config.cache << "EOF"
libc_cv_forced_unwind=yes
libc_cv_c_cleanup=yes
libc_cv_gnu89_inline=yes
libc_cv_ssp=no
EOF
echo "slibdir=/tools/lib64" >> configparms # on cible /tools/lib64
BUILD_CC="gcc" CC="${CLFS_TARGET}-gcc ${BUILD64}" \
	AR="${CLFS_TARGET}-ar" RANLIB="${CLFS_TARGET}-ranlib" \
	$SOURCES/${EGLIBC}/libc/configure --prefix=/tools \
	--host=${CLFS_TARGET} --build=${CLFS_HOST} --libdir=/tools/lib64 \
	--disable-profile --enable-add-ons \
	--with-tls --enable-kernel=2.6.28 --with-__thread \
	--with-binutils=/cross-tools/bin --with-headers=/tools/include \
	--cache-file=config.cache
make
make install

# gcc final
cd $SOURCES
rm -rf $GCC
rm -rf gcc-build
tar xf $SOURCES/$GCC.tar.*
cd $SOURCES/$GCC
cat $SOURCES/gcc-4.5.1-specs-1.patch | patch -p1
echo -en '#undef STANDARD_INCLUDE_DIR\n#define STANDARD_INCLUDE_DIR "/tools/include/"\n\n' >> gcc/config/linux.h
echo -en '\n#undef STANDARD_STARTFILE_PREFIX_1\n#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"\n' >> gcc/config/linux.h
echo -en '\n#undef STANDARD_STARTFILE_PREFIX_2\n#define STANDARD_STARTFILE_PREFIX_2 ""\n' >> gcc/config/linux.h
cp -v gcc/Makefile.in{,.orig}
sed -e "s@\(^CROSS_SYSTEM_HEADER_DIR =\).*@\1 /tools/include@g" gcc/Makefile.in.orig > gcc/Makefile.in
touch /tools/include/limits.h
mkdir -p $SOURCES/gcc-build
cd $SOURCES/gcc-build
AR=ar LDFLAGS="-Wl,-rpath,/cross-tools/lib" \
	$SOURCES/$GCC/configure --prefix=/cross-tools \
	--build=${CLFS_HOST} --target=${CLFS_TARGET} --host=${CLFS_HOST} \
	--with-sysroot=${CLFS} --with-local-prefix=/tools --disable-nls \
	--enable-shared --enable-languages=c,c++ --enable-__cxa_atexit \
	--with-mpfr=/cross-tools --with-gmp=/cross-tools --enable-c99 \
	--with-ppl=/cross-tools --with-cloog=/cross-tools \
	--enable-long-long --enable-threads=posix
make AS_FOR_TARGET="${CLFS_TARGET}-as" LD_FOR_TARGET="${CLFS_TARGET}-ld"
make install

# On passe en environnement-cible 64 bits
export CC="${CLFS_TARGET}-gcc"
export CXX="${CLFS_TARGET}-g++"
export AR="${CLFS_TARGET}-ar"
export AS="${CLFS_TARGET}-as"
export RANLIB="${CLFS_TARGET}-ranlib"
export LD="${CLFS_TARGET}-ld"
export STRIP="${CLFS_TARGET}-strip"

# gmp
cd $SOURCES
rm -rf $GMP
tar xvf $SOURCES/$GMP.tar.*
cd $SOURCES/$GMP
HOST_CC=gcc CPPFLAGS=-fexceptions CC="${CC} ${BUILD64}" \
	CXX="${CXX} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET} \
	--libdir=/tools/lib64 --enable-cxx
make
make install

# mpfr
cd $SOURCES
rm -rf $MPFR
tar xf $SOURCES/$MPFR.tar.*
cd $SOURCES/$MPFR
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET} \
	--libdir=/tools/lib64 --enable-shared
make
make install

# mpc
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET} \
	--libdir=/tools/lib64
mek
make install

# ppl
cd $SOURCES
rm -rf $PPL
tar xf $SOURCES/$PPL.tar.*
cd $SOURCES/$PPL
sed -i -e "s/__GMP_BITS_PER_MP_LIMB/GMP_LIMB_BITS/g" configure
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET} \
	--enable-interfaces="c,cxx" --libdir=/tools/lib64 --enable-shared \
	--disable-optimization --with-libgmp-prefix=/tools \
	--with-libgmpxx-prefix=/tools
make
make install

# cloog-ppl
cd $SOURCES
rm -rf $CLOOGPPL
tar xf $SOURCES/$CLOOGPPL.tar.*
cd $SOURCES/$CLOOGPPL
cp configure{,.orig}
sed "/LD_LIBRARY_PATH=/d" configure.orig > configure
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET} --with-bits=gmp \
	--libdir=/tools/lib64 --enable-shared \
	--with-gmp=/tools --with-ppl=/tools
make
make install

# zlib
cd $SOURCES
rm -rf $ZLIB
tar xf $SOURCES/$ZLIB.tar.*
cd $SOURCES/$ZLIB
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--shared --libdir=/tools/lib64
make
make install

# binutils
cd $SOURCES
rm -rf $BINUTILS
rm -rf binutils-build
tar xf $SOURCES/$BINUTILS.tar.*
rm -rf $SOURCES/binutils-build
cd $SOURCES/$BINUTILS
mkdir -p $SOURCES/binutils-build
cd $SOURCES/binutils-build
CC="${CC} ${BUILD64}" $SOURCES/$BINUTILS/configure \
	--prefix=/tools --libdir=/tools/lib64 --with-lib-path=/tools/lib64:/tools/lib \
	--build=${CLFS_HOST} --host=${CLFS_TARGET} --target=${CLFS_TARGET} \
	--disable-nls --enable-shared --enable-64-bit-bfd
make configure-host
make
make install

# gcc 64 bits
cd $SOURCES
rm -rf $GCC
rm -rf gcc-build
tar xf $SOURCES/$GCC.tar.*
cd $SOURCES/$GCC
cat $SOURCES/gcc-4.5.1-specs-1.patch | patch -p1
echo -en '#undef STANDARD_INCLUDE_DIR\n#define STANDARD_INCLUDE_DIR "/tools/include/"\n\n' >> gcc/config/linux.h
echo -en '\n#undef STANDARD_STARTFILE_PREFIX_1\n#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"\n' >> gcc/config/linux.h
echo -en '\n#undef STANDARD_STARTFILE_PREFIX_2\n#define STANDARD_STARTFILE_PREFIX_2 ""\n' >> gcc/config/linux.h
cp -v gcc/Makefile.in{,.orig}
sed -e "s@\(^CROSS_SYSTEM_HEADER_DIR =\).*@\1 /tools/include@g" gcc/Makefile.in.orig > gcc/Makefile.in
touch /tools/include/limits.h
mkdir -p $SOURCES/gcc-build
cd $SOURCES/gcc-build
CC="${CC} ${BUILD64}" CXX="${CXX} ${BUILD64}" \
	$SOURCES/$GCC/configure --prefix=/tools \
	--libdir=/tools/lib64 --build=${CLFS_HOST} --host=${CLFS_TARGET} \
	--target=${CLFS_TARGET} --with-local-prefix=/tools  --enable-long-long \
	--enable-c99 --enable-shared --enable-threads=posix \
	--enable-__cxa_atexit --disable-nls --enable-languages=c,c++ \
	--disable-libstdcxx-pch
cp Makefile{,.orig}
sed "/^HOST_\(GMP\|PPL\|CLOOG\)\(LIBS\|INC\)/s:-[IL]/\(lib\|include\)::" Makefile.orig > Makefile
make AS_FOR_TARGET="${AS}" LD_FOR_TARGET="${LD}"
make install

# ncurses
cd $SOURCES
rm -rf $NCURSES
tar xf $SOURCES/$NCURSES.tar.*
cd $SOURCES/$NCURSES
CC="${CC} ${BUILD64}" CXX="${CXX} ${BUILD64}" \
	./configure --prefix=/tools --with-shared \
	--build=${CLFS_HOST} --host=${CLFS_TARGET} \
	--without-debug --without-ada \
	--enable-overwrite --with-build-cc=gcc \
	--libdir=/tools/lib64
make
make install

# bash
cd $SOURCES
cp -a $SOURCES/bash/$BASH4.tar.* .
rm -rf $BASH4
tar xf $SOURCES/$BASH4.tar.*
cd $SOURCES/$BASH4
cat $SOURCES/bash-4.1-branch_update-1.patch | patch -p0
# De nombreux tests ne comprennent pas la compilation croisee
cat > config.cache << "EOF"
ac_cv_func_mmap_fixed_mapped=yes
ac_cv_func_strcoll_works=yes
ac_cv_func_working_mktime=yes
bash_cv_func_sigsetjmp=present
bash_cv_getcwd_malloc=yes
bash_cv_job_control_missing=present
bash_cv_printf_a_format=yes
bash_cv_sys_named_pipes=present
bash_cv_ulimit_maxfds=yes
bash_cv_under_sys_siglist=yes
bash_cv_unusable_rtsigs=no
gt_cv_int_divbyzero_sigfpe=yes
EOF
CC="${CC} ${BUILD64}" CXX="${CXX} ${BUILD64}" \
	./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET} \
	--without-bash-malloc --cache-file=config.cache
make
make install
ln -sfv bash /tools/bin/sh

# bison
cd $SOURCES
rm -rf $BISON
tar xf $SOURCES/$BISON.tar.*
cd $SOURCES/$BISON
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET}
make
make install

# bzip2
cd $SOURCES
rm -rf $BZIP2
tar xf $SOURCES/$BZIP2.tar.*
cd $SOURCES/$BZIP2
cp -v Makefile{,.orig}
sed -e 's@^\(all:.*\) test@\1@g' -e 's@/lib\(/\| \|$\)@/lib64\1@g' Makefile.orig > Makefile
make CC="${CC} ${BUILD64}" AR="${AR}" RANLIB="${RANLIB}"
make PREFIX=/tools install


# coreutils
cd $SOURCES
rm -rf $COREUTILS
tar xf $SOURCES/$COREUTILS.tar.*
cd $SOURCES/$COREUTILS
# Quelques tests ne comprennent pas la compilation croisee
cat > config.cache << EOF
fu_cv_sys_stat_statfs2_bsize=yes
gl_cv_func_rename_trailing_slash_bug=no
gl_cv_func_working_mkstemp=yes
EOF
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET} \
	--enable-install-program=hostname --cache-file=config.cache
touch man/hostname.1
make
make install

#diffutils
cd $SOURCES
rm -rf $DIFFUTILS
tar xf $SOURCES/$DIFFUTILS.tar.*
cd $SOURCES/$DIFFUTILS
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET}
make
make install

#find
cd $SOURCES
rm -rf $FINDUTILS
tar xf $SOURCES/$FINDUTILS.tar.*
cd $SOURCES/$FINDUTILS
echo "gl_cv_func_wcwidth_works=yes" > config.cache
echo "ac_cv_func_fnmatch_gnu=yes" >> config.cache
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET} \
	--cache-file=config.cache
make
make install

# file
cd $SOURCES
rm -rf $FILE
tar xf $SOURCES/$FILE.tar.*
cd $SOURCES/$FILE
cat $SOURCES/file-5.03-cross_compile-1.patch | patch -p1
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--libdir=/tools/lib64 --build=${CLFS_HOST} --host=${CLFS_TARGET}
make
make install


# flex
cd $SOURCES
rm -rf $FLEX
tar xf $SOURCES/$FLEX.tar.*
cd $SOURCES/$FLEX
cat $SOURCES/flex-2.5.35-gcc44-1.patch | patch -p1
cp -v Makefile.in{,.orig}
sed "s/-I@includedir@//g" Makefile.in.orig > Makefile.in
cat > config.cache << EOF
ac_cv_func_malloc_0_nonnull=yes
ac_cv_func_realloc_0_nonnull=yes
EOF
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET} \
	--cache-file=config.cache
make
make install

# gawk
cd $SOURCES
rm -rf $GAWK
tar xf $SOURCES/$GAWK.tar.*
cd $SOURCES/$GAWK
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET} \
	--disable-libsigsegv
make
make install

# gettext
cd $SOURCES
rm -rf $GETTEXT
tar xf $SOURCES/$GETTEXT.tar.*
cd $SOURCES/$GETTEXT
cd gettext-tools
echo "gl_cv_func_wcwidth_works=yes" > config.cache
CC="${CC} ${BUILD64}" CXX="${CXX} ${BUILD64}" \
	./configure --prefix=/tools --disable-shared \
	--build=${CLFS_HOST} --host=${CLFS_TARGET} \
	--cache-file=config.cache
make -C gnulib-lib
make -C src msgfmt
cp -v src/msgfmt /tools/bin

# grep
cd $SOURCES
rm -rf $GREP
tar xf $SOURCES/$GREP.tar.*
cd $SOURCES/$GREP
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET} \
	--disable-perl-regexp --without-included-regex
make
make install

# gzip
cd $SOURCES
rm -rf $GZIP
tar xf $SOURCES/$GZIP.tar.*
cd $SOURCES/$GZIP
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET}
make
make install


# m4
cd $SOURCES
rm -rf $M4
tar xf $SOURCES/$M4.tar.*
cd $SOURCES/$M4
cat > config.cache << EOF
gl_cv_func_btowc_eof=yes
gl_cv_func_mbrtowc_incomplete_state=yes
gl_cv_func_mbrtowc_sanitycheck=yes
gl_cv_func_mbrtowc_null_arg=yes
gl_cv_func_mbrtowc_retval=yes
gl_cv_func_mbrtowc_nul_retval=yes
gl_cv_func_wcrtomb_retval=yes
gl_cv_func_wctob_works=yes
EOF
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET} --cache-file=config.cache
make
make install

# make
cd $SOURCES
rm -rf $MAKE
tar xf $SOURCES/$MAKE.tar.*
cd $SOURCES/$MAKE
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET}
make
make install

# patch
cd $SOURCES
rm -rf $PATCH
tar xf $SOURCES/$PATCH.tar.*
cd $SOURCES/$PATCH
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET}
make
make install

# sed
cd $SOURCES
rm -rf $ED
tar xf $SOURCES/$SED.tar.*
cd $SOURCES/$SED
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET}
make
make install

# tar
cd $SOURCES
rm -rf $TAR
tar xf $SOURCES/$TAR.tar.*
cd $SOURCES/$TAR
cat $SOURCES/tar-1.23-overflow_fix-1.patch | patch -p1
cat > config.cache << EOF
gl_cv_func_wcwidth_works=yes
gl_cv_func_btowc_eof=yes
ac_cv_func_malloc_0_nonnull=yes
ac_cv_func_realloc_0_nonnull=yes
gl_cv_func_mbrtowc_incomplete_state=yes
gl_cv_func_mbrtowc_nul_retval=yes
gl_cv_func_mbrtowc_null_arg=yes
gl_cv_func_mbrtowc_retval=yes
gl_cv_func_wcrtomb_retval=yes
EOF
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET} \
	--cache-file=config.cache
make
make install

# texinfo
cd $SOURCES
rm -rf $TEXINFO
tar xf $SOURCES/$TEXINFO.tar.*
cd $SOURCES/texinfo-4.13
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET}
make -C tools/gnulib/lib
make -C tools
make
make install

# xz
cd $SOURCES
rm -rf $XZ
tar xf $SOURCES/$XZ.tar.*
cd $SOURCES/$XZ
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} \
	--host=${CLFS_TARGET}
make
make install

# util-linux-ng
cd $SOURCES
rm -rf $UTILLINUXNG
tar xf $SOURCES/$UTILLINUXNG.tar.*
cd $SOURCES/$UTILLINUXNG
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET} \
	--disable-makeinstall-chown
make
make install

# C'est fini !
