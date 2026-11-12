export NVS_HOME="$HOME/.nvs"
[ -s "$NVS_HOME/nvs.sh" ] && . "$NVS_HOME/nvs.sh"

nvs auto on
nvs use

# EXTRA CA CERTS
export NODE_EXTRA_CA_CERTS="$HOME/.certs/mekanics-ca.crt"