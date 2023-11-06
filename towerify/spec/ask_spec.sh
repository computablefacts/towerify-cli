Describe 'ask.sh'
  Include src/lib/ask.sh

  Describe 'ask_password'

    It 'return typed password'
      Data
        #| mypassword
      End
      When call ask_password
      The output should equal 'mypassword'
    End
  End

  Describe 'ask_string'

    It 'return typed string'
      Data
        #| mystring
      End
      When call ask_string
      The output should equal 'mystring'
    End
  End

  Describe 'ask_choices'

    It 'return choosen item'
      Data
        #|2
      End
      When call ask_choices 'static' 'lamp' 'lemp'
      The line 1 of stderr should eq '1) static'
      The line 2 of stderr should eq '2) lamp'
      The line 3 of stderr should eq '3) lemp'
      The line 4 of stderr should eq 'Votre choix : '
      The output should equal 'lamp'
    End

    It 'return first item'
      Data
        #|1
      End
      When call ask_choices 'static' 'lamp' 'lemp'
      The stderr should be present
      The output should equal 'static'
    End

    It 'return last item'
      Data
        #|3
      End
      When call ask_choices 'static' 'lamp' 'lemp'
      The stderr should be present
      The output should equal 'lemp'
    End

    Describe 'Failures'
      Include src/lib/colors.sh

      It 'fail if no choices'
        
        When run ask_choices
        The status should eq 1
        The stderr should include 'ask_choices() need at least a choice as first argument'
      End

      It 'fail if more than 9 choices'

        When run ask_choices '1' '2' '3' '4' '5' '6' '7' '8' '9' '10'
        The status should eq 1
        The stderr should include 'ask_choices() accept a maximum of 9 arguments'
      End
    End
  End
End
