filter_app_config_should_not_exist() {
  if [[ -f $app_config_file ]]; then
    echo "$(red_bold "Le fichier $app_config_file existe déjà dans ce répertoire.")"
    echo
    echo "Si vous voulez effacer cette configuration pour en créer une nouvelle, utilisez :"
    echo "  $(bold "towerify init --force")"
  fi
}

filter_app_config_should_exist() {
  if [[ ! -f $app_config_file ]]; then
    echo "$(red_bold "Le fichier $app_config_file n'existe pas dans ce répertoire.")"
    echo
    echo "Si vous voulez initialiser cette application, utilisez :"
    echo "  $(bold "towerify init")"
  fi
}