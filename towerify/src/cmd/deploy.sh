inspect_args

set_debug() {
  debug=$1
}

# Paramétrage
set_debug ${args[--debug]:-0}
curl_cli=${deps[curl]}
jq_cli=${deps[jq]}


# TODO: lire .towerify.yaml pour récupérer app_name et app_type

towerify_deploy "my-app_env" "static"

