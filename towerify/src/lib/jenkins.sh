is_json_valid() {
  json=$1

  (${jq_cli:-jq} . >/dev/null 2>&1 <<< "${json}")
  return $?
}


jenkins_base_url() {
  debug_output "CONFIG_FILE=$CONFIG_FILE"

  jenkins_domain=$(config_get jenkins_domain "not_found")
  echo "https://${jenkins_domain}/"
}

jenkins_is_accessible() {
  user=$(config_get towerify_login "not_found")
  entrypoint="user/${user}/api/json"
  debug_output "user=$user" "\n"
  debug_output "entrypoint=$entrypoint"

  result=$(jenkins_api $entrypoint)
  user_id=$(echo $result | ${jq_cli:-jq} -r '.id')
  debug_output "user_id=$user_id"

  if [[ "$user_id" != "$user" ]]; then
    debug_output "Jenkins est accessible"
    false
  else
    debug_output "Jenkins n'est pas accessible"
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

jenkins_create_job() {
  jenkins_job_name=${1}
  app_type=${2}

  entrypoint="createItem?name=${jenkins_job_name}"
  debug_output "entrypoint=${entrypoint}" "\n"

  jenkins_template_file="${SCRIPT_DIR:-.}/${template_dir}/jenkins/${app_type}.xml"
  debug_output "jenkins_template_file=${jenkins_template_file}"
  if [[ ! -r $jenkins_template_file ]]; then
    echo "$(red_bold "Modèle de pipeline non trouvé.")" 1>&2
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

jenkins_build_job() {
  jenkins_job_name=${1}
  app_env=${2}

  entrypoint="job/${jenkins_job_name}/buildWithParameters"
  debug_output "entrypoint=${entrypoint}" "\n"

  towerify_domain=$(config_get towerify_domain "not_found")

  result=$(jenkins_api "${entrypoint}" "POST" "--form app.tar.gz=@app.tar.gz --form APP_ENV=${app_env} --form TOWERIFY_MAIN_DOMAIN=${towerify_domain}")
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

  base_url="$(jenkins_base_url)"
  api_url="${base_url}${entrypoint}"
  user=$(config_get towerify_login "not_found")
  pwd=$(config_get towerify_password "not_found")
  debug_output "api_url=${api_url}"

  if [[ "${verb}" == "POST" ]]; then
    curl_cmd="${curl_cli:-curl} -s -L --user ${user}:${pwd} ${base_url}crumbIssuer/api/json"
    debug_output "curl_cmd=${curl_cmd}"
    crumb="$(${curl_cmd} | ${jq_cli} -r '.crumbRequestField + ":" + .crumb')"
    debug_output "crumb=${crumb}"
    extra_curl_parameters="-H ${crumb} ${extra_curl_parameters}"
  fi

  curl_cmd="${curl_cli:-curl} -X ${verb} -s -L --user ${user}:${pwd} ${extra_curl_parameters} ${api_url}"
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

  echo "${result}"
}
