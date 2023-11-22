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
