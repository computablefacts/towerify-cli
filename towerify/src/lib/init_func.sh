towerify_init() {
  name=${1:-ask}
  type=${2:-ask}
  force=${3:-0}

  # Check if app config file already exists (only if --force is not used)
  if [[ $force -eq 0 ]]; then
    filter_error=$(filter_app_config_should_not_exist)
    if [[ -n $filter_error ]]; then
      echo "$filter_error" >&2
      exit 1
    fi
  fi

  # Ask for name if needed
  if [[ "$name" = "ask" ]]; then
    display_question "Quel est le nom de votre application"
    name=$(ask_string)
    echo
  fi

  debug_output "name=$name"

  # Validate app name
  local message=$(validate_app_name $name)
  if [[ -n "$message" ]]; then
    echo "$(red_bold $message)"
    echo
    exit 1
  fi

  # Ask for type if needed
  if [[ "$type" = "ask" ]]; then
    display_question "Choissisez un type d'application"
    type=$(ask_choices "static" "laravel-9" "laravel-10")
    echo
  fi

  debug_output "type=$type"

  # Write app config file
  debug_output "app_config_dir=$app_config_dir"
  mkdir -p $app_config_dir
  echo "name: $name" > $app_config_dir/$app_config_file
  echo "type: $type" >> $app_config_dir/$app_config_file

  debug_output "template_dir=$template_dir"

  # Create a default .tarignore
  if [[ -f "${template_dir}/${type}/.tarignore" ]]; then
    cp "${template_dir}/${type}/.tarignore" "${app_config_dir}/.tarignore"
  fi

  # Create a default .gitignore
  if [[ -f "${template_dir}/${type}/.gitignore" ]]; then
    cp ${template_dir}/${type}/.gitignore $app_config_dir/.gitignore
  fi

  # Success
  echo "$(green_bold "Application $name initialisée")"
  echo
  echo "Pour déployer cette application, utilisez :"
  echo "  $(bold "towerify deploy")"
  echo
}
