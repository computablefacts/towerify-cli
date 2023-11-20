app_config_get() {
  yaml_key=${1}
  default_value=${2:-}

  result=$(${yq_cli:-yq} eval ${yaml_key} ${app_config_dir}/${app_config_file})
  [[ "$result" = "null" ]] && echo $default_value || echo $result
}

app_config_set() {
  yaml_key=${1}
  yaml_value=${2}

  yq -i "${yaml_key} = \"${yaml_value}\"" ${app_config_dir}/${app_config_file}
}
