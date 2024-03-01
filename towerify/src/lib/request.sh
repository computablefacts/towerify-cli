declare -g request_last_result=""
declare -g request_last_info=""

request_make() {
  url=${1}
  verb=${2:-GET}
  extra_curl_parameters=${3:-}

  curl_cmd="${curl_cli:-curl} -X ${verb} -w "\\n---curlInfo---\\n%{json}" -s -L ${extra_curl_parameters} ${url}"
  debug_output "curl_cmd=${curl_cmd}"
  curl_result=$(${curl_cmd})

  request_last_result=$(echo "$curl_result" | awk '/---curlInfo---/{exit} { print }')
  request_last_info=$(echo "$curl_result" | awk '/---curlInfo---/{flag=1;next} flag')

  echo "${request_last_result}"
}

request_get_last_result() {
  echo "${request_last_result}"
}

request_get_last_content_type() {
  echo $request_last_info | jq -r '.content_type'
}

request_get_last_http_status() {
  echo $request_last_info | jq -r '.http_code'
}

request_get_last_method() {
  echo $request_last_info | jq -r '.method'
}

request_get_last_time_total() {
  echo $request_last_info | jq -r '.time_total'
}

request_get_last_url() {
  echo $request_last_info | jq -r '.url'
}


