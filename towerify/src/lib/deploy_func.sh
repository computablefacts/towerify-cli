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
  progress_start "Tentative de connexion à Towerify"
  if ! jenkins_is_accessible; then
    progress_stop "KO" "red_bold"
    echo "$(red_bold "==> Connexion échouée.")"
    echo "Verifiez vos informations de connexion à Towerify."
    echo
    exit 1
  fi
  progress_stop "OK" "green_bold"

  # Vérifier si le job Jenkins existe déjà ou pas
  # Job name = <app_name>_<env>
  progress_start "Vérification du pipeline de déploiement"
  if ! jenkins_check_job_exists $jenkins_job_name; then
    # Le job n'existe pas
    progress_update "création" "yellow"
    if ! jenkins_create_job $jenkins_job_name $app_type; then
      progress_stop "KO" "red_bold"
      echo "$(red_bold "==> Création échouée.")"
      exit 1
    fi
    progress_stop "OK" "green_bold"
  else
    progress_stop "OK" "green_bold"
  fi
  
  # Envoyer les secrets
  # Secret name = <app_name>_<env>
  progress_start "Envoi des secrets"
  if ! jenkins_send_secrets $jenkins_job_name; then
    # Erreur
    progress_stop "KO" "red_bold"
    echo "$(red_bold "==> Création des secrets échouée.")"
    exit 1
  else
    progress_stop "OK" "green_bold"
  fi
  
  # Zipper le répertoire
  progress_start "Compression des fichiers de votre application"
  if ! app_compress; then
    progress_stop "KO" "red_bold"
    echo "$(red_bold "==> Compression échouée.")"
    exit 1
  fi
  progress_stop "OK" "green_bold"

  # Récupérer le numéro du dernier build
  local last_job_status=$(jenkins_job_status $jenkins_job_name)
  local last_build_number=$(echo "${last_job_status}" | jq -r '.number')
  debug_output "last_build_number=$last_build_number"

  # Envoyer le ZIP au Job Jenkins
  progress_start "Lancement du déploiement"
  if ! jenkins_build_job $jenkins_job_name $app_env; then
    progress_stop "KO" "red_bold"
    echo "$(red_bold "==> Lancement échoué.")"
    exit 1
  else
    progress_stop "OK" "green_bold"
  fi

  # Surveiller l'avancement du Job
  local job_status
  local build_number=$last_build_number

  # Attendre que le job commence
  while [ "${last_build_number}" == "${build_number}" ]; do
      progress_start "Job en attente de démarrage"
      sleep 3
      job_status=$(jenkins_job_status $jenkins_job_name)
      build_number=$(echo "${job_status}" | jq -r '.number')
  done
  local job_start_time=$(date +%s)
  progress_change_title "Job en cours d'exécution"
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
        progress_change_title "Job en cours d'exécution... Temps restant estimé à ${remaining_time}s"
        progress_update "${progress}%"
      else
        progress_change_title "Job en cours d'exécution... depuis ${duration}s"
      fi

      sleep 3
      building=$(echo "${job_status}" | jq -r '.building')
  done

  # Afficher Success ou Failure
  progress_change_title "Le job est terminé avec le statut : ${result}"
  if [ "${result}" == "SUCCESS" ]; then
    progress_stop "OK" "green_bold"
    echo "$(green_bold "==> Le job a réussi.")"
  else
    progress_stop "KO" "red_bold"
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

  # Afficher l'URL vers l'application
  local url_domain=$(app_config_get ".config.envs.${app_env}.domain" "${app_env}.${app_name}.${towerify_domain}")
  local url_path=$(app_config_get ".config.envs.${app_env}.path" "")  
  echo
  echo "Vous pouvez accéder à votre application avec :"
  echo "$(bold "https://${url_domain}/${url_path}")"
  echo
}
