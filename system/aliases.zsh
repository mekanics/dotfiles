# Pipe my public key to my clipboard.
alias pubkey="more ~/.ssh/id_rsa.pub | pbcopy | echo '=> Public key copied to pasteboard.'"

### FIX El Capitan rights
alias fixElCapitan="sudo chown -R $(whoami):admin /usr/local"

alias cat='bat'
alias ping='prettyping --nolegend'

## FIX iCloud Sync
alias fixiCloud="killall bird"

## Get my WAN IP
alias wanip="dig @resolver4.opendns.com myip.opendns.com +short"
