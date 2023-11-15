display_question() {
  echo "$(bold "? $1 ?")"
}

debug_output() {
  [[ $debug -eq 1 ]] && echo -e "$(cyan "${2:-}[DEBUG] ${FUNCNAME[1]}() ${1:-}")" 1>&2
}