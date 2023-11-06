Describe 'towerify init'
  Path app-config-file='./.towerify.yaml'

  Describe 'with no app initialised'
    remove_app_config() {
      if [[ -e './.towerify.yaml' ]]; then
        rm ./.towerify.yaml
      fi
    }

    Before 'remove_app_config'

    It 'should initialise app static'
      Data
        #|my-app
        #|1
      End
      
      When run source ./towerify init
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
      
      When run source ./towerify init
      The file app-config-file should be present
      The line 1 of contents of file app-config-file should eq 'name: my-app'
      The line 2 of contents of file app-config-file should eq 'type: static'
      The stderr should be present # ask_choice()
      The output should be present
    End
  End


  Describe 'with app initialised'
    create_app_config() {
      echo 'name: my-app' > ./.towerify.yaml
      echo 'type: static' >> ./.towerify.yaml
    }

    Before 'create_app_config'

    It 'should fail'

      When run source ./towerify init
      The status should eq 1
      The stderr should include 'Le fichier .towerify.yaml existe déjà dans ce répertoire'
    End
  End
End
