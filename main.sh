#!/usr/bin/env bash

. lib/util.sh
eval "`include_once field.sh`"
eval "`include_once draw.sh`"

# Player coords. Initial coords are guaranted to be valid and not inside the wall

declare -g px=1
declare -g py=1

# Player direction

declare -g pd=right

function try_move_player_to() {
    if ! isinteger $1 || ! isinteger $2; then
        print_ferror "arguments must be integers"
        return 1
    fi
    if [ $1 -lt 0 -o $2 -lt 0 -o $1 -ge $field_width -o $1 -ge $field_height ]; then
        return 1
    fi
    local field_idx=`get_field_idx $1 $2`
    if [ ${field[$field_idx]} == '#' ]; then
        return 1
    else
        px=$1
        py=$2
        pd=$3
        return 0
    fi
}

function move_player() {
    case $1 in
    up)
        try_move_player_to $px $(( $py - 1 )) $1
        ;;
    down)
        try_move_player_to $px $(( $py + 1 )) $1
        ;;
    left)
        try_move_player_to $(( $px - 1 )) $py $1
        ;;
    right)
        try_move_player_to $(( $px + 1 )) $py $1
        ;;
    *)
        return 1
        ;;
    esac
}

while true; do
    clear
    draw_field_with_player
    draw_controls
    read -sN 1 key
    case $key in
    q)
        exit 0
        ;;
    w)
        move_player up
        ;;
    a)
        move_player left
        ;;
    d)
        move_player right
        ;;
    s)
        move_player down
        ;;
    *)
        continue
    esac
done
