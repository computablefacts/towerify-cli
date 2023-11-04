filter_app_config_should_not_exist() {
  [[ -f $app_config_file ]] && echo "$(error_app_config_file_already_exists)"
}

filter_app_config_should_exist() {
  [[ -f $app_config_file ]] || echo "$(error_app_config_file_does_not_exist)"
}