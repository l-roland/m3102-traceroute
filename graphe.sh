#!/bin/bash
#ROLAND Louis - R&T2 A2

#delete previous <.dot> file
rm -rf graphe.dot

#if not args
if_rte=${1:?"Veuillez indiquer au moins un fichier .rte"}

echo "--------------------------------------------"
echo "M3102 - Script Graphique XDOT - ROLAND Louis"
echo "--------------------------------------------"
echo "./graphe.sh [.rte]"
echo "Tous les fichiers .rte présents dans le répertoire courant seront utilisés pour créer le graphique"
echo "--------------------------------------------"

#start graph
echo "digraph graphe {" >> graphe.dot

#create graph .rte per .rte
for file in $@
do
	#set line1 varaible to 1
	line1=1
	
	#generate radom color for arrows (1 color per .rte)
	declare -a color=($(hexdump -n 3 -v -e '"#" 3/1 "%02X" "\n"' /dev/urandom))
	
	#print terminal <file>.rte used
	echo "OK - $file"
	
	#extract address from file name
	server=`echo $file | sed 's/.rte//g'`
	
	#set length of the file
	len=$(wc -l $file|awk '{print $1}')
	
	#write .dot while addr1 < file length
	while [ $line1 -lt $len ]
	do
		#set line2 varaible to line1+1
		line2=$(($line1 + 1))
		
		#extract ip source in terms of line1
		src=$(cat $file|head -n$line1|tail -n1)
		
		#extract ip destination in terms of line2
		dst=$(cat $file|head -n$line2|tail -n1)
		
		#increment line1 of 1
		((line1++))
		
		#print source -> destination to graphe
		echo "\"$src\"->\"$dst\"[color=\"${color}\"]"  ";" >> graphe.dot
	done
	
	#when file finished, print destination -> final address
	echo "\"$dst\"->\"$server\"[arrowhead=none,penwidth=2]" >> graphe.dot
	
	#set line1 to 1
	line1=1
done

#end of the graph
echo "}" >> graphe.dot

echo "--------------------------------------------"
echo "La création du graphique 'graphe.dot' s'est déroulée correctement"
echo "Fermeture du programme..."
echo "--------------------------------------------"
