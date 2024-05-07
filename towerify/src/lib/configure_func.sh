towerify_configure() {
  local domain=${1:-ask}
  local login=${2:-ask}
  local password=${3:-ask}

  debug_output "domain=$domain"
  debug_output "login=$login"
  debug_output "password=$password"
  debug_output "profile=$g_profile"

  # Ask for domain if needed
  if [[ "$domain" = "ask" ]]; then
    towerify_domain=$(config_get "${g_profile}.towerify_domain" '')
    display_question "Quel est le domaine de votre Towerify"
    domain=$(ask_string $towerify_domain)
    echo
  fi
  jenkins_domain=jenkins.$domain

  debug_output "domain=$domain"
  debug_output "jenkins_domain=$jenkins_domain"

  # Ask for login if needed
  towerify_login=$login
  if [[ "$login" = "ask" ]]; then
    towerify_login=$(config_get "${g_profile}.towerify_login" '')
    display_question "Quel est votre login Towerify"
    login=$(ask_string $towerify_login)
    towerify_login=$login
    echo
  fi

  debug_output "login=$login"

  # Ask for password if needed
  towerify_password=$password
  if [[ "$password" = "ask" ]]; then
    display_question "Quel est votre mot de passe Towerify"
    password=$(ask_password)
    towerify_password=$password
    echo
  fi

  debug_output "password=$password"

  # Debug config.ini
  [[ $g_debug -eq 1 ]] && config_show

  # Check Towerify access
  echo
  echo -n "Tentative de connexion à Towerify... "
  if ! jenkins_is_accessible; then
    echo "$(red_bold "==> Connexion échouée.")"
    echo "Verifiez vos informations de connexion à Towerify."
    echo
    exit 1
  fi
  # Ecrire dans le fichier de conf
  debug_output "CONFIG_FILE=$CONFIG_FILE"
  config_set "${g_profile}.towerify_domain" $domain
  config_set "${g_profile}.towerify_login" $login
  config_set "${g_profile}.towerify_password" $password
  config_set "${g_profile}.jenkins_domain" $jenkins_domain

  echo "$(green_bold "==> Connexion réussie.")"
  echo
  echo "$(green_bold "Towerify CLI est correctement configuré pour l'instance Towerify ${domain}")"
  echo
  echo "Pour déployer votre première application, allez dans le répertoire de votre application et utilisez :"
  echo "  $(bold "towerify init")"
  echo
}
