#! /usr/bin/gawk -f

@include "help.awk"
@include "./array.awk"
@include "./commons.awk"
@include "./io.awk"
@include "./log.awk"
@include "./maths.awk"
@include "./parser.awk"
@include "./string.awk"


# TODO delete array to prevent exists values
function initMain() {
    initAnsiCode()
}


BEGIN {
    # TODO put these lines into an init function
    PREC="oct"
    CONVFMT="%.5g"

    ExitCode = 0

    pos = 0
    noargc = 0

    initMain()

    while(ARGV[++pos]) {

        ## Information options

        # -V, -version
        match(ARGV[pos], /^--?(V|vers(i(on?)?)?)$/)
        if (RSTART) {
            InfoOnly = "version"
            continue
        }

        # -H, -help
        match(ARGV[pos], /^--?(H|h(e(lp?)?)?)$/)
        if (RSTART) {
            InfoOnly = "help"
            continue
        }

        # -U, -upgrade
        match(ARGV[pos], /^--?(U|upgrade)$/)
        if (RSTART) {
            InfoOnly = "upgrade"
            continue
        }

        # non-option argument
        noargv[noargc++] = ARGV[pos]

    }


    ## Info only session

    switch (InfoOnly) {
        case "version":
            print getVersion()
            exit ExitCode
        case "help":
            print getHelp()
            exit ExitCode
        case "upgrade":
            upgrade()
            exit ExitCode
    }

    json = curl("http://api.bitcoincharts.com/v1/markets.json")
    tokenize(tokens, json)
    parseJson(ast, tokens)
    pseudoArrToMArr(ast, mast)
    asort(mast[0], market, "compare_record")
    print getMarket(market)

}

function eval(value) {
    if (value == "null") return ""
    else if (value ~ "[+-]?((0|[1-9][0-9]*)|[.][0-9]*|(0|[1-9][0-9]*)[.][0-9]*)([Ee][+-]?[0-9]+)?") return value+0.0
    else return value
}

# human readable unixtime
function humanUnixTime(unixtime) {
    return strftime("%F", unixtime)
}

function compare_record(i1, v1, i2, v2,    vdiff)
{
    vdiff = v2["volume"] - v1["volume"]
    if (!vdiff) 
        return v2["latest_trade"] - v1["latest_trade"]
    else 
        return vdiff
}



function getMarket(market,    i, h) {
    h =  min(getOutput("tput lines") - 6, length(market))
    for (i = 1; i <= h; i++) {
        ret = ret sprintf("%s@%s@%s@%s@%s@%s@%s@%s@%s@%s@%s@%s@%s@\n", unparameterize(eval(market[i]["symbol"])), unparameterize(eval(market[i]["currency"])), eval(market[i]["bid"]), eval(market[i]["ask"]), humanUnixTime(market[i]["latest_trade"]), eval(market[i]["high"]), eval(market[i]["low"]), eval(market[i]["avg"]), eval(market[i]["close"]), eval(market[i]["weighted_price"]), eval(market[i]["duration"]), eval(market[i]["volume"]), eval(market[i]["currency_volume"]))
    }
    return ret
}

function curl(url, output,    command, content, line) {

    if (!isExistProgram("curl --version")) {
        warning("[WARNING] curl is not found.")
        return NULLSTR
    }

    command = "curl" " --location --silent"
    if (Option["proxy"])
        command = command " --proxy " parameterize(Option["proxy"])
    if (Option["user-agent"])
        command = command " --user-agent " parameterize(Option["user-agent"])
    command = command " " parameterize(url)
    if (output) {
        command = command " --output " parameterize(output)
        system(command)
        return NULLSTR
    }
    content = NULLSTR
    while ((command |& getline line) > 0)
        content = (content ? content "\n" : NULLSTR) line
    return content
}

