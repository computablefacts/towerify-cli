Describe 'towerify configure'
  Include src/lib/globals.sh
  Include src/lib/common.sh
  Include src/lib/colors.sh
  Include src/lib/ask.sh
  Include src/lib/config.sh
  Include src/lib/ini.sh
  Include src/lib/configure_func.sh

  declare -g dummy_config_dir="./towerify.shellspec"
  CONFIG_FILE="$dummy_config_dir/config.ini"
  Path towerify-config-file=$CONFIG_FILE

  empty_towerify_config() {
    mkdir -p $dummy_config_dir
    if [[ -e $CONFIG_FILE ]]; then
      rm $CONFIG_FILE
      touch $CONFIG_FILE
    fi
  }

  Before 'empty_towerify_config'

  It "should ask for domain, login and password and store to default profile"
#    debug=1
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
    The line 1 of contents of file towerify-config-file should eq '[default]'
    The line 2 of contents of file towerify-config-file should eq 'jenkins_domain=jenkins.my-corp.towerify.io'
    The line 3 of contents of file towerify-config-file should eq 'towerify_domain=my-corp.towerify.io'
    The line 4 of contents of file towerify-config-file should eq 'towerify_login=my_login'
    The line 5 of contents of file towerify-config-file should eq 'towerify_password=MyP@ssw0rD'
  End

  It "should use parameters for domain, login and password and store to default profile"
#    debug=1
    jenkins_is_accessible() {
      true
    }

    When run towerify_configure 'my-corp2.towerify.io' 'my_login2' 'MyP@ssw0rD2'
#    Dump
    The line 4 of output should include 'Towerify CLI est correctement configuré'
    The line 4 of output should include 'instance Towerify my-corp2.towerify.io'
    The path towerify-config-file should be file
    The line 1 of contents of file towerify-config-file should eq '[default]'
    The line 2 of contents of file towerify-config-file should eq 'jenkins_domain=jenkins.my-corp2.towerify.io'
    The line 3 of contents of file towerify-config-file should eq 'towerify_domain=my-corp2.towerify.io'
    The line 4 of contents of file towerify-config-file should eq 'towerify_login=my_login2'
    The line 5 of contents of file towerify-config-file should eq 'towerify_password=MyP@ssw0rD2'
  End

  It "should ask for domain, login and password and store to my_profile"
#    debug=1
    jenkins_is_accessible() {
      true
    }

    Data
      #|my-corp3.towerify.io
      #|my_login3
      #|MyP@ssw0rD3
    End
    
    When run towerify_configure 'ask' 'ask' 'ask' 'my_profile'
#    Dump
    The line 1 of output should include 'Quel est le domaine de votre Towerify'
    The line 3 of output should include 'Quel est votre login Towerify'
    The line 5 of output should include 'Quel est votre mot de passe Towerify'
    The line 10 of output should include 'Towerify CLI est correctement configuré'
    The line 10 of output should include 'instance Towerify my-corp3.towerify.io'
    The path towerify-config-file should be file
    The line 1 of contents of file towerify-config-file should eq '[my_profile]'
    The line 2 of contents of file towerify-config-file should eq 'jenkins_domain=jenkins.my-corp3.towerify.io'
    The line 3 of contents of file towerify-config-file should eq 'towerify_domain=my-corp3.towerify.io'
    The line 4 of contents of file towerify-config-file should eq 'towerify_login=my_login3'
    The line 5 of contents of file towerify-config-file should eq 'towerify_password=MyP@ssw0rD3'
  End

  It "should use parameters for domain, login and password and store to my_profile"
#    debug=1
    jenkins_is_accessible() {
      true
    }

    When run towerify_configure 'my-corp4.towerify.io' 'my_login4' 'MyP@ssw0rD4' 'my_profile'
#    Dump
    The line 4 of output should include 'Towerify CLI est correctement configuré'
    The line 4 of output should include 'instance Towerify my-corp4.towerify.io'
    The path towerify-config-file should be file
    The line 1 of contents of file towerify-config-file should eq '[my_profile]'
    The line 2 of contents of file towerify-config-file should eq 'jenkins_domain=jenkins.my-corp4.towerify.io'
    The line 3 of contents of file towerify-config-file should eq 'towerify_domain=my-corp4.towerify.io'
    The line 4 of contents of file towerify-config-file should eq 'towerify_login=my_login4'
    The line 5 of contents of file towerify-config-file should eq 'towerify_password=MyP@ssw0rD4'
  End
End
