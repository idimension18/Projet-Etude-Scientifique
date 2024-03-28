# Projet-Etude-Scientifique
Ce projet porte sur l'étude d'algorithme de plus court chemin appliqué sur divers maps.

## Dépendances 
Afin de pouvoir utilisé ce programme, les librairies suivantes doivent être installé dans julia : 
- DataType
- Image

## Utilisation
Le programme principale (main.jl) doit être chargé dans julia REPL avec la commande include  <br>
Après avoir été chargé, ce programme offre plusieurs options de test possible :  <br>

### Tests possibles :
- `test(source, debut, fin)` <br>
Test l'entrée sur les 3 fonctions principales (flood_fill, dijkstra, A*) <br>
Elle affichera ainsi les statistiques d'éxecution, ainsi que le résultat et eventuellement une sortie graphique.

- `algoFloodFill(source, debut, fin)` <br>
Produit le même test mais que pour l'algo du Flood Fill.

- `algoDijkstra(source, debut, fin)` <br>
Produit le même test mais que pour l'algo de Dijkstra.

- `algoASstar(source, debut, fin)` <br>
Produit le même test mais que pour l'algo de A*.

- `algoWA(source, debut, fin, w)` <br>
Produit le même test mais que pour l'algo de WA. (avec w comme poids sur l'heuristique).


### *Notes* :
Les cordonnée de la map sont traités au format suivant : (abscisse, ordonnée) <br>
Avec l'axe des ordonnées dirigée vers le bas

## Observations
Les test suivant on été réalisé sur mon ordinateur.

### *theglaive.map :  debut = (437, 226) ; fin = (193, 189)*
- *Flood fill* <br>
temps d'éxecution : ~ 0.134 seconds <br>
Distance trouvée : 281 <br>
Nombre de case vue : ~ 94420 <br>

- *Dijkstra* <br>
Temps d'éxecution : ~ 0.132 seconds <br>
Distance trouvée : 335 <br>
Nombre de case vue : ~ 71241  <br>

- *A** <br>
Temps d'éxecution : ~ 0.005 seconds  <br>
Distance trouvée : 335  <br>
Nombre de case vue : ~ 16499  <br>

### *64room_007.map : debut = (10, 10) ; fin = (500, 500)*
- *Dijkstra* <br>
Temps d'éxecution : ~ 0.073 seconds <br>
Distance trouvée : 1060 <br>
Nombre de case vue : ~ 253711 <br>

- *A** <br>
Temps d'éxecution : ~ 0.035 seconds <br>
Distance trouvée : 1060 <br>
Nombre de case vue : ~ 142628 <br>
