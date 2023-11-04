# Paramétrage
debug=${args[--debug]:-0}
name=${args[name]:-ask}
type=${args[type]:-ask}
force=${args[--force]:-0}

# Debug arguments
[[ $debug -eq 1 ]] && inspect_args

# Check if app config file already exists (only if --force is not used)
if [[ $force -eq 0 ]]; then
  filter_error=$(filter_app_config_should_not_exist)
  if [[ -n $filter_error ]]; then
    echo "$filter_error" >&2
    exit 1
  fi
fi

# Ask for name if needed
if [[ "$name" = "ask" ]]; then
  display_question "Quel est le nom de votre application"
  name=$(ask_string)
  echo
fi

[[ $debug = 1 ]] && echo "name=$name"

# Ask for type if needed
if [[ "$type" = "ask" ]]; then
  display_question "Choissisez un type d'application"
  type=$(ask_choices "static" "lamp")
  echo
fi

[[ $debug = 1 ]] && echo "type=$type"

# Write app config file
echo "name: $name" > $app_config_file
echo "type: $type" >> $app_config_file

# Success
echo "$(green_bold "Application $name initialisée")"
echo
echo "Pour déployer cette application, utilisez :"
echo "  $(bold "towerify deploy")"
echo
