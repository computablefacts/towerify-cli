download_towerify() {
  install_dir=$1

  tempdirname=$(mktemp -d)
  curl --progress-bar https://cli.towerify.io/towerify.tar.gz | tar -zx -C $tempdirname

  # Update templates
  rm -Rf $install_dir/templates
  mkdir -p $install_dir/templates
  cp -R $tempdirname/templates/* $install_dir/templates

  # Update towerify (CLI)
  rm $install_dir/towerify
  cp $tempdirname/towerify $install_dir/towerify

  rm -Rf $tempdirname
}

available_version_is_newer() {
  local new_version="$1"

  # Découper les versions en parties avec le point comme séparateur
  IFS='.' read -ra new_version_parts <<< "$new_version"
  IFS='.' read -ra version_parts <<< "$version"

  # Déterminer le plus grand nombre de parties
  local length_max=${#new_version_parts[@]}
  if [ ${#version_parts[@]} -gt $length_max ]; then
      length_max=${#version_parts[@]}
  fi

  for ((i = 0; i < length_max; i++)); do
      # Traiter les parties manquantes comme des zéros
      local new_version_part=${new_version_parts[i]:-0}
      local version_part=${version_parts[i]:-0}

      if [ "$new_version_part" -lt "$version_part" ]; then
          # new_version est inférieure à version
          return 1
      elif [ "$new_version_part" -gt "$version_part" ]; then
          # new_version est supérieure à version
          return 0
      fi
  done

  # Les versions sont égales
  return 1
}

towerify_update() {
  force=${1:-0}

  install_dir=$HOME/.towerify

  if [[ $force -eq 0 ]]; then
    # Check version to decide if we need to update
    new_version=$(curl -s -L https://cli.towerify.io/version.txt)
    debug_output "version=$version"
    debug_output "new_version=$new_version"

    if ! available_version_is_newer $new_version; then
      echo "$(green_bold "Vous avez la version la plus récente (${version})")"
      echo
      echo "Vous pouvez tout de même forcer la mise à jour avec la commande :"
      echo "  $(bold "towerify update --force")"
      exit 1
    fi

    echo "$(bold "Mise à jour de Towerify CLI vers la version ${new_version}...")"
  else
    echo "$(bold "Mise à jour forcée de Towerify CLI pour la version ${version}...")"
  fi

  download_towerify $install_dir
  echo "$(bold "Terminé.")"
  echo
  echo "Si vous voulez ajouter la complétion à votre bash, utilisez :"
  echo "  $(bold "eval \"\$(towerify completions)\"")"
  echo

}
