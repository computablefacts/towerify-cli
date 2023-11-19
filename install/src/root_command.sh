# Paramétrage
debug=${args[--debug]}
towerify_domain=${args[domain]}
install_dir=$HOME/.towerify
towerify_script=$install_dir/towerify
CONFIG_FILE=$install_dir/config.ini

# Debug arguments
[[ $debug ]] && inspect_args

# Créer le répertoire d'installation s'il n'existe pas
mkdir -p $install_dir

# Vérifier si Towerify CLI est déjà installé
[[ -f "$towerify_script" ]] && error_already_installed

# Télécharger towerify cli
echo
echo "$(bold "Installation de Towerify CLI pour l'instance $towerify_domain")"
download_towerify $install_dir
echo

# Add a link into a directory in $PATH
# TODO: verify that $HOME/.local/bin exist and is in the PATH
ln -sf $towerify_script $HOME/.local/bin

# Ecrire le fichier de conf (URL+Token) dans $HOME/.towerify/config.ini
config_set towerify_domain $towerify_domain

# Protect config.ini
chmod 600 $CONFIG_FILE

# Debug config.ini
[[ $debug ]] && config_show

# Success
echo "$(green_bold "Towerify CLI est installé pour l'instance $towerify_domain")"
echo
echo "Pour le configurer avec vos login et mot de passe, utilisez :"
echo "  $(bold "towerify configure")"
echo
