Describe 'app_config.sh'
  Include src/lib/common.sh
  Include src/lib/colors.sh
  Include src/lib/app_config.sh
  
  declare -g app_config_file="shellspec.config.yaml"
  Path app-config-file=$app_config_file

  create_app_config() {
    touch $app_config_file
  }
  delete_app_config() {
    rm $app_config_file
  }

  Describe 'app_config_get'
    create_app_config() {
      echo 'name: my-app' > $app_config_file
      echo 'type: static' >> $app_config_file
      echo 'config:' >> $app_config_file
      echo '  dockerfile: my.Dockerfile' >> $app_config_file
    }

    Before 'create_app_config'
    After 'delete_app_config'

    It 'reads a simple key'

      When call app_config_get '.name'
      The output should equal 'my-app'
    End

    It 'reads a nested key'

      When call app_config_get '.config.dockerfile'
      The output should equal 'my.Dockerfile'
    End

    It 'should return the default value if key does not exist'

      When call app_config_get '.config.envs.dev.domain' 'default.domain.com'
      The output should equal 'default.domain.com'
    End
  End

  Describe 'app_config_set'

    Before 'create_app_config'
    After 'delete_app_config'

    It 'should write a simple key and value'

      When call app_config_set '.name' 'test-app'
      The first line of contents of the file app-config-file should equal 'name: test-app'
    End

    It 'should write a nested key and value'

      When call app_config_set '.config.dockerfile' 'app.Dockerfile'
      The line 1 of contents of the file app-config-file should equal 'config:'
      The line 2 of contents of the file app-config-file should equal '  dockerfile: app.Dockerfile'
    End
  End
End
