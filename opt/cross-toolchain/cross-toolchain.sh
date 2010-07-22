#!/bin/env bash
# Construction de la chaine d'outils croisee multilib i686/x86_64.
# Il faut avoir cree les liens /tools et /cross-tools pointant vers les bons
# repertoires. On doit avoir cree les repertoires sources, tools, cross-tools
# dans un repertoire dedie (une partition idealement).

set -xe
umask 022
CWD=$(pwd)
unset CC CXX AR AS RANLIB LD STRIP CFLAGS CXXFLAGS

# La partition separee ou on va placer les fichiers compiles
CLFS=${CLFS:-/0-prod}

# L'hote *dinstinct* de l'hote reel
CLFS_HOST=${CLFS_HOST:-$(echo ${MACHTYPE} | sed "s/$(echo ${MACHTYPE} | cut -d- -f2)/cross/")}

# Le systeme cible 32 bits
CLFS_TARGET32=${CLFS_TARGET32:-i686-0-linux-gnu}

# Le systeme cible 64 bits
CLFS_TARGET=${CLFS_TARGET:-x86_64-0-linux-gnu}

# La locale (C ou POSIX et pas autre chose)
export LC_ALL=${LC_ALL:-POSIX}

# Les drapeaux de compilation 32 et 64 bits
BUILD32=${BUILD32:--m32}
BUILD64=${BUILD64:--m64}

# Emplacement des archives sources et des correctifs
SOURCES=${SOURCES:-$CWD/sources}

LINUX=${LINUX:-linux-2.6.32.2}
FILE=${FILE:-file-5.03}
NCURSES=${NCURSES:-ncurses-5.7}
GMP=${GMP:-gmp-4.3.1}
MPFR=${MPFR:-mpfr-2.4.2}
FINDUTILS=${FINDUTILS:-findutils-4.4.2}
BINUTILS=${BINUTILS:-binutils-2.20}
GCC=${GCC:-gcc-4.4.2}
EGLIBC=${EGLIBC:-eglibc-2.11_20100103}
PPL=${PPL:-ppl-0.10.2}
CLOOGPPL=${CLOOGPPL:-cloog-ppl-0.15.7}
TCL=${TCL:-tcl8.5.8}
EXPECT=${EXPECT:-expect-5.43.0}
DEJAGNU=${DEJAGNU:-dejagnu-1.4.4}
BISON=${BISON:-bison-2.4.1}
BASH4=${BASH4:-bash-4.1}
ZLIB=${ZLIB:-zlib-1.2.3}
BZIP2=${BZIP2:-bzip2-1.0.5}
COREUTILS=${COREUTILS:-coreutils-8.2}
DIFFUTILS=${DIFFUTILS:-diffutils-2.8.7}
FLEX=${FLEX:-flex-2.5.35}
GAWK=${GAWK:-gawk-3.1.7}
GETTEXT=${GETTEXT:-gettext-0.17}
GREP=${GREP:-grep-2.5.4}
GZIP=${GZIP:-gzip-1.3.13}
M4=${M4:-m4-1.4.13}
MAKE=${MAKE:-make-3.81}
PATCH=${PATCH:-patch-2.6}
PERL=${PERL:-perl-5.10.1}
SED=${SED:-sed-4.2.1}
TAR=${TAR:-tar-1.22}
TEXINFO=${TEXINFO:-texinfo-4.13a}
VIM72=${VIM72:-vim-7.2}
XZ=${XZ:-xz-4.999.9beta}
UTILLINUXNG=${UTILLINUXNG:-util-linux-ng.2.16.2}

# linux-headers
cd $SOURCES
rm -rf $LINUX
tar xf $CWD/../linux/$LINUX.tar.*
cd $LINUX
install -dv /tools/include
make mrproper
make ARCH=x86_64 headers_check
make ARCH=x86_64 INSTALL_HDR_PATH=dest headers_install
cp -rv dest/include/* /tools/include

# file
cd $SOURCES
rm -rf $FILE
tar xf $CWD/../file/$FILE.tar.*
cd $SOURCES/$FILE
./configure --prefix=/cross-tools
make
make install

# ncurses
cd $SOURCES
rm -rf $NCURSES
tar xf $CWD/../ncurses/$NCURSES.tar.*
cd $SOURCES/$NCURSES
cat $SOURCES/ncurses-5.7-bash_fix-1.patch | patch -p1
./configure --prefix=/cross-tools \
	--without-debug --without-shared
make -C include
make -C progs tic
install -m755 progs/tic /cross-tools/bin

# gmp
cd $SOURCES
rm -rf $GMP
tar xf $CWD/../gmp/$GMP.tar.*
cd $SOURCES/$GMP
CPPFLAGS=-fexceptions ./configure \
	--prefix=/cross-tools --enable-cxx
make
make install

# mpfr
cd $SOURCES
rm -rf $MPFR
tar xf $CWD/../mpfr/$MPFR.tar.*
cd $SOURCES/$MPFR
cat $SOURCES/mpfr-2.4.1-branch_update-2.patch | patch -p1
LDFLAGS="-Wl,-rpath,/cross-tools/lib" \
	./configure --prefix=/cross-tools \
	--enable-shared --with-gmp=/cross-tools
make
make install

# ppl
cd $SOURCES
rm -rf $PPL
tar xf $CWD/../ppl/$PPL.tar.*
cd $SOURCES/$PPL
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
tar xf $CWD/../cloog-ppl/$CLOOGPPL.tar.*
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
tar xf $CWD/../binutils/$BINUTILS.tar.*
rm -rf $SOURCES/binutils-build
cd $SOURCES/$BINUTILS
cat $SOURCES/binutils-2.19.51-genscripts_multilib-1.patch | patch -p1
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
tar $CWD/../gcc/xf $GCC.tar.*
cd $SOURCES/$GCC
cat $SOURCES/gcc-4.4.2-specs-1.patch | patch -p1
cat $SOURCES/gcc-4.4.2-branch_update-1.patch | patch -p1
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
	--build=${CLFS_HOST} --host=${CLFS_HOST} --target=${CLFS_TARGET} \
	--with-sysroot=${CLFS} --with-local-prefix=/tools --disable-nls \
	--disable-shared --with-mpfr=/cross-tools --with-gmp=/cross-tools \
	--with-ppl=/cross-tools --with-cloog=/cross-tools \
	--without-headers --with-newlib --disable-decimal-float \
	--disable-libgomp --disable-libmudflap --disable-libssp \
	--disable-threads --enable-languages=c
make all-gcc all-target-libgcc
make install-gcc install-target-libgcc

# eglibc 32 bits
cd $SOURCES
rm -rf ${EGLIBC}
rm -rf eglibc-build
tar xf $CWD/../eglibc/${EGLIBC}.tar.*
cd $SOURCES/${EGLIBC}/libc
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
tar xf $CWD/../eglibc/${EGLIBC}.tar.*
cd $SOURCES/${EGLIBC}/libc
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
tar xf $CWD/../gcc/$GCC.tar.*
cd $SOURCES/$GCC
cat $SOURCES/gcc-4.4.2-specs-1.patch | patch -p1
cat $SOURCES/gcc-4.4.2-branch_update-1.patch | patch -p1
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
tar xvf $CWD/../gmp/$GMP.tar.*
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
tar xf $CWD/../mpfr/$MPFR.tar.*
cd $SOURCES/$MPFR
cat $SOURCES/mpfr-2.4.1-branch_update-2.patch | patch -p1
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET} \
	--libdir=/tools/lib64 --enable-shared
make
make install

# ppl
cd $SOURCES
rm -rf $PPL
tar xf $CWD/../ppl/$PPL.tar.*
cd $SOURCES/$PPL
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
tar xf $CWD/../cloog-ppl/$CLOOGPPL.tar.*
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
tar xf $CWD/../zlib/$ZLIB.tar.*
cd $SOURCES/$ZLIB
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--shared --libdir=/tools/lib64
make
make install

# binutils
cd $SOURCES
rm -rf $BINUTILS
rm -rf binutils-build
tar xf $CWD/../binutils/$BINUTILS.tar.*
rm -rf $SOURCES/binutils-build
cd $SOURCES/$BINUTILS
cat $SOURCES/binutils-2.19.51-genscripts_multilib-1.patch | patch -p1
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
tar xf $CWD/../gcc/$GCC.tar.*
cd $SOURCES/$GCC
cat $SOURCES/gcc-4.4.2-specs-1.patch | patch -p1
cat $SOURCES/gcc-4.4.2-branch_update-1.patch | patch -p1
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
tar xf $CWD/../ncurses/$NCURSES.tar.*
cd $SOURCES/$NCURSES
cat $SOURCES/ncurses-5.7-bash_fix-1.patch | patch -p1
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
cp -a $CWD/../bash/$BASH4.tar.* .
rm -rf $BASH4
tar xf $SOURCES/$BASH4.tar.*
cd $SOURCES/$BASH4
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
tar xf $CWD/../bison/$BISON.tar.*
cd $SOURCES/$BISON
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET}
make
make install

# bzip2
cd $SOURCES
rm -rf $BZIP2
tar xf $CWD/../bzip2/$BZIP2.tar.*
cd $SOURCES/$BZIP2
cp -v Makefile{,.orig}
sed -e 's@^\(all:.*\) test@\1@g' -e 's@/lib\(/\| \|$\)@/lib64\1@g' Makefile.orig > Makefile
make CC="${CC} ${BUILD64}" AR="${AR}" RANLIB="${RANLIB}"
make PREFIX=/tools install


# coreutils
cd $SOURCES
rm -rf $COREUTILS
tar xf $CWD/../coreutils/$COREUTILS.tar.*
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
tar xf $CWD/../diffutils/$DIFFUTILS.tar.*
cd $SOURCES/$DIFFUTILS
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET}
make
make install

#find
cd $SOURCES
rm -rf $FINDUTILS
tar xf $CWD/../findutils/$FINDUTILS.tar.*
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
tar xf $CWD/../tar/$FILE.tar.*
cd $SOURCES/$FILE
cat $SOURCES/file-5.03-cross_compile-1.patch | patch -p1
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--libdir=/tools/lib64 --build=${CLFS_HOST} --host=${CLFS_TARGET}
make
make install


# flex
cd $SOURCES
rm -rf $FLEX
tar xf $CWD/../flex/$FLEX.tar.*
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
tar xf $CWD/../gawk/$GAWK.tar.*
cd $SOURCES/$GAWK
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET} \
	--disable-libsigsegv
make
make install

# gettext
cd $SOURCES
rm -rf $GETTEXT
tar xf $CWD/../gettext/$GETTEXT.tar.*
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
tar xf $CWD/../grep/$GREP.tar.*
cd $SOURCES/$GREP
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET} \
	--disable-perl-regexp --without-included-regex
make
make install

# gzip
cd $SOURCES
rm -rf $GZIP
tar xf $CWD/../gzip/$GZIP.tar.*
cd $SOURCES/$GZIP
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET}
make
make install


# m4
cd $SOURCES
rm -rf $M4
tar xf $CWD/../m4/$M4.tar.*
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
tar xf $CWD/../make/$MAKE.tar.*
cd $SOURCES/$MAKE
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET}
make
make install

# patch
cd $SOURCES
rm -rf $PATCH
tar xf $CWD/../patch/$PATCH.tar.*
cd $SOURCES/$PATCH
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET}
make
make install

# sed
cd $SOURCES
rm -rf $ED
tar xf $CWD/../sed/$SED.tar.*
cd $SOURCES/$SED
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET}
make
make install

# tar
cd $SOURCES
rm -rf $TAR
tar xf $CWD/../tar/$TAR.tar.*
cd $SOURCES/$TAR
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
tar xf $CWD/../texinfo/$TEXINFO.tar.*
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
tar xf $CWD/../xz/$XZ.tar.*
cd $SOURCES/$XZ
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} \
	--host=${CLFS_TARGET}
make
make install

# util-linux-ng
cd $SOURCES
rm -rf $UTILLINUXNG
tar xf $CWD/../util-linux-ng/$UTILLINUXNG.tar.*
cd $SOURCES/$UTILLINUXNG
CC="${CC} ${BUILD64}" ./configure --prefix=/tools \
	--build=${CLFS_HOST} --host=${CLFS_TARGET} \
	--disable-makeinstall-chown
make
make install

# C'est fini !
