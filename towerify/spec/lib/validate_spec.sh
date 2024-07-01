Describe 'validate.sh'
  Include src/lib/validate.sh
  Include src/lib/config.sh
  Include src/lib/ini.sh
  Include src/lib/colors.sh

  Describe 'validate_key_value'
    Describe 'valid'
      Parameters
        'x=a'
        'MY_KEY=myvalue'
        'MY_KEY="my value"'
        '_key=value'
        'key='
      End

      It "should succeed with '$1'"

        When call validate_key_value "$1"
        The output should be blank
      End
    End

    Describe 'contain = sign'
      Parameters
        'a'
        'xxx'
      End

      It "should fail with '$1'"

        When call validate_key_value "$1"
        The output should include 'doit contenir un signe ='
      End
    End

    Describe 'empty key'
      Parameters
        '=a'
        '='
        '="my value"'
      End

      It "should fail with '$1'"

        When call validate_key_value "$1"
        The output should include 'la clé ne doit pas être vide'
      End
    End

    Describe 'key starts with [a-zA-Z_]'
      Parameters
        '0_key=a'
        '%key=a'
      End

      It "should fail with '$1'"

        When call validate_key_value "$1"
        The output should include 'la clé doit commencer par un de ces caractères [a-zA-Z_]'
      End
    End

    Describe 'key with [a-zA-Z0-9_] chars'
      Parameters
        'e%d=a'
        'e$d=a'
      End

      It "should fail with '$1'"

        When call validate_key_value "$1"
        The output should include 'la clé ne doit contenir que les caractères [a-zA-Z0-9_]'
      End
    End
  End

  Describe 'validate_key'
    Describe 'valid'
      Parameters
        'x'
        'MY_KEY'
        '_key'
      End

      It "should succeed with '$1'"

        When call validate_key "$1"
        The output should be blank
      End
    End

    Describe 'invalid'
      Parameters
        'x=a'
        '0_MY_KEY'
        'MY%KEY'
        '_k$ey'
      End

      It "should fail with '$1'"

        When call validate_key "$1"
        The output should include 'la clé ne doit contenir que les caractères [a-zA-Z_][a-zA-Z0-9_]*'
      End
    End
  End

  Describe 'validate_profile'
    Describe 'valid'
      Parameters
        'x'
        'AWS-02'
        'xyz-02'
        'abcdefghif1234567890123456789012'
      End

      It "should succeed with '$1'"

        When call validate_profile "$1"
        The output should be blank
      End
    End

    Describe 'invalid first char'
      Parameters
        ''
        '-profile'
        '_pro'
        '3-AWS'
      End

      It "should fail with '$1'"

        When call validate_profile "$1"
        The output should include 'le profil doit commencer par un de ces caractères [a-zA-Z]'
      End
    End

    Describe 'invalid chars'
      Parameters
        'a_xyz'
        'a=34'
        'a_pro'
        'a-AWS_'
      End

      It "should fail with '$1'"

        When call validate_profile "$1"
        The output should include 'le profil ne doit contenir que les caractères [a-zA-Z0-9-]'
      End
    End

    Describe 'too long'
      Parameters
        'abcdefghif12345678901234567890123'
      End

      It "should fail with '$1'"

        When call validate_profile "$1"
        The output should include 'le profil doit avoir 32 caractères maximum'
      End
    End
  End

  Describe 'validate_profile_should_exist'
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

    add_towerify_profile() {
      echo "[${1-default}]" > $CONFIG_FILE
      echo 'jenkins_domain=jenkins.my-corp2.towerify.io' >> $CONFIG_FILE
      echo 'towerify_domain=my-corp2.towerify.io' >> $CONFIG_FILE
      echo 'towerify_login=my_login2' >> $CONFIG_FILE
      echo 'towerify_password=MyP@ssw0rD2' >> $CONFIG_FILE
    }

    Describe 'valid'
      Parameters
        'x'
        'AWS-02'
        'xyz-02'
        'abcdefghif1234567890123456789012'
      End

      It "should succeed with '$1'"

        add_towerify_profile $1

        When call validate_profile_should_exist "$1"
        The output should be blank
      End
    End

    Describe 'profile does not exist'

      It "should fail for my-profile profil"

        When call validate_profile_should_exist "my-profile"
        # Dump
        The output should include "le profil my-profile n'existe pas"
        The output should include "Vous pouvez configurer ce profil avec"
        The output should include "towerify configure --profile my-profile"
      End
    End

  End

  Describe 'validate_app_name'
    Describe 'valid'
      Parameters
        'x'
        'AWS-02'
        'xyz-02'
        'abcdefghif1234567890123456789012'
      End

      It "should succeed with '$1'"

        When call validate_app_name "$1"
        The output should be blank
      End
    End

    Describe 'invalid first char'
      Parameters
        ''
        '-profile'
        '_pro'
        '3-AWS'
      End

      It "should fail with '$1'"

        When call validate_app_name "$1"
        The output should include "le nom de l'application doit commencer par un de ces caractères [a-zA-Z]"
      End
    End

    Describe 'invalid chars'
      Parameters
        'a_xyz'
        'a=34'
        'a_pro'
        'a-AWS_'
      End

      It "should fail with '$1'"

        When call validate_app_name "$1"
        The output should include "le nom de l'application ne doit contenir que les caractères [a-zA-Z0-9-]"
      End
    End

    Describe 'too long'
      Parameters
        'abcdefghif12345678901234567890123'
      End

      It "should fail with '$1'"

        When call validate_app_name "$1"
        The output should include "le nom de l'application doit avoir 32 caractères maximum"
      End
    End
  End

  # env will be use to make the app URL/domain so it should
  # respect the RFC-1035 for preferred name syntax
  # See: https://www.rfc-editor.org/rfc/rfc1035.html#section-2.3.1
  # So: 63 characters max, starting with a letter and contain only letters, digits and hyphen (`-`) and should not ending by an hyphen
  # Here we prefer to limit size to 32 chars max because the whole domain is limited to 253 chars max.
  # And we prefer using only lowercase letters
  Describe 'validate_env'
    Describe 'valid'
      Parameters
        'x'
        'xyz-02'
        'abcdefghif1234567890123456789012'
      End

      It "should succeed with '$1'"

        When call validate_env "$1"
        The output should be blank
      End
    End

    Describe 'invalid first char'
      Parameters
        ''
        '-profile'
        '_pro'
        '3-AWS'
      End

      It "should fail with '$1'"

        When call validate_env "$1"
        The output should include "le nom de l'environnement doit commencer par une lettre minuscule"
      End
    End

    Describe 'invalid chars'
      Parameters
        'a_xyz'
        'a=34'
        'a_pro'
        'a-AWS_'
        'aBcDe'
      End

      It "should fail with '$1'"

        When call validate_env "$1"
        The output should include "le nom de l'environnement ne doit contenir que les caractères [a-z0-9-]"
      End
    End

    Describe 'too long'
      Parameters
        'abcdefghif12345678901234567890123'
      End

      It "should fail with '$1'"

        When call validate_env "$1"
        The output should include "le nom de l'environnement doit avoir 32 caractères maximum"
      End
    End

    Describe 'no hyphen at the end'
      Parameters
        'a-'
        'xyz-02-'
        'abcdefghif123456789012345678901-'
      End

      It "should fail with '$1'"

        When call validate_env "$1"
        The output should include "le nom de l'environnement ne doit pas se terminer par un tiret"
      End
    End
  End
End
