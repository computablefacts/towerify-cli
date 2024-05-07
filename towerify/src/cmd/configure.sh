# Paramétrage
set_debug ${args[--debug]:-0}
set_profile ${args[--profile]:-default}
[[ $g_debug -eq 1 ]] && inspect_args

towerify_configure "${args[--domain]:-ask}" "${args[--login]:-ask}" "${args[--password]:-ask}"
