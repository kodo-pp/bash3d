#!/usr/bin/env false
# DO NOT RUN THIS SCRIPT DIRECTLY, INCLUDE IT USING 'source SCRIPTNAME'

. lib/util.sh

__include_list["draw.sh"]=1

function draw_field() {
    _draw_field
    return $?
}

function draw_field_with_player() {
    _draw_field -p
    return $?
}

function put_player() {
    echo -ne '\e[1;32m'
    case $pd in
    up)
        echo -n '^'
        ;;
    down)
        echo -n 'v'
        ;;
    left)
        echo -n '<'
        ;;
    right)
        echo -n '>'
        ;;
    default)
        echo -n '@'
        ;;
    esac
    echo -ne ' \e[0m'
}

function put_enemy() {
    local ex=${enemies_x[$1]}
    local ey=${enemies_y[$1]}

    echo -ne "\e[$(($ey+2));$(($ex*2 + 2))H"
    echo -ne '\e[1;31m@ \e[0m'
}

function put_field() {
    if [ "${field[$1]}" == "#" ]; then
        echo -ne "\e[1m#\e[0m "
    else
        echo -n "  "
    fi
    return 0
}

function draw_enemies() {
    for (( i=0; $i<$enemies_count; ++i )) {
        put_enemy $i
    }
    echo -ne '\e[40;0H'
}

function _draw_field() {
    # Fast version, does not parse coords every time

    # Player
    local player_idx=`get_field_idx $px $py`

    for (( i=0; $i<$((2*$field_width + 2)); ++i )); do
        echo -n '#'
    done
    echo
    echo -n '#'
    for (( i=0; $i<$field_len; ++i )); do
        if [ $(( $i % $field_width )) == 0 ] && [ $i -ne 0 ]; then
            echo -ne '#\n#'
        fi
        if [ "$1" == "-p" -a "$i" == "$player_idx" ]; then
            put_player
        else
            put_field $i
        fi
    done
    echo -e "\e[$(($field_height + 1));$((2 * $field_width + 2))H#"
    for (( i=0; $i<$((2*$field_width + 2)); ++i )); do
        echo -n '#'
    done
    echo
}

function draw_player() {
    echo -ne "\e[$(($py + 2));$((2 * $px + 2))H"
    put_player
}

function put_hp() {
    echo -n 'HP: '
    for (( i=0; $i<$ph; ++i )); do
        echo -ne '\e[1;31m\u2589\e[0m'
    done
    for (( i=$ph; $i<10; ++i )); do
        echo -ne '\e[37m\u2589\e[0m'
    done
}

function draw_controls() {
    echo -ne "\e[$(($field_height + 3));0H"
    echo "[w], [a], [s], [d] - move"
    echo "[z] - idle"
    echo "[e] - shoot (be careful!)"
    echo "[q] - quit"
    put_hp
}
