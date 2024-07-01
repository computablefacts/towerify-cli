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
  echo "  $(bold "towerify configure")"
  echo
  exit 1
}

download_towerify() {
  install_dir=$1

  tempdirname=$(mktemp -d)
  curl --progress-bar https://cli.towerify.io/towerify.tar.gz | tar -zx -C $tempdirname

  cp -R $tempdirname/* $install_dir

  rm -Rf $tempdirname
}

display_question() {
  echo "$(bold "? $1 ?")"
}
