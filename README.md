# Towerify CLI

Cette repo contient le script Bash `towerify` qui permet d'interagir avec
une instance Towerify.

Elle contient également le script d'installation de Towerify CLI.

Ces 2 scripts sont générés grâce à [Bashly](https://bashly.dannyb.co/).

## Build

``` bash
./build.sh
```

La build utilise l'image Docker de Bashly.
Elle génère les 2 scripts en version production.

Le script d'installation se trouve dans `./install/install` et
le script Towerify CLI se trouve dans `./towerify/towerify`.

## Publication

Etape à faire après la build.

Ce mettre à la racine de la repo et faire la commande :
```
towerify deploy --profile addapps
```

Towerify CLI sera publié sur https://acme.towerify.io/cli/.

Ce mettre à la racine de la repo et faire la commande :
```
towerify deploy --env=prod --profile addapps
```

Towerify CLI sera publié sur https://cli.towerify.io/.

La publication en DEV correspond à l'ancienne URL et sera bientôt supprimée.

## Developpement

Il faut d'abord installer Bashly :

```bash
sudo gem install bashly
```

Le plus pratique pour développer un script est qu'il se regénère 
automatiquement après chaque changement dans le code.

Pour cela, ouvrir une ligne de commande dans le répertoire `./towerify` et
taper :

``` bash
bashly generate -w -u
```

Puis ouvrir une deuxième ligne de commande dans le répertoire `./towerify` 
pour pouvoir tester le script :

``` bash
./towerify --help
```

## Tests

J'utilise [ShellSpec](https://shellspec.info/) pour faire des tests automatiques sur les fonctions
écrites en Bash.

Pour l'installer :

``` bash
curl -fsSL https://git.io/shellspec | sh -s -- --yes
```

Pour lancer les tests, se mettre dans le répertoire du script (`towerify` ou `install`) et :

``` bash
shellspec
```

Pour que les tests se relancent automatiquement :

``` bash
watch --color shellspec -q -f tap --color
```
