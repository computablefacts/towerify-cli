towerify_deploy() {
  jenkins_job_name=${1}
  app_type=${2}

  # Vérifier la connexion à Jenkins (le mettre dans un filtre Bashly ?)
  echo -n "Tentative de connexion à Towerify... "
  jenkins_is_accessible
  return_code=$?
  if [[ $return_code -ne 0 ]]; then
    echo "$(red_bold "==> Connexion échouée.")"
    echo "Verifiez vos informations de connexion à Towerify."
    echo
    exit 1
  fi
  echo "$(green_bold "==> Connexion réussie.")"

  # Vérifier si le job Jenkins existe déjà ou pas
  # Job name = <app_name>_<env>
  echo -n "Vérification du pipeline de déploiement... "
  jenkins_check_job_exists $jenkins_job_name
  return_code=$?
  [[ $debug -eq 1 ]] && echo "jenkins_check_job_exists-return_code=$return_code" 1>&2
  if [[ $return_code -ne 0 ]]; then
    # Le job n'existe pas
    echo "$(yellow "==> Pipeline non trouvé.")"
    echo -n "Création du pipeline... "
    jenkins_create_job $jenkins_job_name $app_type
    return_code=$?
    if [[ $return_code -ne 0 ]]; then
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
