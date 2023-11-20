declare -g app_config_dir="./towerify"
declare -g app_config_file="config.yaml"
declare -g template_dir="./templates"

# Bug in config.sh line 96 (config_loaded : variable sans liaison)
declare -g config_loaded=false
