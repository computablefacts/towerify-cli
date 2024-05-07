# Paramétrage
set_debug ${args[--debug]:-0}
key=${args[key]}
env=${args[--env]}

# Debug arguments
[[ $g_debug -eq 1 ]] && inspect_args

app_name=$(app_config_get '.name')
debug_output "app_name=$app_name"

mkdir -p "${SCRIPT_DIR}/secrets"
declare -g CONFIG_FILE="${SCRIPT_DIR}/secrets/${app_name}_${env}"

config_del $key
