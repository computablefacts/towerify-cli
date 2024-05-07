towerify_deploy() {
  app_name=${1} 
  app_env=${2}
  app_type=${3}

  debug_output "app_name=${app_name}"
  debug_output "app_env=${app_env}"
  debug_output "app_type=${app_type}"
  debug_output "profile=${g_profile}"

  jenkins_job_name="${app_name}_${app_env}"
  debug_output "jenkins_job_name=${jenkins_job_name}"

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
  local last_build_number=0
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
    local last_job_status=$(jenkins_job_status $jenkins_job_name)
    last_build_number=$(echo "${last_job_status}" | jq -r '.number')
    progress_stop "OK" "green_bold"
  fi
  debug_output "last_build_number=$last_build_number"
  
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
      job_status=$(jenkins_job_status $jenkins_job_name 2>/dev/null)
      build_number=$(echo "${job_status}" | jq -r '.number')
      if [ -z "$build_number" ]; then build_number=0; fi
      debug_output "Waiting job start: build_number=[$build_number]"
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
      # .estimatedDuration vaut -1 si c'est la première exécution. Donc estimated_duration vaut -1/1000 = 0
      if [ "$estimated_duration" -gt "0" ]; then
        local progress=$((duration * 100 / estimated_duration))
        local remaining_time=$((estimated_duration - duration))
        local build_number=$(echo "${job_status}" | jq -r '.number')
      fi

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

    # Afficher l'URL permettant d'aller voir les logs dans Jenkins
    echo "Lien vers le pipeline : $(jenkins_base_url)blue/organizations/jenkins/${jenkins_job_name}/detail/${jenkins_job_name}/${build_number}/pipeline"
  fi

  # Renomme le tar.gz avec un timestamp
  tar_timestamp=$(date +%Y%m%d-%H%M%S)
  mkdir -p ${app_config_dir}/${app_env}
  mv ${app_config_dir}/app.tar.gz ${app_config_dir}/${app_env}/app.${tar_timestamp}.tar.gz
  echo "Application compressée dans ${app_config_dir}/${app_env}/app.${tar_timestamp}.tar.gz"

  # Afficher l'URL vers l'application
  local url_domain=$(app_config_get ".config.envs.${app_env}.domain" "${app_env}.${app_name}.${g_towerify_domain}")
  local url_path=$(app_config_get ".config.envs.${app_env}.path" "")  
  echo
  echo "Vous pouvez accéder à votre application avec :"
  echo "$(bold "https://${url_domain}/${url_path}")"
  echo
}
