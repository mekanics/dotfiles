# Pipe my public key to my clipboard.
alias pubkey="more ~/.ssh/id_rsa.pub | pbcopy | echo '=> Public key copied to pasteboard.'"

### FIX El Capitan rights
alias fixElCapitan="sudo chown -R $(whoami):admin /usr/local"

alias cat='bat'
alias ping='prettyping --nolegend'
