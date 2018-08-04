#!/bin/bash

source ./simple_curses.sh

export AWK_CRYPTO_DIR=`dirname $0`
AWK_PRG="gawk -i "${AWK_CRYPTO_DIR}/array.awk" -i "${AWK_CRYPTO_DIR}/commons.awk" -i "${AWK_CRYPTO_DIR}/help.awk" -i "${AWK_CRYPTO_DIR}/io.awk" -i "${AWK_CRYPTO_DIR}/log.awk" -i "${AWK_CRYPTO_DIR}/maths.awk" -i "${AWK_CRYPTO_DIR}/parser.awk"  -i "${AWK_CRYPTO_DIR}/string.awk" -f "${AWK_CRYPTO_DIR}/main.awk" -- "

    #echo `$AWK_PRG 1`

main (){
    window "Bitcoin charts" "red"
    append_tabbed "symbol@currency@bid@ask@latest_trade@high@low@avg@close@weighted_price@duration@volume@currency_volume\t" 13 "@"
    addsep
    append
    append_tabbed "`$AWK_PRG`" 13 "@"

    endwin 
}
main_loop 60
