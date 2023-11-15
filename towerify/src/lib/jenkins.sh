is_json_valid() {
  json=$1

  (jq . >/dev/null 2>&1 <<< "${json}")
  return $?
}


jenkins_base_url() {
  [[ $debug -eq 1 ]] && echo "jenkins_base_url() CONFIG_FILE=$CONFIG_FILE" 1>&2

  jenkins_domain=$(config_get jenkins_domain "not_found")
  echo "https://${jenkins_domain}/"
}

jenkins_is_accessible() {
  user=$(config_get towerify_login "not_found")
  entrypoint="user/${user}/api/json"
  [[ $debug -eq 1 ]] && echo -e "\njenkins_is_accessible() user=$user" 1>&2
  [[ $debug -eq 1 ]] && echo "jenkins_is_accessible() entrypoint=$entrypoint" 1>&2

  result=$(jenkins_api $entrypoint)
  user_id=$(echo $result | jq -r '.id')

  if [[ "$user_id" != "$user" ]]; then
    return 1
  fi

  return 0
}

jenkins_check_job_exists() {
  jenkins_job_name=${1}

  entrypoint="api/json"
  [[ $debug -eq 1 ]] && echo "jenkins_check_job_exists() entrypoint=$entrypoint" 1>&2

  result=$(jenkins_api $entrypoint)
  [[ $debug -eq 1 ]] && echo -e "jenkins_check_job_exists() result=\n----\n${result}\n----\n" 1>&2

  jobs=$(echo $result | jq -r '.jobs[] | .name')
  [[ $debug -eq 1 ]] && echo -e "jenkins_check_job_exists() jobs=\n----\n${jobs}\n----\n" 1>&2
  if [[ $jobs =~ "$jenkins_job_name" ]]; then
    [[ $debug -eq 1 ]] && echo "jenkins_check_job_exists() Job trouvé" 1>&2
    return 0
  else
    [[ $debug -eq 1 ]] && echo "jenkins_check_job_exists() Job non trouvé" 1>&2
    return 1
  fi
}

jenkins_create_job() {
  jenkins_job_name=${1}
  app_type=${2}

  entrypoint="createItem?name=${jenkins_job_name}"
  [[ $debug -eq 1 ]] && echo "jenkins_create_job() entrypoint=${entrypoint}" 1>&2

  result=$(jenkins_api "${entrypoint}" "POST" "-H Content-Type:application/xml --data-binary @../conf/templates/jenkins/static.xml")
  [[ $debug -eq 1 ]] && echo -e "jenkins_create_job() result=\n----\n${result}\n----\n" 1>&2


  return 0
}

jenkins_api() {
  entrypoint=${1:-}
  verb=${2:-GET}
  extra_curl_parameters=${3:-}

  base_url="$(jenkins_base_url)"
  api_url="${base_url}${entrypoint}"
  user=$(config_get towerify_login "not_found")
  pwd=$(config_get towerify_password "not_found")
  [[ $debug -eq 1 ]] && echo "jenkins_api() api_url=${api_url}" 1>&2

  if [[ "${verb}" == "POST" ]]; then
    curl_cmd="curl -s -L --user ${user}:${pwd} ${base_url}crumbIssuer/api/json"
    [[ $debug -eq 1 ]] && echo "jenkins_api() curl_cmd=${curl_cmd}" 1>&2
    crumb="$(${curl_cmd} | jq -r '.crumbRequestField + ":" + .crumb')"
    [[ $debug -eq 1 ]] && echo "jenkins_api() crumb=${crumb}" 1>&2
    extra_curl_parameters="-H ${crumb} ${extra_curl_parameters}"
  fi

  curl_cmd="curl -X ${verb} -s -L --user ${user}:${pwd} ${extra_curl_parameters} ${api_url}"
  [[ $debug -eq 1 ]] && echo "jenkins_api() curl_cmd=${curl_cmd}" 1>&2
  result=$(${curl_cmd})
  return_code="$?"
  [[ $debug -eq 1 ]] && echo "jenkins_api() curl return_code=${return_code}" 1>&2

  if [[ $return_code -ne 0 ]]; then
    echo "$(red_bold "==> Connexion échouée.")" 1>&2
    echo "Impossible de joindre ${api_url}" 1>&2
    echo "Verifiez que vous avez bien accès à Internet." 1>&2
    exit 1
  fi

  [[ $debug -eq 1 ]] && echo -e "jenkins_api() result=\n----\n${result}\n----\n" 1>&2
  is_json_valid "${result}"
  return_code=$?
  [[ $debug -eq 1 ]] && echo "jenkins_api() is_json_valid return_code=${return_code}" 1>&2

  if [[ return_code -ne 0 ]]; then
    # User is NOT connected
    echo "$(red_bold "==> Connexion échouée.")" 1>&2
    echo "Verifiez vos informations de connexion à Towerify." 1>&2
    exit 1
  fi

  echo "${result}"
}
