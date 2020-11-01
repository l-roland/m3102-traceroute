#!/bin/bash

echo -n $(rm -rf graph.dot)

if [ -f res.txt ]; then 										
	nbLignes=$(echo $(wc -l res.txt)|awk '{print $1}') 						
	lastLigne=$(echo $(cat -v res.txt | sed -n "$nbLignes p"))					
	echo "digraph map {" >> graph.dot
	for i in $(seq 1 $nbLignes); do 									ligne=$(echo $(cat -v res.txt | sed -n "$i p"))						
		next=$(($i + 1))						
		ligneSuivante=$(echo $(cat -v res.txt | sed -n "$next p"))	
		if [[ $lastLigne == $ligne ]];then 							
			echo $(sed 's/###//g' res.txt) 							
			echo -e "\n}" >> graph.dot				
		fi
		nbDoublons=$(echo $(cat -n graph.dot | grep "}" | wc -l)) 					
		nbSupr=$(($nbDoublons - 1)) 									
		if [[ $nbDoublons -ge 2 ]];then					
			for sup in $(seq 1 $nbSupr);do 								
				numLigne=$(echo $(cat -n graph.dot | grep "}" | head -n $sup | awk '{print $1}')) 
				echo $(sed -i "$dataLigne d" graph.dot)							
			done
		fi
		if [[ "$ligneSuivante" == "" ]];then
			ligneSuivante='@IP Founded'
		fi
		if  [[ ! $ligne == "###" ]] && [[ ! $ligneSuivante == "###" ]];then 				
			echo -e "\n\t \"$ligne\"" "->" >> graph.dot 						
			echo  -e "\"$ligneSuivante\";" >> graph.dot
		fi
	done
	echo -e "}" >> graph.dot

else
	echo "Aucun fichier contenant les commandes traceroute a été trouvé, veuillez lancer tr.sh avant celui-ci."
fi

