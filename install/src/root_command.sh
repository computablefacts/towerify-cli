# Paramétrage
debug=${args[--debug]}
towerify_domain=${args[domain]}
jenkins_domain=jenkins.$towerify_domain
install_dir=$HOME/.towerify
towerify_script=$install_dir/towerify
CONFIG_FILE=$install_dir/config.ini

# Debug arguments
[[ $debug ]] && inspect_args

# Créer le répertoire d'installation s'il n'existe pas
mkdir -p $install_dir

# Vérifier si Towerify CLI est déjà installé
[[ -f "$towerify_script" ]] && error_already_installed

# TODO : Demander le Token Jenkins
jenkins_token=SrtgZrtgzAtgr684eaerfQERF

# Télécharger towerify cli
download_towerify $towerify_script

# Add a link into a directory in $PATH
# TODO: verify that $HOME/.local/bin exist and is in the PATH
ln -sf $towerify_script $HOME/.local/bin

# Ecrire le fichier de conf (URL+Token) dans $HOME/.towerify/config.ini
config_set towerify_domain $towerify_domain
config_set jenkins_domain $jenkins_domain
config_set jenkins_token $jenkins_token

# Debug config.ini
[[ $debug ]] && config_show

# Success
install_succeeded $towerify_domain
