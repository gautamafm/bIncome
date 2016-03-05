/*
Takes the full psid individual-level dataset and renames the variables to match our other programs and drops variables
we don't use.  Saves "individual_small".
*/

clear all


set mem 500m
set more off

use r:\bankrupt\psid\indiv_6807\psid6807, clear

rename ER33902 cutoff2007
rename ER33802 cutoff2005
rename ER33702 cutoff2003
rename ER33602 cutoff2001
rename ER33502 cutoff1999
rename ER33402 cutoff1997
rename ER33302 cutoff1996
rename ER33202 cutoff1995
rename ER33102 cutoff1994
rename ER30807 cutoff1993
rename ER30734 cutoff1992
rename ER30690 cutoff1991
rename ER30643 cutoff1990
rename ER30607 cutoff1989
rename ER30571 cutoff1988
rename ER30536 cutoff1987
rename ER30499 cutoff1986
rename ER30464 cutoff1985
rename ER30430 cutoff1984
rename ER30400 cutoff1983
rename ER30374 cutoff1982
rename ER30344 cutoff1981
rename ER30314 cutoff1980
rename ER30284 cutoff1979
rename ER30247 cutoff1978
rename ER30218 cutoff1977
rename ER30189 cutoff1976
rename ER30161 cutoff1975
rename ER30139 cutoff1974
rename ER30118 cutoff1973
rename ER30092 cutoff1972
rename ER30068 cutoff1971
rename ER30044 cutoff1970
rename ER30021 cutoff1969

rename ER33901 match2007
rename ER33801 match2005
rename ER33701 match2003
rename ER33601 match2001
rename ER33501 match1999
rename ER33401 match1997
rename ER33301 match1996
rename ER33201 match1995
rename ER33101 match1994
rename ER30806 match1993
rename ER30733 match1992
rename ER30689 match1991
rename ER30642 match1990
rename ER30606 match1989
rename ER30570 match1988
rename ER30535 match1987
rename ER30498 match1986
rename ER30463 match1985
rename ER30429 match1984
rename ER30399 match1983
rename ER30373 match1982
rename ER30343 match1981
rename ER30313 match1980
rename ER30283 match1979
rename ER30246 match1978
rename ER30217 match1977
rename ER30188 match1976
rename ER30160 match1975
rename ER30138 match1974
rename ER30117 match1973
rename ER30091 match1972
rename ER30067 match1971
rename ER30043 match1970
rename ER30020 match1969
rename ER30001 match1968

rename ER30010 educ1968
rename ER30052 educ1969
rename ER30076 educ1970
rename ER30100 educ1971
rename ER30126 educ1972
rename ER30147 educ1973
rename ER30147 educ1974
rename ER30169 educ1975
rename ER30197 educ1976
rename ER30226 educ1977
rename ER30255 educ1978
rename ER30296 educ1979
rename ER30326 educ1980
rename ER30356 educ1981
rename ER30384 educ1982
rename ER30413 educ1983
rename ER30443 educ1984
rename ER30478 educ1985
rename ER30513 educ1986
rename ER30549 educ1987
rename ER30584 educ1988
rename ER30620 educ1989
rename ER30657 educ1990
rename ER30703 educ1991
rename ER30748 educ1992
rename ER30820 educ1993
rename ER33115 educ1994
rename ER33215 educ1995
rename ER33315 educ1996
rename ER33415 educ1997
rename ER33516 educ1999
rename ER33616 educ2001
rename ER33716 educ2003
rename ER33817 educ2005
rename ER33917 educ2007

rename ER30013 hrwork1967
rename ER30034 hrwork1968
rename ER30058 hrwork1969
rename ER30082 hrwork1970
rename ER30107 hrwork1971
rename ER30131 hrwork1972
rename ER30153 hrwork1973
rename ER30177 hrwork1974
rename ER30204 hrwork1975
rename ER30233 hrwork1976
rename ER30270 hrwork1977
rename ER30300 hrwork1978
rename ER30330 hrwork1979
rename ER30360 hrwork1980
rename ER30388 hrwork1981
rename ER30417 hrwork1982
rename ER30447 hrwork1983
rename ER30482 hrwork1984
rename ER30517 hrwork1985
rename ER30553 hrwork1986
rename ER30588 hrwork1987
rename ER30624 hrwork1988
rename ER30661 hrwork1989
rename ER30709 hrwork1990
rename ER30754 hrwork1991
rename ER30823 hrwork1992

rename ER30293 employ1979
rename ER30323 employ1980
rename ER30353 employ1981
rename ER30382 employ1982
rename ER30411 employ1983
rename ER30441 employ1984
rename ER30474 employ1985
rename ER30509 employ1986
rename ER30545 employ1987
rename ER30580 employ1988
rename ER30616 employ1989
rename ER30653 employ1990
rename ER30699 employ1991
rename ER30744 employ1992
rename ER30816 employ1993
rename ER33111 employ1994
rename ER33211 employ1995
rename ER33311 employ1996
rename ER33411 employ1997
rename ER33512 employ1999
rename ER33612 employ2001
rename ER33712 employ2003
rename ER33813 employ2005
rename ER33913 employ2007

rename ER33903 relhead2007
rename ER33803 relhead2005
rename ER33703 relhead2003
rename ER33603 relhead2001
rename ER33503 relhead1999
rename ER33403 relhead1997
rename ER33303 relhead1996
rename ER33203 relhead1995
rename ER33103 relhead1994
rename ER30808 relhead1993
rename ER30735 relhead1992
rename ER30691 relhead1991
rename ER30644 relhead1990
rename ER30608 relhead1989
rename ER30572 relhead1988
rename ER30537 relhead1987
rename ER30500 relhead1986
rename ER30465 relhead1985
rename ER30431 relhead1984
rename ER30401 relhead1983
rename ER30375 relhead1982
rename ER30345 relhead1981
rename ER30315 relhead1980
rename ER30285 relhead1979
rename ER30248 relhead1978
rename ER30219 relhead1977
rename ER30190 relhead1976
rename ER30162 relhead1975
rename ER30140 relhead1974
rename ER30119 relhead1973
rename ER30093 relhead1972
rename ER30069 relhead1971
rename ER30045 relhead1970
rename ER30022 relhead1969
rename ER30003 relhead1968

rename ER33904 age2007
rename ER33804 age2005
rename ER33704 age2003
rename ER33604 age2001
rename ER33504 age1999
rename ER33404 age1997
rename ER33304 age1996
rename ER33204 age1995
rename ER33104 age1994
rename ER30809 age1993
rename ER30736 age1992
rename ER30692 age1991
rename ER30645 age1990
rename ER30609 age1989
rename ER30573 age1988
rename ER30538 age1987
rename ER30501 age1986
rename ER30466 age1985
rename ER30432 age1984
rename ER30402 age1983
rename ER30376 age1982
rename ER30346 age1981
rename ER30316 age1980
rename ER30286 age1979
rename ER30249 age1978
rename ER30220 age1977
rename ER30191 age1976
rename ER30163 age1975
rename ER30141 age1974
rename ER30120 age1973
rename ER30094 age1972
rename ER30070 age1971
rename ER30046 age1970
rename ER30023 age1969
rename ER30004 age1968

rename ER33306 birthyr

rename ER33318 longwt

keep birthyr match* cutoff* age* relhead* age* employ* hrwork* educ* longwt

gen age2006 = .
replace age2006 = age2007 - 1 if age2007!=.
replace age2006 = age2005 + 1 if age2005!=. & age2007==.

gen age2004 = .
replace age2004 = age2005 - 1 if age2005!=.
replace age2004 = age2003 + 1 if age2003!=. & age2005==.

gen age2002 = .
replace age2002 = age2003 - 1 if age2003!=.
replace age2002 = age2001 + 1 if age2001!=. & age2003==.

gen age2000 = .
replace age2000 = age2001 - 1 if age2001!=.
replace age2000 = age1999 + 1 if age1999!=. & age2001==.

gen age1998 = .
replace age1998 = age1999 - 1 if age1999!=.
replace age1998 = age1997 + 1 if age1997!=. & age1999==.

save individual_small, replace
