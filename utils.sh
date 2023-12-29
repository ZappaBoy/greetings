#!/usr/bin/env bash

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT
ctrl_c() {
    clear
    exit
}

get_columns() {
    echo $(tput cols)
}

get_lines() {
    echo $(tput lines)
}

get_random(){
    min_value=${1:-0}
    max_value=${2:-100}
    echo $(( ( RANDOM % max_value ) + min_value ))
}

check_dependencies(){
    dependencies=("figlet")

    for dependency in "${dependencies[@]}"; do
        if ! command -v "$dependency" &> /dev/null; then
            echo "$dependency could not be found. Please install it and try again."
            exit 1
        fi
    done
}
