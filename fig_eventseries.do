clear all
set more off

run util/env.do

cap log close
// noi cap log using fig_eventseries01 , replace
set scheme s2manual
graph set eps logo off 
graph set eps mag 195
graph set eps fontface times



/******************************************************************/
// INCOME 
/******************************************************************/
// post data clean up
// incdist01 is an observation for each time period (-10 to 10) for each 
//  income bin 2-6 plus bankrupt

use $DATA_PATH/incdist01, clear
cap drop temp
drop if time == .

// get missing years
fillin year incbin time  
drop _fillin

// currently this affects no obs
bys incbin year (time) : replace Btot = Btot[1] if Btot==. // give Btot to all the later obs

// interpolation on missing years
bys incbin year (time) : replace inc1 = .5*inc1[_n-1] + .5* inc1[_n+1] if inc1==.
bys incbin year (time) : replace inc1 = inc1[_n-1] + (inc1[_n-1] - inc1[_n-2])  if inc1==. 

// collapse years into one weighted dataset
collapse  (mean) inc = inc1  [pw=Btot] , by(incbin time)
reshape wide inc , j(incbin) i(time)

keep if time>=-10

label var inc100 "Median HH Income of Bankrupt (in thousands of 2009 $)"
label var inc2 "2nd Decile of Peer Pop."
label var inc3 "3rd Decile of Peer Pop."
label var inc4 "4th Decile of Peer Pop."
label var inc5 "5th Decile of Peer Pop."
label var time "Years Before and After Filing"

foreach var of varlist inc* {
    qui replace `var' = `var'/1000
}


cap prog drop all
prog def plot_income_es_bank_only
    // standard errors are about 1.4 until t+5 then 1.48 1.54 1.58 1.63 1.73
    // XXX Hard coded std errors!!
    gen se = 1.4 + .045*max(time-4,0)
    replace se = 1.73 if time==10

    gen inchi = inc100 + 1.96*se
    gen inclo = inc100 - 1.96*se

    twoway  rarea inchi inclo time if abs(time)<11  || ///
            connected inc100 time if abs(time)<11, /// 
            title("Figure 1: Median Real Household Income of Bankrupt") ///
            subtitle(Decade Before and After Filing) /// 
            ytitle("Median HH Income (in thousands of 2009 $)" , margin(vsmall)) ///
            legend(off) xline(0) ylabel(35(5)70) /// 
            saving($OUT_PATH/fig_Bevent1 , replace) name(fig_Bevent1, replace)
    graph export $OUT_PATH/fig_Bevent1.pdf , replace
end

prog def plot_income_es
    label var inc100 "Bankrupt"
    twoway connected inc100 time || line inc3 inc4 inc5 time || if abs(time)<11, /// 
        title("Figure 2: Median Real Household Income of Bankrupt") ///
        subtitle("Compared to Peers")  /// 
        ytitle("Median HH Income (in thousands of 2009 $)" , margin(vsmall))  ///
        xline(0) ylabel(35(5)70) /// 
        saving($OUT_PATH/fig_Bevent2 , replace) name(fig_Bevent2, replace)
    graph export $OUT_PATH/fig_Bevent2.pdf , replace
end

prog def _floater_code
    gen dif5 = inc100 - inc5
    gen dif4 = inc100 - inc4
    gen dif3 = inc100 - inc3

    gen timesq= time*time
    tsset time
    prais dif5 time timesq
    prais dif4 time timesq
    prais dif3 time timesq

    gen debt30 = sum(dif3)
    list debt30 time
end

prog def plot_simulated_debt
    sort time
    gen sim_inc = (inc4 + inc5)/2
    gen sim_def = inc100 - sim_inc
    gen def40 = inc100 - inc4

    gen debt40 = sum(def40)
    gen sim_debt = sum(sim_def)

    label var sim_def "Yearly Deficit"
    label var sim_debt "Cumulative Debt"
    label var time "Years Before Filing"

    twoway bar sim_def time if time<1 & time>-11, barwidth(.8) || ///
            connected sim_debt time if time<1 & time>-11 , yaxis(2) , ///
            title("Figure 3: Hypothetical Debt and Deficit") ///
            subtitle("In Thousands of Dollars") legend(on) ///
            ylabel( 2(-2)-12 , axis(1)) ylabel( 10(-10)-60 , axis(2)) ///
            saving($OUT_PATH/fig_debt1, replace)
    graph export $OUT_PATH/fig_debt1.pdf, replace
end

plot_income_es

exit

/******************************************************************/
// CONSUMPTION
/******************************************************************/
use $DATA_PATH/incdist01, replace
local vars housing foodtot  foodouttot famsize  heq  // mort hvalue  mortpri heq_ratio   rent homeowner  

cap drop temp
cap rename temp_incbin incbin
drop if time==. | incbin==.

// get missing years
fillin year incbin time
drop _fillin

// interpolation on missing years
bys incbin year (time) : replace Btot = Btot[1] if Btot==.

foreach var of varlist `vars' {
    replace `var' = . if `var' == 0 
    bys incbin year (time) : replace `var' = .5*`var'[_n-1] + .5* `var'[_n+1] if `var'==.
    local vars_list `vars_list' `var'
    }

// collapse into one weighted dataset
collapse  (mean) `vars'  [pw=Btot] , by(incbin time)
replace heq = heq/1000

reshape wide `vars' , j(incbin) i(time)
gen timesq = time*time

label var time "Years Before Filing"

foreach var of varlist *3 {
    label var `var' "3rd Income Decile"
}

foreach var of varlist *4 {
    label var `var' "4th Income Decile"
}

foreach var of varlist *5 {
    label var `var' "5th Income Decile"
}

foreach var of varlist *100 {
    label var `var' "Bankrupt"
}

local foodtot_title "Median Household Money Spent on Food"
local foodouttot_title "Median Household Money Spent Eating Out"
local fracfoodout_title "Median Fraction of Food Budget Spent Eating Out"
local housing_title "Median Household Money Spent on Housing"
local famsize_title "Family Size"
local heq_title "Total Housing Equity"

local foodtot_y "Median Monthly Food Exp. in 2009 $"
local foodouttot_y "Median Money Spent Eating Out in 2009 $"
local fracfoodout_y "Median Fraction Spent on Eating Out"
local housing_y "Median Monthly Housing Exp. in 2009 $"
local famsize_y "Average Family Size"
local heq_y "Total Housing Equity in Thousands of 2009 $"

local fignum = 4
foreach var of local vars_list {
    
    twoway  scatter `var'100  time || ///
            qfit `var'100  time, lpattern(solid) || ///
            line `var'3 time || ///
            line `var'4 time || ///
            line `var'5  time || ///
            if time<=0 &  abs(time)<11, ///
            name(`var', replace) ///
            title("Figure `fignum': ``var'_title'") ///
            subtitle("Before Bankruptcy") ///
            ytitle("``var'_y'" , margin(vsmall)) xline(0) ///
            saving($OUT_PATH/`var'01, replace)
    local ++fignum
    graph export $OUT_PATH/`var'1.pdf, replace
    
}

exit
/******************************************************************/
// DIVORCE and UNEMPLOYMENT
/******************************************************************/
use altshock01, replace
cap drop temp
drop if time==.
// get missing years
fillin year B time
drop _fillin

// interpolation on missing years
bys B year (time) : replace Btot = Btot[1] if Btot==.

foreach var of varlist unemployed unmarried {
    bys B year (time) : replace `var' = .5*`var'[_n-1] + .5* `var'[_n+1] if `var'==.
}

// collapse into one weighted dataset
collapse  (mean) unemployed unmarried  [pw=Btot] , by(B time)
reshape wide unemp unmarried , j(B) i(time)

label var unemployed0 "Peer Population"
label var unmarried0 "Peer Population"

label var unemployed1 "Bankrupt"
label var unmarried1 "Bankrupt"

label var time "Years Before and After Filing"

twoway  scatter unemployed1 time || ///
        qfit unemployed1 time || ///
        connected unemployed0 time  || ///
        if time<5 & abs(time)<11, ///
        name(unemp, replace) legend(label(2 "Bankrupt Fitted Line")) ///
        title(Figure 4: Unemployment) subtitle(Before and After Bankruptcy) ///
        xline(0)  ///
        saving($OUT_PATH/unemp01, replace)
graph export $OUT_PATH/unemp01.pdf , replace

twoway  scatter unmarried1 time || ///
        qfit unmarried1 time || ///
        connected unmarried0 time || ///
        if time<5 & abs(time)<11 , ///
        name(unmarried, replace) legend(label(2 "Bankrupt Fitted Line")) ///
        title("Figure 5: Marriage Terminations") ///
        subtitle("Before and After Bankruptcy") ///
        xline(0)  ///
        saving($OUT_PATH/unmarried01, replace) 
graph export $OUT_PATH/unmarried01.pdf, replace
