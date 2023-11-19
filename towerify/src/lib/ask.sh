ask_password() {
  read -s -p "(Par sécurité, les caractères que vous tapez ne s'afficheront pas à l'écran)
> " answer
  echo $answer
}

ask_string() {
  default=${1:-}
  read -e -p "> " -i "${default}" answer
  echo $answer
}

ask_choices() {
  choices=("$@")
  choices_count=${#choices[@]}

  [[ $choices_count -eq 0 ]] && echo "$(red_bold "${BASH_SOURCE[1]} line ${BASH_LINENO[0]}: ${FUNCNAME[0]}() need at least a choice as first argument")" >&2 && exit 1

  [[ $choices_count -ge 10 ]] && echo "$(red_bold "${BASH_SOURCE[1]} line ${BASH_LINENO[0]}: ${FUNCNAME[0]}() accept a maximum of 9 arguments")" >&2 && exit 1

  PS3='Votre choix : '
  select opt in "${choices[@]}"
  do
      case $REPLY in
          [1-$choices_count])
              echo "$opt"
              break
              ;;
          *) ;;
      esac
  done
}
