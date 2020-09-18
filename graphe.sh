#!/bin/bash

rm -rf graphe.xdot
rm -rf graphe.pdf

len=1
echo "digraph {" >> graphe.xdot
for file in ip.route
do
	
	nb=$(wc -l $file|cut -d " " -f 1)
	while [ $len -lt $nb ]
	do
		len1=$(($len + 1))
		a=$(cat $file|head -n $len1|tail -n 1)
		b=$(cat $file|head -n $len|tail -n 1)
		((len+=1))
		echo "\"$b\"->\"$a\" [label=\"$file\"]" >> graphe.xdot
	done
	len=1
done
echo } >> graphe.xdot
dot -Tpdf graphe.xdot -o graphe.pdf
atril graphe.pdf
