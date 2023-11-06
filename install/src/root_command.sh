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

# Demander le Token Jenkins
echo "$(bold "Installation de Towerify pour l'instance $towerify_domain")"
echo
echo "Pour vous authentifier auprès de Towerify, vous devez fournir votre login"
echo "et votre mot de passe."
echo
display_question "Quel est votre login Towerify"
towerify_login=$(ask_string)
echo
echo
display_question "Quel est votre mot de passe Towerify"
towerify_password=$(ask_password)
echo
echo

# Check Towerify access
echo "$(bold "Vérification de l'accès au Towerify $towerify_domain")"
jenkins_confirm_access $jenkins_domain $towerify_login $towerify_password


# Télécharger towerify cli
download_towerify $towerify_script

# Add a link into a directory in $PATH
# TODO: verify that $HOME/.local/bin exist and is in the PATH
ln -sf $towerify_script $HOME/.local/bin

# Ecrire le fichier de conf (URL+Token) dans $HOME/.towerify/config.ini
config_set towerify_domain $towerify_domain
config_set towerify_login $towerify_login
config_set towerify_password $towerify_password
config_set jenkins_domain $jenkins_domain

# Protect config.ini
chmod 600 $CONFIG_FILE

# Debug config.ini
[[ $debug ]] && config_show

# Success
install_succeeded $towerify_domain
