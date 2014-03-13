# Si l'on dispose de Busybox (il vaudrait mieux, soit dit en passant) :
if [ -x /usr/bin/busybox ]; then
	BUSYBOXBIN="/usr/bin/busybox"
fi

# On tente de migrer depuis l'ancienne structure :
rm -f usr/lib 2>/dev/null || true # Cette commande échouera sur un répertoire ;)

# On s'assure de la présence des liens symboliques critiques :
# Si '/usr/lib' est un répertoire, on est dans le cas du x86_64 multilib :
if [ -d usr/lib ]; then
	[ -e libARCH ] || ${BUSYBOXBIN} ln -sf usr/libARCH libARCH
	[ -e lib ] || ${BUSYBOXBIN} ln -sf usr/lib lib
else
	[ -e lib ] || ${BUSYBOXBIN} ln -sf usr/lib lib
	[ -e usr/lib ] || ${BUSYBOXBIN} ln -sf libARCH usr/lib || true # Si LIBDIRSUFFIX est vide
fi

# On crée des liens standards pour les binaires :
[ -e bin ] || ${BUSYBOXBIN} ln -sf usr/bin bin
[ -e sbin ] || ${BUSYBOXBIN} ln -sf usr/sbin sbin

# Création/vérification des utilisateurs et groupes du système.
# Syntaxe : champs séparés par des deux-points « : », le tout entre double-guillemets :
# Dans basegid : nom:GID
# Dans baseuid : nom:UID:GID:Description de l'utilisateur:répertoire dédié:shell

basegid=(
		"root:0"
		"bin:1"
		"daemon:2"
		"sys:3"
		"adm:4"
		"tty:5"
		"disk:6"
		"lp:7"
		"mem:8"
		"kmem:9"
		"wheel:10"
		"floppy:11"
		"mail:12"
		"news:13"
		"uucp:14"
		"man:15"
		"dialout:16"
		"audio:17"
		"video:18"
		"cdrom:19"
		"games:20"
		"slocate:21"
		"utmp:22"
		"tape:23"
		"smmsp:25"
		"polkit:26"
		"mysql:27"
		"rpc:32"
		"sshd:33"
		"kdm:41"
		"gdm:42"
		"shadow:43"
		"avahi:44"
		"ftp:50"
		"oprofile:51"
		"lock:54"
		"tomcat:66"
		"dovenull:74"
		"dovecot:76"
		"apache:80"
		"dbus:81"
		"plugdev:83"
		"power:84"
		"netdev:86"
		"sudo:88"
		"pop:90"
		"scanner:93"
		"nogroup:99"
		"users:100"
		"console:101"
		"polkitd:102"
		"colord:108"
		"gdm:120"
		"vboxusers:215"
		)

baseuid=(
		"root:0:0:Super Utilisateur:/root:/bin/bash"
		"bin:1:1:Utilisateur bin:/usr/bin:/usr/bin/false"
		"daemon:2:2:Utilisateur daemon:/usr/sbin:/usr/bin/false"
		"adm:3:4:Utilisateur adm:/var/log:/usr/bin/false"
		"lp:4:7:Utilisateur impression lp:/var/spool/lpd:/usr/bin/false"
		"sync:5:0:Utilisateur sync:/usr/bin:/usr/bin/sync"
		"shutdown:6:0:Utilisateur shutdown:/usr/sbin:/usr/sbin/shutdown"
		"halt:7:0:Utilisateur halt:/usr/sbin:/usr/sbin/halt"
		"mail:8:12:Utilisateur mail:/:/usr/bin/false"
		"news:9:13:Utilisateur news:/usr/lib/news:/usr/bin/false"
		"uucp:10:14:Utilisateur uucp:/var/spool/uucppublic:/usr/bin/false"
		"operator:11:0:Utilisateur operator:/root:/usr/bin/bash"
		"games:12:100:Utilisateur des jeux:/usr/share/games:/usr/bin/false"
		"ftp:14:50:Utilisateur FTP:/home/ftp:/usr/bin/false"
		"smmsp:25:25:Utilisateur smmsp:/var/spool/clientmqueue:/usr/bin/false"
		"polkit:26:26:Utilisateur PolKit:/:/usr/bin/false"
		"mysql:27:27:Utilisateur MySQL:/var/lib/mysql:/usr/bin/false"
		"rpc:32:32:Utilisateur RPC:/:/usr/bin/false"
		"sshd:33:33:Utilisateur du démon SSH:/:/usr/bin/false"
		"kdm:41:41:Utilisateur KDM:/var/lib/kdm:/usr/bin/false"
		"gdm:42:42:Utilisateur GDM:/var/state/gdm:/usr/bin/false"
		"avahi:44:44:Utilisateur Avahi:/dev/null:/usr/bin/false"
		"oprofile:51:51:Utilisateur oprofile:/usr/bin:/usr/bin/false"
		"tomcat:66:66:Utilisateur Tomcat:/var/lib/tomcat:/usr/bin/false"
		"dovenull:74:74:Utiliateur non fiable pour dovecot:/var/empty:/usr/bin/false"
		"dovecot:76:76:Utiliateur dovecot:/var/empty:/usr/bin/false"
		"apache:80:80:Utilisateur Apache httpd:/srv/httpd:/usr/bin/false"
		"messagebus:81:81:Utilisateur dbus:/run/dbus:/usr/bin/false"
		"pop:90:90:Utilisateur POP:/:/usr/bin/false"
		"nobody:99:99:Utilisateur fictif nobody:/:/usr/bin/false"
		"polkitd:102:102:Utilisateur Policy Kit:/:/usr/bin/false"
		"colord:108:108:Utilisateur pour colord:/:/usr/bin/false"
		"gdm:120:120:Utilisateur GNOME GDM:/var/lib/gdm:/usr/bin/false"
		"vboxweb:240:215:Utilisateur VirtualBox (Web):/var/lib/vboxweb:/usr/bin/false"
		)

# Pas de fichiers 'passwd' ou 'group' ? On crée le minimum syndical :
if [ ! -f etc/passwd ]; then
	cat > etc/passwd << "EOF"
root:x:0:0:Super Utilisateur:/root:/bin/bash
bin:x:1:1:Utilisateur bin:/usr/bin:/usr/bin/false
daemon:x:2:2:Utilisateur daemon:/usr/sbin:/usr/bin/false
adm:x:3:4:Utilisateur adm:/var/log:/usr/bin/false
lp:x:4:7:Utilisateur impression lp:/var/spool/lpd:/usr/bin/false
sync:x:5:0:Utilisateur sync:/usr/bin:/usr/bin/sync
shutdown:x:6:0:Utilisateur shutdown:/usr/sbin:/usr/sbin/shutdown
halt:x:7:0:Utilisateur halt:/usr/sbin:/usr/sbin/halt
mail:x:8:12:Utilisateur mail:/:/usr/bin/false
news:x:9:13:Utilisateur news:/usr/lib/news:/usr/bin/false
uucp:x:10:14:Utilisateur uucp:/var/spool/uucppublic:/usr/bin/false
operator:x:11:0:Utilisateur operator:/root:/bin/bash
games:x:12:100:Utilisateur des jeux:/usr/share/games:/usr/bin/false
ftp:x:14:50:Utilisateur FTP:/home/ftp:/usr/bin/false
smmsp:x:25:25:Utilisateur smmsp:/var/spool/clientmqueue:/usr/bin/false
polkit:x:26:26:Utilisateur PolKit:/:/usr/bin/false
mysql:x:27:27:Utilisateur MySQL:/var/lib/mysql:/usr/bin/false
rpc:x:32:32:Utilisateur RPC:/:/usr/bin/false
sshd:x:33:33:Utilisateur du démon SSH:/:/usr/bin/false
kdm:x:41:41:Utilisateur KDM:/var/lib/kdm:/usr/bin/false
gdm:x:42:42:Utilisateur GDM:/var/state/gdm:/usr/bin/false
avahi:x:44:44:Utilisateur Avahi:/dev/null:/usr/bin/false
oprofile:x:51:51:Utilisateur oprofile:/usr/bin:/usr/bin/false
tomcat:x:66:66:Utiliasteur Tomcat:/var/lib/tomcat:/usr/bin/false
apache:x:80:80:Utilisateur Apache httpd:/srv/httpd:/usr/bin/false
messagebus:x:81:81:User for D-BUS:/var/run/dbus:/bin/false
haldaemon:x:82:82:User for HAL:/var/run/hald:/bin/false
pop:x:90:90:Utilisateur POP:/:/usr/bin/false
nobody:x:99:99:Utilisateur fictif nobody:/:/usr/bin/false
polkitd:x:102:102:Utilisateur Policy Kit:/:/usr/bin/false
colord:x:108:108:Utilisateur pour colord:/:/usr/bin/false
vboxweb:x:240:215:Utilisateur VirtualBox (Web):/var/lib/vboxweb:/usr/bin/false
dovenull:x:74:74:Utiliateur non fiable pour dovecot:/var/empty:/usr/bin/false
dovecot:x:76:76:Utiliateur dovecot:/var/empty:/usr/bin/false

EOF

fi

if [ ! -f etc/group ]; then
	cat > etc/group << "EOF"
root:x:0:root
bin:x:1:root,bin
daemon:x:2:root,bin,daemon
sys:x:3:root,bin,adm
adm:x:4:root,adm,daemon
tty:x:5:
disk:x:6:root,adm
lp:x:7:lp
mem:x:8:
kmem:x:9:
wheel:x:10:root
floppy:x:11:root
mail:x:12:mail
news:x:13:news
uucp:x:14:uucp
man:x:15:
dialout:x:16:uucp
audio:x:17:root
video:x:18:root
cdrom:x:19:root
games:x:20:
slocate:x:21:
utmp:x:22:
tape:x:23:
smmsp:x:25:smmsp
polkit:x:26:root
mysql:x:27:
rpc:x:32:
sshd:x:33:sshd
kdm:x:41:
gdm:x:42:
shadow:x:43:
avahi:x:44:
ftp:x:50:
oprofile:x:51:
tomcat:x:66:
apache:x:80:
messagebus:x:81:
haldaemon:x:82:
plugdev:x:83:root
power:x:84:root
netdev:x:86:root
pop:x:90:pop
scanner:x:93:root
nobody:x:98:nobody
nogroup:x:99:
users:x:100:
console:x:101:
polkitd:x:102:
colord:x:108:
vboxusers:x:215:
lock:x:54:
dovenull:x:74:
dovecot:x:76:
sudo:x:88:

EOF

fi

# Pour chaque ligne du tableau des groupes :
for ((i = 0; i < ${#basegid[@]}; i++)); do
	champgroupe=$(echo "${basegid[$i]}" | awk -F ":" '{ print $1 }')
	champgid=$(echo "${basegid[$i]}" | awk -F ":" '{ print $2 }')
	
	if [ ! "$(grep -E "^${champgroupe}:" etc/group)" = "" ]; then
		
		# Le groupe existe, on le corrige (même s'il est correct) :
		chroot . groupmod -g ${champgid} -n ${champgroupe} ${champgroupe} 2>/dev/null
	
	elif [ ! "$(grep ":x:${champgid}" etc/group)" = "" ]; then
		
		# Le groupe existe mais sous un autre nom, on le corrige :
		anciengroupe="$(grep ":x:${champgid}:" etc/group | awk -F ":" '{ print $3 }')"
		chroot . groupmod -g ${champgid} -n ${champgroupe} ${anciengroupe} 2>/dev/null
	else
		
		# Le groupe n'existe pas, on le crée :
		chroot . groupadd -g ${champgid} ${champgroupe} 2>/dev/null
	fi
done

# Pour chaque ligne du tableau des comptes utilisateur :
for ((i = 0; i < ${#baseuid[@]}; i++)); do
	
	# On vérifie que 6 champs sont identifiables, sinon on quitte :
	valide="$(echo "${baseuid[$i]}" | awk -F ":" 'NF != 6 { print "ERREUR : 6 champs séparés par des DEUX-POINTS « : » sont requis. Or il y a "NF" champs dans \""$0"\"" }')"
	
	if [ ! "$(echo ${valide} | grep ERREUR)" = "" ];then
		echo ${valide}
		exit 1
	fi
	
	champnom=$(echo "${baseuid[$i]}" | awk -F ":" '{ print $1 }')
	champuid=$(echo "${baseuid[$i]}" | awk -F ":" '{ print $2 }')
	champgid=$(echo "${baseuid[$i]}" | awk -F ":" '{ print $3 }')
	champdesc=$(echo "${baseuid[$i]}" | awk -F ":" '{ print $4 }')
	champhome=$(echo "${baseuid[$i]}" | awk -F ":" '{ print $5 }')
	champshell=$(echo "${baseuid[$i]}" | awk -F ":" '{ print $6 }')
	
	# Si le compte utilisateur existe :
	if [ ! "$(grep -E "^${champnom}:" etc/passwd)" = "" ]; then
	
		# Le groupe qu'on veut lui attribuer existe-t-il ?
		if [ ! "$(grep ":x:${champgid}" etc/group)" = "" ]; then
			
			# Le groupe existe, on peut modifier le compte :
			chroot . usermod -s ${champshell} -c "${champdesc}" -d ${champhome} -u ${champuid} -g ${champgid} ${champnom} 2>/dev/null
		fi
	
	# Si le compte utilisateur n'existe pas :
	else
		# Le groupe qu'on veut lui attribuer existe-t-il ?
		if [ ! "$(grep ":x:${champgid}" etc/group)" = "" ]; then
			
			# Le groupe existe, on peut créer le compte :
			chroot . useradd -s ${champshell} -c "${champdesc}" -d ${champhome} -u ${champuid} -g ${champgid} -r ${champnom} 2>/dev/null
		fi
	fi
done

# On s'assure que '/var/run' et '/var/lock' pointent bien sur '/run', quitte à
# déplacer des fichiers : :
if [ ! -L var/run ] && [ -d var/run ]; then
	${BUSYBOXBIN} cp -ar var/run/* run/
	${BUSYBOXBIN} rm -rf var/{lock,run}
	${BUSYBOXBIN} ln -sf ../run var/
	${BUSYBOXBIN} ln -sf ../run/lock var/
fi

# On s'assure des permissions :
chown root.utmp run/utmp* var/log/wtmp* >/dev/null 2>&1
chmod 664 run/utmp* >/dev/null 2>&1
chown root.shadow etc/shadow* etc/gshadow* >/dev/null 2>&1
chgrp ftp srv/ftp >/dev/null 2>&1
