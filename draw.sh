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

function _draw_field() {
    # Fast version, does not parse coords every time

    # Player
    local player_idx=`get_field_idx $px $py`

    for (( i=0; i<field_len; ++i )); do
        if [ $(( $i % $field_width )) == 0 ] && [ $i -ne 0 ]; then
            echo
        fi
        if [ "$1" == "-p" -a "$i" == "$player_idx" ]; then
            put_player
        else
            echo -n "${field[$i]} "
        fi
    done
    echo
}

function draw_controls() {
    echo "[w], [a], [s], [d] - move"
    echo "[q] - quit"
}
