/*
Takes prepared yearly PSID family data from "smalldata" directory (created by
dataprep_a) and matches individuals through the years using the
individual-level dataset.

Two separate files are created: bankruptpeople1, nonbankpeople1

Steps:
1) Load the family data from 1996 (bankruptcy response year), `small1996`
2) Keep bankrupty and non-bankrupt people separate for some reason...
3) Merge in all of the other family data files on own-year Interview Number
    (family's unique ID)
4) Deflate all dollar-valued variables using CPI
5) 

*/

clear all
set more off

run clean/io


global B wtrBank yrfile1 chapter bank_count asset_seize value_seize plan13_amt plan13_payperiod plan13_yrs plan13_mos plan13_wks plan13_done debt_totfiled debt_totremain statefiled
global bweight bankruptweight86-96

	//reshape variables
global widevars match cutoff state famsize hometype inc wt age sexofhead relhead employ hrwork educ headrace headinc mrstat heademp wifeemploy wifeinc numchild numadult rent rentmo mort mortmo mortpri wifelabor hvalue stamps stampsper foodhome_st foodhomeper_st fooddel_st fooddelper_st foodout_st foodoutper_st foodhome foodhomeper fooddel fooddelper foodout foodoutper foodtot foodouttot _m

local defyear 2009

foreach round in bank nobank {	
	
	use $td\small1996

	if ("`round'"=="bank") keep if yr>=1985 & yr<=1996		//keep people who filed between 1985 and 1996 for bankrupt round
	if ("`round'"=="nobank") keep if yr==0					//keep non-filers for non-bankrupt round
	
	merge match1996 using $DATA_PATH/individual_small, uniqm sort		//merge in individual multi-year dataset
	keep if _m==3
	drop _m
	
	if ("`round'"=="bank") {
		gen bankage = yr - birthyr
		drop if bankage<24 | bankage>1000
	}
	
	foreach i of num 2007(-2)1997 1995(-1)1974 {
		merge match`i' using $td/small`i', uniqus sort
		rename _merge _m`i'
		if ("`round'"=="bank") keep if yr>=1985 & yr<=1996
		if ("`round'"=="nobank") keep if yr==0
	}

	cross using "d:\users\daniel\google drive\postbinc\cpi1970_wide"	//deflators
	cross using "d:\users\daniel\google drive\postbinc\badyear_wide"	//t-2 income fix
															//Begin deflations
	foreach i of num 2006 2004 2002(-1)1974 {
		replace tfinc`i' = . if tfinc`i'>=9999998
		gen inc`i' = ratio`i'*tfinc`i'*cpi`defyear'/cpi`i'
	}

	foreach i of num 2006(-2)2002 1998 1996(-1)1974 {
		gen headinc`i' = headlabor`i'*cpi`defyear'/cpi`i'
		gen wifeinc`i' = wifelabor`i'*cpi`defyear'/cpi`i'
	}
	
	foreach i of num 1974/1986 1989/1996 1998(2)2006 {
		replace foodtot`i' = foodtot`i'*cpi`defyear'/cpi`i'
		replace foodouttot`i' = foodouttot`i'*cpi`defyear'/cpi`i'
	}
	
	foreach i of num 1976/1981 1983/1987 1990/1993 {
		if (1976<=`i' & `i'<=1981) replace mort`i'=. if mort`i'>=9999
		replace mort`i' = mort`i'*cpi`defyear'/cpi`i'
	}

	foreach i of num 1993/1997 1999(2)2007 {
		replace mortmo`i' = . if mortmo`i'>=99998
		replace mortmo`i' = mortmo`i'*cpi`defyear'/cpi`i'
	}

	foreach i of num 1974/1987 1990/1993 {
		if (`i'<=1982) replace rent`i'=. if rent`i'>=9998
		if (`i'>=1983) replace rent`i'=. if rent`i'>=99998
		replace rent`i' = rent`i'*cpi`defyear'/cpi`i'
	}

	foreach i of num 1993/1997 1999(2)2007 {
		replace rentmo1993 = . if rentmo1993>=9999
		if (`i'>=1994) replace rentmo`i'=. if rentmo`i'>=99998
		replace rentmo`i' = rentmo`i'*cpi`defyear'/cpi`i'
	}

	foreach i of num 1976/1981 1983/1997 1999(2)2007 {
		if (`i'>=1994) replace mortpri`i'=. if mortpri`i'>=9999997
		if (`i'<=1993 & `i'>=1983) replace mortpri`i'=. if mortpri`i'>=999997
		if (`i'<=1981) replace mortpri`i'=. if mortpri`i'>=99999
		replace mortpri`i' = mortpri`i'*cpi`defyear'/cpi`i'
	}

	foreach i of num 1974/1997 1999(2)2007 {
		if (`i'<=1993) replace hvalue`i' = . if hvalue`i'>=999998
		if (`i'>=1994) replace hvalue`i' = . if hvalue`i'>=9999997
		replace hvalue`i' = hvalue`i'*cpi`defyear'/cpi`i'
	}

	if ("`round'"=="bank") {
		replace debt_totfiled = . if debt_totfiled>=9999998
		replace debt_totremain = . if debt_totremain>=9999998
		forval i = 1985/1996 {
			replace debt_totfiled = debt_totfiled * cpi`defyear'/cpi`i' if yr==`i'
			replace debt_totremain = debt_totremain * cpi`defyear'/cpi`i' if yr==`i'
		}
	}


	drop ratio* cpi* tfinc* headlabor* wifelabor*
	compress

	gen id = _n
	if ("`round'"=="nobank") replace id = id + 100000


	gen famsize2006=.
	replace famsize2006 = (famsize2007 + famsize2005)/2 if famsize2007!=. & famsize2005!=. 
	replace famsize2006 = famsize2005 if famsize2007==. & famsize2005!=.
	replace famsize2006 = famsize2007 if famsize2007!=. & famsize2005==.
	
	gen famsize2004=.
	replace famsize2004 = (famsize2003 + famsize2005)/2 if famsize2003!=. & famsize2005!=. 
	replace famsize2004 = famsize2005 if famsize2003==. & famsize2005!=.
	replace famsize2004 = famsize2003 if famsize2003!=. & famsize2005==.

	gen famsize2002=.
	replace famsize2002 = (famsize2001 + famsize2003)/2 if famsize2001!=. & famsize2003!=. 
	replace famsize2002 = famsize2001 if famsize2003==. & famsize2001!=.
	replace famsize2002 = famsize2003 if famsize2003!=. & famsize2001==.

	gen famsize2000=.
	replace famsize2000 = (famsize2001 + famsize1999)/2 if famsize1999!=. & famsize2001!=. 
	replace famsize2000 = famsize2001 if famsize1999==. & famsize2001!=.
	replace famsize2000 = famsize1999 if famsize1999!=. & famsize2001==.

	gen famsize1998=.
	replace famsize1998 = (famsize1997 + famsize1999)/2 if famsize1999!=. & famsize1997!=. 
	replace famsize1998 = famsize1997 if famsize1999==. & famsize1997!=.
	replace famsize1998 = famsize1999 if famsize1999!=. & famsize1997==.

	
	
	reshape long $widevars , i(id) j(year)
	


	gen white = (headrace==1) if headrace<8
	gen black = (headrace==2) if headrace<8
	gen other_race = (headrace!=1 & headrace!=2) if headrace<8
		
	gen married = (mrstat==1) if mrstat<6
	gen single = (mrstat==2) if mrstat<6
	gen divorced = (mrstat==4) if mrstat<6
	gen other_mrstat = (mrstat==3 | mrstat==5) if mrstat<6
	

	if ("`round'"=="bank") replace age = year - birthyr if age==0 | age==-1
	else if ("`round'"=="nobank") {
		replace age = . if age<=0 | age>200
		replace birthyr = . if birthyr==0 | birthyr>3000
		replace age = year - birthyr if age==. & birthyr!=.
		gen newbirth = year - age if birthyr==.
		bys id: egen nb2 = median(newbirth)
		replace nb2 = floor(nb2)
		replace age = year - nb2 if age==. & birthyr==.
		drop if age == .
		replace age = . if age<0
		drop newbirth
		rename nb2 newbirth
		replace newbirth = birthyr if newbirth==.
	}

	gen capitainc = inc/famsize
	if ("`round'"=="bank") gen eventyr = year - yrfile1

	
	gen fracfoodout = foodouttot/foodtot

	xtset id year

	gen temp = wt if year==1996
	bys id (temp): gen wt2 = temp[1]
	drop temp

	replace match=. if match==0

	if ("`round'"=="bank") save $DATA_PATH/bankruptpeople1, replace
	else if ("`round'"=="nobank") save $DATA_PATH/nonbankpeople1, replace
}
