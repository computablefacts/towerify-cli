towerify_deploy() {
  app_name=${1} 
  app_env=${2}
  app_type=${3}
  profile=${4:-default}

  debug_output "app_name=${app_name}"
  debug_output "app_env=${app_env}"
  debug_output "app_type=${app_type}"
  debug_output "profile=${profile}"

  jenkins_job_name="${app_name}_${app_env}"
  debug_output "jenkins_job_name=${jenkins_job_name}"

  # Read Jenkins configuration
  debug_output "CONFIG_FILE=$CONFIG_FILE"
  towerify_domain=$(config_get "${profile}.towerify_domain" "not_found")
  jenkins_domain=$(config_get "${profile}.jenkins_domain" "not_found")
  towerify_login=$(config_get "${profile}.towerify_login" "not_found")
  towerify_password=$(config_get "${profile}.towerify_password" "not_found")

  debug_output "towerify_domain=${towerify_domain}"
  debug_output "jenkins_domain=${jenkins_domain}"
  debug_output "towerify_login=${towerify_login}"
  debug_output "towerify_password=${towerify_password}"

  # Vérifier la connexion à Jenkins (le mettre dans un filtre Bashly ?)
  display_progress "Tentative de connexion à Towerify"
  if ! jenkins_is_accessible; then
    display_progress "Tentative de connexion à Towerify" "KO" "red_bold"
    echo
    echo "$(red_bold "==> Connexion échouée.")"
    echo "Verifiez vos informations de connexion à Towerify."
    echo
    exit 1
  fi
  display_progress "Tentative de connexion à Towerify" "OK" "green_bold"
  echo

  # Vérifier si le job Jenkins existe déjà ou pas
  # Job name = <app_name>_<env>
  display_progress "Vérification du pipeline de déploiement"
  if ! jenkins_check_job_exists $jenkins_job_name; then
    # Le job n'existe pas
    display_progress "Vérification du pipeline de déploiement" "création" "yellow"
    if ! jenkins_create_job $jenkins_job_name $app_type; then
      display_progress "Vérification du pipeline de déploiement" "KO" "red_bold"
      echo
      echo "$(red_bold "==> Création échouée.")"
      exit 1
    fi
    display_progress "Vérification du pipeline de déploiement" "OK" "green_bold"
    echo
  else
    display_progress "Vérification du pipeline de déploiement" "OK" "green_bold"
    echo
  fi
  
  # Envoyer les secrets
  # Secret name = <app_name>_<env>
  display_progress "Envoi des secrets"
  if ! jenkins_send_secrets $jenkins_job_name; then
    # Erreur
    display_progress "Envoi des secrets" "KO" "red_bold"
    echo
    echo "$(red_bold "==> Création des secrets échouée.")"
    exit 1
  else
    display_progress "Envoi des secrets" "OK" "green_bold"
    echo
  fi
  
  # Zipper le répertoire
  display_progress "Compression des fichiers de votre application"
  if ! app_compress; then
    display_progress "Compression des fichiers de votre application" "KO" "red_bold"
    echo
    echo "$(red_bold "==> Compression échouée.")"
    exit 1
  fi
  display_progress "Compression des fichiers de votre application" "OK" "green_bold"
  echo

  # Récupérer le numéro du dernier build
  local last_job_status=$(jenkins_job_status $jenkins_job_name)
  local last_build_number=$(echo "${last_job_status}" | jq -r '.number')
  debug_output "last_build_number=$last_build_number"

  # Envoyer le ZIP au Job Jenkins
  display_progress "Lancement du déploiement"
  if ! jenkins_build_job $jenkins_job_name $app_env; then
    display_progress "Lancement du déploiement" "KO" "red_bold"
    echo
    echo "$(red_bold "==> Lancement échoué.")"
    exit 1
  else
    display_progress "Lancement du déploiement" "OK" "green_bold"
    echo
  fi

  # Surveiller l'avancement du Job
  local job_status
  local build_number=$last_build_number

  # Attendre que le job commence
  while [ "${last_build_number}" == "${build_number}" ]; do
      display_progress "Job en attente de démarrage"
      sleep 3
      job_status=$(jenkins_job_status $jenkins_job_name)
      build_number=$(echo "${job_status}" | jq -r '.number')
  done
  local job_start_time=$(date +%s)
  display_progress "Job en cours d'exécution"
  sleep 3
  
  local building=true

  # Attendre que le job se termine
  while [ "${building}" == "true" ]; do
      local current_time=$(date +%s)
      job_status=$(jenkins_job_status $jenkins_job_name)

      # Extraire les informations pertinentes
      local result=$(echo "${job_status}" | jq -r '.result')
      local estimated_duration=$(echo "${job_status}" | jq -r '.estimatedDuration' | awk '{ print int($1 / 1000) }')  # Conversion en secondes
      local duration=$((current_time - job_start_time))
      local progress=$((duration * 100 / estimated_duration))
      local remaining_time=$((estimated_duration - duration))
      local build_number=$(echo "${job_status}" | jq -r '.number')

      # Afficher les informations
      if [ "$estimated_duration" -gt "$duration" ]; then
        display_progress "Job en cours d'exécution... Temps restant estimé à ${remaining_time}s" "${progress}%"
      else
        display_progress "Job en cours d'exécution... depuis ${duration}s"
      fi

      sleep 3
      building=$(echo "${job_status}" | jq -r '.building')
  done

  # Afficher Success ou Failure
  if [ "${result}" == "SUCCESS" ]; then
    display_progress "Le job est terminé avec le statut : ${result}" "OK" "green_bold"
    echo 
    echo "$(green_bold "==> Le job a réussi.")"
  else
    display_progress "Le job est terminé avec le statut : ${result}" "KO" "red_bold"
    echo
    echo "$(red_bold "==> Le job a échoué.")"
    echo "Vous pouvez utiliser le lien ci-dessous pour avoir plus de détails sur l'erreur."
  fi

  # Afficher l'URL permettant d'aller voir les logs dans Jenkins
  echo "Lien vers le pipeline : $(jenkins_base_url)blue/organizations/jenkins/${jenkins_job_name}/detail/${jenkins_job_name}/${build_number}/pipeline"

  # Renomme le tar.gz avec un timestamp
  tar_timestamp=$(date +%Y%m%d-%H%M%S)
  mkdir -p ${app_config_dir}/${app_env}
  mv ${app_config_dir}/app.tar.gz ${app_config_dir}/${app_env}/app.${tar_timestamp}.tar.gz
  echo "Application compressée dans ${app_config_dir}/${app_env}/app.${tar_timestamp}.tar.gz"
}
