inspect_args

set_debug() {
  debug=$1
}

# Paramétrage
set_debug ${args[--debug]:-0}
curl_cli=${deps[curl]}
jq_cli=${deps[jq]}
env=${args[--env]}

app_name=$(app_config_get '.name')
app_type=$(app_config_get '.type')

towerify_deploy "${app_name}_${env}" ${app_type}
