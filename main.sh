#!/usr/bin/env bash

. lib/util.sh
eval "`include_once field.sh`"
eval "`include_once draw.sh`"
eval "`include_once enemies.sh`"

# Player coords

declare -g px=1
declare -g py=1

# Player direction

declare -g pd=right

# Player HP

declare -g ph=10

function try_move_player_to() {
    if ! isinteger $1 || ! isinteger $2; then
        print_ferror "arguments must be integers"
        return 1
    fi
    if [ $1 -lt 0 ] || [ $2 -lt 0 ] || [ $1 -ge $field_width ] || [ $2 -ge $field_height ]; then
        return 1
    fi
    local field_idx=`get_field_idx $1 $2`
    if [ ${field[$field_idx]} == '#' ]; then
        return 1
    else
        echo -ne "\e[$(($py + 2));$((2 * $px + 2))H "
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

function player_hit() {
    (( --ph ))
    if [ $ph -le 0 ]; then
        echo -en "\e[$(($field_height + 6));0H\e[1;31m"
        toilet 'You died!'
        echo -en "\e[0m"
        echo "Press Enter to exit"
        read -s
        stty echo
        echo -e "\e[?25h"
        exit 0
    fi
}

function shoot_player() {
    local dx=0
    local dy=0
    case $pd in
        up)
            dy=-1
            ;;
        down)
            dy=1
            ;;
        right)
            dx=1
            ;;
        left)
            dx=-1
            ;;
    esac
    local x=$px
    local y=$py
    while true; do
        if [ $x -lt 0 -o $y -lt 0 -o $x -ge $field_width -o $y -ge $field_height ]; then
            (( x -= $dx * 2 ))
            (( j -= $dy * 2 ))
            break
        fi
        if [ $x -ne $px -o $y -ne $py ]; then
            echo -ne "\e[$(($y+2));$(($x*2 + 2))H"
            echo -ne '\e[1;33m**\e[0m'
        fi
        local field_idx=`get_field_idx $x $y`
        if [ ${field[$field_idx]} == '#' ]; then
            break
        fi
        (( x += $dx ))
        (( y += $dy ))
    done

    if [ $x -lt 0 ]; then
        x=0
    elif [ $x -ge $field_width ]; then
        x=$(($field_width - 1))
    fi

    if [ $y -lt 0 ]; then
        y=0
    elif [ $y -ge $field_height ]; then
        y=$(($field_height - 1))
    fi

    for i in 0 1 2; do
        for j in 0 1 2; do
            xx=$(($x+$i-1))
            yy=$(($y+$j-1))
            if ! [ $xx -lt 0 -o $yy -lt 0 -o $xx -ge $field_width -o $yy -ge $field_height ]; then
                echo -ne "\e[$(($yy+2));$(($xx*2 + 2))H"
                echo -ne '\e[1;43;31mxx\e[0m'
                field[`get_field_idx $xx $yy`]='.'
                if [ $xx == $px -a $yy == $py ]; then
                    player_hit
                    player_hit
                    player_hit
                fi
            fi
            sleep 0.01
        done
    done
    field[`get_field_idx $x $y`]='.'
    sleep 1
    clear
    draw_field_with_player
}

trap 'echo -e "\e[?25h"; stty echo; exit 127' SIGINT # TODO: НЕ РАБОТАЕТ!!!!!!

stty -echo
echo -e '\e[?25l' # Hide cursor
clear
draw_field_with_player
while true; do
    draw_player
    draw_enemies
    draw_controls
    read -sN 1 key
    case $key in
    q)
        echo
        echo "Really quit? [y/N]: "
        stty echo
        echo -ne '\e[?25h' # Show cursor
        read ans
        case $ans in
            y|yes)
                exit 0
                ;;
        esac
        stty -echo
        echo -e '\e[?25l' # Hide cursor
        clear
        draw_field_with_player
        ;;
    z)
        true
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
    e)
        shoot_player
        ;;
    *)
        continue
    esac
    move_enemies
done
