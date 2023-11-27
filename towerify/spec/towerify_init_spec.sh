Describe 'towerify init'
  Include src/lib/globals.sh
  Include src/lib/filters.sh
  Include src/lib/common.sh
  Include src/lib/colors.sh
  Include src/lib/ask.sh
  Include src/lib/init_func.sh

  declare -g template_dir="../conf/templates"
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

    Parameters
      'static' 'my-app-static' '1'
      'laravel-10' 'my-app-l10' '2'
    End


    It "should initialise app ($1)"
      Data:expand
        #|$2
        #|$3
      End
      
      When run towerify_init
      The line 1 of output should include 'Quel est le nom de votre application'
      The line 3 of output should include "Choissisez un type d'application"
      The stderr should be present # ask_choice()
      The line 5 of output should include "Application $2 initialisée"
    End

    It "should create app config file ($1)"
      Data:expand
        #|$2
        #|$3
      End
      
      When run towerify_init
      The path app-config-file should be file
      The line 1 of contents of file app-config-file should eq "name: $2"
      The line 2 of contents of file app-config-file should eq "type: $1"
      The stderr should be present # ask_choice()
      The output should be present
    End

    It "should create a default .tarignore ($1)"

      template_for() {
        cat "$template_dir/$1/.tarignore"
      }

      When run towerify_init "$2" "$1"
      The path "$app_config_dir/.tarignore" should be file
      The contents of file "$app_config_dir/.tarignore" should eq "$(template_for $1)"
      The output should be present
    End

    It "should create a default .gitignore ($1)"

      template_for() {
        cat "$template_dir/$1/.gitignore"
      }

      When run towerify_init "$2" "$1"
      The path "$app_config_dir/.gitignore" should be file
      The contents of file "$app_config_dir/.gitignore" should eq "$(template_for $1)"
      The output should be present
    End
  End

  Describe 'missing tarignore template'
    remove_tarignore_template() {
      mv "$template_dir/static/.tarignore" "$template_dir/static/.tarignore.old"
    }
    restore_tarignore_template() {
      mv "$template_dir/static/.tarignore.old" "$template_dir/static/.tarignore"
    }

    Before 'remove_tarignore_template'
    After 'restore_tarignore_template'

    It 'should not fail if no .tarignore exist'

      When run towerify_init 'my-app' 'static'
      The path "$app_config_dir/.tarignore" should not be file
      The output should be present
    End
  End

  Describe 'missing gitignore template'
    remove_gitignore_template() {
      mv "$template_dir/static/.gitignore" "$template_dir/static/.gitignore.old"
    }
    restore_gitignore_template() {
      mv "$template_dir/static/.gitignore.old" "$template_dir/static/.gitignore"
    }

    Before 'remove_gitignore_template'
    After 'restore_gitignore_template'

    It 'should not fail if no .gitignore exist'

      When run towerify_init 'my-app' 'static'
      The path "$app_config_dir/.gitignore" should not be file
      The output should be present
    End
  End
End
