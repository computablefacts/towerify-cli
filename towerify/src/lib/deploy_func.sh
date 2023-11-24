towerify_deploy() {
  app_name=${1} 
  app_env=${2}
  app_type=${3}

  jenkins_job_name="${app_name}_${app_env}"

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
  
  # Envoyer les secrets
  # Secret name = <app_name>_<env>
  echo -n "Envoi des secrets ... "
  if ! jenkins_send_secrets $jenkins_job_name; then
    # Erreur
    echo "$(red_bold "==> Création des secrets échouée.")"
    exit 1
  else
    echo "$(green_bold "==> Secrets créés.")"
  fi
  
  # Zipper le répertoire
  echo -n "Compression des fichiers de votre application... "
  if ! app_compress; then
    echo "$(red_bold "==> Compression échouée.")"
    exit 1
  fi
  echo "$(green_bold "==> Compression réussie.")"

  # Envoyer le ZIP au Job Jenkins
  echo -n "Lancement du déploiement... "
  if ! jenkins_build_job $jenkins_job_name $app_env; then
    echo "$(red_bold "==> Lancement échoué.")"
    exit 1
  else
    echo "$(green_bold "==> Déploiement en cours.")"
  fi

  # Surveiller l'avancement du Job

  # Afficher Success ou Failure
  # Afficher l'URL permettant d'aller voir les logs dans Jenkins

  # Renomme le tar.gz avec un timestamp
  tar_timestamp=$(date +%Y%m%d-%H%M%S)
  mv ${app_config_dir}/app.tar.gz ${app_config_dir}/app.${tar_timestamp}.tar.gz
  echo "Application compressée dans ${app_config_dir}/app.${tar_timestamp}.tar.gz"
}
