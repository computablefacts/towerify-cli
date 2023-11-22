# Paramétrage
debug=${args[--debug]:-0}
key_value=${args[key_value]}
env=${args[--env]}

# Debug arguments
[[ $debug -eq 1 ]] && inspect_args

app_name=$(app_config_get '.name')
debug_output "app_name=$app_name"

key=${key_value%%=*}
value=${key_value#*=}
debug_output "key=$key"
debug_output "value=$value"

mkdir -p "${SCRIPT_DIR}/secrets"
declare -g CONFIG_FILE="${SCRIPT_DIR}/secrets/${app_name}_${env}"

config_set $key $value
