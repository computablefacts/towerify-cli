display_question() {
  echo "$(bold "? $1 ?")"
}

debug_output() {
  if [[ $debug -eq 1 ]]; then
    echo -e "$(cyan "${2:-}[DEBUG] ${FUNCNAME[1]}() ${1:-}")" 1>&2
  fi
}

display_progress() {
  local title=${1:-}
  local progress=${2:-??}
  local progress_color=${3:-echo}

  local screen_nb_cols=$(($(tput cols) - 2))
  local nb_points=$(($screen_nb_cols - ${#title} - ${#progress} - 2))

  printf "%s" "${title}"
  printf "%0.s." $(seq 1 $nb_points)
  printf "%s\r" "[$($progress_color "${progress}")]"
}
