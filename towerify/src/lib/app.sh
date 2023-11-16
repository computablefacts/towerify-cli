app_compress() {
  if [[ -e 'app.tar.gz' ]]; then
    rm 'app.tar.gz'
  fi

  tempfilename=$(mktemp)

  if [[ -e '.tarignore' ]]; then
    tar -X .tarignore -czf ${tempfilename} . && cp ${tempfilename} 'app.tar.gz' && rm ${tempfilename}
  else
    tar -czf ${tempfilename} . && cp ${tempfilename} 'app.tar.gz' && rm ${tempfilename}
  fi
}
