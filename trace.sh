#!/bin/bash

rm -rf ip.route

echo "--------------------------------------------"
echo "M3102 - Script Traceroute - ROLAND Louis"
echo "--------------------------------------------"

echo "./route.sh [ip]"
echo "@IP à tracer : $1"
echo "--------------------------------------------"

if_addr=${1:?"Veuillez indiquer une @IP ou un nom de domaine"}

protocole=("-I" "-U -p53" "-U -p80" "-U -p123" "-U -p143" "-U -p443" "-U -p1193" "-T -p53" "-T -p80" "-T -p123" "-T -p143" "-T -p443" "-T -p1193")
ttl=0

for ttl in $(seq 0 29); do		
	((++ttl))
	for option in $protocole
	do
		echo "Protocole du TTL $ttl : $option"
		cmd="traceroute $option -n -f $ttl -m $ttl -N1 -q1 $1"

		if [ $ttl -ge 10 ]
        	then
       			ip=$($cmd | cut -d" " -f3 | tail -n1)
                	if [ "$ip" != '*' ]
                	then
                		$cmd | cut -d" " -f3,4 | tail -n1 >> temp
						break
                	fi
                	else
                		ip=$($cmd | cut -d " " -f4 | tail -n1)
                        if [ "$ip" != '*' ]
                        then
                        	$cmd | cut -d" " -f4,5 | tail -n1 >> temp
							break
                        fi
         fi
	done
done

cat temp | uniq > ip.route
rm temp

echo "--------------------------------------------"
echo "La liste des routes empruntées par $1 sont indiquées dans le fichier ip.route"
echo "Créer un graphe à partir de ce fichier? [o-n]"	
read rep
if [[ $(echo $rep) = "o" ]]; then
	echo $(./graphe.sh)												
	echo "Graphique généré !"
	echo "Fermeture du programme..."
	echo "--------------------------------------------"
else 
	echo "Fermeture du programme..."
echo "--------------------------------------------"
fi
