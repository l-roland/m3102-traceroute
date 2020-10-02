#!/bin/bash

rm -rf graphe.dot

echo "--------------------------------------------"
echo "M3102 - Script Graphique XDOT - ROLAND Louis"
echo "--------------------------------------------"

echo "Tous les fichiers .rte présents dans le répertoire courant seront utilisés pour créer le graphique"
echo "--------------------------------------------"

rm -rf graphe.dot
longueur=1
echo "digraph A {" >> graphe.dot
for file in *.rte
do
	echo "OK - $file"
	server=`echo $file | sed 's/.rte//g'`
	taille=$(wc -l $file|cut -d " " -f 1)
	while [ $longueur -lt $taille ]
	do
		longueur1=$(($longueur + 1))
		ipa=$(cat $file|head -n $longueur1|tail -n 1)
		ipb=$(cat $file|head -n $longueur|tail -n 1)
		((longueur+=1))
		echo "\"$ipb\"->\"$ipa\"" >> graphe.dot
	done
	longueur=1
done
echo } >> graphe.dot

echo "--------------------------------------------"
echo "La création du graphique s'est déroulée correctement"
echo "Fermeture du programme..."
