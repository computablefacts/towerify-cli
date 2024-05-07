set_debug() {
  debug=$1
}

# Paramétrage
set_debug ${args[--debug]:-0}
[[ $debug -eq 1 ]] && inspect_args

towerify_configure "${args[--domain]:-ask}" "${args[--login]:-ask}" "${args[--password]:-ask}" "${args[--profile]:-default}"
