#!/bin/bash

rm -rf $1.rte

if_addr=${1:?"Veuillez indiquer une @IP"}
ip=`getent ahosts $1 | awk '{print $1}' | head -n1`

echo "--------------------------------------------"
echo "M3102 - Script Traceroute - ROLAND Louis"
echo "--------------------------------------------"
echo "./route.sh [@]"
echo "$1 = $ip"
echo "--------------------------------------------"

declare -a protocole=("-I" "-U -p53" "-T -p443" "-T -p22" "-T -p25" "-T -p80")

a=0

for ttl in `seq 1 30`; do		
	for option in "${!protocole[@]}"; do
		echo "TTL $ttl : traceroute -n -A -f$ttl -m$ttl ${protocole[option]} $ip"
        trace=`traceroute -n -A -f$ttl -m$ttl ${protocole[option]} $ip |tail -n1|awk '{print $2}'|sed 's/*/°/g'`
        as=`traceroute -n -A -f$ttl -m$ttl ${protocole[option]} $ip |tail -n1|awk '{print $3}'`
        echo "$trace $as";echo
		
		if [[ $trace == $ip ]]; then
			echo "$trace $as" >> $1.rte
			echo "--------------------------------------------"
			echo "La liste des routes empruntées par $1 sont indiquées dans le fichier $1.rte"
			echo "Fermeture du programme..."
			echo "--------------------------------------------"
			exit
		fi
		
		if [[ $trace == '°' ]]; then
			if [ $option -eq 5 ]; then
				echo "$1 blank$a $as" >> $1.rte
				a=$((a+1))
				break
			fi
		else
			echo "$trace $as" >> $1.rte
			break
		fi
	done
done
