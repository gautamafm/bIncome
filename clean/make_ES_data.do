clear all
set more off

run util/env.do

//  fig04 is going to try to simplify this mess a fair bit.  
//  instead of a new set of weights for each year, we'll just use the Bwt weights
//  which are averaged over the whole sample.  or at least that will be my goal



/**********************************************************/
// bankruptcy weights -- make a set of weights (Bwt) that make the rest of the
//                       population have the same age distribution as the bankrupt
//                       ten years before they filed.
//                       do this over many different starting years and save each version
//  remember that Bwt is a weight that gives each person a weight that makes the
//    nonB population the same as the nonB population



// make fake datasets to append results to
set obs 1
gen temp = 0
save $DATA_PATH/incdist01, replace
save $DATA_PATH/altshock01, replace

use $DATA_PATH/regdata03

gen foodpercap = foodtot/famsize
// gen fracfoodout = foodouttot/foodtot

//  make a stat list 
local C  housing mort rent fracfoodout foodpercap foodouttot foodtot mortpri hvalue heq heq_ratio
foreach var of varlist `C' {
	local C_mean `C_mean' `var'_M = `var' 
	}

	
	
forval year = 1975(1)1986 {
	// 2014 find the weight of the B in that year
	// but without eventyr restriction this is the weight of all the people who ever file, not just file in `year'
	//  the eventyr restriction made it just the filing -10 year.  I am not sure which way I want it
	//  yet -- 

	// I use Btot to weight each year when I collapse down to the ES
	qui summ Bwt if /*eventyr==-10 &*/ year == `year' & B // this is the total weight of the B in that year
	local Btot = r(sum) //  put this aggregate weight in the local Btot 
	
	// now I assign the year's weights to each nonB person across his whole profile based on
	// the Bwt that I used in the t-10 year 
	// note that the B will all have missing tempwt
	bys id : gen tempwt = Bwt if !B & year==`year' // only one -- these are not B people
	bys id : egen Bwtlife`year' = sum(tempwt) // only one nonempty so Bwtlife`year' is constant over the id
	replace Bwtlife`year' = 0 if Bwtlife`year' == .

	/**********************************************************/ 
	// income profile bins for nonB based on t-10 income
	sort inc3
	gen temp = sum(tempwt) //  these are nonmissing for the current year
	gen trash = temp/temp[_N] // this goes from 0 to 1 by income but only on this years obs 
	gen incbin`year' = 1 + floor(9.9999*trash) if inc3<. & !B & year ==`year'  // makes ten income buckets
	drop temp tempwt trash
	// the above only assigns a value in the current year
    // assigns the one nonmissing temp incbin across all person's observations	
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
	append using $DATA_PATH/consumption01
	save $DATA_PATH/consumption01 , replace
	restore
*/	
   drop temp_incbin
}
