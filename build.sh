#!/usr/bin/env bash

# Use Docker image for Bashly (comment these lines if you want to use your local installation)
shopt -s expand_aliases
alias bashly='docker run --rm -it --user $(id -u):$(id -g) --volume "$PWD:/app" dannyben/bashly'

cd ./install || exit
bashly generate --env production

cd ../towerify || exit
bashly generate --env production

cd ..

mkdir -p ./site/towerify
cp ./towerify/towerify ./site/towerify/towerify
cp -R ./conf/templates ./site/towerify/templates

cd ./site/towerify
tar -czvf ../towerify.tar.gz .

cd ../..
rm -Rf ./site/towerify/
cp ./install/install.sh ./site/install.sh
