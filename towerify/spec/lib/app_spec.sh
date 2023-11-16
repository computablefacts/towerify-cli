Describe 'app.sh'
  Include src/lib/common.sh
  Include src/lib/colors.sh
  Include src/lib/app.sh

  delete_tarignore() {
    if [[ -e '.tarignore' ]]; then
      rm '.tarignore'
    fi
  }
  create_tarignore() {
    echo './spec' > .tarignore
  }


  Describe 'app_compress'

    Describe 'without .tarignore'
      Before 'delete_tarignore'

      It 'should create the app.tar.gz archive'

        When call app_compress
        The file 'app.tar.gz' should be file
      End
    End


    Describe 'with .tarignore'
      Before 'create_tarignore'
      After 'delete_tarignore'

      It 'should ignore files list in .tarignore'
        
        list_files() {
          tar -tf app.tar.gz  
        }

        When call app_compress
        The function list_file should not include './spec/'
      End
    End
  End
End
