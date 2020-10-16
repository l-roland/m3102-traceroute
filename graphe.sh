#!/bin/bash

rm -rf graphe.dot

if_rte=${1:?"Veuillez indiquer au moins un fichier .rte"}

echo "--------------------------------------------"
echo "M3102 - Script Graphique XDOT - ROLAND Louis"
echo "--------------------------------------------"
echo "./graphe.sh [.rte]"
echo "Tous les fichiers .rte présents dans le répertoire courant seront utilisés pour créer le graphique"
echo "--------------------------------------------"

nb=`ls -l | grep .rte | wc -l`
echo "$nb fichier .rte présents"
a=1

echo "digraph graphe {" >> graphe.dot
for file in $@
do
	declare -a color=($(hexdump -n 3 -v -e '"#" 3/1 "%02X" "\n"' /dev/urandom))
	echo "OK - $file"
	server=`echo $file | sed 's/.rte//g'`
	len=$(wc -l $file|cut -d " " -f 1)
	while [ $a -lt $len ]
	do
		b=$(($a + 1))
		src=$(cat $file|head -n $a|tail -n 1)
		dst=$(cat $file|head -n $b|tail -n 1)
		((a++))
		echo "\"$src\"->\"$dst\"[color=\"${color}\"]"  ";" >> graphe.dot
	done
	echo "\"$dst\"->\"$server\"[arrowhead=none,penwidth=2]" >> graphe.dot
	a=1
done
echo "}" >> graphe.dot

echo "--------------------------------------------"
echo "La création du graphique 'graphe.dot' s'est déroulée correctement"
echo "Fermeture du programme..."
echo "--------------------------------------------"
