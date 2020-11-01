# cr_script

> ROLAND Louis - Groupe A2
> 01/11/20

Au cours de ce module nous avions du créer 2 scripts qui fonctionnent séparémment : 
- Un script qui permet d'automatiser la commande traceroute.
- Un script qui permet de créer un graphe à l'aide des réultats du premier script

Le but de ces scripts est de cartographier tous les sites que nous avons tracés dans un graphe. Voici un exemple de graphe indiquant les différentes routes empruntées de 11 sites :
https://i.imgur.com/FhfW67d.png

## Partie 1 - Script Traceroute

- Le but de ce script est de récupérer l'@ et l'AS de chaque routeur et de les écrire dans un fichier `.rte`. On utilsera une liste de protocoles et de ports si nous ne trouvons aucune @ (le résultat de traceroute indique une étoile si pas d'adresse).

```
$ traceroute perdu.com
traceroute to perdu.com (208.97.177.124), 30 hops max, 60 byte packets
 1  _gateway (192.168.1.254)  0.385 ms  0.696 ms  0.689 ms
 2  * * *  <----- ici aucune adresse est trouvée
```

- Ici la stratégie est de déterminer l'@ et l'AS TTL par TTL (du TTL 1 au TTL 30). On utilisera ainsi une boucle `for` pour n'utiliser que le premier TTL, le second TTl, etc... Bref le TTL s'incrémentera de 1 quand l'adresse sera trouvé. Pour cela on utilisera les options `-f numTTL` et `-m numTTL` de traceroute.

- Si malgré cela nous ne trouvons rien on écrit l'erreur dans le fichier .rte en indiquant le mot blank dedans puis on passe au TTL suivant. Si au bout d'un moment nous trouvons une adresse IP, on écrit cette IP dans .rte puis on passe au TTL suivant.

- Par défault le script utilisera dans l'ordre le protocole ICMP car c'est le plus rapide, le protocole UDP puis ensuite le protocole TCP.

- Au début de programme, la commande getent permettra de convertir un nom de domaine en son adresse IP. Cela simplifiera les comparaisons et les tests pour la suite du script.

```
getent ahosts perdu.com | awk '{print $1}' | head -n1
208.97.177.124   <----- @IP convertie
```

- Si l'adresse IP trouvée par traceroute est identique à l'adresse IP convertie, on écrit cette IP dans le fichier .rte puis le programme s'arrêtera.

- Voici un algorithme simplifié du script. Vous trouverez en annexe le script final

```
#commande IP traceroute : traceroute -n -A -f$ttl -m$ttl ${protocole[option]} $ip |tail -n1|awk '{print $2}'|sed 's/*/°/g'
#commande AS traceroute : traceroute -n -A -f$ttl -m$ttl ${protocole[option]} $ip |tail -n1|awk '{print $3}'

début
	supprimer tous les fichiers .rte présents
	convertir nom de domaine en son IP
	protocoles <- Chaine de caractères contenant les protocoles et les ports à utiliser
	
	for (pour TTL de 1,2,3,...,30)
		for (ICMP, puis UDP avec ports, puis TCP avec ports)
			trace <- variable contenant l'IP de la commande traceroute
			as <- variable contenant l'IP de la commande traceroute
			afficher les variables trace et as sur le terminal

			si (ip indiquée par trace = ip convertie) 
				ecrire dans .rte
				stopper le programme
			fin si
			
			si (ip indiquée par trace = rien)
				ecrire blank dans .rte
				passer au TTL suivant
			sinon
				ecrire ip dans .rte
				passer au TTL suivant
			fin si
		fin for
	fin for
fin
```

## Partie 2 - Script Xdot

- Le but de ce script est de récupérer un, plusieurs ou tous les fichiers .rte afin d'en faire un graphe. Pour cela on utilisera le paquet xdot permettant de faire des graphes en format `.dot`. Dans notre cas nous utiliserons le type  de graphe `digraph`. Voici à quoi devrait ressembler le contenu de notre graphe

```
digraph graphe {
    ip_a -> ip_b
    ip_b -> ip_c
    ip_c -> ip_d
    ip_d -> ...
}
```

- En effet le script prend en charge l'ouverture d'un seul, de plusieurs ou de tous les fichiers .rte présents dans le dossier utilisé par les scripts. On indiquera ces fichiers en tant qu'argument quand nous exécutons le script. Ce dernier va lire les fichiers 1 par 1

	- lire un seul fichier : `./graphe.sh file1.rte`
	- lire plusieurs fichiers`./graphe.sh file1.rte file2.rte file3.rte`
	- lire tous les fichiers`./graphe.sh *.rte`

- Nous aurons des fleches portant une couleur générée aléatoirement pour chaque fichier pour mieux distinguer les routes empruntées pour un site en question (exemple : #15645D pour les flèches de perdu.com, #A127BE pour les flèches de ruffat.org, ...) 

- Une variable line1 va récupérer la première ligne du .rte en question (line1=1)
Une autre variable line2 va récupérer la seconde ligne du .rte (line2=2)

- A l'aide de ces variables nous pourrons afficher les adresses de la ligne 1 (adresse_src) puis de la ligne 2 (adresse_destination). On écrit ainsi à l'aide de `echo` dans le fichier .dot `adresse_src -> adresse_destination`

- Une fois les adresses 1 et 2 exportées dans le graphe, on icrémente les variables line1 et line2 de 1 (line1=2 et line2=3, line1=3 et line2=4, etc...) pour passer aux adresses suivantes, jusqu'à la fin du fichier .rte. Si il y a plusieurs fichiers, le script passera au fichier suivant etc...

- Voici un algorithme simplifié du script. Vous trouverez en annexe le script final

```
début
	supprimer tous le fichier graphe.dot existant
	afficher "digraph graphe {" pour commencer le graphe

	for lecture des arguments (un, plusieurs ou tous les .rte)
		
		line1 <- 1 (pour commencer à la première ligne du fichier .rte)
		len <- variable ou l'on récupère la taille du fichier
		server <- variable ou l'on récupére le nom du fichier
		couleur <- chaîne de caractères afin de générer une couleur aléatoire
		
		tant que (line1 < len)
			line2 <- line1+1
			src <- variable ou l'on stocke la premiere adresse
			dst <- variable ou l'on stocke la seconde adresse
			incrémenter line1 de 1 (ligne2 s'incrémentera aussi)
			afficher "src -> dst" dans le graphe et utiliser la couleur générée pour la flèche
		fin tant que

		afficher "dernière adresse -> server" dans le graphe avec un trait gras pour faire correspondre l'@IP au domaine indiqué dans ./traceroute.sh
		line1 <- on reset la variable à 1 pour la première ligne du fichier suivant

	fin for
	afficher "}" pour terminer le graphe
fin
```

Améliorations possibles : 

- Indiquer l'@IP de la machine avant d'indiquer la première route dans le graphe

## Partie 3 - Annexes

### Script trace.sh

```
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
			# write blank and as if last option is used
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
```

### Script graphe.sh

```
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
```