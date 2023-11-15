Describe 'towerify deploy'
  Include src/lib/globals.sh
  Include src/lib/colors.sh
  Include src/lib/jenkins.sh
  Include src/lib/deploy_func.sh

  Path app-config-file="$app_config_file"

  Describe 'with app initialised'
    create_app_config() {
      echo 'name: my-app' > $app_config_file
      echo 'type: static' >> $app_config_file
    }

    Before 'create_app_config'

  End


  Describe 'with no app initialised'
    remove_app_config() {
      if [[ -e $app_config_file ]]; then
        rm $app_config_file
      fi
    }

    Before 'remove_app_config'

    It 'should fail'

      When run source ./towerify deploy
      The status should eq 1
      The stderr should include "Le fichier $app_config_file n'existe pas dans ce répertoire"
    End
  End
End
