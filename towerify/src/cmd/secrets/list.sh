# Paramétrage
debug=${args[--debug]:-0}
env=${args[--env]}

# Debug arguments
[[ $debug -eq 1 ]] && inspect_args

app_name=$(app_config_get '.name')
debug_output "app_name=$app_name"

mkdir -p "${SCRIPT_DIR}/secrets"
declare -g CONFIG_FILE="${SCRIPT_DIR}/secrets/${app_name}_${env}"

config_load
for key in $(ini_keys); do
  echo "$key=$(echo "${ini[$key]}" | sed 's/^\(..\).*\(..\)$/\1*****\2/')"
done
