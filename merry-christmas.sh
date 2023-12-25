#!/usr/bin/env sh

SNOWFLAKE_CHAR="❄"
MAX_SNOWFLAKE_PER_LINE=6
SNOWFLAKES_OFFSETS=2
SLEEPING_TIME=0.3

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

columns=$(get_columns)
lines=$(get_lines)

snowflakes_x=()
snowflakes_y=()

loop() {
    random_snowflake_number=$(get_random 0 $MAX_SNOWFLAKE_PER_LINE)
    #echo $random_snowflake_number

    # Move the snowflakes to right or left
    updated_x_positions=()
    for x in "${snowflakes_x[@]}"; do
        offset=$(get_random 0 $SNOWFLAKES_OFFSETS)
        negative_offset=$(get_random 0 2)
        if [ "$negative_offset" -eq 1 ]; then
            offset=$((-$offset))
        fi
        new_x_position=$((x + $offset))
        updated_x_positions+=($new_x_position)
    done
    snowflakes_x=("${updated_x_positions[@]}")

    # Move the snowflakes down
    updated_y_positions=()
    i=0
    for y in "${snowflakes_y[@]}"; do
        new_y_position=$((y + 1))
        # Remove y greater than lines number
        if [ "$new_y_position" -gt "$((lines))" ]; then
            # Simply remove x position
            snowflakes_x=("${snowflakes_x[@]:0:$((i-1))}" "${snowflakes_x[@]:$((i))}")
        else
            updated_y_positions+=("$new_y_position")
            i=$((i + 1))
        fi
    done

    snowflakes_y=("${updated_y_positions[@]}")

    # Add new snowflakes
    for snowflake in $(seq 1 "$random_snowflake_number"); do
        random_x=$(get_random 0 "$columns")
        snowflakes_x=("$random_x" "${snowflakes_x[@]}")
        snowflakes_y=("0" "${snowflakes_y[@]}")
    done

    # Print all snowflakes
    # Snowflakes positions arrays has the same length
    length=${#snowflakes_x[@]}
    clear

    for ((i = 0; i < length; i++)); do
        x_position=${snowflakes_x[$i]}
        y_position=${snowflakes_y[$i]}
        # Print snowflake only if x (column value) is positive
        if [ "$x_position" -gt 0 ]; then
            # Set cursor position
            tput cup "${y_position}" "${x_position}"
            #echo -n $SNOWFLAKE_CHAR
            printf %s $SNOWFLAKE_CHAR
        fi
    done

    tput cup 0 0
}

while : ; do
    loop
    sleep $SLEEPING_TIME
done
