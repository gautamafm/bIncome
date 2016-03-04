
// notes for 2015
// look at incomes with age adjustment but not education 
// check new PSID for bankruptcy info

// data05 chops a bunch of stuff out to conentrate on the regressions.  
// this may break compatibility with the figure and fig_eventseries
//  I am not sure, but for that we can go back to data03

clear all
set more off

cap log close
log using data05 , replace

set scheme s2manual
graph set eps logo off 
graph set eps mag 195
graph set eps fontface times


/*

/******************************************************/
// DATA CREATION
/******************************************************/


use bankruptpeople1
gen byte B=1

append using nonbankpeople1
replace B=0 if B==.
compress
replace inc=. if inlist(year,2003,2005,2007)  // 2014 is this still a good idea?
xtset id year

/******************************************************/
// since all of our sample is present in 1996, we
//   will use 1996 weights throughout
rename wt oldwt
gen wt = oldwt if year == 1996
bys id (wt): replace wt = wt[1] // only one nonmissing per person 
xtset  // reset the order

/**********************************************************/
// basic variable creation

// remake age to be consistent for the bankrupt
// age buckets
egen age2 = cut(age) , at(0,13,18,25,30,35,40,50,120)
gen agesq = age*age
gen yearsq = year* year

// duplicates
duplicates drop id year, force


// make final education in bins -- educ2
replace educ = 0 if educ==98 | educ ==99 | educ==.
bys id: egen educ2 = max(educ)  // final level of education
replace educ = educ2 if educ==0 & age>=24 

replace educ2 = 11 if inrange(educ2,1,11)  // clump schooling
replace educ2 = 14 if inrange(educ2,13,15)  // clump schooling
replace educ2 = 16 if educ2>=16 & educ2<.
replace educ2 = . if educ2==0

gen educmissing = inlist(educ,0,98,99) | educ==.

// marital stuff
gen malehead = sexofhead==1
gen homeowner = hometype==1
gen head = relhead == 1 | relhead==10
gen spouse = relhead == 2 | relhead==20

// gen unmarried = l.married==1 & married==0  if mrstat<. & head & age>18 & l.mrstat<.
gen unmarried = l.married==1 & married==0  if mrstat<.  & l.mrstat<.
gen divorce_now = l.married==1 & divorced==1


// income
// 2015 I need to censor incomes that are too low or high
replace inc = 1000 if inc<1000
replace inc = 500000 if inc>500000 & inc<.

gen linc = ln(inc)
gen lcapinc = ln(capita)

/******************************************************/
cap prog drop av3 
prog define av3
  syntax varlist // [, xtset(varlist)]
  xtset 
  tempvar lag forward
  foreach var of varlist  `varlist'  {
    qui gen double `lag' = l.`var'
    qui gen double `forward' = f.`var'
    qui egen double `var'3 = rowmean(`lag' `var' `forward')
    qui drop `lag' `forward'
  }
end

/******************************************************/
//  average over next ten years
/******************************************************/
cap prog drop av10
prog define av10
  syntax varlist // [, xtset(varlist)]
  xtset 
  tempvar f1 f2 f3 f4 f5 f6 f7 f8 f9 f10
  foreach var of varlist  `varlist'  {
    local forward 
    forval i == 1/10 {
    qui gen `f`i'' = f`i'.`var'
	local forward `forward' `f`i''
	}

    qui egen double av`var'10 = rowmean(`var' `forward')
    qui drop `forward'
  }
end
/******************************************************/




//  make average
av3 inc
gen linc3 = ln(inc3)

replace famsize = round(famsize)  // round this for convenience
gen bigwt  = round(100*wt)




// make a big d10 and then make smaller d's for everyone and all times
//  2014 -- restrict the d's to be before 96 by the right number of years
gen d10 = f10.inc - inc if (eventyr==-10 & B )	|  ( !B & year<=1986)
gen d5 = f5.inc - inc if (eventyr<=-5 & B )	|  ( !B & year<=1991)
gen d3 = f3.inc - inc if (eventyr<=-3 & B )	|  ( !B & year<=1993)
gen d1 = f1.inc - inc if (eventyr<=-1 & B )	|  ( !B & year<=1995)

gen pd10 = max(min(d10/inc,.4),-1) if inc>0 & d10<.
gen pd10_alt = max(min(d10/inc3,0),-1) if inc>0 & d10<.
gen pd5 = max(min(d5/inc,0),-1) if inc>0 & d5<.
gen pd3 = max(min(d3/inc,0),-1) if inc>0 & d3<.
gen pd1 = max(min(d1/inc,0),-1) if inc>0 & d1<.

gen ld10 = f10.linc - linc if (eventyr==-10 & B )	|  ( !B & year<=1986)
gen ld5 = f5.linc - linc if (eventyr<=-5 & B )	|  ( !B & year<=1991)
gen ld3 = f3.linc - linc if (eventyr<=-3 & B )	|  ( !B & year<=1993)
gen ld2 = f2.linc - linc if (eventyr<=-2 & B )	|  ( !B & year<=1994)
gen ld1 = f1.linc - linc if (eventyr<=-1 & B )	|  ( !B & year<=1995)

gen ld310 = min(max(-5,f10.linc3 - linc3),5) if (eventyr==-10 & B )	|  ( !B & year<=1986)
 


gen minld5 = max(-3,min(0,ld5,f.ld5,f2.ld5,f3.ld5,f4.ld5, f5.ld5))
gen minld2 = max(-3,min(0,ld2,f.ld2,f2.ld2,f3.ld2,f4.ld2, f5.ld2 , f6.ld2, f7.ld2, f8.ld2))
gen minld3 = max(-3,min(0,ld3,f.ld3,f2.ld3,f3.ld3,f4.ld3, f5.ld3 , f6.ld3, f7.ld3))
gen minld1 = max(-3,min(0,ld1,f.ld1,f2.ld1,f3.ld1,f4.ld1, f5.ld1 , f6.ld1, f7.ld1, f8.ld1, f9.ld1))



xtset
gen mind5 = min(d5,f.d5,f2.d5,f3.d5,f4.d5, f5.d5)
gen mind3 = min(d3,f.d3,f2.d3,f3.d3,f4.d3, f5.d3 , f6.d3, f7.d3)
gen mind1 = min(d1,f.d1,f2.d1,f3.d1,f4.d1, f5.d1 , f6.d1, f7.d1, f8.d1, f9.d1)

gen Mpd3 = min(pd3,f.pd3,f2.pd3,f3.pd3,f4.pd3, f5.pd3 , f6.pd3, f7.pd3)
gen Mpd1 = min(pd1,f.pd1,f2.pd1,f3.pd1,f4.pd1, f5.pd1 , f6.pd1, f7.pd1, f8.pd1, f9.pd1)

/******************************************************/
/* MAKE WEIGHTS USING CELLS BY AGE AND EDUCATION -- Bwt */
// normalizing weights
// this is for figures later -- may want to move somewhere else
gen Bwt = wt if B & eventyr==-10 & inc3<. & wt>0
bys age2 educ2: egen sumBwt = sum(Bwt)  // sum of weight for bankrupt in each cell
qui summ Bwt if B & eventyr==-10 & inc3<. & wt>0
replace sumBwt = sumBwt/r(sum)  // now sumBwt is the fraction of all the weight that is in each cell

// reweight for age and education
gen temp = wt if !B & inc3<. & wt>0
bys age2 educ2 year : egen sumtemp = sum(temp)  // sum of weight for nonbankrupt in each cell by year
bys year : egen temp2 = sum(temp) if sumBwt>0   // only sum over nonzero cells
replace sumtemp = sumtemp/temp2 // now this is the amount of each cell in the year's total

replace Bwt = (wt*sumBwt/sumtemp) if !B & inc3<. 
drop temp temp2 sumtemp

replace Bwt = 0 if Bwt==.
/******************************************************/



/****************************************************/

// make a variable that gets one person per household, preferably the head
// 2014 does this work?  I am not sure it does
bys B match year (head spouse): gen hhtag2 = _n==_N if match!=.


xtset

// sample of bankrupt/not bankrupt 10 years before bankruptcy -- only over those with an income
//  and who are in sample ten years later (starting in 1987 going back)
gen byte B10 = B & eventyr==-10 if inc3<. & f10.inc3<. & year<=1986 & hhtag2==1

/******************************************************/
// HOUSING
// rent rentmo mort mortmo foodout
/******************************************************/
replace rent = cond(year<=1993,rent/12,rentmo, .)
replace mort = cond(year<=1993,mort/12,mortmo, .)
replace foodouttot = cond(year<1992,foodouttot/12,foodouttot, .)
replace foodtot = cond(year<1992,foodtot/12,foodtot, .)

// drop a couple outliers
foreach var of varlist rent mort foodouttot foodtot {
	replace `var' = . if `var' >10000 & `var'<.
}

replace rent =. if rent < 50
replace mort =. if mort<50
egen housing = rsum(rent mort)
replace housing =. if housing==0 | year ==1982 
replace mortpri = . if mortpri==0
replace hvalue = . if hvalue==0

gen heq = hvalue - mortpri if mortpri<. & mortpri >0
gen heq_ratio = heq/hvalue

av3 housing foodout foodtot

gen lfoodout3 = ln(foodout3) 
gen lhousing3= ln(housing3) 
gen lcons3 = ln(foodtot3 + housing3) 
gen lsaving3 = linc3 - lcons3
qui summ lsaving
 drop if abs(lsaving- r(mean))/r(sd)>3 // this normalizes cons as well as savings
/******************************************************/

xtset
gen t = year - 1975

/*
/******************************************************/
// grab the worst year and the number of years that are negative
/******************************************************/
cap drop trash
gen trash = inc<.
gen byte worstyear=.
forval i = 1(1)10 {
	local i1 = `i'-1
	bys id (year): replace worstyear = `i' if mind1==f`i1'.d1 & worstyear==.
	bys id (year): gen byte neg0k`i' = f`i1'.d1<0  if f`i1'.d1<.   // only count if inc is there
	
	bys id (year): gen byte neg5k`i' = f`i1'.d1<-5000  if f`i1'.d1<.   // only count if inc is there
	bys id (year): gen byte pos5k`i' = f`i1'.d1>5000  if f`i1'.d1<.   // only count if inc is there	

	bys id (year): gen byte neg15k`i' = f`i1'.d1<-15000  if f`i1'.d1<.   // only count if inc is there
	bys id (year): gen byte pos15k`i' = f`i1'.d1>15000  if f`i1'.d1<.   // only count if inc is there	
	
}		


// histogram worstyear [aw=Bwt] if eventyr==-10 | !B  , discrete 

summ neg0k* [aw=Bwt] if B==0

graph bar neg0k* [w=wt] if eventyr==-10 & hhtag,  ascategory ytitle(Fraction with Negative Income Shock) b1title(Years Before Filing)  yvaroptions( relabel(1 "-9" 2 "-8" 3 "-7" 4 "-6" 5 "-5" 6 "-4" 7 "-3" 8 "-2" 9 "-1" 10 "0")) title(Filers with Negative Income Shocks) subtitle(Before Bankruptcy) yline(.46 , lpattern(dash) lwidth(medium)  ) blabel(bar , format(%6.2g) pos(inside) ) intensity(50) name(neg0k, replace)
graph export neg0k.eps, replace


summ neg5k* [aw=Bwt] if B==0 & inrange(year, 1975,1985)

graph bar neg5k* [w=Bwt] if eventyr==-10 & hhtag,  ascategory ytitle(Fraction with $5K Income Drop) b1title(Years Before Filing)  yvaroptions( relabel(1 "-9" 2 "-8" 3 "-7" 4 "-6" 5 "-5" 6 "-4" 7 "-3" 8 "-2" 9 "-1" 10 "0")) title(Filers with $5000 Income Drop In One Year) subtitle(Before Bankruptcy) yline(.30 , lpattern(dash) lwidth(medium)  ) blabel(bar , format(%6.2g) pos(inside) ) intensity(50) name(neg5k, replace)
graph export neg5k.eps, replace


summ neg15k* [aw=Bwt] if B==0 & inrange(year, 1975,1985)

graph bar neg15k* [w=Bwt] if eventyr==-10 & hhtag,  ascategory ytitle(Fraction with $15K Income Drop) b1title(Years Before Filing)  yvaroptions( relabel(1 "-9" 2 "-8" 3 "-7" 4 "-6" 5 "-5" 6 "-4" 7 "-3" 8 "-2" 9 "-1" 10 "0")) title(Filers with $15000 Income Drop In One Year) subtitle(Before Bankruptcy) yline(.155 , lpattern(dash) lwidth(medium)  ) blabel(bar , format(%6.2g) pos(inside) ) intensity(50) name(neg15k, replace)
graph export neg15k.eps, replace


summ pos5k* [aw=Bwt] if B==0 & inrange(year, 1975,1985)

graph bar pos5k* [w=Bwt] if eventyr==-10 & hhtag,  ascategory ytitle(Fraction with $5K Income Increase) b1title(Years Before Filing)  yvaroptions( relabel(1 "-9" 2 "-8" 3 "-7" 4 "-6" 5 "-5" 6 "-4" 7 "-3" 8 "-2" 9 "-1" 10 "0")) title(Filers with $5000 Income Increase In One Year) subtitle(Before Bankruptcy) yline(.36 , lpattern(dash) lwidth(medium)  ) blabel(bar , format(%6.2g) pos(inside) ) intensity(50) name(pos5k, replace)
graph export pos5k.eps, replace
*/



// make ten year averages

/*
foreach var of varlist t inc linc housing foodouttot foodtot famsize {
	cap drop trash
	gen trash = `var'<.
	gen av`var'10 = cond(trash==1,`var',0)
	forval i = 1(1)10 {
		local i1 = `i'-1
		bys id (year): replace trash = trash+1 if f`i'.inc<. & f`i'.`var'<.   // only count if inc is there
		bys id (year): replace av`var'10 = av`var'10 + f`i'.`var' if f`i'.`var'<. & f`i'.inc<.

		}
	replace av`var'10 = av`var'10/trash
	cap drop trash
}
*/

// makes averages
av10 t inc linc housing foodouttot foodtot famsize

	gen lfamsize = ln(avfamsize)

	// how do I deal with missing years?


compress
xtset
saveold regdata03, replace
*/ 



/******************************************************/
// REGRESSIONS
/******************************************************/

use regdata03, replace
keep if year<=1995
gen byte B0 = B & eventyr==0 if inc3<.  & year<=1996 & hhtag2==1
replace ld310 = min(max(-3,ld310),1) if ld310<.
gen agecu = age*age*age/1000

keep if eventyr<=0 | ( B==0 & year<=1996)

gen f9linc = f9.linc
gen f9linc3 = f9.linc3
gen predlinc3 = l3.linc3

global controls age agesq  i.educ t lfamsize // i.state
global controls age agesq  i.educ2 i.educ2#c.age  t lfamsize // i.state

//  form three predictions -- one OLS and one purely based on prior earnings
reg linc3  i.age i.educ (c.age c.age2)#i.educ2 i.year i.state lfamsize [pw=wt] if  B10<.   & /// 
   inrange(year,1976,1996)  & inrange(age,20,65)
predict predlinc1 if hhtag2  & inrange(year,1976,1996)  // & inrange(age,20,65) , xb   

reg linc3 l3.linc3  $controls [pw=wt] if inrange(year,1976,1996)  & inrange(age,20,65) & B10<.  
predict predlinc2 if inrange(year,1976,1996) // & hhtag2     // & inrange(age,20,65) , xb
// replace predlinc = l3.linc

//  three possible predictors -- 
//   3 prior income
//   2 prior income and demographics (basic controls)
//   1 just demographics (but more than basic controls)

// gen short = -0.0001*min(500000,max(-500000,inc3 - predlinc)) if predlinc<. & inc3<.
// gen short2 = -0.0001*min(500000,max(-500000,inc3 - l3.inc3)) if l3.linc3<. & inc3<.


forval i = 1/3 {
 gen short`i' = -1*min(2,max(-2,linc3 - predlinc`i')) if predlinc`i'<. & linc3<. & inrange(year,1976,1996)  

//  get a count on observations
gen ntrash = short`i'<.
// second round for short2 

bys id (year) : gen numer = sum(short`i')
bys id (year) : gen denom = sum(ntrash)
gen  avshort`i' = (f10.numer - numer)/(f10.denom - denom)
replace avshort`i' = (f9.numer - numer)/(f9.denom - denom) if avshort`i'==.
 drop numer denom ntrash

gen f9short`i' = f9.short`i'
}
 
replace ld1 = -2 if ld1<-2
replace ld1 = 2 if ld1>2 & ld1<.


gen last3 = f9.linc - f7.linc
twoway (kdensity last3 if B10 == 0 [aw=altwt]) (kdensity last3 if B10 == 1 [aw=altwt])



// now that I have gathered the cross-person data, drop the bankrupt
//  for all other years besides B-10 that have B10 nonmissing
//  leave the missing in to grab time series things 
 drop if B==1 & B10==0


/******************************************************/
//  divide weights by the number of times the person appears
//  this should be 1 for the bankrupt and 1-10 for others
/******************************************************/
qui reg B10 avshort2 f9linc3 linc3 $controls if year<=1986 & year>=1976 & hhtag2   [pw=wt], cluster(id)
gen trashsamp = e(sample)
bys id: egen trash = sum(trashsamp) if e(sample)
gen altwt = wt/trash
drop trash*


/******************************************************/ 
// PROBITS
/******************************************************/
****************************************************
****************************************************
** B10 imposes most sample restrictions by being missing 
** for the obs not in sample
****************************************************
****************************************************

asdf

forval i = 1/3 {
 probit B10  avshort`i'  $controls if year<=1986 & year>=1976    [pw=altwt], cluster(id)
  est store p`i'1
 probit B10  avshort`i' f9short`i'  $controls if year<=1986 & year>=1976   [pw=altwt], cluster(id)
  est store p`i'2
 probit B10  avshort`i' f9short`i' linc3 $controls if year<=1986 & year>=1976   [pw=altwt], cluster(id)
  est store p`i'3

}

 probit B10 f9linc3  $controls if year<=1986 & year>=1976   [pw=altwt], cluster(id)
  est store p41
 probit B10 linc3   $controls if year<=1986 & year>=1976   [pw=altwt], cluster(id)
  est store p42
 probit B10 linc3 f9linc3  $controls if year<=1986 & year>=1976   [pw=altwt], cluster(id)
  est store p43
  
  

forval i = 1/4 {
  est table p`i'* ,drop($controls) b(%5.3f) se(%5.3f) stat(N N_clust)
}






log close
exit
