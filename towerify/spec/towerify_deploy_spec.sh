Describe 'towerify deploy'
  Include src/lib/globals.sh
  Include src/lib/colors.sh
  Include src/lib/jenkins.sh
  Include src/lib/deploy_func.sh

  declare -g app_config_dir="./towerify.shellspec"
  app_config_fullname="$app_config_dir/$app_config_file"
  Path app-config-file=$app_config_fullname

  Describe 'with no app initialised'
    remove_app_config() {
      if [[ -e $app_config_fullname ]]; then
        rm $app_config_fullname
      fi
    }

    Before 'remove_app_config'

    It 'should fail'
      Skip "Should test towerify deploy without calling the executable (call the towerify_deploy function)"

      When run source ./towerify deploy
      The status should eq 1
      The stderr should include "Le fichier $app_config_dir/$app_config_file n'existe pas dans ce répertoire"
    End
  End
End
