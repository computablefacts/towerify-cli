Describe 'app.sh'
  Include src/lib/common.sh
  Include src/lib/colors.sh
  Include src/lib/app.sh

  declare -g app_config_dir="./towerify.shellspec"

  delete_tarignore() {
    if [[ -e "${app_config_dir}/.tarignore" ]]; then
      rm "${app_config_dir}/.tarignore"
    fi
  }


  Describe 'app_compress'

    Describe 'without .tarignore'
      Before 'delete_tarignore'

      It 'should create the app.tar.gz archive'

        When call app_compress
        The path "${app_config_dir}/app.tar.gz" should be file
      End
    End

    Describe 'with .tarignore (./spec)'
      create_tarignore() {
        mkdir -p ${app_config_dir}
        echo './spec' > ${app_config_dir}/.tarignore
      }

      Before 'create_tarignore'
      After 'delete_tarignore'

      It 'should ignore files in ./spec'
        
        list_files() {
          tar -tf ${app_config_dir}/app.tar.gz  
        }

        When call app_compress
        The result of function list_files should not include './spec/'
        The result of function list_files should include './src/'
      End
    End

    Describe 'with .tarignore (.?*/*)'
      create_test_files() {
        mkdir -p .testtarignore
        touch .testtarignore/test01
        touch .testtarignore/.test02
        touch test03
        touch .test04
      }
      delete_test_files() {
        rm -Rf .testtarignore/
        rm -f test03
        rm -f .test04
      }      
      create_tarignore() {
        mkdir -p ${app_config_dir}
        echo '.?*/*' > ${app_config_dir}/.tarignore
      }

      Before 'create_tarignore'
      Before 'create_test_files'
      After 'delete_test_files'
      After 'delete_tarignore'

      It 'should ignore files and directories starting with a dot'
        
        list_files() {
          tar -tf ${app_config_dir}/app.tar.gz  
        }

        When call app_compress
        The result of function list_files should not include './.testtarignore/test01'
        The result of function list_files should not include './.testtarignore/.test02'
        The result of function list_files should include './test03'
        The result of function list_files should include './.test04'
        The result of function list_files should include './src/'
      End
    End
  End
End
