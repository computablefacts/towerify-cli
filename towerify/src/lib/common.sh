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
  
  declare -g g_towerify_domain=$(config_get "${g_profile}.towerify_domain" "")
  declare -g g_jenkins_domain=$(config_get "${g_profile}.jenkins_domain" "not_found")
  declare -g g_towerify_login=$(config_get "${g_profile}.towerify_login" "")
  declare -g g_towerify_password=$(config_get "${g_profile}.towerify_password" "not_found")

  debug_output "g_towerify_domain=${g_towerify_domain}"
  debug_output "g_jenkins_domain=${g_jenkins_domain}"
  debug_output "g_towerify_login=${g_towerify_login}"
  debug_output "g_towerify_password=${g_towerify_password}"
}

display_progress() {
  local min_interval=30 # Interval minimum en secondes
  local eol
  local screen_nb_cols

  if [ -t 0 ]; then
    # Nous sommes dans un terminal, afficher avec retour à la ligne (\r)
    eol='\r'
    screen_nb_cols=$(tput cols)
  else
    # Nous ne sommes pas dans un terminal, limiter les affichages et afficher avec saut de ligne (\n)
    current_time=$(date +%s)
    if (( current_time - progress_last_display_time < min_interval )); then
      return
    fi
    progress_last_display_time=$current_time
    eol='\n'
    screen_nb_cols=80
  fi

  screen_nb_cols=$((screen_nb_cols - 2)) # ajuster pour les espaces de début et de fin
  local nb_points=$(($screen_nb_cols - ${#progress_title} - ${#progress_status} - 4))

  printf "%s" "${progress_title} " >&2
  printf "%0.s." $(seq 1 $nb_points) >&2
  printf "%s${eol}" " [$($progress_color "${progress_status}")]" >&2
}

progress_start() {
  declare -g progress_title=${1}
  declare -g progress_status=${2:-??}
  declare -g progress_color=${3:-blue}
  declare -g progress_last_display_time=0

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
  declare -g progress_status=${1:-??}
  declare -g progress_color=${2:-blue}
  declare -g progress_last_display_time=0

  display_progress
  echo

  declare -g progress_title="Call progress_start first"
}
