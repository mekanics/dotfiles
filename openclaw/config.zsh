openclaw() {
    (cd "$HOME/openclaw" && docker compose run --rm openclaw-cli "$@")
}