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
echo "Pour vous authentifier auprès de Towerify, vous devez fournir votre Token"
echo "Jenkins. Vous pouvez le créer en utilisant cette URL :"
echo "  https://$jenkins_domain/me/configure"
echo
echo "Pour accéder à cette page, Towerify vous demandera de vous connecter avec"
echo "vos login et mot de passe."
echo
display_question "Quel est votre login Towerify"
jenkins_login=$(ask_string)
echo
echo "Pour créer votre Token :"
echo "- cliquez sur \"Ajouter un jeton\""
echo "- saisissez son nom (\"Towerify CLI\" par exemple)"
echo "- cliquez sur \"Générer\""
echo "- copiez le Token"
echo
echo "Coller ensuite votre Token ci-dessous."
echo
display_question "Quel est votre Token"
jenkins_token=$(ask_string)
echo

# Télécharger towerify cli
download_towerify $towerify_script

# Add a link into a directory in $PATH
# TODO: verify that $HOME/.local/bin exist and is in the PATH
ln -sf $towerify_script $HOME/.local/bin

# Ecrire le fichier de conf (URL+Token) dans $HOME/.towerify/config.ini
config_set towerify_domain $towerify_domain
config_set jenkins_domain $jenkins_domain
config_set jenkins_login $jenkins_login
config_set jenkins_token $jenkins_token

# Debug config.ini
[[ $debug ]] && config_show

# Success
install_succeeded $towerify_domain
