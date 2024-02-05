display_question() {
  echo "$(bold "? $1 ?")"
}

debug_output() {
  if [[ $debug -eq 1 ]]; then
    echo -e "$(cyan "${2:-}[DEBUG] ${FUNCNAME[1]}() ${1:-}")" 1>&2
  fi
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
