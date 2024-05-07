# Paramétrage
set_debug ${args[--debug]:-0}
[[ $g_debug -eq 1 ]] && inspect_args
force=${args[--force]:-0}

towerify_update $force
