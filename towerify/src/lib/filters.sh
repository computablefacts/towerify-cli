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

filter_tar_should_be_gnu_tar() {

  # Vérifier si la commande tar existe
  if ! command -v tar > /dev/null; then

    # La commande 'tar' n'existe pas
    if [[ "$(uname)" == "Darwin" ]]; then
      # MacOS

      # Vérifier si la commande gtar existe
      if ! command -v gtar > /dev/null; then
        # La commande 'gtar' n'existe pas
        echo "Vous devez installer GNU tar."
        echo "brew install gnu-tar"
      fi

    else
      # Non MacOS
      echo "Vous devez installer tar."
      echo "sudo apt-get install -y tar"
    fi

  else 

    # La commande 'tar' existe
    if [[ "$(uname)" == "Darwin" ]]; then
      # MacOS

      # Vérifier si la commande tar est GNU tar
      if ! tar --version | grep -q "GNU tar"; then
        # Vérifier si la commande gtar existe
        if ! command -v gtar > /dev/null; then
          # La commande 'gtar' n'existe pas
          echo "Vous devez installer GNU tar."
          echo "brew install gnu-tar"
        fi
      fi

    # Je suppose que si 'tar' existe pour les non MacOS alors c'est GNU tar
    fi

  fi
}
