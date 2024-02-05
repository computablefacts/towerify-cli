is_json_valid() {
  json=$1

  (${jq_cli:-jq} . >/dev/null 2>&1 <<< "${json}")
  return $?
}


jenkins_base_url() {
  echo "https://${jenkins_domain}/"
}

jenkins_is_accessible() {
  entrypoint="user/${towerify_login}/api/json"
  debug_output "entrypoint=$entrypoint"

  result=$(jenkins_api $entrypoint)
  user_id=$(echo $result | ${jq_cli:-jq} -r '.id')
  debug_output "user_id=$user_id"

  if [[ "$user_id" != "$towerify_login" ]]; then
    debug_output "Jenkins n'est pas accessible"
    false
  else
    debug_output "Jenkins est accessible"
    true
  fi
}

jenkins_check_job_exists() {
  jenkins_job_name=${1}

  entrypoint="api/json"
  debug_output "entrypoint=$entrypoint" "\n"

  result=$(jenkins_api $entrypoint)
  debug_output "result=\n----\n${result}\n----\n"

  jobs=$(echo $result | ${jq_cli:-jq} -r '.jobs[] | .name')
  debug_output "jobs=\n----\n${jobs}\n----\n"
  if [[ $jobs =~ "$jenkins_job_name" ]]; then
    debug_output "Job trouvé"
    true
  else
    debug_output "Job non trouvé"
    false
  fi
}

jenkins_job_status() {
  jenkins_job_name=${1}

  entrypoint="/job/${jenkins_job_name}/lastBuild/api/json"
  debug_output "entrypoint=$entrypoint" "\n"

  result=$(jenkins_api $entrypoint)
  debug_output "result=\n----\n${result}\n----\n"

  echo "$result"
}

jenkins_create_job() {
  jenkins_job_name=${1}
  app_type=${2}

  entrypoint="createItem?name=${jenkins_job_name}"
  debug_output "entrypoint=${entrypoint}" "\n"

  ## Si un modèle de job Jenkins existe pour ce type
  if [ -e "${template_dir}/${app_type}/jenkins.xml" ]; then
    ## on l'utilise
    jenkins_template_file="${template_dir}/${app_type}/jenkins.xml"
  else
    ## sinon on prend le modèle par défaut
    jenkins_template_file="${template_dir}/common/jenkins.xml"
  fi
  debug_output "jenkins_template_file=${jenkins_template_file}"
  if [[ ! -r $jenkins_template_file ]]; then
    echo "$(red_bold "Modèle de pipeline non trouvé (${jenkins_template_file}).")" 1>&2
    false
  else
    result=$(jenkins_api "${entrypoint}" "POST" "-H Content-Type:application/xml --data-binary @${jenkins_template_file}")
    return_code=$?
    debug_output "jenkins_api return_code=${return_code}"

    if [[ $return_code -ne 0 ]]; then
      debug_output "result=\n----\n${result}\n----\n"
      false
    else
      true
    fi
  fi
}

jenkins_secrets_already_exists() {
  local readonly jenkins_job_name=${1}

  local readonly base_url="$(jenkins_base_url)"
  local readonly secret_url="${base_url}manage/credentials/store/system/domain/_/credential/${jenkins_job_name}/"
  debug_output "secret_url=${secret_url}"

  curl_cmd="${curl_cli:-curl} --output /dev/null --silent --head --fail --user ${towerify_login}:${towerify_password} ${secret_url}"
  debug_output "curl_cmd=${curl_cmd}"
  result=$(${curl_cmd})
  return_code=$?
  debug_output "curl return_code=${return_code}"

  if [[ $return_code -eq 0 ]]; then
    true
  else
    false
  fi
}

jenkins_send_secrets() {
  jenkins_job_name=${1}

  entrypoint="credentials/store/system/domain/_/createCredentials"
  debug_output "entrypoint=${entrypoint}" "\n"

  app_secret_file="${SCRIPT_DIR}/secrets/${jenkins_job_name}"
  debug_output "app_secret_file=${app_secret_file}"

  ## Send secrets only if a secret file is found locally
  if [[ -f "${app_secret_file}" ]]; then

    ## Check if secret file already exists in Jenkins
    if jenkins_secrets_already_exists $jenkins_job_name; then
      echo -n "Les secrets existent déjà. " 1>&2
      result=$(jenkins_api "/manage/credentials/store/system/domain/_/credential/${jenkins_job_name}/doDelete" "POST" "-H Accept:application/json" "false")
      return_code=$?
      debug_output "jenkins_api return_code='${return_code}'"

      if [[ $return_code -eq 0 ]]; then
        echo "$(green_bold "==> secrets effacés.")" 1>&2
      else
        debug_output "result=\n----\n${result}\n----\n"
        echo "$(red_bold "==> impossible de supprimer les secrets.")" 1>&2
        exit 1
      fi
    else
      echo "Les secrets n'existent pas." 1>&2
    fi

    app_secret_file_json="${SCRIPT_DIR}/secrets/${jenkins_job_name}.json"
    debug_output "app_secret_file_json=${app_secret_file_json}"

    jq -n '{credentials: $ARGS.named}' --arg scope GLOBAL --arg file file0 --arg id ${jenkins_job_name} --arg \$class org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl > ${app_secret_file_json}

    result=$(jenkins_api "${entrypoint}" "POST" "-H Accept:application/json --form file0=@${app_secret_file} --form json=@${app_secret_file_json}" "false")
    return_code=$?
    debug_output "jenkins_api return_code='${return_code}'"

    if [[ $return_code -ne 0 ]]; then
      debug_output "result=\n----\n${result}\n----\n"
      false
    else
      true
    fi
  else
    true
  fi
}

jenkins_build_job() {
  jenkins_job_name=${1}
  app_env=${2}

  entrypoint="job/${jenkins_job_name}/buildWithParameters"
  debug_output "entrypoint=${entrypoint}" "\n"

  result=$(jenkins_api "${entrypoint}" "POST" "--form app.tar.gz=@${app_config_dir}/app.tar.gz --form APP_ENV=${app_env} --form TOWERIFY_MAIN_DOMAIN=${towerify_domain}")
  return_code=$?
  debug_output "jenkins_api return_code=${return_code}"

  if [[ $return_code -ne 0 ]]; then
    debug_output "result=\n----\n${result}\n----\n"
    false
  else
    true
  fi
}

jenkins_api() {
  entrypoint=${1:-}
  verb=${2:-GET}
  extra_curl_parameters=${3:-}
  result_should_be_a_valid_json=${4:-true}

  base_url="$(jenkins_base_url)"
  api_url="${base_url}${entrypoint}"
  debug_output "api_url=${api_url}"

  if [[ "${verb}" == "POST" ]]; then
    curl_cmd="${curl_cli:-curl} -s -L --user ${towerify_login}:${towerify_password} ${base_url}crumbIssuer/api/json"
    debug_output "curl_cmd=${curl_cmd}"
    crumb="$(${curl_cmd} | ${jq_cli} -r '.crumbRequestField + ":" + .crumb')"
    debug_output "crumb=${crumb}"
    extra_curl_parameters="-H ${crumb} ${extra_curl_parameters}"
  fi

  curl_cmd="${curl_cli:-curl} -X ${verb} -s -L --user ${towerify_login}:${towerify_password} ${extra_curl_parameters} ${api_url}"
  debug_output "curl_cmd=${curl_cmd}"
  result=$(${curl_cmd})
  return_code=$?
  debug_output "curl return_code=${return_code}"

  if [[ $return_code -ne 0 ]]; then
    echo "$(red_bold "==> Connexion échouée.")" 1>&2
    echo "Impossible de joindre ${api_url}" 1>&2
    echo "Verifiez que vous avez bien accès à Internet." 1>&2
    exit 1
  fi

  if [[ "$result_should_be_a_valid_json" = "true" ]]; then
    debug_output "result=\n----\n${result}\n----\n"
    is_json_valid "${result}"
    return_code=$?
    debug_output "is_json_valid return_code=${return_code}"

    if [[ return_code -ne 0 ]]; then
      # User is NOT connected
      echo "$(red_bold "==> Connexion échouée.")" 1>&2
      echo "Verifiez vos informations de connexion à Towerify." 1>&2
      exit 1
    fi
  fi

  echo "${result}"
}
