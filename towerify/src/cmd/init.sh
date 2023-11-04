# Paramétrage
debug=${args[--debug]:-0}
name=${args[name]:-ask}
type=${args[type]:-ask}

# Debug arguments
[[ $debug = 1 ]] && inspect_args

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


echo "$(green_bold "Application $name initialisée")"
echo
echo "Pour déployer cette application, utilisez :"
echo "  $(bold "towerify deploy")"
echo
