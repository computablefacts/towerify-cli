Describe 'request.sh'
  Include src/lib/request.sh
  Include src/lib/common.sh

  fake_request_info() {
    declare -g request_last_info='{"content_type":"application/json","http_code":200,"method":"GET","time_total":0.148026,"url":"https://dummy.mydomain.org/page"}'
  }

  Describe 'request_get_last_content_type'
    Before 'fake_request_info'

    It 'should return content type'

      When call request_get_last_content_type
#      Dump
      The output should eq "application/json"
    End
  End

  Describe 'request_get_last_http_status'
    Before 'fake_request_info'

    It 'should return HTTP status'

      When call request_get_last_http_status
#      Dump
      The output should eq 200
    End
  End

  Describe 'request_get_last_method'
    Before 'fake_request_info'

    It 'should return HTTP method'

      When call request_get_last_method
#      Dump
      The output should eq "GET"
    End
  End

  Describe 'request_get_last_time_total'
    Before 'fake_request_info'

    It 'should return total time'

      When call request_get_last_time_total
#      Dump
      The output should eq 0.148026
    End
  End

  Describe 'request_get_last_url'
    Before 'fake_request_info'

    It 'should return url'

      When call request_get_last_url
#      Dump
      The output should eq "https://dummy.mydomain.org/page"
    End
  End

  Describe 'request_make'

    It 'should store result and info'

      When call request_make "https://jsonplaceholder.typicode.com/todos/2"
#      Dump
      The length of variable request_last_result should not eq 0
      The length of variable request_last_info should not eq 0
      The result of function request_get_last_url should eq "https://jsonplaceholder.typicode.com/todos/2"
      The result of function request_get_last_http_status should eq 200
      The result of function request_get_last_content_type should eq "application/json; charset=utf-8"
      The result of function request_get_last_result should include "quis ut nam facilis et officia qui"
    End

    It 'should work for 404 Not Found url'

      When call request_make "https://jsonplaceholder.typicode.com/todos/250"
#      Dump
      The length of variable request_last_result should not eq 0
      The length of variable request_last_info should not eq 0
      The result of function request_get_last_url should eq "https://jsonplaceholder.typicode.com/todos/250"
      The result of function request_get_last_http_status should eq 404
    End

  End

End
