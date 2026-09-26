# Pipe my public key to my clipboard.
alias pubkey="more ~/.ssh/id_rsa.pub | pbcopy | echo '=> Public key copied to pasteboard.'"

### FIX El Capitan rights
alias fixElCapitan="sudo chown -R $(whoami):admin /usr/local"

alias cat='bat'
alias ping='prettyping --nolegend'
alias rsyncp="rsync -az --info=progress2"

## FIX iCloud Sync
alias fixiCloud="killall bird"

## Get my WAN IP
alias wanip="dig @resolver4.opendns.com myip.opendns.com +short"

## Edit mz Finances
alias finance="code ~/Finance"
alias dotfiles="cursor ~/.dotfiles"

alias jsontidy="pbpaste | jq '.' | pbcopy"

## Convenience
alias dev="cd ~/Development"
alias homelab="cursor ~/Development/private/homelab/homelab.code-workspace"
alias spuhl="cursor ~/Development/j2y/originate/SpuehlSoftware/recipe-management-webapp.code-workspace"