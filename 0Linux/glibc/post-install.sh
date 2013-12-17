# On passe à la nouvelle libc. 

# On copie les nouvelles bibliothèques venant du tampon :
for newlib in usr/libc_tampon/*.newlib; do
	busybox cp -af ${newlib} usr/libARCH/
done

# On les ajoute toutes à l'éditeur de liens avec 'ldconfig' :
ldconfig -l usr/libARCH/*.newlib 2>/dev/null

# Pour chaque bibliothèque :
for newlib in usr/libARCH/*.newlib ; do
	
	# On supprime l'ancienne bib' originale :
	busybox rm -f usr/libARCH/$(busybox basename ${newlib} .newlib)
	
	# On supprime l'extension ".newlib" de la nouvelle pour la renommer comme l'ancienne :
	busybox cp -af ${newlib} usr/libARCH/$(busybox basename ${newlib} .newlib)
	
	# On la passe à 'ldconfig' ni vu ni connu :
	ldconfig -l usr/libARCH/$(busybox basename ${newlib} .newlib) 2>/dev/null
	
	# On supprime la bibliothèque suffixée ".newlib", maintenant inutile :
	busybox rm -f ${newlib}
done

# On peut supprimer la libc tampon :
busybox rm -rf usr/libc_tampon

# On recrée les liens à la main  :
busybox ln -sf            libc-VERSION.so usr/libARCH/libc.so.6 
busybox ln -sf              ld-VERSION.so usr/libARCH/ld-linux.so.2
busybox ln -sf          libanl-VERSION.so usr/libARCH/libanl.so.1
busybox ln -sf                libanl.so.1 usr/libARCH/libanl.so
busybox ln -sf libBrokenLocale-VERSION.so usr/libARCH/libBrokenLocale.so.1
busybox ln -sf       libBrokenLocale.so.1 usr/libARCH/libBrokenLocale.so
busybox ln -sf         libcidn-VERSION.so usr/libARCH/libcidn.so.1
busybox ln -sf               libcidn.so.1 usr/libARCH/libcidn.so
busybox ln -sf        libcrypt-VERSION.so usr/libARCH/libcrypt.so.1
busybox ln -sf              libcrypt.so.1 usr/libARCH/libcrypt.so
busybox ln -sf           libdl-VERSION.so usr/libARCH/libdl.so.2
busybox ln -sf                 libdl.so.2 usr/libARCH/libdl.so
busybox ln -sf            libm-VERSION.so usr/libARCH/libm.so.6
busybox ln -sf                  libm.so.6 usr/libARCH/libm.so
busybox ln -sf          libnsl-VERSION.so usr/libARCH/libnsl.so.1
busybox ln -sf                libnsl.so.1 usr/libARCH/libnsl.so 
busybox ln -sf   libnss_compat-VERSION.so usr/libARCH/libnss_compat.so.2
busybox ln -sf         libnss_compat.so.2 usr/libARCH/libnss_compat.so
busybox ln -sf       libnss_db-VERSION.so usr/libARCH/libnss_db.so.2
busybox ln -sf             libnss_db.so.2 usr/libARCH/libnss_db.so
busybox ln -sf      libnss_dns-VERSION.so usr/libARCH/libnss_dns.so.2
busybox ln -sf            libnss_dns.so.2 usr/libARCH/libnss_dns.so
busybox ln -sf    libnss_files-VERSION.so usr/libARCH/libnss_files.so.2
busybox ln -sf          libnss_files.so.2 usr/libARCH/libnss_files.so
busybox ln -sf   libnss_hesiod-VERSION.so usr/libARCH/libnss_hesiod.so.2
busybox ln -sf         libnss_hesiod.so.2 usr/libARCH/libnss_hesiod.so
busybox ln -sf      libnss_nis-VERSION.so usr/libARCH/libnss_nis.so.2
busybox ln -sf            libnss_nis.so.2 usr/libARCH/libnss_nis.so
busybox ln -sf  libnss_nisplus-VERSION.so usr/libARCH/libnss_nisplus.so.2
busybox ln -sf        libnss_nisplus.so.2 usr/libARCH/libnss_nisplus.so
busybox ln -sf      libpthread-VERSION.so usr/libARCH/libpthread.so.0
busybox ln -sf       libresolv-VERSION.so usr/libARCH/libresolv.so.2
busybox ln -sf             libresolv.so.2 usr/libARCH/libresolv.so
busybox ln -sf           librt-VERSION.so usr/libARCH/librt.so.1
busybox ln -sf                 librt.so.1 usr/libARCH/librt.so
busybox ln -sf        libthread_db-1.0.so usr/libARCH/libthread_db.so.1
busybox ln -sf          libthread_db.so.1 usr/libARCH/libthread_db.so
busybox ln -sf         libutil-VERSION.so usr/libARCH/libutil.so.1
busybox ln -sf               libutil.so.1 usr/libARCH/libutil.so

# On met à jour l'éditeur de liens :
ldconfig -r . 2>/dev/null

# On recharge 'init' :
usr/sbin/telinit u 2>/dev/null
