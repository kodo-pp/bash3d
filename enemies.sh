#!/usr/bin/env false
# DO NOT RUN THIS SCRIPT DIRECTLY, INCLUDE IT USING 'source SCRIPTNAME'

. lib/util.sh

eval "`include_once field.sh`"

# TODO: randomize
declare -ag enemies_x=(8 18 21 7 19 22 6 14 27)
declare -ag enemies_y=(28 1 18 29 2 16 28 3 16)
declare -ag enemies_d=(up down up right down down up left up)
declare -g  enemies_count=9

function try_move_enemy_to() {
    if ! isinteger $1 || ! isinteger $2; then
        print_ferror "arguments must be integers"
        return 1
    fi
    if [ $1 -lt 0 -o $2 -lt 0 -o $1 -ge $field_width -o $2 -ge $field_height ]; then
        return 1
    fi
    local field_idx=`get_field_idx $1 $2`
    if [ ${field[$field_idx]} == '#' ]; then
        return 1
    else
        local ex=${enemies_x[$4]}
        local ey=${enemies_y[$4]}
        echo -ne "\e[$(($ey + 2));$((2 * $ex + 2))H "
        enemies_x[$4]=$1
        enemies_y[$4]=$2
        enemies_d[$4]=$3
        return 0
    fi
}

function get_random_direction() {
    case $(( $RANDOM % 4 )) in
    0)
        echo right
        ;;
    1)
        echo left
        ;;
    2)
        echo up
        ;;
    3)
        echo down
        ;;
    esac
}

function hits_enemy() {
    for (( i = 0; i < enemies_count; ++i )); do
        if [ ${enemies_x[$i]} == $1 -a ${enemies_y[$i]} == $2 ]; then
            echo $i
            return
        fi
    done
}

function move_enemy() {
    ex=${enemies_x[$1]}
    ey=${enemies_y[$1]}
    ed=${enemies_d[$1]}
    case $ed in
    up)
        try_move_enemy_to $ex $(( $ey - 1 )) $ed $1
        ;;
    down)
        try_move_enemy_to $ex $(( $ey + 1 )) $ed $1
        ;;
    left)
        try_move_enemy_to $(( $ex - 1 )) $ey $ed $1
        ;;
    right)
        try_move_enemy_to $(( $ex + 1 )) $ey $ed $1
        ;;
    *)
        return 1
        ;;
    esac
}

function move_enemies() {
    local chance=30
    for (( i=0; $i<$enemies_count; ++i )); do
        local ddx=$((${enemies_x[$i]} - $px))
        local ddy=$((${enemies_y[$i]} - $py))
        local qdist=$(( ($ddx) * ($ddx) + ($ddy) * ($ddy) ))
        if [ $qdist -le 36 ]; then
            if [ $(( $RANDOM % 2 )) == 1 ]; then
                if [ ${enemies_x[$i]} -lt $px ]; then
                    enemies_d[$i]=right
                else
                    enemies_d[$i]=left
                fi
            else
                if [ ${enemies_y[$i]} -lt $py ]; then
                    enemies_d[$i]=down
                else
                    enemies_d[$i]=up
                fi
            fi
        fi

        if [ ${enemies_x[$i]} == $px ]; then
            if [ ${enemies_y[$i]} -lt $py ]; then
                enemies_d[$i]=down
            else
                enemies_d[$i]=up
            fi
        elif [ ${enemies_y[$i]} == $py ]; then
            if [ ${enemies_x[$i]} -lt $px ]; then
                enemies_d[$i]=right
            else
                enemies_d[$i]=left
            fi
        elif [ $(( $RANDOM % 100 )) -lt $chance ]; then
            enemies_d[$i]=`get_random_direction`
        fi

        if [ $(( $RANDOM % 100 )) -lt 80 ]; then
            move_enemy $i
        fi

        if [ ${enemies_x[$i]} == $px -a ${enemies_y[$i]} == $py ]; then
            player_hit
        fi
    done
}
