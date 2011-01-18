#!/usr/bin/env bash

# On synchronise avant toute chose :
sync

# RACINE

# On va faire confiance à 'blkid' pour s'assurer du système de fichiers créé :
FSRACINE=$(blkid -s TYPE ${ROOTSELECT} | cut -d'=' -f2 | tr -d \")

# On ajoute le choix de la racine à ajouter à '/etc/fstab' :
echo "${ROOTSELECT}     /     ${FSRACINE}     defaults     1     1" > $TMP/choix_partitions

# On note la partition racine dans un fichier temporaire :
echo "${ROOTSELECT}" > $TMP/partition_racine

# LINUX SUPPLÉMENTAIRES

# On va faire confiance à 'blkid' pour s'assurer du système de fichiers créé :
FSLINUXADD=$(blkid -s TYPE ${LINUXADD} | cut -d'=' -f2 | tr -d \")

# On crée le point de montage :
mkdir -p ${SETUPROOT}/${MOUNTPOINT}

# On monte enfin le système de fichiers :
echo "Montage de ${LINUXADD} dans ${SETUPROOT}/${MOUNTPOINT}..."
mount ${LINUXADD} ${SETUPROOT}/${MOUNTPOINT} -t ${FSLINUXADD} 1> /dev/null 2> /dev/null

# On ajoute le choix de la partition à ajouter à '/etc/fstab' :
echo "${LINUXADD}     ${MOUNTPOINT}     ${FSLINUXADD}     defaults     1     2" >> $TMP/choix_partitions

# FAT/NTFS

# On crée le point de montage :
mkdir -p ${SETUPROOT}/${MOUNTPOINT}

# On ajoute le choix de la partition à ajouter à '/etc/fstab' :
echo "${FATADD}     ${MOUNTPOINT}     ${FSTYPE}     ${SECU}     1     0" >> $TMP/choix_partitions_fat
