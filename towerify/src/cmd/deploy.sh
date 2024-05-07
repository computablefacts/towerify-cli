# Paramétrage
set_debug ${args[--debug]:-0}
set_profile ${args[--profile]:-default}
[[ $g_debug -eq 1 ]] && inspect_args
curl_cli=${deps[curl]}
jq_cli=${deps[jq]}
env=${args[--env]}

debug_output "env=${env}"

app_name=$(app_config_get '.name')
app_type=$(app_config_get '.type')

debug_output "app_name=${app_name}"
debug_output "app_type=${app_type}"

towerify_deploy $app_name $env $app_type
