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

    It 'should call jenkins_is_accessible'
      Skip 'TODO'
      jenkins_is_accessible() {
        echo "jenkins_is_accessible called"
        return 1
      }

      When call towerify_deploy
      The output should include 'jenkins_is_accessible called'
      The status should eq 1
    End

    It 'should call jenkins_check_job_exists'
      Skip 'TODO'
      jenkins_is_accessible() { 
        return 0
      }
      jenkins_check_job_exists() {
        echo "jenkins_check_job_exists called"
      }

      When call towerify_deploy
      The output should include 'jenkins_check_job_exists called'
    End

    It 'should call jenkins_create_job if it does not already exist'
      Skip 'TODO'
      jenkins_is_accessible() { 
        return 0
      }
      jenkins_check_job_exists() { 
        return 1
      }
      jenkins_create_job() {
        echo "jenkins_create_job called"
      }

      When call towerify_deploy
      The output should include 'jenkins_create_job called'
    End
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
