Describe 'towerify configure'
  Include src/lib/globals.sh
  Include src/lib/common.sh
  Include src/lib/colors.sh
  Include src/lib/ask.sh
  Include src/lib/config.sh
  Include src/lib/ini.sh
  Include src/lib/configure_func.sh

  declare -g app_config_dir="./towerify.shellspec"
  CONFIG_FILE="$app_config_dir/config.ini"
  Path towerify-config-file=$CONFIG_FILE

#  debug=1

  It "should configure Towerify"
    jenkins_is_accessible() {
      true
    }

    Data
      #|my-corp.towerify.io
      #|my_login
      #|MyP@ssw0rD
    End
    
    When run towerify_configure
#    Dump
    The line 1 of output should include 'Quel est le domaine de votre Towerify'
    The line 3 of output should include 'Quel est votre login Towerify'
    The line 5 of output should include 'Quel est votre mot de passe Towerify'
    The line 10 of output should include 'Towerify CLI est correctement configuré'
    The line 10 of output should include 'instance Towerify my-corp.towerify.io'
    The path towerify-config-file should be file
    The line 1 of contents of file towerify-config-file should eq 'jenkins_domain=jenkins.my-corp.towerify.io'
    The line 2 of contents of file towerify-config-file should eq 'towerify_domain=my-corp.towerify.io'
    The line 3 of contents of file towerify-config-file should eq 'towerify_login=my_login'
    The line 4 of contents of file towerify-config-file should eq 'towerify_password=MyP@ssw0rD'
  End

End
