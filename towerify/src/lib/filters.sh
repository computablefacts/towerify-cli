filter_app_config_should_not_exist() {
  if [[ -f "$app_config_dir/$app_config_file" ]]; then
    echo "$(red_bold "Le fichier $app_config_dir/$app_config_file existe déjà dans ce répertoire.")"
    echo
    echo "Si vous voulez effacer cette configuration pour en créer une nouvelle, utilisez :"
    echo "  $(bold "towerify init --force")"
  fi
}

filter_app_config_should_exist() {
  if [[ ! -f "$app_config_dir/$app_config_file" ]]; then
    echo "$(red_bold "Le fichier $app_config_dir/$app_config_file n'existe pas dans ce répertoire.")"
    echo
    echo "Si vous voulez initialiser cette application, utilisez :"
    echo "  $(bold "towerify init")"
  fi
}

filter_towerify_config_should_exist() {
  if [[ ! -f ${CONFIG_FILE:-} ]]; then
    echo "$(red_bold "Impossible de trouver le fichier de configuration de Towerify CLI.")"
    echo "Ce fichier devrait être $SCRIPT_DIR/config.ini"
    echo
    echo "Vous pouvez configurer Towerify CLI avec :"
    echo "  $(bold "towerify configure")"
  fi
}
