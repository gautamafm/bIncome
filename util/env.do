if regexm(c(pwd), "oogle") {
    global DATA_PATH = "../data"
    global OUT_PATH = "../out"
}
else if c(os) == "Windows" {
    global DATA_PATH "d:/data/bIncome"
    global OUT_PATH "../out"
}
else {
    noi di as err "Environment variables not set (see `util/env.do`)"
    err 999
}

set scheme s2manual
graph set eps logo off 
graph set eps mag 195
graph set eps fontface times
