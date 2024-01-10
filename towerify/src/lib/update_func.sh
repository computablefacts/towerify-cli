download_towerify() {
  install_dir=$1

  tempdirname=$(mktemp -d)
  curl --progress-bar https://acme.towerify.io/cli/towerify.tar.gz | tar -zx -C $tempdirname

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
  new_version=$1

  dpkg --compare-versions $new_version gt $version
}

towerify_update() {
  force=${1:-0}

  install_dir=$HOME/.towerify

  if [[ $force -eq 0 ]]; then
    # Check version to decide if we need to update
    new_version=$(curl -s -L https://acme.towerify.io/cli/version.txt)
    debug_output "version=$version"
    debug_output "new_version=$new_version"

    if ! available_version_is_newer $new_version; then
      echo "$(green_bold "Vous avez la version la plus récente (${version})")"
      echo
      echo "Vous pouvez tout de même forcer la mise à jour avec la commande :"
      echo "  $(bold "towerify update --force")"
      exit 1
    fi
  fi

  echo "$(bold "Mise à jour de Towerify CLI...")"
  download_towerify $install_dir
  echo "$(bold "Terminé.")"

}
