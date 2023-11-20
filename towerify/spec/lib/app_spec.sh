Describe 'app.sh'
  Include src/lib/common.sh
  Include src/lib/colors.sh
  Include src/lib/app.sh

  declare -g app_config_dir="./towerify.shellspec"
  #Path app-config-file=$app_config_file

  delete_tarignore() {
    if [[ -e "${app_config_dir}/.tarignore" ]]; then
      rm "${app_config_dir}/.tarignore"
    fi
  }
  create_tarignore() {
    mkdir -p ${app_config_dir}
    echo './spec' > ${app_config_dir}/.tarignore
  }


  Describe 'app_compress'

    Describe 'without .tarignore'
      Before 'delete_tarignore'

      It 'should create the app.tar.gz archive'

        When call app_compress
        The file "${app_config_dir}/app.tar.gz" should be file
      End
    End


    Describe 'with .tarignore'
      Before 'create_tarignore'
      After 'delete_tarignore'

      It 'should ignore files list in .tarignore'
        
        list_files() {
          tar -tf ${app_config_dir}/app.tar.gz  
        }

        When call app_compress
        The function list_file should not include './spec/'
      End
    End
  End
End
