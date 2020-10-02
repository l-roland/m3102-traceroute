#!/bin/bash

rm -rf $1.rte

echo "--------------------------------------------"
echo "M3102 - Script Traceroute - ROLAND Louis"
echo "--------------------------------------------"

echo "./route.sh [ip]"
echo "@IP à tracer : $1"
echo "--------------------------------------------"

if_addr=${1:?"Veuillez indiquer une @IP"}

declare -a protocole=("-I" "-U -p 53" "-T -p 443" "-T -p 22" "-T -p 25" "-T -p 80")

for ((ttl=1; ttl<=30; ttl++)); do		
	for option in "${protocole[@]}"
	do
		echo "TTL $ttl : traceroute $option -N1 -f$ttl -m$ttl $1"
        trace=`traceroute $option -N1 -f$ttl -m$ttl $1 | sed "1d" | sed 's/*/°/g' | awk '{print $3}' | sed 's/(//' | sed 's/)//'`
        echo "@IP trouvée pour le TTL $ttl : $trace"
        echo
		
		if [[ $trace == $1 ]]
		then
			cat $1.tmp >> $1.rte
			rm $1.tmp
			echo "--------------------------------------------"
			echo "La liste des routes empruntées par $1 sont indiquées dans le fichier $1.rte"
			echo "Fermeture du programme..."
			exit
		fi
		if [[ $trace != '°' ]]
		then
			echo $trace >> $1.tmp
			break
		fi
	done
done

cat $1.tmp >> $1.rte
rm $1.tmp

echo "--------------------------------------------"
echo "La liste des routes empruntées par $1 sont indiquées dans le fichier $1.rte"
echo "Fermeture du programme..."
