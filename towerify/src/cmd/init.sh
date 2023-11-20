# Paramétrage
debug=${args[--debug]:-0}
name=${args[name]:-ask}
type=${args[type]:-ask}
force=${args[--force]:-0}

# Debug arguments
[[ $debug -eq 1 ]] && inspect_args

towerify_init $name $type $force
