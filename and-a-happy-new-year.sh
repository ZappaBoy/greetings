#!/usr/bin/env sh

FIREWORK_CHAR="|"
MAX_FIREWORKS_TO_DISPLAY=3
FIREWORKS_SIZE=(15 25 35)
SPAWN_FIREWORK_PROBABILITY=10
SLEEPING_TIME=0.3
OWNER="ZappaBoy"

SPAWN="SPAWN"
UP="UP"

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
. "$script_dir/utils.sh"

check_dependencies

fireworks_status=("$SPAWN")
# Fireworks path are structured as "x_coordinate:y_coordinate"
fireworks_paths=()
loop() {
    # Checking columns and lines inside the loop allow the "resizable" behavior
    columns=$(get_columns)
    lines=$(get_lines)

    # if [ $fireworks_on_display -lt $MAX_FIREWORKS_TO_DISPLAY ]; then
    #     random_probability=$(get_random 0 100)
    #     if [ "$random_probability" -le $SPAWN_FIREWORK_PROBABILITY ]; then
    #         fireworks_on_display=$((fireworks_on_display + 1))
    #     fi
    # fi

    i=0
    for status in "${fireworks_status[@]}"; do

        case $status in
            "$SPAWN")
                random_spawn=$(get_random 0 "$columns")
                fireworks_paths+=([i]="$random_spawn:$lines" "${fireworks_path[@]:i}")
                fireworks_status+=([i]="$UP" "${fireworks_status[@]:i}")
                ;;
            "$UP")
                path="${fireworks_path[i]}"
                coordinates=(${path//:/ })
                #echo "${coordinates[0]}" "${coordinates[1]}"
                new_coordinates="${coordinates[0]}:$((coordinates[1] - 1))"
                fireworks_paths+=([i]="$new_coordinates" "${fireworks_path[@]:i}")
                ;;
        esac
        i=$((i + 1))
    done

    clear
    tput cup $((lines / 5)) 0
    figlet -c -k -w "$columns" "Happy new year by $OWNER"
    tput cup 0 0

    length=${#fireworks_paths[@]}

    for ((i = 0; i < length; i++)); do
        path="${fireworks_paths[i]}"
        coordinates=(${path//:/ })
        x_position=${coordinates[0]}
        y_position=${coordinates[1]}

        # Print snowflake only if x (column value) is positive
        if [ "$x_position" -gt 0 ]; then
            # Set cursor position
            tput cup "${y_position}" "${x_position}"
            printf %s "$FIREWORK_CHAR"
        fi
    done

}

while : ; do
    loop
    sleep $SLEEPING_TIME
done
