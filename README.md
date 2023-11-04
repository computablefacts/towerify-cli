# Towerify CLI

Cette repo contient le script Bash `towerify` qui permet d'interagir avec
une instance Towerify.

Elle contient également le script d'installation de Towerify CLI.

Ces 2 scripts sont générés grâce à [Bashly](https://bashly.dannyb.co/).

## Build

``` bash
./build.sh
```

La build utilise l'image Docker de Bashky.
Elle génère les 2 scripts en version production.

Le script d'installation se trouve dans `./install/install` et
le script Towerify CLI se trouve dans `./towerify/towerify`.

## Developpement

Le plus pratique pour développer un script est qu'il se regénère 
automatiquement après chaque changement dans le code.

Pour cela, ouvrir une ligne de commande dans le répertoire `./towerify` et
taper :

``` bash
bashly generate -w
```

Puis ouvrir une deuxième ligne de commande dans le répertoire `./towerify` 
pour pouvoir tester le script :

``` bash
./towerify --help
```
