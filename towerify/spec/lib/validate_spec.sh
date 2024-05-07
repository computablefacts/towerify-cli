Describe 'validate.sh'
  Include src/lib/validate.sh

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
End
