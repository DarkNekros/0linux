#!/usr/bin/env bash

IFS=${IFS}/
set $@

case "$1" in
  button)
    case "$2" in
      power) /sbin/init 0
         ;;
      *) logger "L'action $2 pour l'événement ACPI $1 n'est pas définie."
         ;;
    esac
    ;;
  *)
    logger "Ni l'événement ACPI $1 ni son action spécifique $2 ne sont définis."
    ;;
esac
