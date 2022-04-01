export NVS_HOME="$HOME/.nvs"
[ -s "$NVS_HOME/nvs.sh" ] && . "$NVS_HOME/nvs.sh"

nvs auto on
nvs use

# Disable next telemetry
export NEXT_TELEMETRY_DISABLED=1
