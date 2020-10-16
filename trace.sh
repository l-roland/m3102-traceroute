#!/bin/bash
#ROLAND Louis - R&T2 A2

#delete all previous <.rte> files
rm -rf $1.rte

#if not arg1
if_addr=${1:?"Veuillez indiquer une @IP"}

#domain to ipv4
ip=`getent ahosts $1 | awk '{print $1}' | head -n1`

echo "--------------------------------------------"
echo "M3102 - Script Traceroute - ROLAND Louis"
echo "--------------------------------------------"
echo "./route.sh [@]"
echo "$1 = $ip"
echo "--------------------------------------------"

#delare icmp, udp and tcp with ports
declare -a protocole=("-I" "-U -p53" "-T -p443" "-T -p22" "-T -p25" "-T -p80")

#id number if blank route
a=0

#set ttl max to 30
for ttl in `seq 1 30`; do

	#traceroute option per option
	for option in "${!protocole[@]}"; do
	
		#print ttl number in the terminal
		echo "TTL $ttl : traceroute -n -A -f$ttl -m$ttl ${protocole[option]} $ip"
		
		#declare route command and as command
        trace=`traceroute -n -A -f$ttl -m$ttl ${protocole[option]} $ip |tail -n1|awk '{print $2}'|sed 's/*/°/g'`
        as=`traceroute -n -A -f$ttl -m$ttl ${protocole[option]} $ip |tail -n1|awk '{print $3}'`
        
        #return result for route and as
        echo "$trace $as";echo
		
		#if route = ip, write last route and as in .rte and close the script
		if [[ $trace == $ip ]]; then
			echo "$trace $as" >> $1.rte
			echo "--------------------------------------------"
			echo "La liste des routes empruntées par $1 sont indiquées dans le fichier $1.rte"
			echo "Fermeture du programme..."
			echo "--------------------------------------------"
			exit
		fi
		
		#if route not found, write blank and as in .rte
		if [[ $trace == '°' ]]; then
			if [ $option -eq 5 ]; then
				echo "$1 blank$a $as" >> $1.rte
				a=$((a+1))
				break
			fi
			
		#else if route found , write route and as in .rte
		else
			echo "$trace $as" >> $1.rte
			break
		fi
	done
done
