#!/usr/bin/env bash

. lib/util.sh
eval "`include_once field.sh`"
eval "`include_once draw.sh`"
eval "`include_once enemies.sh`"

pts=0
cyc=1
las=0

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
    aplay hit.rawsound &>/dev/null &
    (( --ph ))
    if [ $ph -le 0 ]; then
        echo -en "\e[$(($field_height + 6));0H\e[1;31m"
        toilet 'You died!'
        echo -en "\e[0m"
        echo "Result: you died"
        echo "Points: $pts"
        echo "Cycles: $cyc"
        echo "Accurracy: $(if [ $las -gt 0 ]; then echo | awk "{print $pts * 100 / $las}" | xargs printf '%.2f%%\n'; else echo '<...>'; fi)"
        echo "Avg. pt. earn: $(echo | awk "{print $pts * 10000 / $cyc}" | xargs printf '%.2f\n')"
        echo "Press Enter to exit"
        read -s
        stty echo
        echo -e "\e[?25h"
        exit 0
    fi
}

function shoot_player() {
    aplay wallbuster.rawsound &>/dev/null &
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
    sleep 0.5
    clear
    draw_field_with_player
}

function shoot_player_grow() {
    aplay wallbuster.rawsound &>/dev/null &
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
                field[`get_field_idx $xx $yy`]='#'
                if [ $xx == $px -a $yy == $py ]; then
                    player_hit
                    player_hit
                    player_hit
                fi
            fi
            sleep 0.01
        done
    done
    field[`get_field_idx $x $y`]='#'
    sleep 0.5
    clear
    draw_field_with_player
}

function shoot_player_laser() {
    (( ++las ))
    aplay laser.rawsound &>/dev/null &
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
            (( x -= $dx ))
            (( j -= $dy ))
            break
        fi
        local field_idx=`get_field_idx $x $y`
        if [ ${field[$field_idx]} == '#' ]; then
            (( x -= $dx ))
            (( j -= $dy ))
            break
        fi
        if [ $x -ne $px -o $y -ne $py ]; then
            echo -ne "\e[$(($y+2));$(($x*2 + 2))H"
            echo -ne '\e[1;31m'
            enm=`hits_enemy $x $y`
            if ! [ -z "$enm" ]; then
                (( ++pts ))
                enemies_x[$enm]=$(( $RANDOM % $field_width ))
                enemies_y[$enm]=$(( $RANDOM % $field_height ))
                case $pd in
                    up|down)
                        echo -n '$'
                        ;;
                    left|right)
                        echo -n '$-'
                        ;;
                esac
            else
                case $pd in
                    up|down)
                        echo -n '|'
                        ;;
                    left|right)
                        echo -n '--'
                        ;;
                esac
            fi
            echo -ne '\e[0m'
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

    sleep 0.5
    clear
    draw_field_with_player
}

trap 'echo -e "\e[?25h"; stty echo; exit 127' SIGINT # TODO: НЕ РАБОТАЕТ!!!!!!

stty -echo
echo -e '\e[?25l' # Hide cursor
clear
draw_field_with_player
while true; do
    if [ $(( $RANDOM % 3 )) == 0 ]; then
        wx=$(( $RANDOM % $field_width ))
        wy=$(( $RANDOM % $field_height ))
        fii=`get_field_idx $wx $wy`
        field[$fii]='#'
        echo -ne "\e[$(($wy+2));$(($wx*2 + 2))H"
        echo -ne '\e[0;1m# \e[0m'
    fi

    if [ $(( $cyc % 20 )) == 0 ]; then
        enemies_x[$enemies_count]=$(( $RANDOM % $field_width ))
        enemies_y[$enemies_count]=$(( $RANDOM % $field_height ))
        enemies_d[$enemies_count]=up
        (( ++enemies_count ))
    fi

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
                echo "Result: you gave up"
                echo "Points: $pts"
                echo "Cycles: $cyc"
                echo "Accurracy: $(if [ $las -gt 0 ]; then echo | awk "{print $pts * 100 / $las}" | xargs printf '%.2f%%\n'; else echo '<...>'; fi)"
                echo "Avg. pt. earn: $(echo | awk "{print $pts * 10000 / $cyc}" | xargs printf '%.2f\n')"
                exit 0
                ;;
        esac
        stty -echo
        echo -e '\e[?25l' # Hide cursor
        clear
        draw_field_with_player
        ;;
    z)
        (( ++cyc ))
        true
        ;;
    w)
        (( ++cyc ))
        move_player up
        ;;
    a)
        (( ++cyc ))
        move_player left
        ;;
    d)
        (( ++cyc ))
        move_player right
        ;;
    s)
        (( ++cyc ))
        move_player down
        ;;
    e)
        (( ++cyc ))
        shoot_player
        ;;
    f)
        (( ++cyc ))
        shoot_player_grow
        ;;
    r)
        (( ++cyc ))
        shoot_player_laser
        ;;
    *)
        continue
    esac
    move_enemies
done
