#!/usr/bin/env bash
BLOCKS="blocs"

NOLINUXPART_TITLE="Aucune partition Linux n'a été détectée."
NOLINUXPART_MSG=" \
Il ne semble pas y avoir de partition de type Linux sur cette \
machine. Il vous faut au moins une partition de ce type pour installer \
Linux. Pour ce faire, vous devez quitter l'installateur puis créer ces \
partitions en utilisant 'cfdisk' ou 'fdisk'. Pour en savoir plus, lisez \
l'aide de l'installateur."

CANNOTUMOUNTVARRLOGMOUNT="Impossible de démonter /var/log/mount. Redémarrez et relancez 'installateur'."

MOUNTTABLECORRUPTED="Table de montage corrompue. Redémarrez la machine puis relancez 'installateur'."

MAINMENU_BACKTITLE="Installer votre système Linux."

MAINMENU_TITLE="Installation de votre système Linux"

MAINMENU_MSG=" \
Bienvenue dans l'installateur. \
Choisissez une rubrique ci-dessous en utilisant HAUT/BAS, ESPACE et ENTRÉE. \
Vous pouvez aussi utiliser les touches : +, - et TABULATION."

HELPMENU_LABEL="Aide"
HELPMENU_MSG="Lire l'aide de l'installateur."

KEYBOARDMENU_LABEL="Clavier"
KEYBOARDMENU_MSG="Redéfinir la disposition des touches du clavier."

SWAPMENU_LABEL="Swap"
SWAPMENU_MSG="Définir votre partition d'échange 'swap'."

TARGETMENU_LABEL="Partitions"
TARGETMENU_MSG="Définir les partitions sur lesquelles installer."

SOURCEMENU_LABEL="Média"
SOURCEMENU_MSG="Spécifier le média d'installation."

INSTALLMENU_LABEL="Installation"
INSTALLMENU_MSG="Lancer l'installation du système."

CONFIGMENU_LABEL="Configuration"
CONFIGMENU_MSG="Configurer votre nouveau système Linux."

QUITMENU_LABEL="Quitter"
QUITMENU_MSG="Quitter l'installateur."

SYSTEMNOTREADY_TITLE="Le système n'est pas préparé"
SYSTEMNOTREADY_MSG="Avant de procéder à l'installation des paquets logiciels, vous devez \
au préalable terminer certaines étapes, au minimum :\n \
\n \
- avoir choisi les partitions sur lesquelles installer votre nouveau système,\n \
- avoir spécifié le média source où se trouvent les paquets.\n  \
\n \
Appuyez sur ENTRÉE pour retourner au menu principal."

INSTALLHELP_TITLE="Aide a l'installation de votre système Linux"

CLOSE_BUTTON="Fermer"

INSTALLSUCCESSFUL="L'installation de votre système Linux est terminée."

REMOVEMEDIAANDREBOOTNOW=" \
Veuillez retirer le média d'installation puis appuyez sur \
'Ctrl+Alt+Suppr' pour redémarrer la machine."

REBOOTNOW="Vous pouvez maintenant appuyer sur 'Ctrl+Alt+Suppr' pour redémarrer."

FINISHEDINSTALL_TITLE="Installation du système terminée"
FINISHEDINSTALL_MSG=" \
L'installation et la configuration du système sont terminées. Vous pouvez  \
à présent quitter l'installateur afin de redémarrer votre machine."

KEYMAPMENU_TITLE="Choix de la disposition du clavier"
KEYMAPMENU_MSG="Vous pouvez activer l'une des dispositions de clavier ci-dessous. \
Les dispositions francophones figurent en premier dans la liste. Si vous avez un \
doute, sachez que les plus répandues de chaque pays francophone apparaissent \
en premier."

CFKEYMAP_DESC="Canadien-français"
FRCHLATIN1KEYMAP_DESC="Suisse français latin-1"
FRCHKEYMAP_DESC="Suisse français"
BEKEYMAP_DESC="Belge français latin-1"
FRLATIN9KEYMAP_DESC="Français étendu latin-9"
FRLATIN1KEYMAP_DESC="Français latin-1"
FRPCKEYMAP_DESC="Français"
FRKEYMAP_DESC="Français"
AZERTYKEYMAP_DESC="AZERTY standard"
BEPOUTF8KEYMAP_DESC="bépo français + UTF-8"
BEPOKEYMAP_DESC="bépo français"
DVORAKFRKEYMAP_DESC="Dvorak français"
USKEYMAP_DESC="Par défaut, QWERTY des États-Unis"

KEYBOARDTESTMENU_TITLE="Test du clavier"
KEYBOARDTESTMENU_MSG=" \
La nouvelle disposition est maintenant activée. Tapez tout ce que vous \
voulez pour la tester. Pour quitter le test du clavier, entrez simplement \
le chiffre 1 sans aucun autre caractère et appuyez sur ENTRÉE pour valider \
votre choix, ou bien entrez le chiffre 2 sans aucun autre caractère pour \
refuser la disposition et en choisir une autre."

NOSWAPFOUND_TITLE="Partition d'échange introuvable"
NOSWAPFOUND_MSG="Aucune partition d'échange « swap » n'a été trouvée. \
Voulez-vous continuer l'installation sans partition d'echange ? "

ABORTSWAP_TITLE="Abandon de l'installation"
ABORTSWAP_MSG="Créez une partition d'échange « swap » avec disk' ou 'cfdisk' \
puis relancez 'installateur'."

SIZEOFSWAPPARTITION="Partition swap de"

SWAPSELECT_BACKTITLE="Définir la ou les partitions d'échange."
SWAPSELECT_TITLE="Partition(s) d'échange détectée(s)"
SWAPSELECT_MSG="Le programme a détecté une ou plusieurs partitions d'échange \
(de type « swap ») sur votre système. Ces partitions ont été présélectionnées. \
Si vous ne souhaitez pas utiliser certaines de ces partitions, \
veuillez les déselectionner en utilisant HAUT/BAS et ESPACE. \
Si vous souhaitez les utiliser comme défini ci-dessous, appuyez simplement \
sur ENTRÉE."

SWAPCONFIGURED_TITLE="Partition(s) d'échange configurée(s)"
SWAPCONFIGURED_MSG="Votre espace d'échange a bien été configuré. Les informations \
suivantes seront ajoutées à votre fichier '/etc/fstab' :\n"

FORMATTING_TITLE="Formatage en cours"
FORMATTING_BACKTITLE="Formatage de $2 en $1."
FORMATTING_MSG="Formatage de $2 \n\
Taille de la partition : ${TAILLEPARTITION} \n\
Système de fichiers : $1"

MOUNTEDON_MSG="montée sur"
CONFIGURED_MSG="(configurée)"
NOMOREPARTITIONS_MSG="(Ajout des partitions terminé)"

LINUXFORMAT_BACKTITLE="Voulez-vous formater la partition Linux"
LINUXFORMAT_TITLE="Formatage de la partition"
LINUXFORMAT_MSG="Si cette partition n'a pas été formatée, vous devriez le \
faire maintenant. N.B.: Ceci effacera toutes les données s'y trouvant !\n \
Procéder au formatage de la partition ?"

LINUXFORMAT_LABEL="Formater"
LINUXFORMAT_MSG="Formatage rapide sans vérifier les secteurs défectueux"
LINUXCHECKFORMAT_LABEL="Vérifier"
LINUXCHECKFORMAT_MSG="Formatage lent avec vérification des secteurs défectueux"
LINUXDONTFORMAT_LABEL="Non !"
LINUXDONTFORMAT_MSG="Ne pas formater cette partition"

SELECTFS_TITLE="Choix du système de fichiers pour $1"
SELECTFS_BACKTITLE="La partition $1 va être formatée."
SELECTFS_MSG="Veuillez choisir le type de système de fichiers à utiliser \
sur le périphérique $1 dans la liste ci-dessous :"

EXT2_LABEL="Ext2"
EXT3_LABEL="Ext3"
EXT4_LABEL="Ext4"
JFS_LABEL="JFS"
REISERFS_LABEL="ReiserFS"
XFS_LABEL="XFS"
EXT2_MSG="Système de fichiers traditionnel sous Linux"
EXT3_MSG="Version journalisée et plus récente de Ext2"
EXT4_MSG="Le récent successeur de Ext3"
JFS_MSG="Système de fichiers journalisé d'IBM"
REISERFS_MSG="Système journalisé performant"
XFS_MSG="Système de SGI performant pour les gros fichiers"

SELECTROOTDEV_BACKTITLE="Preparer la partition racine pour Linux."
SELECTROOTDEV_TITLE="Choisissez la partition d'installation de Linux :"
SELECT_BUTTON="Choisir"
CONTINUE_BUTTON="Continuer"
SELECTROOTDEV_MSG="Veuillez choisir une partition dans la liste suivante \
pour la racine (« / ») de votre système Linux."

ADDOTHERLINUX_BACKTITLE="Ajouter d'autres partitions Linux à /etc/fstab"
ADDOTHERLINUX_TITLE="Activer d'autres partitions Linux."
ADDOTHERLINUX_MSG="Il y a plus d'une partition de type Linux sur cette machine. \
Vous pouvez utiliser ce spartitions pour distribuer votre système Linux sur \
plusieurs partitions. Actuellement, votre racine (« / ») pour Linux est montée. \
Vous pouvez également monter des répertoires tels que /home or /usr/local \
sur des partitions séparées. Evitez de monter les répertoires /etc, /sbin, \
ou /bin sur leur propre partition car ils contiennent des programmes \
necessaires au fonctionnement interne du systeme. Choisissez les partitions \
ci-dessous à monter à un emplacement de votre choix, ou choisissez « Continuer » \
si vous avez terminé."

SELECTMOUNTPOINT_BACKTITLE="Choisir un point de montage pour ${PARTITION_SUIVANTE}."
SELECTMOUNTPOINT_TITLE="Choix du point de montage pour ${PARTITION_SUIVANTE}"
SELECTMOUNTPOINT_MSG="Bien, il vous faut maintenant indiquer l'emplacement \
de votre choix pour monter et accéder à cette partition. Par exemple, \
pour la monter dans le répertoire '/usr/local', répondez : /usr/local\n\
Dans quel répertoire désirez-vous monter ${PARTITION_SUIVANTE} ?"

PARTITIONSCREATED_BACKTITLE="Montage des partitions terminé."
PARTITIONSCREATED_TITLE="Ajout des partitions à /etc/fstab terminé"
PARTITIONSCREATED_MSG="Ajout des informations suivantes a votre '/etc/fstab' :\n"

ADDFAT_BACKTITLE="Définir les partitions non-Linux."
ADDFAT_TITLE="Partitions FAT ou NTFS détectées"
ADDFAT_MSG="Des partitions de type FAT ou NTFS, communément utilisées par \
DOS et Windows, ont été détectées sur votre système. Voulez-vous ajouter ces \
partitions à '/etc/fstab' afin qu'elles soient accessibles sous Linux ?"

SELECTFAT_BACKTITLE="Sélection des partitions autres que Linux."
SELECTFAT_TITLE="Activer des partitions autres que Linux"
SELECTFAT_MSG="Afin de rendre ces partitions visibles sous Linux, il nous \
faut les ajouter a votre fichier '/etc/fstab'.  Choisissez une partition \
ci-dessous, ou choisissez « Continuer » si vous avez terminé."

NTFSSECU_BACKTITLE="Definir les permissions sur la partition NTFS."
NTFSSECU_BACKTITLE="Permissions de la partition NTFS ${PARTITIONFAT}"
NTFSSECU_MSG="Puisque les utilisateurs peuvent accéder à (voire detruire, \
selon les droits definis) votre partition DOS/Windows, vous devez definir les\
autorisations par défaut des fichiers de cette partition. Les niveaux de \
permissions vont du tout-restrictif (aucun droit) au tout-permissif \
(accès en lecture/écriture/exécution), ce pour chaque utilisateur de la \
machine. Une valeur raisonnable a été présélectionnée (lecture et écriture \
uniquement pour root) mais vous pouvez la modifier selon vos besoins :"
UMASK077_LABEL="umask=077"
UMASK077_MSG="Aucun accès, seul root a tous les droits"
UMASK222_LABEL="umask=222"
UMASK222_MSG="Lecture seule pour tous"
UMASK022_LABEL="umask=022"
UMASK022_MSG="Lecture seule pour tous mais root a tous les droits"
UMASK000_LABEL="umask=000"
UMASK000_MSG="Tout le monde a tous les droits"

SELECTFATMOUNTPOINT_BACKTITLE="Choisir un point de montage pour $PARTITIONFAT."
SELECTFATMOUNTPOINT_TITLE="Choix du point de montage pour $PARTITIONFAT"
SELECTFATMOUNTPOINT_MSG="À présent, cette partition doit être montée à un \
emplacement de votre choix. Veuillez entrer le répertoire dans lequel \
vous souhaitez monter cette partition. Vous pouvez choisir le \
répertoire /fat, /mon-lecteur-c, /windows ou quelque chose de similaire.  \
N.B.: Cette partition ne sera montée qu'après le redémarrage de la machine. \
Où souhaitez-vous monter $PARTITIONFAT ?"

SELECTMEDIA_BACKTITLE="Choisir le support d'installation."
SELECTMEDIA_TITLE="Choix du support d'installation"
SELECTMEDIA_MSG="Veuillez choisir ci-dessous le support dont vous disposez \
pour installer votre système Linux :"
SELECTDVD_LABEL="DVD"
SELECTDVD_MSG="Installer depuis un DVD"
SELECTUSB_LABEL="USB"
SELECTUSB_MSG="Installer depuis une clé USB"
SELECTHDD_LABEL="Dur"
SELECTHDD_MSG="Installer depuis le disque dur"
SELECTNFS_LABEL="NFS"
SELECTNFS_MSG="Installer depuis un volume distant NFS"
SELECTFTP_LABEL="FTP"
SELECTFTP_MSG="Installer depuis un serveur distant FTP ou HTTP"

DETECTDVD_BACKTITLE="Installer depuis un lecteur optique."
DETECTDVD_TITLE="Détection d'un lecteur optique"
DETECTDVD_MSG="Assurez-vous d'avoir inséré un disque d'installation dans votre \
lecteur optique puis appuyez sur ENTRÉE pour lancer la détection."
AUTODETECTDVD_LABEL="Automatique"
AUTODETECTDVD_MSG="Detecter le lecteur CD ou DVD (recommande)"
MANUALDETECTDVD_LABEL="Manuel"
MANUALDETECTDVD_MSG="Specifier manuellement un peripherique"

ENTERDVDDEV_BACKTITLE="Indiquer manuellement le lecteur optique."
ENTERDVDDEV_TITLE="Saisie du périphérique optique"
ENTERDVDDEV_MSG="Veuillez saisir ci-dessous le nom du périphérique optique \
(par exemple : /dev/hdc ou /dev/sr0) que vous souhaitez utiliser pour monter \
le disque d'installation de votre système Linux :" \

IDEAUTODETECTING_TITLE="Détection en cours..."
IDEAUTODETECTING_MSG="Detection automatique d'un lecteur optique IDE contenant \
un disque d'installation..."

SCSIAUTODETECTING_TITLE="Détection en cours..."
SCSIAUTODETECTING_MSG="Detection automatique d'un lecteur optique SCSI/SATA \
contenant un disque d'installation..."

CANTFINDDVD_TITLE="Lecteur optique introuvable"
CANTFINDDVD_MSG="Aucun lecteur optique n'a été détecté sur aucun des \
périphériques scannés. Soit vous utilisez un disque d'amorçage ou un noyau \
qui ne supporte pas pas votre lecteur, soit certains parametres necessaires \
à certains lecteurs n'ont pas été passés au noyau, soit le disque \
d'installation ne se trouve pas dans votre lecteur ou bien vous utilisez \
un lecteur connecté a une carte son Plug-and-Play (dans ce dernier cas, \
connecter directement le lecteur a l'interface IDE ou SCSI/SATA peut aider). \
Assurez-vous de bien utiliser le disque d'amorçage adapté à votre \
matériel ou vérifiez l'état du disque d'installation puis tentez à nouveau \
la détection. Si tout échoue, choisissez un autre support d'installation.\n \
\n \
Vous allez à present retourner au menu principal."

DVDFOUND_TITLE="Lecteur optique détecté"
DVDFOUND_MSG="Un disque a été trouvé dans $LECTEUR_OPTIQUE."
DVDMOUNTFAILED_TITLE="Erreur lors du montage"
DVDMOUNTFAILED_MSG="Une erreur est survenue lors du montage du disque sur \
$LECTEUR_OPTIQUE. Soit le nom du périphérique est incorrect, soit le disque \
d'installation n'est pas inséré (ou est endommagé) ou bien le noyau que vous \
utilisez ne supporte pas le périphérique.\n \
Assurez-vous de bien utiliser le disque d'amorçage adapté à votre \
matériel ou vérifiez l'état du disque d'installation puis tentez à nouveau \
la détection. Si tout échoue, choisissez un autre support d'installation.\n\
\n\
Vous allez à present retourner au menu principal."

DETECTUSB_BACKTITLE="Installer depuis un lecteur USB."
DETECTUSB_TITLE="Détection d'un lecteur USB"
DETECTUSB_MSG="Assurez-vous d'avoir inséré un support d'installation dans votre \
lecteur USB puis appuyez sur ENTRÉE pour lancer la détection."
AUTODETECTUSB_LABEL="Automatique"
AUTODETECTUSB_MSG="Detecter le lecteur USB (recommande)"
MANUALDETECTUSB_LABEL="Manuel"
MANUALDETECTUSB_MSG="Specifier manuellement un peripherique"

ENTERUSBDEV_BACKTITLE="Indiquer manuellement le lecteur USB."
ENTERUSBDEV_TITLE="Saisie du périphérique USB"
ENTERUSBDEV_MSG="Veuillez saisir ci-dessous le nom du périphérique USB \
(par exemple : /dev/sdd1 ou /dev/sr0) que vous souhaitez utiliser pour monter \
le disque d'installation de votre système Linux :" \

USBAUTODETECTING_TITLE="Détection en cours..."
USBAUTODETECTING_MSG="Detection automatique d'un lecteur USB contenant \
un support d'installation..."

CANTFINDUSB_TITLE="Lecteur USB introuvable"
CANTFINDUSB_MSG="Aucun lecteur USB n'a été détecté sur aucun des \
périphériques scannés. Soit vous utilisez un disque d'amorçage ou un noyau \
qui ne supporte pas pas votre lecteur, soit certains parametres necessaires \
à certains lecteurs n'ont pas été passés au noyau ou bien le support \
d'installation ne se trouve pas dans votre lecteur.\n \
Assurez-vous de bien utiliser le disque d'amorçage adapté à votre \
matériel ou vérifiez l'état du support d'installation puis tentez à nouveau \
la détection. Si tout échoue, choisissez un autre support d'installation.\n \
\n \
Vous allez à present retourner au menu principal."

USBFOUND_TITLE="Volume détecté"
USBFOUND_MSG="Un volume a été trouvé dans $LECTEUR_USB."
USBMOUNTFAILED_TITLE="Erreur lors du montage"
USBMOUNTFAILED_MSG="Une erreur est survenue lors du montage du volume sur \
$LECTEUR_USB. Soit le nom du périphérique est incorrect, soit le support \
d'installation n'est pas inséré (ou est endommagé) ou bien le noyau que vous \
utilisez ne supporte pas le périphérique.\n \
Assurez-vous de bien utiliser le disque d'amorçage adapté à votre \
matériel ou vérifiez l'état du support d'installation puis tentez à nouveau \
la détection. Si tout échoue, choisissez un autre support d'installation.\n\
\n\
Vous allez à present retourner au menu principal."

INSTALLFROMHDD_BACKTITLE="Installer depuis le disque dur."
INSTALLFROMHDD_TITLE="Installation depuis le disque dur"
INSTALLFROMHDD_MSG="Afin d'installer directement depuis le disque dur, vous \
devez disposer des fichiers d'installation sur votre disque dur dans un \
répertoire dédié, rangés comme vous pouvez les trouver sur les sites FTP. \
Par exemple, si la distribution se trouve dans '/mes_logiciels/0/', alors \
on devra y trouver le sous-répertoire '/mes_logiciels/0/paquets/' contenant \
les paquets du système à installer. Vous pouvez installer depuis des partitions \
FAT ou Linux. Veuillez entrer la partition (par exemple '/dev/sda1') où se \
trouve le répertoire '0/' contenant les paquets ou bien appuyez sur ENTRÉE pour \
consulter une liste des partitions détectées par l'installateur."

PARTITIONLIST_TITLE="Liste des partitions"

HDDMOUNTFAILED_TITLE="Erreur de montage"
HDDMOUNTFAILED_MSG="Un probleme est survenu lors du montage de la partition. Voulez-vous :"
HDDMOUNTRETRY_LABEL="Réessayer"
HDDMOUNTRETRY_MSG="Réessayer de monter la partition"
HDDMOUNTABORT_LABEL="Ignorer "
HDDMOUNTABORT_MSG="Ignorer l'erreur et continuer"

PKGDIRFOUND_TITLE="Répertoire des paquets trouvé"
PKGDIRFOUND_MSG="Les fichiers d'installation sont bien sur la partition."

PKGDIRNOTFOUND_TITLE="Répertoire des paquets introuvable"
PKGDIRNOTFOUND_MSG="Fichiers d'installation introuvables. Retour au menu."

PKGTOBEINSTALLED="Installation imminente des paquets..."

PKGINSTALLDESC_TITLE="Installation en cours du paquet..."

PREPARINGTOCONFIG_TITLE="Installation des paquets terminée"
PREPARINGTOCONFIG_MSG="Entrée dans la configuration du système..."

DEFINEROOTPASSWORD_TITLE="Aucun mot de passe pour root n'est défini"
DEFINEROOTPASSWORD_MSG="Il n'y a actuellement aucun mot de passe défini \
pour le compte de l'administrateur (root). Il est fortement recommandé \
d'en définir un afin qu'il soit actif dès le premier démarrage de la \
machine. Voulez-vous définir un mot de passe pour root maintenant ?"
