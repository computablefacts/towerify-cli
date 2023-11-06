is_json_valid() {
  json=$1

  (jq . >/dev/null 2>&1 <<< "$result")
  local exit_code="$?"

  if [[ "$exit_code" = "0" ]]; then
    echo "true"
  else
    echo "false"
  fi
}

jenkins_confirm_access() {
  domain=$1
  user=$2
  pwd=$3

  result=$(curl -s -L --user ${user}:${pwd} https://${domain}/user/${user}/api/json)
  result_is_valid_json="$(is_json_valid $result)"

  if [[ "$result_is_valid_json" != "true" ]]; then
    # User is NOT connected
    echo "$(red_bold "==> Connexion échouée.")"
    echo "Verifiez vos informations de connexion à Towerify."
    echo
    exit 1
  fi

  user_id=$(echo $result | jq -r '.id')
  user_fullname=$(echo $result | jq -r '.fullName')

  if [[ "$user_id" = "$user" ]]; then
    # User is connected
    echo "$(green_bold "==> Connexion réussie.")"
    echo "$(green_bold "Bienvenue $user_fullname.")"
    echo
  else
    # User is NOT connected
    echo "$(red_bold "==> Connexion échouée.")"
    echo "Verifiez vos informations de connexion à Towerify."
    echo
    exit 1
  fi
}
