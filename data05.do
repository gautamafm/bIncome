
// notes for 2015
// look at incomes with age adjustment but not education 
// check new PSID for bankruptcy info

// data05 chops a bunch of stuff out to conentrate on the regressions.  
// this may break compatibility with the figure and fig_eventseries
//  I am not sure, but for that we can go back to data03

clear all
set more off

run util/env.do

cap log close

set scheme s2manual
graph set eps logo off 
graph set eps mag 195
graph set eps fontface times


use $DATA_PATH/regdata03, replace
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
