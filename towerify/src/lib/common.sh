display_question() {
  echo "$(bold "? $1 ?")"
}

set_debug() {
  g_debug=$1
}

debug_output() {
  if [[ $g_debug -eq 1 ]]; then
    echo -e "$(cyan "${2:-}[DEBUG] ${FUNCNAME[1]}() ${1:-}")" 1>&2
  fi
}

set_profile() {
  declare -g g_profile=$1

  read_profile_settings
}

read_profile_settings() {
  debug_output "CONFIG_FILE=$CONFIG_FILE"
  
  declare -g towerify_domain=$(config_get "${g_profile}.towerify_domain" "not_found")
  declare -g jenkins_domain=$(config_get "${g_profile}.jenkins_domain" "not_found")
  declare -g towerify_login=$(config_get "${g_profile}.towerify_login" "not_found")
  declare -g towerify_password=$(config_get "${g_profile}.towerify_password" "not_found")

  debug_output "towerify_domain=${towerify_domain}"
  debug_output "jenkins_domain=${jenkins_domain}"
  debug_output "towerify_login=${towerify_login}"
  debug_output "towerify_password=${towerify_password}"
}

display_progress() {
  local screen_nb_cols=$(($(tput cols) - 2))
  local nb_points=$(($screen_nb_cols - ${#progress_title} - ${#progress_status} - 4))

  printf "%s" "${progress_title} " >&2
  printf "%0.s." $(seq 1 $nb_points) >&2
  printf "%s\r" " [$($progress_color "${progress_status}")]" >&2
}

progress_start() {
  declare -g progress_title=${1}
  declare -g progress_status=${2:-??}
  declare -g progress_color=${3:-blue}

  display_progress
}

progress_change_title() {
  declare -g progress_title=${1}

  display_progress
}

progress_update() {
  declare -g progress_status=${1:-??}
  declare -g progress_color=${2:-blue}

  display_progress
}

progress_stop() {
  progress_update "$1" "$2"
  echo
  
  declare -g progress_title="Call progress_start first"
}
