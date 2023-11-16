towerify_deploy() {
  jenkins_job_name=${1}
  app_type=${2}

  debug_output "jenkins_job_name=${jenkins_job_name}"
  debug_output "app_type=${app_type}"

  # Vérifier la connexion à Jenkins (le mettre dans un filtre Bashly ?)
  echo -n "Tentative de connexion à Towerify... "
  if ! jenkins_is_accessible; then
    echo "$(red_bold "==> Connexion échouée.")"
    echo "Verifiez vos informations de connexion à Towerify."
    echo
    exit 1
  fi
  echo "$(green_bold "==> Connexion réussie.")"

  # Vérifier si le job Jenkins existe déjà ou pas
  # Job name = <app_name>_<env>
  echo -n "Vérification du pipeline de déploiement... "
  if ! jenkins_check_job_exists $jenkins_job_name; then
    # Le job n'existe pas
    echo "$(yellow "==> Pipeline non trouvé.")"
    echo -n "Création du pipeline... "
    if ! jenkins_create_job $jenkins_job_name $app_type; then
      echo "$(red_bold "==> Création échouée.")"
      exit 1
    fi
    echo "$(green_bold "==> Création réussie.")"
  else
    echo "$(green_bold "==> Pipeline trouvé.")"
  fi
  


  # Si le job n'existe pas, demander confirmation pour la création
  # => yes, créer le job (à partir d'un XML installé en même temps que towerify dans $0/../conf/templates/jenkins/<app_type>.xml)
  # => no, arrêt de la commande

  # Zipper le répertoire

  # Envoyer le ZIP au Job Jenkins

  # Surveiller l'avancement du Job

  # Afficher Success ou Failure
  # Afficher l'URL permettant d'aller voir les logs dans Jenkins
}
