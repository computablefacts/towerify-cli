Describe 'jenkins.sh'
  Include src/lib/jenkins.sh
  Include src/lib/common.sh
  #Include src/lib/globals.sh

  config_get() {
    if [[ "$1" = "jenkins_domain" ]]; then
      echo 'my.jenkins.domain'
    elif [[ "$1" = "towerify_login" ]]; then
      echo "login"
    else
      echo 'error: wrong key'
    fi
  }

  Describe 'is_json_valid()'

    It 'should return true (=0) when valid'

      When call is_json_valid '{"_class":"hudson.model.User","absoluteUrl":"https://jenkins.myapps.addapps.io/user/cfadmin","description":null,"fullName":"CF Admin","id":"cfadmin","property":[{"_class":"jenkins.security.ApiTokenProperty"},{"_class":"com.cloudbees.plugins.credentials.UserCredentialsProvider$UserCredentialsProperty"},{"_class":"hudson.plugins.emailext.watching.EmailExtWatchAction$UserProperty","triggers":[]},{"_class":"hudson.model.MyViewsProperty"},{"_class":"org.jenkinsci.plugins.displayurlapi.user.PreferredProviderUserProperty"},{"_class":"hudson.model.PaneStatusProperties"},{"_class":"jenkins.security.seed.UserSeedProperty"},{"_class":"hudson.search.UserSearchProperty","insensitiveSearch":true},{"_class":"hudson.model.TimeZoneProperty"},{"_class":"jenkins.model.experimentalflags.UserExperimentalFlagsProperty"},{"_class":"hudson.tasks.Mailer$UserProperty","address":"cfadmin@myapps.addapps.io"},{"_class":"hudson.plugins.favorite.user.FavoriteUserProperty"}]}'
      The status should eq 0
    End

    It 'should return false (!=0) when invalid'

      When call is_json_valid '{"key": alue"}'
      The status should not eq 0
    End
  End

  Describe 'jenkins_base_url()'

    It 'should return the Jenkins URL'

      When call jenkins_base_url
      The output should eq 'https://my.jenkins.domain/'
    End
  End

  Describe 'jenkins_is_accessible()'

    It 'should return true if Jenkins answers'
      jenkins_api() {
        echo '{"id": "login"}'
      }

      When call jenkins_is_accessible
      The status should eq 0
    End

    It 'should return false if Jenkins does NOT answer'
      jenkins_api() {
        echo '{"id": "an_other_user"}'
      }

      When call jenkins_is_accessible
      The status should eq 1
    End
  End
End
