# cr_traceroute

> ROLAND Louis - Groupe A2
> 01/11/20

Les différentes séances de TP que nous avons eu depuis le début de l’année ont consisté à cartographier l’internet grâce à des scripts permettant d’automatiser `Traceroute` et de créer un graphique `Graphviz` indiquant toutes les routes empruntées d’un point A vers un point B.

## Partie 1 -  Présentation de traceroute

- Le paquet traceroute (Linux) ou tracert (Windows) est un utilitaire qui permet de suivre les chemins qu’un paquet de données (paquet IP) va prendre pour aller de la machine locale à une autre machine connectée au réseau IP. 

- Ceci nous permettra de voir quels routeurs sont empruntés afin d’atteindre notre destination. On pourra aussi visualiser les systèmes autonaumes des différents routeurs, ce sont des zones ou sont regroupés tous les routeurs, on appelle aussi cela des AS.

- Par défaut Traceroute utilise le protcole UDP pour communiquer avec les routeurs. Il commence aussi au port 34334 puis s'incrémente de 1 pour chaque saut.

- Les paquets IP sont acheminés vers la destination en passant d’un routeur à un autre. Chaque routeur examine sa table de routage pour déterminer le routeur suivant. Traceroute va permettre d’identifier les routeurs empruntés, indiquer le délai entre chacun des routeurs et les éventuelles pertes de paquets. Ces informations seront utiles pour diagnostiquer des problèmes de routage, comme des boucles, pour déterminer s’il y a de la congestion ou un autre problème sur un des liens vers la destination.

- Le principe de fonctionnement de Traceroute consiste à envoyer des paquets UDP (certaines versions peuvent aussi utiliser TCP ou bien ICMP ECHO Request) avec un paramètre Time-To-Live (TTL) de plus en plus grand (en commençant à 1). Chaque routeur qui reçoit un paquet IP en décrémente le TTL avant de le transmettre. Lorsque le TTL atteint 0, le routeur émet un paquet ICMP d’erreur Time to live exceeded vers la source. Traceroute découvre ainsi les routeurs de proche en proche.

- Une fois le paquet sonde arrivé à sa destination finale, traceroute cesse de re-cevoir des TTL exceeded, et reçoit un paquet réponse ayant pour adresse IPsource celle de l’interface de l’équipement sondé à travers laquelle est émis lepaquet ICMP. Traceroute essaie volontairement de contacter un port invalide, donc le paquet réponse est normalement de type ICMP Port Unreachable. Si la machine destination avait par hasard un programme écoutant sur ce port, le comportement n’est pas certain et dépend du programme.

- Il existe cependant un certain nombre d’éléments qui peuvent compliquer l’interprétation du résultat :

- Le chemin suivi par les paquets peut être asymétrique et traceroute nemontre que l’aller ;
    - le chemin suivi peut être radicalement différent depuis un autre point,même proche géographiquement ;
    - les routeurs émettent le paquet ICMP avec l’adresse source de l’interfaceutilisée pour vous joindre, ce n’est pas forcément l’interface par laquell votre paquet sonde est passé ;
    - les routeurs ne traitent pas nécessairement les paquets ICMP en transitde la même façon que le trafic de données. Les temps de réponse en coursde route peuvent ne pas refléter ceux que l’on observerait au niveau dutrafic applicatif. Ce sera particulièrement le cas si le réseau fait usage dequalité de service et que le trafic sur certains liens approche la congestion.
    - la création du paquet ICMP « TTL exceeded » est une opération complexe qui sollicite le CPU du routeur, alors que le trafic est habituellementtraité au niveau du matériel spécialisé. Il se peut qu’un délai supplémentaire soit observé si le CPU est occupé à d’autres tâches plus essentielles (gestion des tables de routage, traitement des requêtes de gestion du réseau), alors que ce délai n’a pas d’effet sur le trafic de transit du routeur.
    - un routeur peut ne pas répondre aux requêtes ICMP. Dans ce cas, onvoit généralement des signes astérisques `(*)` sur les nœuds intermédiairesqui ne répondent pas aux requêtes ICMP. Il se peut aussi que, pour desraisons de performance, le routeur limite le nombre de paquets ICMP généré par unité de temps, ce qui cause l’apparition d’étoiles sur le par-cours, qui ne sont cependant pas le symptôme d’un problème.
    - l’adresse IP de la réponse ICMP TTL Exceeded peut être privée (RFC1918), et donc bloquée en cas de transit par Internet, ou impossible àidentifier.

*Source : https://fr.wikipedia.org/wiki/Traceroute*

J'ai aussi trouvé un schéma qui explique parfaitement le fonctionnement de Traceroute . 

![](https://i.imgur.com/OYBA5kM.png)

*Source : http://racine.gatoux.com/lmdr/index.php/icmp-cest-quoi/*

## Partie 2 - Utilisation de Traceroute sur un terminal

Afin d'exécuter Traceroute, il faut passer par un terminal, que ce soit sur Windows ou sur Linux. On tape ainsi dans le terminal Linux `traceroute [ip/domaine]` et dans le terminal Windows `tracert [ip/domaine]`. Dans mon cas j'étudierai Traceroute sur Linux

On peut aussi indiquer plusieurs options afin de filtrer certaines adresses ou autres :

- `-f` : commencer par un TTL autre que le premier (indiqué par l'utilisateur)
- `-m` : définir un TTL maximum (indiqué par l'utilisateur, la valeur est fixée à 30 par défaut)
- `-n` : ne pas indiquer de nom de domaine (uniquement des @IP)
- `-p` : utiliser un port en question pour communiquer avec le(s) routeur(s) (indiqué par l'utilisateur)
- `-N` : spécifie le nombre de paquets de sonde envoyés simultanément (3 par défaut)
- `-A` : afficher les AS (en plus des @IP ou des domaines)
- `-I` : envoyer des paquets avec ICMP (le plus léger)
- `-U` : envoyer des paquets avec UDP (utilisé par défaut)
- `-T` : envoyer des paquets avec TCP (le plus lourd)

Voici quelques exemples de fonctionnement de Traceroute sans et avec des options

### 1er exemple : utilisation basique de Traceroute

Ici nous allons utiliser Traceroute sans option afin de voir à quoi ressemble le résultat de la commande. Ici on souhaitera trouver les différentes routes empruntées afin d'arriver vers le domaine perdu.com

```
$ traceroute perdu.com
traceroute to perdu.com (208.97.177.124), 30 hops max, 60 byte packets
 1  _gateway (192.168.1.254)  0.385 ms  0.696 ms  0.689 ms
 2  * * *
 3  38.195.118.80.rev.sfr.net (80.118.195.38)  16.237 ms  16.419 ms  16.412 ms
 4  ae2.mpr1.cdg11.fr.zip.zayo.com (64.125.14.37)  15.663 ms  15.405 ms  15.520 ms
 5  ae27.cs1.cdg11.fr.eth.zayo.com (64.125.29.4)  101.055 ms  101.162 ms  101.154 ms
 6  * * *
 7  ae15.er5.iad10.us.zip.zayo.com (64.125.25.167)  103.342 ms  103.244 ms  103.138 ms
 8  208.185.23.134.t00867-03.above.net (208.185.23.134)  102.364 ms  102.405 ms  102.397 ms
 9  iad1-cr-1.sd.dreamhost.com (208.113.156.208)  95.285 ms iad1-cr-2.sd.dreamhost.com (208.113.156.58)  101.268 ms iad1-cr-1.sd.dreamhost.com (208.113.156.208)  95.585 ms
10  ip-208-113-156-14.dreamhost.com (208.113.156.14)  99.509 ms  99.295 ms  98.739 ms
11  * * *
12  * * *
13  * * *
14  * * *
15  * * *
16  * * *
17  * * *
18  * * *
19  * * *
20  * * *
21  * * *
22  * * *
23  * * *
24  * * *
25  * * *
26  * * *
27  * * *
28  * * *
29  * * *
30  * * *
```

### 2eme exemple : utilisation plus avancée de Traceroute

Ici nous souhaiterons utiliser le procole ICMP avec le port 80 en ne spécifiant qu'un seul paquet envoyé simultanément vers le site ruffat.org. On affichera les AS de chaque route, on commencera par le TTL 2 puis on s'arrêtera au TTL 5. On ne souhaiterai aussi afficher uniquement des @IP (pas les noms de domaine).

```
$ traceroute -f2 -m5 -N1 -n -I -p80 -A ruffat.org
traceroute to ruffat.org (51.159.28.79), 5 hops max, 60 byte packets
 2  194.149.169.240 [AS12322]  15.757 ms * *
 3  194.149.166.62 [AS12322]  14.525 ms  14.747 ms  14.885 ms
 4  * * *
 5  195.154.2.199 [AS12876]  15.775 ms  16.164 ms  16.291 ms
```

## Partie 3 - Capture de trames avec Wireshark

### Demande de communication DNS avec perdu.com

```
No.     Time           Source                Destination           Protocol Length Info
     41 1.501330       192.168.1.27          192.168.1.254         DNS      80     Standard query 0xdd8d AAAA perdu.com OPT

No.     Time           Source                Destination           Protocol Length Info
     42 1.516952       192.168.1.254         192.168.1.27          DNS      141    Standard query response 0xdd8d AAAA perdu.com SOA ns1.dreamhost.com OPT
```

- La machine utilisateur commence par faire une requête vers perdu.com
- Le site perdu.com renvoie une réponse à la machine et peuvent communiquer

### Echanges avec le protocole UDP

```
No.     Time           Source                Destination           Protocol Length Info
     43 1.517468       192.168.1.27          208.97.177.124        UDP      74     41317 → 33434 Len=32
- Time to Live: 1
- Source Address: 192.168.1.27
- Destination Address: 208.97.177.124
- Src Port: 41317, Dst Port: 33434

No.     Time           Source                Destination           Protocol Length Info
     44 1.517486       192.168.1.27          208.97.177.124        UDP      74     57103 → 33435 Len=32

No.     Time           Source                Destination           Protocol Length Info
     45 1.517496       192.168.1.27          208.97.177.124        UDP      74     54022 → 33436 Len=32

No.     Time           Source                Destination           Protocol Length Info
     46 1.517513       192.168.1.27          208.97.177.124        UDP      74     45404 → 33437 Len=32
- Time to Live: 2
- Source Address: 192.168.1.27
- Destination Address: 208.97.177.124
- Src Port: 45404, Dst Port: 33437

...
```

On peut ainsi constater dans le détail des captures de trames

- @IP source (192.168.1.27) et @IP destinsation (208.97.177.124)
- Le protocole utilisé (UDP)
- Le numéro du Time To Leave (TTL)
- Le port source et le port destination (33434 pour le premier puis incrémentation de 1)

Ici les trames 43, 44 et 45 ont le même TTL puisque par défaut Traceroute envoie 3 paquets par routeur. Si nous avions utilisé l'option -N1, nous n'aurions qu'unez trame par TTL.

### Messages TTL exceeded

```
No.     Time           Source                Destination           Protocol Length Info
     57 1.517690       192.168.1.254         192.168.1.27          ICMP     102    Time-to-live exceeded (Time to live exceeded in transit)
- Time to Live: 64

No.     Time           Source                Destination           Protocol Length Info
     60 1.518013       192.168.1.254         192.168.1.27          ICMP     102    Time-to-live exceeded (Time to live exceeded in transit)
- Time to Live: 64
```

On remarque dans ces trames que : 

- Le protocole utilisé pour les TTL exceeded est l'ICMP
- La trame est pour la machine utilisateur. Ainsi c'est le routeur qui renvoie le message d'erreur