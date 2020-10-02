#!/bin/bash

echo "--------------------------------------------"
echo "M3102 - Script Domaine -> IP - ROLAND Louis"
echo "--------------------------------------------"

echo "Utilitaire permettant de convertir un nom de domaine indiqué en son @IP"
echo "--------------------------------------------"

echo "./ip.sh [domain_name]"
echo "Domaine à tracer : $1"
echo "--------------------------------------------"

if_dom=${1:?"Veuillez indiquer un nom de domaine"}

ip=`getent hosts $1 | awk '{ print $1 }'`
echo "@IP : $ip"
echo "$1 : $ip" >> ip.list
