# Projet-Etude-Scientifique
Ce projet porte sur l'étude d'algorithme de plus court chemin appliqué sur divers maps.

## Dépendances 
Afin de pouvoir utilisé ce programme, les librairies suivantes doivent être installé dans julia : 
- DataType
- Image

## Utilisation
Le programme doit être chargé dans julia REPL avec la commande : `include("main.jl")`  <br>
Après avoir été chargé, ce programme offre plusieur option de test possible :  <br>
- `test(source, debut, fin)` <br>
Test l'entrée sur les 3 fonction principale (flood_fill, dijkstra, A*) <br>
Elle afficheras ainsi les states d'éxecution, ainsi que le résultat, et eventuellement une sortie graphique (Si ça marche)

- `algoFloodFill(source, debut, fin)` <br>
Produit le même test mais que pour l'algo du Flood Fill

- `algoDijkstra(source, debut, fin)` <br>
Produit le même test mais que pour l'algo de Dijkstra

- `algoASstar(source, debut, fin)` <br>
Produit le même test mais que pour l'algo de A*

- `algoWA(source, debut, fin, w)` <br>
Produit le même test mais que pour l'algo de WA avec w comme poids sur l'heuristique

## Observation
Considérons le test suivant : Source = theglaive.map    Debut = (193, 189)   Fin (437, 226) <br>
On observe les resultats suivants : 

### *Flood fill* 
temps d'éxecution : ~ 0.13 seconds <br>
Distance trouvée : 281 <br>
Nombre de case vue : ~ 94420 <br>

### *Dijkstra*
Temps d'éxecution : ~ 0.13 seconds <br>
Distance trouvée : 335 <br>
Nombre de case vue : ~ 71241  <br>

### *A**
Temps d'éxecution : ~ 0.005 seconds  <br>
Distance trouvée : 335  <br>
Nombre de case vue : 16499  <br>

