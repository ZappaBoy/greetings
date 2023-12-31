#!/usr/bin/env bash

NO_COLOR='\033[0m'
YELLOW='\033[1;33m'
FIREWORK_CHAR="¡"
FIREWORK_EXPLODE_CHAR="✨"
MAX_FIREWORKS_RADIUS=3
SPAWN_FIREWORK_PROBABILITY=30
FIREWORK_EXPLODE_PROBABILITY=7
SLEEPING_TIME=0.1
OWNER="ZappaBoy"

SPAWN="SPAWN"
UP="UP"
EXPLODE="EXPLODE"

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
. "$script_dir/utils.sh"

check_dependencies

print_char(){
    printf "${YELLOW}${1}${NO_COLOR}"
}

fireworks_status=("$SPAWN" "$SPAWN" "$SPAWN")
# Fireworks path are structured as "x_coordinate:y_coordinate:explosion_radius"
# "explosion_radius" is available only when the firework is in "EXPLODE" state

min_firework_size=$((MAX_FIREWORKS_RADIUS * 3))

fireworks_paths=()
loop() {
    # Checking columns and lines inside the loop allow the "resizable" behavior
    columns=$(get_columns)
    lines=$(get_lines)

    max_fireworks_to_display=$((lines / 5))
    max_firework_size=$((lines - MAX_FIREWORKS_RADIUS - 2))

    fireworks_on_display="${#fireworks_status[@]}"

    if [[ "$fireworks_on_display" -eq 0 || "$fireworks_on_display" -lt $max_fireworks_to_display ]]; then
        random_probability=$(get_random 0 100)
        if [ "$random_probability" -le $SPAWN_FIREWORK_PROBABILITY ]; then
            fireworks_on_display=$((fireworks_on_display + 1))
            fireworks_status+=("$SPAWN")
        fi
    fi

    for ((i = 0; i < fireworks_on_display; i++)); do
        status="${fireworks_status[i]}"
        path="${fireworks_paths[i]}"
        coordinates=(${path//:/ })
        x_coordinate="${coordinates[0]}"
        y_coordinate="${coordinates[1]}"
        explode_radius="${coordinates[2]}"

        firework_size=$((lines - y_coordinate))
        if [[ $status != "$EXPLODE" && -n $y_coordinate && "$firework_size" -gt "$min_firework_size" ]]; then

            if [ $firework_size -gt $max_firework_size ]; then
                random_probability=0
            else
                random_probability=$(get_random 0 100)
            fi

            if [ "$random_probability" -lt $FIREWORK_EXPLODE_PROBABILITY ]; then
                status=$EXPLODE
                fireworks_status[i]="$status"
                explode_radius=0
            fi
        fi
        
        case $status in
            "$SPAWN")
                random_spawn=$(get_random "$((MAX_FIREWORKS_RADIUS + 2))" "$((columns - MAX_FIREWORKS_RADIUS - 2))")
                fireworks_paths[i]="$random_spawn:$lines"
                fireworks_status[i]="$UP"
                ;;
            "$UP")
                new_coordinates="$x_coordinate:$((y_coordinate - 1))"
                fireworks_paths[i]="$new_coordinates"
                ;;
            "$EXPLODE")
                if [ "$explode_radius" -ge $MAX_FIREWORKS_RADIUS ]; then
                    # This may seem weird but it is required to achive an iterable array data structure in bash
                    unset "fireworks_status[$i]"
                    unset "fireworks_paths[$i]"
                    fireworks_status=( "${fireworks_status[@]}" )
                    fireworks_paths=( "${fireworks_paths[@]}" )
                else
                    new_coordinates="$x_coordinate:$y_coordinate:$((explode_radius + 1))"
                    fireworks_paths[i]="$new_coordinates"
                    path="${fireworks_paths[i]}"
                    coordinates=(${path//:/ })
                    x_position=${coordinates[0]}
                    y_position=${coordinates[1]}
                    explode_radius=${coordinates[2]}
                fi
                ;;
        esac
    done

    clear
    tput cup $((lines / 5)) 0
    figlet -c -k -w "$columns" "Happy new year by $OWNER"
    tput cup 0 0

    length="${#fireworks_paths[@]}"

    for ((i = 0; i < length; i++)); do
        path="${fireworks_paths[i]}"
        coordinates=(${path//:/ })
        x_position=${coordinates[0]}
        y_position=${coordinates[1]}
        explode_radius=${coordinates[2]}

        char="$FIREWORK_CHAR"

        if [[ -n $explode_radius ]]; then
            char="$FIREWORK_EXPLODE_CHAR"

            for radius in $( seq 0 "$explode_radius") ; do
                tput cup "$((y_position + radius))" "$((x_position))"
                print_char "$char"
                tput cup "$((y_position + radius))" "$((x_position + radius))"
                print_char "$char"
                tput cup "$((y_position))" "$((x_position + radius))"
                print_char "$char"
                tput cup "$((y_position - radius))" "$((x_position + radius))"
                print_char "$char"
                tput cup "$((y_position - radius))" "$((x_position))"
                print_char "$char"
                tput cup "$((y_position - radius))" "$((x_position - radius))"
                print_char "$char"
                tput cup "$((y_position))" "$((x_position - radius))"
                print_char "$char"
                tput cup "$((y_position + radius))" "$((x_position - radius))"
                print_char "$char"
            done
        fi

        # Print snowflake only if x (column value) is positive
        if [[ -n "$x_position" && "$x_position" -gt 0 ]]; then
            # Set cursor position
            tput cup "$y_position" "$x_position"
            print_char "$char"
        fi
    done

    tput cup 0 0
}

while : ; do
    loop
    sleep $SLEEPING_TIME
done
