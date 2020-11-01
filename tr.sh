#!/bin/bash
# Florentin Raimbault
# RT2-A1 - M3102 - Script Traceroute
TTL=1																											#Déclaration de la variable TTL
IP=${1:?"Veuillez fournir l'adresse IP à tester en tant qu'argument"}												#Affectation de la valeur rentrée en argument à la variable addresse IP				
opt=("-I" "-U -p 53" "-T -p 443" "-T -p 22" "-T -p 25" "-T -p 80" "-T -p 21" "-U -p 1149" "-U -p 5060" "-U -p 5004" "-U -p 33434" "-U -p 33435" "-U -p 33436")	#Définition des différentes options utilisées
rm ./res.txt
for TTL in $(seq 1 29)																							#Démarrage de notre boucle principale pour tester 30 routeurs au maximum
do  																																																				#Incrémentation du TTL
	for i  in "${opt[@]}"; do																					#Démarage de notre boucle testant les différentes options en fonction de la compatibilité avec les routeurs
		echo "Lancement de la commande : traceroute -n $i -q1 -f $TTL -m $TTL $IP"  									#Affichage sur le terminal qu'on va éxecuter une commande traceroute
		resultat=`traceroute -n -A $i -w2 -q1 -m $TTL -f $TTL -m $TTL $IP`																										#Affichage de l'addresse IP obtenue dans le terminal																										#Affichage de l'addresse IP obtenue dans le terminal
		res=`echo "$resultat" | sed -n "2p" | awk '{print $2}' | sed "s/ //" | sed "s/*/#/"`		#Récupération de l'addresse IP dans une variable du routeur testé	
		as=`echo "$resultat" | sed -n "2p" | awk '{print $3}' | sed "s/ //"`
		echo "$res $as"
		if [[ "$res" == "$IP" ]]; then 																		#Si il s'agit de la même @IP que l'initiale
			echo "$res, with AS = $as" >> ./res.txt
			echo "Le script s'est déroulé sans problème. Veuillez lancer le script graph.sh afin de générer le fichier xdot."
			exit 																							#On écrit rien et on passe au TTL suivant																	#Sinon on enregistre le résultat dans le fichier txt
		elif [[ "$res" == "#" ]]; then
			if [[ "$i" == '-U -p 33436' ]]; then
				echo "Unreable router with AS = $as" >> ./res.txt																	#Sinon on remplace le texte par une message d'erreur
			fi
			continue																		#Puis on enregsitre le résultat dans le fichier res.txt																		
		else
			echo "$res, with AS = $as" >> ./res.txt
			break
fi
done
done
