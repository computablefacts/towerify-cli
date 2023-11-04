error_app_config_file_already_exists() {
  echo "$(red_bold "Le fichier $app_config_file existe déjà dans ce répertoire.")"
  echo
  echo "Si vous voulez effacer cette configuration pour en créer une nouvelle, utilisez :"
  echo "  $(bold "towerify init --force")"
}

error_app_config_file_does_not_exist() {
  echo "$(red_bold "Le fichier $app_config_file n'existe pas dans ce répertoire.")"
  echo
  echo "Si vous voulez initialiser cette application, utilisez :"
  echo "  $(bold "towerify init")"
}

display_question() {
  echo "$(bold "? $1 ?")"
}