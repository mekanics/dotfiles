export NVS_HOME="$HOME/.nvs"
[ -s "$NVS_HOME/nvs.sh" ] && . "$NVS_HOME/nvs.sh"

nvs auto on
nvs use

# Disable telemetry
export NEXT_TELEMETRY_DISABLED=1     # next
export STORYBOOK_DISABLE_TELEMETRY=1 # storybook
export FASTLANE_OPT_OUT_USAGE=1      # fastlane
export SST_TELEMETRY_DISABLED=1      # sst

# EXTRA CA CERTS
export NODE_EXTRA_CA_CERTS="$HOME/.certs/mekanics-ca.crt"