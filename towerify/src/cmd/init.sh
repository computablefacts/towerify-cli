# Paramétrage
set_debug ${args[--debug]:-0}
[[ $g_debug -eq 1 ]] && inspect_args
name=${args[name]:-ask}
type=${args[type]:-ask}
force=${args[--force]:-0}

towerify_init $name $type $force
