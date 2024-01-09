set_debug() {
  debug=$1
}

# Paramétrage
set_debug ${args[--debug]:-0}
[[ $debug -eq 1 ]] && inspect_args
domain=${args[domain]:-ask}
login=${args[login]:-ask}
password=${args[password]:-ask}
profile=${args[profile]:-default}

towerify_configure
 