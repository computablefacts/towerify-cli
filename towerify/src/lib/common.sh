display_question() {
  echo "$(bold "? $1 ?")"
}

debug_output() {
  if [[ $debug -eq 1 ]]; then
    echo -e "$(cyan "${2:-}[DEBUG] ${FUNCNAME[1]}() ${1:-}")" 1>&2
  fi
}