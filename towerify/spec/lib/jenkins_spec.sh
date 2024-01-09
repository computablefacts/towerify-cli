Describe 'jenkins.sh'
  Include src/lib/jenkins.sh
  Include src/lib/common.sh
  Include src/lib/colors.sh

  declare -g template_dir="../conf/templates"
  declare -g jenkins_domain='my.jenkins.domain'
  declare -g towerify_login=my_login

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
      #Dump
      The output should eq 'https://my.jenkins.domain/'
    End
  End

  Describe 'jenkins_is_accessible()'
    test_it() {
      #debug=1
      if jenkins_is_accessible; then
        echo "true"
      else
        echo "false"
      fi
    }

    It 'should be true if Jenkins answers'
      jenkins_api() {
        echo '{"id": "my_login"}'
      }

      When call test_it
      The output should eq true
    End

    It 'should be false if Jenkins does NOT answer'
      jenkins_api() {
        echo '{"id": "an_other_user"}'
      }

      When call test_it
      The output should eq false
    End
  End

  Describe 'jenkins_check_job_exists()'
    test_it() {
      #debug=1
      if jenkins_check_job_exists "my_job"; then
        echo "true"
      else
        echo "false"
      fi
    }

    It 'should be true if the job exists'
      jenkins_api() {
        echo '{"jobs": [{"name": "my_job"}, {"name": "job2"}, {"name": "job3"}]}'
      }

      When call test_it
      The output should eq true
    End

    It 'should be false if the job does NOT exist'
      jenkins_api() {
        echo '{"jobs": [{"name": "job1"}, {"name": "job2"}, {"name": "job3"}]}'
      }

      When call test_it
      The output should eq false
    End
  End

  Describe 'jenkins_create_job()'
    Parameters
      'static'
      'laravel-10'
    End

    test_it() {
      #debug=1
      if jenkins_create_job "my_job" ${1}; then
        echo "true"
      else
        echo "false"
      fi
    }

    It "should be true if the job is created ($1)"
      jenkins_api() {
        return 0
      }

      When call test_it "$1"
      The output should eq true
    End

    It "should be false if the job is NOT created ($1)"
      jenkins_api() {
        return 1
      }

      When call test_it "$1"
      The output should eq false
    End

    It 'should be false if the job template is NOT found'
      jenkins_api() {
        return 0
      }

      When call test_it "unknown"
      The output should eq false
      The error should include "Modèle de pipeline non trouvé"
    End
  End
End
