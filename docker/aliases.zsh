# Docker Shell
docker-sh() {
    # Lists Docker containers and starts a command (sh by default) in the selected one
    local command="${1:-sh}"
    local containers="$(docker ps | nl -v 0 -w 1)"
    echo -e "Running containers:\n$containers"
    echo -ne "\nSelect: "
    local number
    read number
    ((number++))
    local container="$(sed -n "${number}p" <<<"$containers" | awk '{ print $2 }')"
    echo -e "\nRunning command \"$command\" in container $container ...\n"
    docker exec -it "$container" "$command"
}
