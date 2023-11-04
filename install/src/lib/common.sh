## Add any function here that is needed in more than one parts of your
## application, or that you otherwise wish to extract from the main function
## scripts.
##
## Note that code here should be wrapped inside bash functions, and it is
## recommended to have a separate file for each function.
##
## Subdirectories will also be scanned for *.sh, so you have no reason not
## to organize your code neatly.
##
error_already_installed() {
  echo "$(red_bold "Towerify CLI est déjà installé")"
  echo
  echo "Si vous voulez mettre à jour Towerify CLI, utilisez :"
  echo "  $(bold "towerify update")"
  echo
  echo "Si vous voulez changer d'instance Towerify, utilisez :"
  echo "  $(bold "towerify config")"
  echo
  exit 1
}

download_towerify() {
  # Mock download by coping
  cp ../towerify/towerify $1
}

install_succeeded() {
  echo "$(green_bold "Towerify CLI est installé")"
  echo
  echo "Il est configuré pour l'instance $(bold "Towerify $1")"
  echo
  echo "Pour déployer votre première application, allez dans le répertoire de votre application et utilisez :"
  echo "  $(bold "towerify init")"
  echo
}