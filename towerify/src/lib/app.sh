app_compress() {
  if [[ -e "${app_config_dir}/app.tar.gz" ]]; then
    rm ${app_config_dir}/app.tar.gz
  fi

  tempfilename=$(mktemp)

  if [[ -e "${app_config_dir}/.tarignore" ]]; then
    tar -X ${app_config_dir}/.tarignore -czf ${tempfilename} . && cp ${tempfilename} ${app_config_dir}/app.tar.gz && rm ${tempfilename}
  else
    tar -czf ${tempfilename} . && cp ${tempfilename} ${app_config_dir}/app.tar.gz && rm ${tempfilename}
  fi
}
