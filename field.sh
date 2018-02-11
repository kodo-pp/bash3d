#!/usr/bin/env false
# DO NOT RUN THIS SCRIPT DIRECTLY, INCLUDE IT USING 'source SCRIPTNAME'

. lib/util.sh

__include_list["field.sh"]=1

eval "`include_once lib/math.sh`"

declare -gr FIELD_INCLUDED=1

# --- Functions ---

function get_field_idx() {
    if [ -z "$1" -o -z "$2" ] || ! isinteger "$1" || ! isinteger "$2"; then
        print_ferror "arguments must be integers"
        return 1
    fi
    if [ $1 -lt 0 -o $2 -lt 0 -o $1 -ge $field_width -o $2 -ge $field_height ]; then
        print_ferror "arguments must be in range [0; width_or_height)"
        return 1
    fi
    echo "$(($1 + $2 * $field_width))"
    return 0
}


# --- Field preparation ---

# Human-readable format
#_field="
## # # # # # # # # #
## . . . . . . . . #
## . . # # . . # . #
## . . . . . . . . #
## . # # # . . # . #
## . # # . . . . . #
## . . # . . . . . #
## . . . . # . . . #
## . . . # # . . . #
## # # # # # # # # #"

# One-dimensional array. Point (x; y) is field[$(( $x + $y * $field_width ))]
declare -ag field

# Some constants
declare -gr field_width=30
declare -gr field_height=30
declare -gr field_len=$(($field_width * $field_height))

for (( i=0; $i < $field_len; ++i )); do
    if [ $(( $RANDOM % 1000 )) -lt 230 ]; then
        field[$i]='#'
    else
        field[$i]='.'
    fi
done



# Clean up
unset idx
unset _field
