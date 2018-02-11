#!/usr/bin/env false
# DO NOT RUN THIS SCRIPT DIRECTLY, INCLUDE IT USING 'source SCRIPTNAME'

. lib/util.sh

__include_list["math.sh"]=1

function isinteger() {
    (! [ -z "$1" ]) && [[ $1 =~ ^-?[0-9]+$ ]]
    return $?
}
