#!/bin/sh
#
# /etc/rc.d/rc.M : ce fichier est exécuté lors du passage en mode multi-
# utilisateur par 'init' (donc dans les niveaux d'exécution 2 à 6).

# L'écran se vide au bout de 15 minutes et entre en veille au bout d'une heure :
setterm -blank 15 -powersave powerdown -powerdown 60

# On spécifie le nom de l'hôte si celui-ci n'existe pas :
if [ -r /etc/HOSTNAME ]; then
	hostname $(cat /etc/HOSTNAME | cut -f1 -d .)
else
	echo "pingouin.exemple.net" > /etc/HOSTNAME
	hostname pingouin
fi

# On sauvegarde le contenu de 'dmesg' dans un fichier :
dmesg -s 262144 > /var/log/dmesg

# Lancement de syslog :
if [ -x /etc/rc.d/rc.syslog -a -x /usr/sbin/syslogd -a -d /var/log ]; then
	. /etc/rc.d/rc.syslog start
fi

# On lit les paramètres réseau :
. /etc/reseau.conf

# On active la boucle locale « loopback ». Si le réseau est disponible :
if [ ! "$(grep lo: /proc/net/dev)" = "" ]; then
	# Si l'interface loopback n'est pas active, on réveille 'lo' :
	if [ "$(ifconfig | grep -E 'Local Loopback|Boucle locale')" = "" ]; then
		ifconfig lo 127.0.0.1
		route add -net 127.0.0.0 netmask 255.0.0.0 lo
	fi
fi

# Pour chaque interface Ethernet configurée dans '/etc/reseau.conf' :
for i in 0 1 2 3; do
	# Si et seulement si l'interface est présente :
	if [ ! "$(grep eth${i}: /proc/net/dev)" = "" ]; then
		# Si l'interface Ethernet concernée n'est pas active, on la réveille :
		if [ "$(ifconfig | grep 'inet addr')" = "" ]; then
			ifconfig eth${i}
			route add -net 127.0.0.0 netmask 255.0.0.0 lo
			fi
		
		# Si un routeur/passerelle spécifique a été configuré :
		 if [ "$(route -n | grep \"^0.0.0.0\")" = "" ]; then
			if [ ! "${PASSERELLE}" = "" ]; then
				route add default gw ${PASSERELLE} metric 1
			fi
		fi
		
		# Si l'IP, le masque et la passerelle sont configurés, on se connecte en statique :
		if [ ! "${PASSERELLE}" = "" -a ! "${IP[${i}]}" = "" -a ! "${SOUSRESEAU[${i}]}" = "" ]; then
			
			# On utilise 'ipmask' pour définir l'adresse à envoyer en « broadcast » :
			BROADCAST[${i}]="$(ipmask ${SOUSRESEAU[${i}]} ${IP[${i}]} | cut -d' ' -f1)"
			
			# On envoie le tout à 'ifconfig' :
			ifconfig eth${i} ${IP[${i}]} broadcast ${BROADCAST[${i}]} netmask ${SOUSRESEAU[${i}]}
		
		# Sinon, on suppose qu'on doit utiliser DHCP. On récupère les options à passer : :
		else
			if [ ! "${HOTEDHCP[${i}]}" = "" ]; then
				OPTIONH${i}="-h ${HOTEDHCP[${i}]}"
			fi
			if [ ! "${IP[${i}]}" = "" ]; then
				OPTIONS${i}="-s ${IP[${i}]}"
			fi
			
			# On demande une IP :
			dhcpcd  ${OPTIONH} ${OPTIONS} eth${i}
		fi
	fi
done

# On monte les volumes NFS :
if [ ! "$(cat /etc/fstab | grep -v '^#' | grep -w nfs)" = "" ]; then
	if [ -r /etc/rc.d/rc.rpc ]; then
		. /etc/rc.d/rc.rpc start
	fi
	
	echo "Montage des systèmes de fichiers distants (NFS)..."
	mount -F -a -t nfs 2> /dev/null
fi

# On monte les partages Samba :
if [ ! "$(cat /etc/fstab | grep -v '^#' | grep -w -E 'cifs|smbfs')" = "" ]; then
	echo "Montage des systèmes de fichiers distants (Samba)..."
	mount -R -a -t cifs,smbfs 2> /dev/null
fi

# On lance le pare-feu :
if [ -x /etc/rc.d/rc.firewall ]; then
	. /etc/rc.d/rc.firewall start
fi

# On lance « l'IP forward » :
if [ -x /etc/rc.d/rc.ip_forward ]; then
	. /etc/rc.d/rc.ip_forward start
fi

# On lance SSH :
if [ -x /etc/rc.d/rc.sshd ]; then
	echo "Démarrage d'OpenSSH..."
	. /etc/rc.d/rc.sshd start
fi

# On lance NFS :
if [ -x /etc/rc.d/rc.nfsd ]; then
	. /etc/rc.d/rc.nfsd start
fi

# Montage du reste des systèmes de fichiers :
mount -F -a 2> /dev/null | grep -v "already mounted"

# Nettoyage du système après le montage de systèmes de fichiers, superflu compris :
rm -f /var/lock/* /tmp/.X*lock /tmp/core /core /tmp/hunt* 2> /dev/null

# Correction des permissions au cas où :
chmod 755 / 2>/dev/null
chmod 1777 /tmp /var/tmp

# Lancement des scripts System V s'il en existe pour ce niveau d'exécution :
if [ -x /etc/rc.d/rc.sysvinit ]; then
	. /etc/rc.d/rc.sysvinit
fi

# Lancement des programmes pour GTK+ et Pango dans les 2 architectures :
if [ -d /etc/gtk-2.0 ]; then
	echo "Mise à jour des modules GTK+..."
	gdk-pixbuf-query-loaders-32 > /etc/gtk-2.0-32/gdk-pixbuf.loaders
	gdk-pixbuf-query-loaders-64 > /etc/gtk-2.0-64/gdk-pixbuf.loaders
	gtk-query-immodules-2.0-32 > /etc/gtk-2.0-32/gtk.immodules
	gtk-query-immodules-2.0-64 > /etc/gtk-2.0-64/gtk.immodules
fi

if [ -d /etc/pango ]; then
	echo "Mise à jour des modules Pango..."
	pango-querymodules-32 > /etc/pango-32/pango.modules
	pango-querymodules-64 > /etc/pango-64/pango.modules
fi

# Lancement de D-Bus :
if [ -x /etc/rc.d/rc.messagebus ]; then
	. /etc/rc.d/rc.messagebus start
fi

# Lancement de wicd :
if [ -x /etc/rc.d/rc.wicd ]; then
	. /etc/rc.d/rc.wicd start
fi

# Lancement de dcron :
echo "Lancement de dcron..."
if [ -x /usr/sbin/crond ]; then
	. /usr/sbin/crond -l10 >> /var/log/cron 2>&1
fi

# Lancement du serveur de pointage GPM :
if [ -x /etc/rc.d/rc.gpm ]; then
	. /etc/rc.d/rc.gpm start
fi

# Lancement du script « local » personnel :
if [ -x /etc/rc.d/rc.local ]; then
	if [ -x /etc/rc.d/rc.local ]; then
	. /etc/rc.d/rc.local
fi

# C'est fini !
