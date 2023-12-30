#!/usr/bin/env bash

FIREWORK_CHAR="|"
FIREWORK_EXPLODE_CHAR="✨"
MAX_FIREWORKS_TO_DISPLAY=8
MAX_FIREWORKS_RADIUS=5
FIREWORKS_SIZE=(15 20 25)
SPAWN_FIREWORK_PROBABILITY=10
FIREWORK_EXPLODE_PROBABILITY=40
SLEEPING_TIME=0.3
OWNER="ZappaBoy"

SPAWN="SPAWN"
UP="UP"
EXPLODE="EXPLODE"

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
. "$script_dir/utils.sh"

check_dependencies

fireworks_status=("$SPAWN" "$SPAWN" "$SPAWN")
# Fireworks path are structured as "x_coordinate:y_coordinate"
fireworks_paths=()
loop() {
    # Checking columns and lines inside the loop allow the "resizable" behavior
    columns=$(get_columns)
    lines=$(get_lines)
    fireworks_on_display="${#fireworks_status[@]}"

    if [[ "$fireworks_on_display" -eq 0 || "$fireworks_on_display" -lt $MAX_FIREWORKS_TO_DISPLAY ]]; then
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
        if [[ $status != "$EXPLODE" && -n $y_coordinate && "${FIREWORKS_SIZE[*]}" =~ "$firework_size" ]]; then

            if [[ $firework_size -lt "${FIREWORKS_SIZE[0]}" ]]; then
                random_probability=0
            elif [[ $firework_size -ge "${FIREWORKS_SIZE[-1]}" ]]; then
                random_probability=100
            else
                random_probability=$(get_random 0 100)
                random_probability=$((100-random_probability))
            fi

            if [ "$random_probability" -gt "$FIREWORK_EXPLODE_PROBABILITY" ]; then
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
                printf %s "$char"
                tput cup "$((y_position + radius))" "$((x_position + radius))"
                printf %s "$char"
                tput cup "$((y_position))" "$((x_position + radius))"
                printf %s "$char"
                tput cup "$((y_position - radius))" "$((x_position + radius))"
                printf %s "$char"
                tput cup "$((y_position - radius))" "$((x_position))"
                printf %s "$char"
                tput cup "$((y_position - radius))" "$((x_position - radius))"
                printf %s "$char"
                tput cup "$((y_position))" "$((x_position - radius))"
                printf %s "$char"
                tput cup "$((y_position + radius))" "$((x_position - radius))"
                printf %s "$char"
            done
        fi

        # Print snowflake only if x (column value) is positive
        if [[ -n "$x_position" && "$x_position" -gt 0 ]]; then
            # Set cursor position
            tput cup "$y_position" "$x_position"
            printf %s "$char"
        fi
    done

    tput cup 0 0
}

while : ; do
    loop
    sleep $SLEEPING_TIME
done
