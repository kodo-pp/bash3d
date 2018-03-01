#!/usr/bin/env false
# DO NOT RUN THIS SCRIPT DIRECTLY, INCLUDE IT USING 'source SCRIPTNAME'

if [ "$__UTIL_SH_INCLUDED" != "1" -o "$__FORCE_REINCLUDE" == "1" ]; then
    declare -g __UTIL_SH_INCLUDED="1"

    declare -Ag __include_list

    function included() {
        ! ([ -z "$1" ] || [ "${__include_list[$1]}" != "1" ])
        return $?
    }

    # Use like:
    # eval "`include_once FILENAME`"
    function include_once() {
        if ! [ -z "$1" ] && ! included "$1"; then
            echo '. "'"$1"'"'
        fi
    }

    function print_ferror() {
        (
            echo -ne "\e[$(($field_height + 3));0H\e[0;31m"
            echo "Error: $@"
            echo "Backtrace:"
            #for (( i=0; $i<${#FUNCNAME}; ++i )); do
            #    echo "  $i: At ${FUNCNAME[$i]} (${BASH_SOURCE[$i+1]}:${BASH_LINENO[$i]})" >&2
            #done

            local cnt=2
            for i in "${FUNCNAME[@]}"; do
                case $cnt in
                0)
                    echo "  Called from $i()"
                    ;;
                1)
                    cnt=0
                    echo "  At $i()"
                    ;;
                2)
                    cnt=1
                    ;;
                esac
            done
            echo
        ) >&2
        stty echo
        # exit 1 # Does not work
        kill $$
    }
fi
