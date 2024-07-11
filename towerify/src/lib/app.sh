app_compress() {
  if [[ -e "${app_config_dir}/app.tar.gz" ]]; then
    rm ${app_config_dir}/app.tar.gz
  fi

  # Choix de la commande tar
  local tar_cmd=tar
  if [[ "$(uname)" == "Darwin" ]]; then
    # MacOS
    tar_cmd=gtar
  fi

  tempfilename=$(mktemp)

  if [[ -e "${app_config_dir}/.tarignore" ]]; then
    $tar_cmd --no-wildcards-match-slash -X ${app_config_dir}/.tarignore -czf ${tempfilename} . && cp ${tempfilename} ${app_config_dir}/app.tar.gz && rm ${tempfilename}
  else
    $tar_cmd -czf ${tempfilename} . && cp ${tempfilename} ${app_config_dir}/app.tar.gz && rm ${tempfilename}
  fi
}
