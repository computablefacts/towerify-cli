Describe 'available_version_is_newer'
  Include src/lib/update_func.sh


  Describe 'compare'

    Parameters
      '2' '1'
      '2.1' '1'
      '2.2.1' '1'

      '2' '1.0'
      '2.0' '1.0'
      '2.0.0' '1.0'
      '1.0.1' '1.0'
      '1.1' '1.0'
      '2.0' '1.5'
      '1.6' '1.5'
      '1.6.8' '1.5'

      '2' '1.2.3'
      '4' '1.2.3'
      '1.3' '1.2.3'
      '2.0' '1.2.3'
      '2.5' '1.2.3'
      '1.2.4' '1.2.3'
      '1.2.12' '1.2.3'
      '1.3.0' '1.2.3'
      '2.0.0' '1.2.3'

      '1' '0.0.1'
      '1.1' '0.0.1'
      '1.1.1' '0.0.1'
    End

    It "'$1' is newer than '$2'"
      
      declare -g version=$2

      When call available_version_is_newer "$1"
#      Dump
      The status should eq 0
    End

    It "'$2' is older than '$1'"
      
      declare -g version=$1

      When call available_version_is_newer "$2"
#      Dump
      The status should eq 1
    End

    It "'$1' is egal to '$1'"
      
      declare -g version=$1

      When call available_version_is_newer "$1"
#      Dump
      The status should eq 1
    End
  End

End
