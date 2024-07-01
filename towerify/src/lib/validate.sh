validate_key_value() {
  if [[ ! "$1" =~ ^.*=.* ]]; then
    echo "doit contenir un signe ="
  elif [[ "$1" =~ ^=.* ]]; then
    echo "la clé ne doit pas être vide"
  elif [[ ! "$1" =~ ^[a-zA-Z_].* ]]; then
    echo "la clé doit commencer par un de ces caractères [a-zA-Z_]"
  elif [[ ! "$1" =~ ^[a-zA-Z0-9_][a-zA-Z0-9_]*=.* ]]; then
    echo "la clé ne doit contenir que les caractères [a-zA-Z0-9_]"
  fi
}

validate_key() {
  [[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || echo "la clé ne doit contenir que les caractères [a-zA-Z_][a-zA-Z0-9_]*"
}

validate_profile() {
  if [[ ! "$1" =~ ^[a-zA-Z].* ]]; then
    echo "le profil doit commencer par un de ces caractères [a-zA-Z]"
  elif [[ ! "$1" =~ ^[a-zA-Z][a-zA-Z0-9-]*$ ]]; then
    echo "le profil ne doit contenir que les caractères [a-zA-Z0-9-]"
  elif [[ "${#1}" -gt 32 ]]; then
    echo "le profil doit avoir 32 caractères maximum"
  fi
}

validate_app_name() {
  if [[ ! "$1" =~ ^[a-zA-Z].* ]]; then
    echo "le nom de l'application doit commencer par un de ces caractères [a-zA-Z]"
  elif [[ ! "$1" =~ ^[a-zA-Z][a-zA-Z0-9-]*$ ]]; then
    echo "le nom de l'application ne doit contenir que les caractères [a-zA-Z0-9-]"
  elif [[ "${#1}" -gt 32 ]]; then
    echo "le nom de l'application doit avoir 32 caractères maximum"
  fi
}

validate_env() {
  if [[ ! "$1" =~ ^[a-z].* ]]; then
    echo "le nom de l'environnement doit commencer par un de ces caractères [a-z]"
  elif [[ ! "$1" =~ ^[a-z][a-z0-9-]*$ ]]; then
    echo "le nom de l'environnement ne doit contenir que les caractères [a-z0-9-]"
  elif [[ "$1" =~ ^.*-$ ]]; then
    echo "le nom de l'environnement ne doit pas se terminer par un tiret"
  elif [[ "${#1}" -gt 32 ]]; then
    echo "le nom de l'environnement doit avoir 32 caractères maximum"
  fi
}
