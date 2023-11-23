Describe 'towerify init'
  Include src/lib/globals.sh
  Include src/lib/filters.sh
  Include src/lib/common.sh
  Include src/lib/colors.sh
  Include src/lib/ask.sh
  Include src/lib/init_func.sh

  declare -g app_config_dir="./towerify.shellspec"
  app_config_fullname="$app_config_dir/$app_config_file"
  Path app-config-file=$app_config_fullname

  remove_app_config() {
    if [[ -e $app_config_fullname ]]; then
      rm $app_config_fullname
    fi
  }

  remove_all_config() {
    rm -Rf $app_config_dir
  }

  Before 'remove_all_config'

  Describe 'with no app initialised'

    Before 'remove_app_config'

    It 'should initialise app static'
      Data
        #|my-app
        #|1
      End
      
      When run towerify_init
      The line 1 of output should include 'Quel est le nom de votre application'
      The line 3 of output should include "Choissisez un type d'application"
      The stderr should be present # ask_choice()
      The line 5 of output should include 'Application my-app initialisée'
    End

    It 'should create app static config file'
      Data
        #|my-app
        #|1
      End
      
      When run towerify_init
      The path app-config-file should be file
      The line 1 of contents of file app-config-file should eq 'name: my-app'
      The line 2 of contents of file app-config-file should eq 'type: static'
      The stderr should be present # ask_choice()
      The output should be present
    End

    It 'should initialise app laravel-10'
      Data
        #|my-app
        #|2
      End
      
      When run towerify_init
      The line 1 of output should include 'Quel est le nom de votre application'
      The line 3 of output should include "Choissisez un type d'application"
      The stderr should be present # ask_choice()
      The line 5 of output should include 'Application my-app initialisée'
    End

    It 'should create app laravel-10 config file'
      Data
        #|my-app
        #|2
      End
      
      When run towerify_init
      The path app-config-file should be file
      The line 1 of contents of file app-config-file should eq 'name: my-app'
      The line 2 of contents of file app-config-file should eq 'type: laravel-10'
      The stderr should be present # ask_choice()
      The output should be present
    End

    It 'should create a default .tarignore'
      Data
        #|my-app
        #|1
      End
      
      When run towerify_init
      The path "$app_config_dir/.tarignore" should be file
      The line 1 of contents of file "$app_config_dir/.tarignore" should start with '##'
      The line 2 of contents of file "$app_config_dir/.tarignore" should eq '.?*/*'
      The stderr should be present # ask_choice()
      The output should be present
    End
  End
End
