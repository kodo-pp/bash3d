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
_field="
# # # # # # # # # #
# . . . . . . . . #
# . . # # . . # . #
# . . . . . . . . #
# . # # # . . # . #
# . # # . . . . . #
# . . # . . . . . #
# . . . . # . . . #
# . . . # # . . . #
# # # # # # # # # #"

# Some constants
declare -gr field_width=10
declare -gr field_height=10
declare -gr field_len=$(($field_width * $field_height))

# One-dimensional array. Point (x; y) is field[$(( $x + $y * $field_width ))]
declare -ag field

# Transform data from human-readable format to one-dimensional array
idx=0
for i in $_field; do
    field[$idx]=$i
    (( ++idx ))
done

# Clean up
unset idx
unset _field
