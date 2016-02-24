clear all
set more off

run clean/io

cap log close

/**********************************************************/
// bankruptcy weights -- make a set of weights (Bwt) that make the rest of the
//                       population have the same age distribution as the bankrupt
//                       ten years before they filed.
//                       do this over many different starting years and save each version




// make fake datasets to append results to
set obs 1
gen temp = 0
save $DATA_PATH/incdist01, replace
save $DATA_PATH/altshock01, replace

use $DATA_PATH/regdata03

gen foodpercap = foodtot/famsize
// gen fracfoodout = foodouttot/foodtot

local C  housing mort rent fracfoodout foodpercap foodouttot foodtot mortpri hvalue heq heq_ratio
foreach var of varlist `C' {
	local C_mean `C_mean' `var'_M = `var' 
	}

forval year = 1975(1)1986 {
    //  2014 -- is this what I want?
	// 2014 find the weight of the B in that year
	// but note that this is the weight of all the people who ever file, not just in `year'
	//  the eventyr restriction made it just the filing -10 year.  I am not sure which way I want it
	//  yet
	qui summ Bwt if /*eventyr==-10 &*/ year == `year' & B 
	local Btot = r(sum)
	
	// now I assign the year's weight's to each person across his whole profile based on
	// the Bwt that I used in the t-10 year 
	bys id : gen tempwt = Bwt if !B & year==`year' // only one
	bys id : egen Bwtlife`year' = sum(tempwt) // only one nonempty so Bwtlife`year' is constant over the id
	replace Bwtlife`year' = 0 if Bwtlife`year' == .

	/**********************************************************/ 
	// income profiles based on t-10 income
	sort inc3
	gen temp = sum(tempwt) 
	gen incbin`year' = 1 + floor(9.9999*temp/temp[_N]) if inc3<. & !B & year ==`year'  // makes ten income buckets
	drop temp tempwt
    // 2014 -- assigns the one nonmissing incbin across all person's observations	
	bys id (incbin`year') : gen temp_incbin = incbin`year'[1] 
	di " year = `year' "	

	// income and consumption series
	preserve
	gen time = eventyr if B
	replace Bwtlife`year' = wt if B
	replace temp_incbin =100 if B
	replace time = year -`year' -10  if inrange(temp_incbin,2,6) // -10 is the weight normed year
	    // B happens in 0

	collapse famsize homeowner `C_mean' (median) inc1 = inc `C' if abs(time)<11  [aw=Bwtlife`year'] , by(time temp_incbin)
	
// 	table time temp_incbin if abs(time)<12 [aw=Bwtlife`year'] , c( p50 inc ) replace name(inc)
	rename temp_incbin incbin
	gen Btot = `Btot'
	gen year = `year'	
	append using $DATA_PATH/incdist01
	save $DATA_PATH/incdist01 , replace
	restore

// unemployment and marriage series
	preserve
	gen time = eventyr if B
	replace Bwtlife`year' = wt if B
	replace time = year -`year' -10  if !B	
	table B time if abs(time)<12 [aw=Bwtlife`year'] , c( mean heademp mean unmarried p50 inc p40 inc p30 inc) replace name(alt)
	gen Btot = `Btot'
	gen year = `year'
	rename alt1 unemployed
	rename alt2 unmarried
	rename alt3 inc_50
	rename alt4 inc_40
	rename alt5 inc_30
	append using $DATA_PATH/altshock01
	save $DATA_PATH/altshock01 , replace
	restore

	/*
// consumption series
	preserve
	gen time = eventyr if B
	replace Bwtlife`year' = wt if B
	replace temp_incbin =100 if B		
	
	replace time = year -`year' -10  if !B
	collapse famsize homeowner numchild numadult (median) housing mort rent foodout mortpri hvalue heq* if time<=0 & time>-11  [aw=Bwtlife`year'] , by(time temp_incbin)
	gen Btot = `Btot'
	gen year = `year'
	rename temp_incbin incbin
	append using  consumption01
	save consumption01 , replace
	restore
*/	
   drop temp_incbin
	}

asdf

save $DATA_PATH/tempdata, replace




//  2014 -- I think the next section is for creating income shock distributions
use $DATA_PATH/tempdata
// get income bins and reweight to be the same as the B income distn at t-10
egen incbin = rsum(incbin*)  if !B // only one is nonmissing
replace incbin = . if incbin==0

// assign incbin to the t-10 B distn for those who are missing
// note that this only is happening for the bankrupt
// need to be more careful here about interpolation that may miss drops
forval i = 1/5 {
	bys year (inc3) : replace incbin = max(incbin[_n-`i'],incbin[_n+`i']) if incbin==.  & inc3!=. & eventyr==-10
	}

// norm by year and incbin for deltas
// then Bwt2 is a weight that re-creates the distribution
//   of the bankrupt at t-10 -- including year and income
//  Bwtlife_year assigns forward and backward the Bwt (or Bwt2) from a certain
//    year to the rest of the person's life cycle.

gen temp = wt*(eventyr ==-10 & inc3<.)  // only the t-10 (B)

bys year: egen Btot = sum(temp)
bys incbin: egen Btot_inc = sum(temp)

qui summ Bwt if B & eventyr==-10 & inc3<.
replace Btot = Btot/r(sum)  // now Btot is the fraction of all the weight that is in each year
qui summ Bwt if B & eventyr==-10 & inc3<.
replace Btot_inc = Btot_inc/r(sum)  // now Btot_inc is the fraction of all the weight that is in each incbin (decile)
drop temp

bys year: egen temp = sum(Bwt) if !B & inc3<.
qui summ Bwt if !B & inc3<. & inrange(year,1975,1986)
gen Bwt2 = Bwt*Btot * r(sum)/temp  if !B & inc3<. & inrange(year,1975,1986)
drop temp

bys incbin: egen temp = sum(Bwt2) if !B & inc3<.
qui summ Bwt2 if !B & inc3<.
gen Bwt3 = Bwt2*Btot_inc * r(sum)/temp  if !B & inc3<.
drop temp

// renorm to be integers and to make the bankrupt the right fraction of all the data

replace Bwt3 = wt if B
replace Bwt2 = wt if B

// now remake the Bwtlife's with Bwt3
forval year = 1975(1)1986 {
	drop Bwtlife`year'
	gen temp = Bwt3 if !B & inc<. & year == `year'
	// get the following nine years only 
	bys id (temp): gen Bwtlife1`year' = temp[1]  if inrange(year,`year',`year'+9)  // should just be one nonmissing temp
	bys id (temp): gen Bwtlife3`year' = temp[1]  if inrange(year,`year',`year'+7)  // should just be one nonmissing temp
	bys id (temp): gen Bwtlife5`year' = temp[1]  if inrange(year,`year',`year'+5)  // should just be one nonmissing temp
	drop temp	
	}

// for each observation add up all its weights
// now this gives it's total weight in the distribution
// of each shock, across all years.
egen Bwtlife1 = rsum(Bwtlife11*)
egen Bwtlife3 = rsum(Bwtlife31*)
egen Bwtlife5 = rsum(Bwtlife51*)

summ d5 if !B [aw=Bwtlife5], d
summ d5  [aw=wt] if B & inrange(eventy,-10,-5), d

summ d3 if !B [aw=Bwtlife3], d
summ d3  [aw=wt] if B & inrange(eventy,-10,-3), d

summ d1 if !B [aw=Bwtlife1], d
summ d1  [aw=wt] if B & inrange(eventy,-10,-1), d

save $DATA_PATH/tempdata2, replace
*/
use $DATA_PATH/tempdata2

egen hhtag = tag(B match year) if match!=.
replace Bwt2 = wt if B  // Bwt2 weights by year which restricts the sample 

// find the worst d in ten years
// just find the min of the shocks going forward

/* JAN 2011 THERE WAS A MISTAKE IN THE BELOW -- SHOULD JUST BE for -10 year, not all years */


summ d10 if !B [aw=Bwt3], d
summ d10  [aw=Bwt3] if B & eventyr==-10, d

summ mind5 if !B [aw=Bwt3], d
summ mind5  [aw=Bwt3] if B & inrange(eventy,-10,-10), d

summ mind3 if !B [aw=Bwt3], d
summ mind3  [aw=Bwt3] if B & inrange(eventy,-10,-10), d

summ mind1 if !B [aw=Bwt3], d
summ mind1  [aw=Bwt3] if B & inrange(eventy,-10,-10), d


xtset , clear
/* get standard errors for the above*/

// quick little program for the bootstrap to work on
cap prog drop trash
prog define trash , rclass
	summ `1' if eventyr<0 [aw=Bwt3] , d
	local p10 = r(p10)
	local p25 = r(p25)
	local p50 = r(p50)
	local p75 = r(p75)
	local p90 = r(p90)
	summ `1' if !B [aw=Bwt3] , d
	return scalar p10 = r(p10) - `p10'
	return scalar p25 = r(p25) - `p25'
	return scalar p50 = r(p50) - `p50'
	return scalar p75 = r(p75) - `p75'
	return scalar p90 = r(p90) - `p90'
end

preserve
keep if (!B | inrange(eventyr,-10,-10)) & hhtag
bootstrap p10=r(p10) p25 = r(p25) p50 = r(p50) p75 = r(p75) p90 = r(p90) , force cluster(id):  trash mind1
test p10 p25 p50 p75 p90
restore

preserve
keep if (!B | inrange(eventyr,-10,-10)) & hhtag
bootstrap p10=r(p10) p25 = r(p25) p50 = r(p50) p75 = r(p75) p90 = r(p90) , force cluster(id):  trash mind3
test p10 p25 p50 p75 p90
restore


preserve
keep if inrange(eventyr,-10,-10) & hhtag
cap noi bootstrap p10=r(p10) p25 = r(p25) p50 = r(p50) p75 = r(p75) p90 = r(p90), force cluster(id) : summ mind1 [aw=Bwt3], d
restore

preserve
keep if !B & hhtag
cap noi bootstrap p10=r(p10) p25 = r(p25) p50 = r(p50) p75 = r(p75) p90 = r(p90), force cluster(id) : summ mind1 [aw=Bwt3], d
restore

preserve
keep if inrange(eventyr,-10,-10) & hhtag
cap noi bootstrap p10=r(p10) p25 = r(p25) p50 = r(p50) p75 = r(p75) p90 = r(p90), force cluster(id) : summ mind3 [aw=Bwt3], d
restore

preserve
keep if !B & hhtag
cap noi bootstrap p10=r(p10) p25 = r(p25) p50 = r(p50) p75 = r(p75) p90 = r(p90), force cluster(id) : summ mind3 [aw=Bwt3], d
restore


// find the worst spell in the lifetime
/*
xtset

gen temp = max(min((inc3 - l10.inc3)/l10.inc3,0),-1)  if inc3<. & l10.inc3<.
bys id : egen Md10 = min(temp)
drop temp

gen temp = max(min((inc - l3.inc)/l3.inc,0),-1) if inc<. & l3.inc<.
bys id : egen Md3 = min(temp)
drop temp

gen temp = max(min((inc - l.inc)/l.inc,0),-1) if inc<. & l3.inc<.
bys id : egen Md1 = min(temp)
drop temp
*/

// make stuff for table on median d10 by incbin
gen incbin8 = min(incbin,8) if incbin<. & incbin >0
bys id (incbin8): replace incbin8 = incbin8[1] if incbin8==. & B  

tab incbin8 [aw=Bwt2] if (B & eventyr==-10)
table incbin8 [aw=Bwt2] if (B & eventyr==-10) | !B  , c(median inc)
table incbin8 B [aw=Bwt2] if (B & eventyr==-10) | !B  , c(median d10)
table incbin8 B [aw=Bwt2] if !B | inrange(eventyr, -10,-1)  , c(median mind1)

xtset , clear

egen matchyear = group(match year) if match !=.

forval i = 1/8 {
	gen byte INCBIN`i' = incbin8 == `i'
	gen byte BINCBIN`i' = incbin8 == `i' & B
	}
drop INCBIN1

// make some hhwts that account for how many times someone is in the sample and famsize
bys id:  gen trash = (inrange(eventyr,-10,-10) | !B) & hhtag2 & educ2<. & avhousing<. & avinc10<. & famsize<. & inrange(year,1975,1986)
bys id:  egen numobs = sum(trash)
drop trash

gen hhwt = wt*famsize/numobs
gen Bhhwt = Bwt3*famsize/numobs if hhtag2 &  match != .

egen age_educ = group(age2 educ2)
qui tab age_educ , gen(AE)
drop AE1
qui tab famsize , gen(FS)
drop FS1
qui tab year, gen(DY)
drop DY1
qui tab state , gen(DS)
drop DS1

foreach var of varlist av*10 heq {
	gen l`var' = ln(`var')
	}




// calculate a ten year average on food, foodout and housing famsize  and income then create predicted income based on c
//  from that and get the avinc10 - predinc10 and create bins of how far off you are -- make bins of percentages
//  show how well this predict is predicted by pd10 and then how well it predicts B


reg avinc10 avfood*10 avhousing10  FS* AE* DY* DS* [aw=hhwt] if (inrange(eventyr,-10,-10) | !B) & hhtag2
predict predinc10 if (inrange(eventyr,-10,-10) | !B) & hhtag2 , xb
gen netconsumption10 = ln(predinc10) - ln(avinc10)
summ netconsumption10 [aw=hhwt] if (inrange(eventyr,-10,-10) | !B) & hhtag2
reg B netconsumption10  FS* AE* DY* DS* [aw=hhwt] if (inrange(eventyr,-10,-10) | !B) & hhtag2

reg lavinc10 lavfood*10  lavhousing10  FS* AE* DY* DS* [aw=hhwt] if (inrange(eventyr,-10,-10) | !B) & hhtag2
predict predlinc10 if (inrange(eventyr,-10,-10) | !B) & hhtag2 , xb
gen netlcons10 = predlinc10 - lavinc10
summ netlcons10 [aw=hhwt] if (inrange(eventyr,-10,-10) | !B) & hhtag2
dprobit B netlcons10  FS* AE* DY* DS* [pw=hhwt] if (inrange(eventyr,-10,-10) | !B) & hhtag2



/* in order for income drops to matter, I need to control for starting income */
/* avinc is average income */

// do a robust regression where I move or drop the top and bottom one percent in d10

qui reg d10 BINCBIN* INCBIN* AE*  FS* DY* DS*  [aw=hhwt] if (inrange(eventyr,-10,-10) | !B) & hhtag2
qui summ d10 if e(sample) , d
local p1 = r(p1)
local p99 = r(p99)

areg d10 BINCBIN* INCBIN* AE*  FS* DY*  [aw=hhwt] if (inrange(eventyr,-10,-10) | !B) & hhtag2 & d10 > `p1' & d10<`p99', cluster(id) absorb(state)
testparm BINCBIN*
testparm BINCBIN* , equal
xtset id year


/* shows that the medians differ alot -- avoid means because of truncation */
 bys B: summ pd10 if e(sample) & hhtag2  [aw=Bhhwt] , d

// causal analysis

gen B1000 = B*1000
egen pd10_bin = cut(pd10) , at(-1,-.8, -.6, -.4, -.2, 0, .2, .4, 10)
tab pd10_bin [aw=Bwt3] if eventy==-10 | !B , gen(DUM_pd10)
tab pd10_bin [aw=Bwt3] if eventy==-10 | !B , summ(B100)

reg B100 DUM_pd10* [aw=Bwt3] if eventy==-10 | !B , nocons cluster(id)
testparm DUM_*, eq

drop DUM_pd101

// make sure I only use one person from each bankrupt household
// egen hhtag = tag(B match year)

qui dprobit B DUM_pd10* INCBIN* AE*  FS* DY* DS* [pw=wt] if eventy==-10 | !B   , cluster(id)
testparm  DUM_*

qui dprobit B DUM_pd10* INCBIN* AE*  FS* DY* DS* [pw=wt] if (eventy==-10 | !B) & hhtag  , cluster(id)
testparm  DUM_* 

qui dprobit B pd10_bin INCBIN* AE*  FS* DY* DS* [pw=wt] if eventy==-10 | !B   , cluster(id)
testparm   pd10_b

qui dprobit B pd10_bin INCBIN* AE*  FS* DY* DS* [pw=wt] if (eventy==-10 | !B) & hhtag  , cluster(id)
testparm  pd10_b

qui dprobit B pd10 INCBIN* AE*  FS* DY* DS* [pw=wt] if eventy==-10 | !B   , cluster(id)
testparm   pd10

qui dprobit B pd10 INCBIN* AE*  FS* DY* DS* [pw=wt] if (eventy==-10 | !B) & hhtag  , cluster(id)
testparm  pd10

drop AE* FS* DY* DS*

/* regressions that combine important elements together */
gen byte incdrop = pd10<0 if pd10<.
gen fracout = min(1,avfoodouttot10/avfoodtot10) if avfoodtot10<. & avfoodouttot10<.
gen pmind3 = min(0,max(-1,mind3/inc))
gen pmind1 = min(0,max(-1,mind1/inc))
gen lfamsize = ln(famsize)
gen pmind1_alt = min(0,max(-1,mind1/inc3))


probit B incdrop lavinc10 lavfoodtot10 fracout lavhousing famsize age i.educ2 [pw=hhwt] if (inrange(eventyr,-10,-10) | !B) & hhtag2 & inrange(year,1975,1986) , cluster(id)

probit B pmind1 incdrop lavinc10 lavfoodtot10 fracout lavhousing famsize age i.educ2 [pw=hhwt] if (inrange(eventyr,-10,-10) | !B) & hhtag2 & inrange(year,1975,1986) , cluster(id)

probit B pmind3 incdrop lavinc10 lavfoodtot10 fracout lavhousing famsize age i.educ2 [pw=hhwt] if (inrange(eventyr,-10,-10) | !B) & hhtag2 & inrange(year,1975,1986) , cluster(id)

probit B incdrop lavinc10 lavfoodtot10 fracout lavhousing famsize i.age2 i.educ2 i.year i.state [pw=hhwt] if (inrange(eventyr,-10,-10) | !B) & hhtag2 & inrange(year,1975,1986), cluster(id)





/* look at income drops in the year before filing */

compress
save $DATA_PATH/tempdata3 , replace

use $DATA_PATH/tempdata3

// make a variable that is worst drop for the nonB and Bdrop for the B
gen trash = d1 if eventyr==-2
bys id (trash) : gen Bd1 = trash[1]
drop trash
replace Bd1 = mind1 if !B
replace Bd1 = min(max(-1,Bd1/inc),.4)

xtset
gen Bdrop10 = max(min( (f10.inc - f9.inc)/inc3 , 1),-1) if f9.inc<. & f10.inc<. & inc3<.
gen Bdrop9 = max(min( (f9.inc - f8.inc)/inc3 , 1),-1) if f9.inc<. & f8.inc<. & inc3<.

gen lfracout = ln(fracout)

probit B pmind1 pd10 lavinc10 lavfoodtot10 lfracout lavhousing famsize age i.educ2 [pw=hhwt] if (inrange(eventyr,-10,-10) | !B) & hhtag2 & inrange(year,1975,1986) , cluster(id)

margins, dydx(*)


probit B pmind1 incdrop lavinc10 lavfoodtot10 lfracout lavhousing famsize age i.educ2 [pw=hhwt] if (inrange(eventyr,-10,-10) | !B) & hhtag2 & inrange(year,1975,1986) , cluster(id)

margins, dydx(*)

// question about divisor for pmind1 -- could divide first and use Mpd1 or divide by starting or by average
probit B pmind1_alt Bdrop* pd10_alt lavinc lavfoodtot10 lfracout lavhousing lfamsize age i.educ2  [pw=hhwt] if (inrange(eventyr,-10,-10) | !B) & hhtag2 & inrange(year,1975,1986) , cluster(id)
probit B Bdrop9 pd10_alt  lavinc10 lavfoodtot10 lfracout lavhousing famsize age i.educ2 [pw=hhwt] if (inrange(eventyr,-10,-10) | !B) & hhtag2 & inrange(year,1975,1986) , cluster(id)
probit B pmind1 Bdrop9 pd10_alt  lavinc10 lavfoodtot10 lfracout lavhousing famsize age i.educ2 [pw=hhwt] if (inrange(eventyr,-10,-10) | !B) & hhtag2 & inrange(year,1975,1986) , cluster(id)


// dummy variables for a drop
// measures of health and divorce
// wage garnishment data is from much later
// household exemptions data I have for 1980s...  could include and
//   then use state fixed effects



// find fraction of sample with a negative income spell
// find distribution of worst incomes



exit


// number of years with an unemployment spell
gen totemp = heademp 
forval i = 1/10 {
	replace totemp = totemp +  l`i'.heademp if l`i'.heademp<.
	}

// BWt2 adjusts for year but not starting income bin
summ totemp if !B [aw=Bwt2]
summ totemp  [aw=wt] if B & eventyr==-10


log close
exit


/*
twoway histogram d10 [aw=Bwt3] if !B & abs(d10)<100000 || kdensity d10 [w=Bwt3] if B & abs(d10)<100000 , bwidth(5000)
histogram d10 [w=Bwt3] if !B & abs(d10)<40000, width(4000)
histogram d10 [w=Bwt3] if B & abs(d10)<40000
*/

