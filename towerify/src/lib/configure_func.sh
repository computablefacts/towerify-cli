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
    domain=''
    while [[ -z "$domain" ]]; do
      display_question "Quel est le domaine de votre Towerify"
      domain=$(ask_string $g_towerify_domain)
    done
    echo
  fi
  g_towerify_domain=$domain
  g_jenkins_domain=jenkins.$g_towerify_domain

  debug_output "g_towerify_domain=$g_towerify_domain"
  debug_output "g_jenkins_domain=$g_jenkins_domain"

  # Ask for login if needed
  if [[ "$login" = "ask" ]]; then
    login=''
    while [[ -z "$login" ]]; do
      display_question "Quel est votre login Towerify"
      login=$(ask_string $g_towerify_login)
    done
    echo
  fi
  g_towerify_login=$login

  debug_output "g_towerify_login=$g_towerify_login"

  # Ask for password if needed
  if [[ "$password" = "ask" ]]; then
    password=''
    while [[ -z "$password" ]]; do
      display_question "Quel est votre mot de passe Towerify"
      password=$(ask_password)
    done
    echo
  fi
  g_towerify_password=$password

  debug_output "g_towerify_password=$g_towerify_password"

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
  config_set "${g_profile}.towerify_domain" $g_towerify_domain
  config_set "${g_profile}.towerify_login" $g_towerify_login
  config_set "${g_profile}.towerify_password" $g_towerify_password
  config_set "${g_profile}.jenkins_domain" $g_jenkins_domain

  echo "$(green_bold "==> Connexion réussie.")"
  echo
  echo "$(green_bold "Towerify CLI est correctement configuré pour l'instance Towerify ${g_towerify_domain}")"
  echo
  echo "Pour déployer votre première application, allez dans le répertoire de votre application et utilisez :"
  echo "  $(bold "towerify init")"
  echo
}
