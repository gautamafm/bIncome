/*
This file takes each year's family PSID dataset, and renames and keeps variables of interest.  Each 
parred down year is then saved in the "smalldata" directory and spliced together by dataprep_b.do
*/

clear all
set maxvar 20000
set more off

run clean/io

global B wrBank yrfile1 chapter bank_count asset_seize value_seize plan13_amt plan13_payperiod plan13_yrs plan13_mos plan13_wks plan13_done debt_totfiled debt_totremain stfiled
global keeper match tf* state famsize hometype sexofhead headrace headlabor mrstat wt wifelabor numchild mort* rent* hvalue food* stamps*

local day 30
local week 30/7
local twoweek 30/14

use $root\fam_2007\fam_2007
rename ER36002 match2007
rename ER36016 famsize2007
rename ER36028 hometype2007		//1 own or buying, 5 rent
rename ER41027 tfinc2006
rename ER41069 wt2007
rename ER36004 state2007
rename ER36018 sexofhead2007
rename ER40565 headrace2007
rename ER40921 headlabor2006
rename ER36013 mrstat2007			//1 married, 2 single, 3 widowed, 4 divored, 5 separated
rename ER40933 wifelabor2006	
rename ER36020 numchild2007
rename ER36044 mortmo2007
rename ER36065 rentmo2007
rename ER36042 mortpri2007
rename ER36029 hvalue2007
rename ER36673 stamps2006
rename ER36674 stampsper2006		//3 week, 4 two weeks, 5 month, 6 year, 7 other, 8 DK, 9 NA refused, 0 Inap.
rename ER36706 foodhome_st2006
rename ER36707 foodhomeper_st2006	//2 day, 3 week, 4 two weeks, 5 month, 6 year, 7 other, 8 DK, 9 NA refused, 0 Inap. 
rename ER36710 fooddel_st2006
rename ER36711 fooddelper_st2006
rename ER36713 foodout_st2006
rename ER36714 foodoutper_st2006
rename ER36716 foodhome2006
rename ER36717 foodhomeper2006
rename ER36720 fooddel2006
rename ER36721 fooddelper2006
rename ER36723 foodout2006
rename ER36724 foodoutper2006
keep  $keeper

foreach sta in 2 _st {
	foreach var in home del out {
		replace food`var'`sta' = . if food`var'`sta'>=99997
		replace food`var'`sta' = food`var'`sta'*`day' if food`var'per`sta'==2
		replace food`var'`sta' = food`var'`sta'*`week' if food`var'per`sta'==3
		replace food`var'`sta' = food`var'`sta'*`twoweek' if food`var'per`sta'==4
		replace food`var'`sta' = food`var'`sta'/12 if food`var'per`sta'==6
		replace food`var'`sta' = . if food`var'per`sta'>6
	}
}
replace stamps2 = . if stamps2>=999997
replace stamps2 = stamps2*`day' if stampsper==2
replace stamps2 = stamps2*`week' if stampsper==3
replace stamps2 = stamps2*`twoweek' if stampsper==4
replace stamps2 = stamps2/12 if stampsper==6 
replace stamps2 = . if stampsper==6

egen foodtot2006 = rowtotal(stamps2 foodhome_st fooddel_st foodout_st foodhome2 fooddel2 foodout2)
egen foodouttot2006 = rowtotal(foodout_st foodout2)

sort match
save $td\small2007, replace

use $root\fam_2005\fam_2005, clear
rename ER25002 match2005
rename ER25016 famsize2005
rename ER25028 hometype2005
rename ER28037 tfinc2004
rename ER28078 wt2005
rename ER25004 state2005
rename ER25018 sexofhead2005
rename ER27393 headrace2005
rename ER27931 headlabor2004
rename ER25023 mrstat2005
rename ER27943 wifelabor2004
rename ER25020 numchild2005
rename ER25044 mortmo2005
rename ER25063 rentmo2005
rename ER25042 mortpri2005
rename ER25029 hvalue2005
rename ER25655 stamps2004
rename ER25656 stampsper2004
rename ER25688 foodhome_st2004
rename ER25689 foodhomeper_st2004
rename ER25692 fooddel_st2004
rename ER25693 fooddelper_st2004
rename ER25695 foodout_st2004
rename ER25696 foodoutper_st2004
rename ER25698 foodhome2004
rename ER25699 foodhomeper2004
rename ER25702 fooddel2004
rename ER25703 fooddelper2004
rename ER25705 foodout2004
rename ER25706 foodoutper2004
keep  $keeper

foreach sta in 2 _st {
	foreach var in home del out {
		replace food`var'`sta' = . if food`var'`sta'>=99997
		replace food`var'`sta' = food`var'`sta'*`day' if food`var'per`sta'==2
		replace food`var'`sta' = food`var'`sta'*`week' if food`var'per`sta'==3
		replace food`var'`sta' = food`var'`sta'*`twoweek' if food`var'per`sta'==4
		replace food`var'`sta' = food`var'`sta'/12 if food`var'per`sta'==6
		replace food`var'`sta' = . if food`var'per`sta'>6
	}
}
replace stamps2 = . if stamps2>=999997
replace stamps2 = stamps2*`day' if stampsper==2
replace stamps2 = stamps2*`week' if stampsper==3
replace stamps2 = stamps2*`twoweek' if stampsper==4
replace stamps2 = stamps2/12 if stampsper==6 
replace stamps2 = . if stampsper==6

egen foodtot2004 = rowtotal(stamps2 foodhome_st fooddel_st foodout_st foodhome2 fooddel2 foodout2)
egen foodouttot2004 = rowtotal(foodout_st foodout2)

sort match2005
save $td\small2005, replace

use $root\fam_2003\fam_2003, clear
rename ER21002 match2003
rename ER21016 famsize2003
rename ER21042 hometype2003
rename ER24099 tfinc2002
rename ER23764 tfinc2001
rename ER24180 wt2003
rename ER21004 state2003
rename ER21018 sexofhead2003
rename ER23426 headrace2003
rename ER24116 headlabor2002
rename ER21023 mrstat2003
rename ER24135 wifelabor2002
rename ER21020 numchild2003
rename ER21053 mortmo2003
rename ER21072 rentmo2003
rename ER21051 mortpri2003
rename ER21043 hvalue2003
rename ER21653 stamps2002
rename ER21654 stampsper2002
rename ER21686 foodhome_st2002
rename ER21687 foodhomeper_st2002
rename ER21690 fooddel_st2002
rename ER21691 fooddelper_st2002
rename ER21693 foodout_st2002
rename ER21694 foodoutper_st2002
rename ER21696 foodhome2002
rename ER21697 foodhomeper2002
rename ER21700 fooddel2002
rename ER21701 fooddelper2002
rename ER21703 foodout2002
rename ER21704 foodoutper2002
keep  $keeper

foreach sta in 2 _st {
	foreach var in home del out {
		replace food`var'`sta' = . if food`var'`sta'>=99997
		replace food`var'`sta' = food`var'`sta'*`day' if food`var'per`sta'==2
		replace food`var'`sta' = food`var'`sta'*`week' if food`var'per`sta'==3
		replace food`var'`sta' = food`var'`sta'*`twoweek' if food`var'per`sta'==4
		replace food`var'`sta' = food`var'`sta'/12 if food`var'per`sta'==6
		replace food`var'`sta' = . if food`var'per`sta'>6
	}
}
replace stamps2 = . if stamps2>=999997
replace stamps2 = stamps2*`day' if stampsper==2
replace stamps2 = stamps2*`week' if stampsper==3
replace stamps2 = stamps2*`twoweek' if stampsper==4
replace stamps2 = stamps2/12 if stampsper==6 
replace stamps2 = . if stampsper==6

egen foodtot2002 = rowtotal(stamps2 foodhome_st fooddel_st foodout_st foodhome2 fooddel2 foodout2)
egen foodouttot2002 = rowtotal(foodout_st foodout2)

sort match2003
save $td\small2003, replace

use $root\fam_2001\fam_2001, clear
rename ER17012 famsize2001
rename ER20165 tfinc1999
rename ER17043 hometype2001
rename ER20456 tfinc2000
rename ER17002 match2001
rename ER20459 wt2001
rename ER17005 state2001
rename ER17014 sexofhead2001
rename ER19989 headrace2001
rename ER17024 mrstat2001
rename ER17635 HU2000
rename ER17353 heademp2000
rename ER20447 wifelabor2000
rename ER17016 numchild2001
rename ER17054 mortmo2001
rename ER17074 rentmo2001
rename ER17052 mortpri2001
rename ER17044 hvalue2001
rename ER18387 stamps2000
rename ER18388 stampsper2000
rename ER18421 foodhome_st2000
rename ER18422 foodhomeper_st2000
rename ER18425 fooddel_st2000
rename ER18426 fooddelper_st2000
rename ER18428 foodout_st2000
rename ER18429 foodoutper_st2000
rename ER18431 foodhome2000
rename ER18432 foodhomeper2000
rename ER18435 fooddel2000
rename ER18436 fooddelper2000
rename ER18438 foodout2000
rename ER18439 foodoutper2000
gen headlabor=1
keep HU heademp  $keeper 

foreach sta in 2 _st {
	foreach var in home del out {
		replace food`var'`sta' = . if food`var'`sta'>=99997
		replace food`var'`sta' = food`var'`sta'*`day' if food`var'per`sta'==2
		replace food`var'`sta' = food`var'`sta'*`week' if food`var'per`sta'==3
		replace food`var'`sta' = food`var'`sta'*`twoweek' if food`var'per`sta'==4
		replace food`var'`sta' = food`var'`sta'/12 if food`var'per`sta'==6
		replace food`var'`sta' = . if food`var'per`sta'>6
	}
}
replace stamps2 = . if stamps2>=999997
replace stamps2 = stamps2*`day' if stampsper==2
replace stamps2 = stamps2*`week' if stampsper==3
replace stamps2 = stamps2*`twoweek' if stampsper==4
replace stamps2 = stamps2/12 if stampsper==6 
replace stamps2 = . if stampsper==6

egen foodtot2000 = rowtotal(stamps2 foodhome_st fooddel_st foodout_st foodhome2 fooddel2 foodout2)
egen foodouttot2000 = rowtotal(foodout_st foodout2)

drop headlabor
foreach s in HU heademp {
	replace `s' = . if `s' ==8 | `s'==9 | `s'==0
	replace `s' = 0 if `s'==5
}
replace heademp = HU if heademp==.
drop HU

sort match2001
save $td\small2001, replace

use $root\fam_1999\fam_1999, clear
rename ER13009 famsize1999
rename ER13040 hometype1999
rename ER16219 tfinc1997
rename ER16462 tfinc1998
rename ER13002 match1999
rename ER16519 wt1999
rename ER13005 state1999
rename ER13011 sexofhead1999
rename ER15928 headrace1999
rename ER16463 headlabor1998
rename ER13021 mrstat1999
rename ER13583 HU1998
rename ER13330 heademp1998
rename ER16465 wifelabor1998
rename ER13013 numchild1999
rename ER13048 mortmo1999
rename ER13065 rentmo1999
rename ER13047 mortpri1999
rename ER13041 hvalue1999
rename ER14256 stamps1998
rename ER14257 stampsper1998
rename ER14288 foodhome_st1998
rename ER14289 foodhomeper_st1998
rename ER14291 fooddel_st1998
rename ER14292 fooddelper_st1998
rename ER14293 foodout_st1998
rename ER14294 foodoutper_st1998
rename ER14295 foodhome1998
rename ER14296 foodhomeper1998
rename ER14298 fooddel1998
rename ER14299 fooddelper1998
rename ER14300 foodout1998
rename ER14301 foodoutper1998
keep HU heademp  $keeper 
foreach s in HU heademp {
	replace `s' = . if `s' ==8 | `s'==9 | `s'==0
	replace `s' = 0 if `s'==5
}
replace heademp = HU if heademp==.

foreach sta in 1 _st {
	foreach var in home del out {
		replace food`var'`sta' = . if food`var'`sta'>=99997
		replace food`var'`sta' = food`var'`sta'*`day' if food`var'per`sta'==2
		replace food`var'`sta' = food`var'`sta'*`week' if food`var'per`sta'==3
		replace food`var'`sta' = food`var'`sta'*`twoweek' if food`var'per`sta'==4
		replace food`var'`sta' = food`var'`sta'/12 if food`var'per`sta'==6
		replace food`var'`sta' = . if food`var'per`sta'>6
	}
}
replace stamps1 = . if stamps1>=999997
replace stamps1 = stamps1*`day' if stampsper==2
replace stamps1 = stamps1*`week' if stampsper==3
replace stamps1 = stamps1*`twoweek' if stampsper==4
replace stamps1 = stamps1/12 if stampsper==6 
replace stamps1 = . if stampsper==6

egen foodtot1998 = rowtotal(stamps1 foodhome_st fooddel_st foodout_st foodhome1 fooddel1 foodout1)
egen foodouttot1998 = rowtotal(foodout_st foodout1)

drop HU
sort match
save $td\small1999, replace

use $root\fam_1997\fam_1997, clear
rename ER10008 famsize1997
rename ER10035 hometype1997
rename ER12079 tfinc1996
rename ER10002 match1997
rename ER12224 wt1997
rename ER10004 state1997
rename ER10010 sexofhead1997
rename ER11848 headrace1997
rename ER12080 headlabor1996
rename ER10016 mrstat1997
rename ER10438 HU1996
rename ER10199 heademp1996
rename ER12082 wifelabor1996
rename ER10012 numchild1997
rename ER10046 mortmo1997
rename ER10060 rentmo1997
rename ER10044 mortpri1997
rename ER10036 hvalue1997
rename ER11050 stamps1996
rename ER11051 stampsper1996
rename ER11068 foodhome_st1996
rename ER11069 foodhomeper_st1996
rename ER11071 fooddel_st1996
rename ER11072 fooddelper_st1996
rename ER11073 foodout_st1996
rename ER11074 foodoutper_st1996
rename ER11076 foodhome1996
rename ER11077 foodhomeper1996
rename ER11079 fooddel1996
rename ER11080 fooddelper1996
rename ER11081 foodout1996
rename ER11082 foodoutper1996
keep HU heademp  $keeper
foreach s in HU heademp {
	replace `s' = . if `s' ==8 | `s'==9 | `s'==0
	replace `s' = 0 if `s'==5
}
replace heademp = HU if heademp==.
drop HU

foreach sta in 1 _st {
	foreach var in home del out {
		replace food`var'`sta' = . if food`var'`sta'>=99997
		replace food`var'`sta' = food`var'`sta'*`day' if food`var'per`sta'==2
		replace food`var'`sta' = food`var'`sta'*`week' if food`var'per`sta'==3
		replace food`var'`sta' = food`var'`sta'*`twoweek' if food`var'per`sta'==4
		replace food`var'`sta' = food`var'`sta'/12 if food`var'per`sta'==6
		replace food`var'`sta' = . if food`var'per`sta'>6
	}
}
replace stamps1 = . if stamps1>=99997
replace stamps1 = stamps1*`day' if stampsper==2
replace stamps1 = stamps1*`week' if stampsper==3
replace stamps1 = stamps1*`twoweek' if stampsper==4
replace stamps1 = stamps1/12 if stampsper==6 
replace stamps1 = . if stampsper==6

egen foodtot1996 = rowtotal(stamps1 foodhome_st fooddel_st foodout_st foodhome1 fooddel1 foodout1)
egen foodouttot1996 = rowtotal(foodout_st foodout1)

sort match
save $td\small1997, replace

use $root\fam_1996\fam_1996, clear
rename ER9244 tfinc1995
rename ER7031 hometype1996
rename ER7002 match1996
rename ER7005 famsize1996
rename ER8915 wrBank
rename ER8917 yrfile1
rename ER8926 chapter
rename ER8916 bank_count
rename ER8927 asset_seize
rename ER8928 value_seize
rename ER8929 plan13_amt
rename ER8930 plan13_payperiod
rename ER8931 plan13_yrs
rename ER8932 plan13_mos
rename ER8933 plan13_wks
rename ER8934 plan13_done
rename ER8935 debt_totfiled
rename ER8936 debt_totremain	//over 997 drop
rename ER8918 stfiled
rename ER9248 state1996
rename ER9251 wt1996
rename ER7007 sexofhead1996
rename ER9060 headrace1996
rename ER9231 headlabor1995
rename ER7013 mrstat1996
rename ER7528 HU1995
rename ER7283 heademp1995
rename ER9235 wifelabor1995
rename ER7657 wifeemploy1996	//1=working, 2=temporarily laid off, sick/maternity, 3=unemployed, 4=retired, 5=disabled, 6=keeping house, 7=student, 8=other, jail, 0=N/A
rename ER7009 numchild1996
rename ER7044 mortmo1996
rename ER7121 rentmo1996
gen longwtfam = wt1996
rename ER7042 mortpri1996
rename ER7032 hvalue1996
rename ER8156 stamps1995
rename ER8157 stampsper1995
rename ER8174 foodhome_st1995
rename ER8175 foodhomeper_st1995
rename ER8177 fooddel_st1995
rename ER8178 fooddelper_st1995
rename ER8179 foodout_st1995
rename ER8180 foodoutper_st1995
rename ER8181 foodhome1995
rename ER8182 foodhomeper1995
rename ER8184 fooddel1995
rename ER8185 fooddelper1995
rename ER8186 foodout1995
rename ER8187 foodoutper1995
keep HU heademp wifeemploy  $keeper $B state1996
foreach s in HU heademp {
	replace `s' = . if `s' ==8 | `s'==9 | `s'==0
	replace `s' = 0 if `s'==5
}
replace heademp = HU if heademp==.
drop HU

foreach sta in 1 _st {
	foreach var in home del out {
		replace food`var'`sta' = . if food`var'`sta'>=99997
		replace food`var'`sta' = food`var'`sta'*`day' if food`var'per`sta'==2
		replace food`var'`sta' = food`var'`sta'*`week' if food`var'per`sta'==3
		replace food`var'`sta' = food`var'`sta'*`twoweek' if food`var'per`sta'==4
		replace food`var'`sta' = food`var'`sta'/12 if food`var'per`sta'==6
		replace food`var'`sta' = . if food`var'per`sta'>6
	}
}
replace stamps1 = . if stamps1>=99997
replace stamps1 = stamps1*`day' if stampsper==2
replace stamps1 = stamps1*`week' if stampsper==3
replace stamps1 = stamps1*`twoweek' if stampsper==4
replace stamps1 = stamps1/12 if stampsper==6 
replace stamps1 = . if stampsper==6

egen foodtot1995 = rowtotal(stamps1 foodhome_st fooddel_st foodout_st foodhome1 fooddel1 foodout1)
egen foodouttot1995 = rowtotal(foodout_st foodout1)

sort match
save $td\small1996, replace

use $root\fam_1995\fam_1995, clear
rename ER5005 famsize1995
rename ER5002 match1995
rename ER5031 hometype1995
rename ER6993 tfinc1994 	//9999998 high
rename ER6997 state1995
rename ER5007 sexofhead1995
rename ER6814 headrace1995
rename ER6980 headlabor1994
rename ER5013 mrstat1995
rename ER7000 wt1995
rename ER5432 HU1994
rename ER5187 heademp1994
rename ER6984 wifelabor1994
rename ER5561 wifeemploy1995
rename ER5009 numchild1995
rename ER5038 mortmo1995
rename ER5048 rentmo1995
rename ER5036 mortpri1995
rename ER5032 hvalue1995
rename ER6059 stamps1994
rename ER6060 stampsper1994
rename ER6077 foodhome_st1994
rename ER6078 foodhomeper_st1994
rename ER6080 fooddel_st1994
rename ER6081 fooddelper_st1994
rename ER6082 foodout_st1994
rename ER6083 foodoutper_st1994
rename ER6084 foodhome1994
rename ER6085 foodhomeper1994
rename ER6087 fooddel1994
rename ER6088 fooddelper1994
rename ER6089 foodout1994
rename ER6090 foodoutper1994
keep HU heademp wifeemploy  $keeper
foreach s in HU heademp {
	replace `s' = . if `s' ==8 | `s'==9 | `s'==0
	replace `s' = 0 if `s'==5
}
replace heademp = HU if heademp==.
drop HU

foreach sta in 1 _st {
	foreach var in home del out {
		replace food`var'`sta' = . if food`var'`sta'>=99997
		replace food`var'`sta' = food`var'`sta'*`day' if food`var'per`sta'==2
		replace food`var'`sta' = food`var'`sta'*`week' if food`var'per`sta'==3
		replace food`var'`sta' = food`var'`sta'*`twoweek' if food`var'per`sta'==4
		replace food`var'`sta' = food`var'`sta'/12 if food`var'per`sta'==6
		replace food`var'`sta' = . if food`var'per`sta'>6
	}
}
replace stamps1 = . if stamps1>=99997
replace stamps1 = stamps1*`day' if stampsper==2
replace stamps1 = stamps1*`week' if stampsper==3
replace stamps1 = stamps1*`twoweek' if stampsper==4
replace stamps1 = stamps1/12 if stampsper==6 
replace stamps1 = . if stampsper==6

egen foodtot1994 = rowtotal(stamps1 foodhome_st fooddel_st foodout_st foodhome1 fooddel1 foodout1)
egen foodouttot1994 = rowtotal(foodout_st foodout1)

sort match
save $td\small1995, replace

use $root\fam_1994\fam_1994, clear
rename ER2006 famsize1994
rename ER2032 hometype1994
rename ER2002 match1994
rename ER4153 tfinc1993		//9999998 high
rename ER4157 state1994
rename ER2008 sexofhead1994
rename ER3944 headrace1994
rename ER4140 headlabor1993
rename ER2014 mrstat1994
rename ER4160 wt1994
rename ER2433 HU1993
rename ER2188 heademp1993
rename ER4144 wifelabor1993
rename ER2562 wifeemploy1994
rename ER2010 numchild1994
rename ER2039 mortmo1994
rename ER2049 rentmo1994
rename ER2037 mortpri1994
rename ER2033 hvalue1994
rename ER3060 stamps1993
rename ER3061 stampsper1993
rename ER3078 foodhome_st1993
rename ER3079 foodhomeper_st1993
rename ER3081 fooddel_st1993
rename ER3082 fooddelper_st1993
rename ER3083 foodout_st1993
rename ER3084 foodoutper_st1993
rename ER3085 foodhome1993
rename ER3086 foodhomeper1993
rename ER3088 fooddel1993
rename ER3089 fooddelper1993
rename ER3090 foodout1993
rename ER3091 foodoutper1993
keep HU heademp wifeemploy  $keeper
foreach s in HU heademp {
	replace `s' = . if `s' ==8 | `s'==9 | `s'==0
	replace `s' = 0 if `s'==5
}
replace heademp = HU if heademp==.
drop HU

foreach sta in 1 _st {
	foreach var in home del out {
		replace food`var'`sta' = . if food`var'`sta'>=99997
		replace food`var'`sta' = food`var'`sta'*`day' if food`var'per`sta'==2
		replace food`var'`sta' = food`var'`sta'*`week' if food`var'per`sta'==3
		replace food`var'`sta' = food`var'`sta'*`twoweek' if food`var'per`sta'==4
		replace food`var'`sta' = food`var'`sta'/12 if food`var'per`sta'==6
		replace food`var'`sta' = . if food`var'per`sta'>6
	}
}

replace stamps1 = . if stamps1>=99997
replace stamps1 = stamps1*`day' if stampsper==2
replace stamps1 = stamps1*`week' if stampsper==3
replace stamps1 = stamps1*`twoweek' if stampsper==4
replace stamps1 = stamps1/12 if stampsper==6 
replace stamps1 = . if stampsper==6

egen foodtot1993 = rowtotal(stamps1 foodhome_st fooddel_st foodout_st foodhome1 fooddel1 foodout1)
egen foodouttot1993 = rowtotal(foodout_st foodout1)

sort match
save $td\small1994, replace

use $root\fam_1993\fam_1993, clear
rename V22405 famsize1993
rename V22427 hometype1993
rename V21602 match1993
rename V23322 tfinc1992
rename V21603 state1993
rename V22407 sexofhead1993
rename V23276 headrace1993
rename V23323 headlabor1992
rename V22412 mrstat1993
rename V23361 wt1993
rename V22735 HU1992
rename V22569 heademp1992
rename V23324 wifelabor1992
rename V22801 wifeemploy1993
rename V22409 numchild1993
rename V21614 mortmo1993
rename V21615 mort1993
rename V21620 rentmo1993
rename V21622 rent1993
rename V21612 mortpri1993
rename V21610 hvalue1993
rename V21713 stamps1992
rename V21714 stampsper1992
rename V21707 foodhome1992
rename V21711 foodout1993

keep HU heademp wifeemploy $keeper
foreach s in HU heademp {
	replace `s' = . if `s' ==8 | `s'==9 | `s'==0
	replace `s' = 0 if `s'==5
}
replace heademp = HU if heademp==.
drop HU
sort match

replace foodhome=. if foodhome>=99998
replace foodout =. if foodout>=9998

replace foodout = foodout/12
replace foodhome = foodhome/12

replace stamps1 = . if stamps1>=9997
replace stamps1 = stamps1*`day' if stampsper==2
replace stamps1 = stamps1*`week' if stampsper==3
replace stamps1 = stamps1*`twoweek' if stampsper==4
replace stamps1 = stamps1/12 if stampsper==6 
replace stamps1 = . if stampsper==6

egen foodtot1992 = rowtotal(stamps1 foodhome foodout)
gen foodouttot1992 = foodout1

save $td\small1993, replace

use $root\fam_1992\fam_1992, clear
rename V20650 famsize1992
rename V20302 match1992
rename V20672 hometype1992
rename V21481 tfinc1991
rename V20303 state1992
rename V20652 sexofhead1992
rename V21420 headrace1992
rename V21484 headlabor1991
rename V20657 mrstat1992
rename V21547 wt1992
rename V20939 HU1991
rename V20792 heademp1991
rename V20436 wifelabor1991
rename V20995 wifeemploy1992
rename V20654 numchild1992
rename V20397 numadult1992
rename V20409 foodout1991
rename V20328 mort1992
rename V20333 rent1992
rename V20326 mortpri1992
rename V20324 hvalue1992
rename V20407 foodhome1991
rename V20411 stamps1991
keep HU heademp wifeemploy numadult $keeper
foreach s in HU heademp {
	replace `s' = . if `s' ==8 | `s'==9 | `s'==0
	replace `s' = 0 if `s'==5
}
replace heademp = HU if heademp==.
drop HU
sort match

replace foodhome=. if foodhome>=99998
replace foodout =. if foodout>=9998
replace stamps=. if stamps>=9998

egen foodtot1991 = rowtotal(stamps foodhome foodout)
gen foodouttot1991 = foodout1

save $td\small1992, replace

use $root\fam_1991\fam_1991, clear
rename V19348 famsize1991
rename V19002 match1991
rename V19372 hometype1991
rename V20175 tfinc1990
rename V19003 state1991
rename V19350 sexofhead1991
rename V20114 headrace1991
rename V20178 headlabor1990
rename V19355 mrstat1991
rename V20243 wt1991
rename V19639 HU1990
rename V19492 heademp1990
rename V19136 wifelabor1990
rename V19695 wifeemploy1991
rename V19352 numchild1991
rename V19097 numadult1991
rename V19109 foodout1990
rename V19028 mort1991
rename V19033 rent1991
rename V19026 mortpri1991
rename V19024 hvalue1991
rename V19107 foodhome1990
rename V19111 stamps1990
keep HU heademp wifeemploy numadult $keeper
foreach s in HU heademp {
	replace `s' = . if `s' ==8 | `s'==9 | `s'==0
	replace `s' = 0 if `s'==5
}
replace heademp = HU if heademp==.
drop HU

replace foodhome=. if foodhome>=99998
replace foodout =. if foodout>=9998
replace stamps=. if stamps>=9998

egen foodtot1990 = rowtotal(stamps foodhome foodout)
gen foodouttot1990 = foodout1

sort match
save $td\small1991, replace

use $root\fam_1990\fam_1990, clear
rename V18048 famsize1990
rename V18072 hometype1990
rename V17702 match1990
rename V18875 tfinc1989
rename V17703 state1990
rename V18050 sexofhead1990
rename V18814 headrace1990
rename V18878 headlabor1989
rename V18055 mrstat1990
rename V18943 wt1990
rename V18339 HU1989
rename V18192 heademp1989
rename V17836 wifelabor1989
rename V18395 wifeemploy1990
rename V18052 numchild1990
rename V17797 numadult1990
rename V17809 foodout1989
rename V17728 mort1990
rename V17733 rent1990
rename V17726 mortpri1990
rename V17724 hvalue1990
rename V17807 foodhome1989
rename V17811 stamps1989
keep HU heademp wifeemploy $keeper
foreach s in HU heademp {
	replace `s' = . if `s' ==8 | `s'==9 | `s'==0
	replace `s' = 0 if `s'==5
}
replace heademp = HU if heademp==.
drop HU

replace foodhome=. if foodhome>=99998
replace foodout =. if foodout>=9998
replace stamps=. if stamps>=9998

egen foodtot1989 = rowtotal(stamps foodhome foodout)
gen foodouttot1989 = foodout1

sort match
save $td\small1990, replace

use $root\fam_1989\fam_1989, clear
rename V16630 famsize1989
rename V16302 match1989
rename V16641 hometype1989
rename V17533 tfinc1988
rename V16303 state1989
rename V16632 sexofhead1989
rename V17483 headrace1989
rename V17534 headlabor1988
rename V16637 mrstat1989
rename V17612 wt1989
rename V16915 HU1988
rename V16754 heademp1988
rename V16420 wifelabor1988
rename V16974 wifeemploy1989
rename V16634 numchild1989
rename V16388 numadult1989
rename V16326 mortpri1989
rename V16324 hvalue1989
rename V16395 stamps1988
gen foodhome=0
gen rent = 0
gen foodout=0
gen mort=0
keep HU heademp wifeemploy numadult $keeper
drop foodout mort rent foodhome
foreach s in HU heademp {
	replace `s' = . if `s' ==8 | `s'==9 | `s'==0
	replace `s' = 0 if `s'==5
}
replace heademp = HU if heademp==.
drop HU

sort match
save $td\small1989, replace

use $root\fam_1988\fam_1988, clear
rename V15129 famsize1988
rename V15140 hometype1988
rename V14802 match1988
rename V16144 tfinc1987
rename V14803 state1988
rename V15131 sexofhead1988
rename V16086 headrace1988
rename V16145 headlabor1987
rename V15136 mrstat1988
rename V16208 wt1988
rename V15400 HU1987
rename V15253 heademp1987
rename V14920 wifelabor1987
rename V15456 wifeemploy1988
rename V15133 numchild1988
rename V14888 numadult1988
rename V14826 mortpri1988
rename V14824 hvalue1988
rename V14895 stamps1987
gen foodhome= 0
gen mort=0
gen foodout=0
gen rent = 0
keep HU heademp wifeemploy numadult $keeper
drop foodout mort rent foodhome
foreach s in HU heademp {
	replace `s' = . if `s' ==8 | `s'==9 | `s'==0
	replace `s' = 0 if `s'==5
}
replace heademp = HU if heademp==.
drop HU

sort match
save $td\small1988, replace

use $root\fam_1987\fam_1987, clear
rename V14113 famsize1987
rename V13702 match1987
rename V14126 hometype1987
rename V14670 tfinc1986
rename V13703 state1987
rename V14115 sexofhead1987
rename V14612 headrace1987
rename V14671 headlabor1986
rename V14120 mrstat1987
rename V14737 wt1987
rename V14290 HU1986
rename V14199 heademp1986
rename V13905 wifelabor1986
rename V14321 wifeemploy1987
rename V14117 numchild1987
rename V13866 numadult1987
rename V13878 foodout1986
rename V13728 mort1987
rename V13732 rent1987
rename V13726 mortpri1987
rename V13724 hvalue1987
rename V13876 foodhome1986
rename V13880 stamps1986
keep HU heademp wifeemploy numadult $keeper
foreach s in HU heademp {
	replace `s' = . if `s' ==8 | `s'==9 | `s'==0
	replace `s' = 0 if `s'==5
}
replace heademp = HU if heademp==.
drop HU

replace foodhome=. if foodhome>=99998
replace foodout =. if foodout>=9998
replace stamps=. if stamps>=9998

egen foodtot1986 = rowtotal(stamps foodhome foodout)
gen foodouttot1986 = foodout1

sort match
save $td\small1987, replace

use $root\fam_1986\fam_1986, clear
rename V13010 famsize1986
rename V12502 match1986
rename V13023 hometype1986
rename V13623 tfinc1985
rename V12503 state1986
rename V13012 sexofhead1986
rename V13565 headrace1986
rename V13624 headlabor1985
rename V13017 mrstat1986
rename V13687 wt1986
rename V13194 HU1985
rename V13101 heademp1985
rename V12803 wifelabor1985
rename V13225 wifeemploy1986
rename V13014 numchild1986
rename V12762 numadult1986
rename V12776 foodout1985
rename V12528 mort1986
rename V12532 rent1986
rename V12526 mortpri1986
rename V12524 hvalue1986
rename V12774 foodhome1985
rename V12778 stamps1985
keep HU heademp wifeemploy numadult $keeper
foreach s in HU heademp {
	replace `s' = . if `s' ==8 | `s'==9 | `s'==0
	replace `s' = 0 if `s'==5
}
replace heademp = HU if heademp==.
drop HU

replace foodhome=. if foodhome>=99998
replace foodout =. if foodout>=9998
replace stamps=. if stamps>=9998

egen foodtot1985 = rowtotal(stamps foodhome foodout)
gen foodouttot1985 = foodout1

sort match
save $td\small1986, replace

use $root\fam_1985\fam_1985, clear
rename V11605 famsize1985
rename V11618 hometype1985
rename V11102 match1985
rename V12371 tfinc1984
rename V11103 state1985
rename V11607 sexofhead1985
rename V11938 headrace1985
rename V12372 headlabor1984
rename V11612 mrstat1985
rename V12446 wt1985
rename V11798 HU1984
rename V11701 heademp1984
rename V11404 wifelabor1984
rename V12000 wifeemploy1985
rename V11609 numchild1985
rename V11363 numadult1985
rename V11377 foodout1984
rename V11129 mort1985
rename V11133 rent1985
rename V11127 mortpri1985
rename V11125 hvalue1985
rename V11375 foodhome1984
rename V11379 stamps1984
keep HU heademp wifeemploy numadult $keeper
foreach s in HU heademp {
	replace `s' = . if `s' ==8 | `s'==9 | `s'==0
	replace `s' = 0 if `s'==5
}
replace heademp = HU if heademp==.
drop HU

replace foodhome=. if foodhome>=99998
replace foodout =. if foodout>=9998
replace stamps=. if stamps>=9998

egen foodtot1984 = rowtotal(stamps foodhome foodout)
gen foodouttot1984 = foodout1

sort match
save $td\small1985, replace

use $root\fam_1984\fam_1984, clear
rename V10418 famsize1984
rename V10437 hometype1984
rename V10002 match1984
rename V11022 tfinc1983
rename V10003 state1984
rename V10420 sexofhead1984
rename V11055 headrace1984
rename V11023 headlabor1983
rename V10426 mrstat1984
rename V11079 wt1984
rename V10625 HU1983
rename V10557 heademp1983
rename V10263 wifelabor1983
rename V10671 wifeemploy1984
rename V10422 numchild1984
rename V10221 numadult1984
rename V10237 foodout1983
rename V10022 mort1984
rename V10026 rent1984
rename V10020 mortpri1984
rename V10018 hvalue1984
rename V10235 foodhome1983
rename V10239 stamps1983
keep HU heademp wifeemploy numadult $keeper
foreach s in HU heademp {
	replace `s' = . if `s' ==8 | `s'==9 | `s'==0
	replace `s' = 0 if `s'==5
}
replace heademp = HU if heademp==.
drop HU

replace foodhome=. if foodhome>=99998
replace foodout =. if foodout>=9998
replace stamps=. if stamps>=9998

egen foodtot1983 = rowtotal(stamps foodhome foodout)
gen foodouttot1983 = foodout1

sort match
save $td\small1984, replace

use $root\fam_1983\fam_1983, clear
rename V8960 famsize1983
rename V8802 match1983
rename V8974 hometype1983
rename V9375 tfinc1982
rename V8803 state1983
rename V8962 sexofhead1983
rename V9408 headrace1983
rename V9376 headlabor1982
rename V9276 mrstat1983
rename V9433 wt1983
rename V9117 HU1982
rename V9032 heademp1982
rename V8881 wifelabor1982
rename V9188 wifeemploy1983
rename V8964 numchild1983
rename V8850 numadult1983
rename V8866 foodout1982
rename V8821 mort1983
rename V8825 rent1983
rename V8819 mortpri1983
rename V8817 hvalue1983
rename V8864 foodhome1982
rename V8868 stamps1982
keep HU heademp wifeemploy numadult $keeper
foreach s in HU heademp {
	replace `s' = . if `s' ==8 | `s'==9 | `s'==0
	replace `s' = 0 if `s'==5
}
replace heademp = HU if heademp==.
drop HU

replace foodhome=. if foodhome>=99998
replace foodout =. if foodout>=9998
replace stamps=. if stamps>=9998

egen foodtot1982 = rowtotal(stamps foodhome foodout)
gen foodouttot1982 = foodout1

sort match
save $td\small1983, replace

use $root\fam_1982\fam_1982, clear
rename V8351 famsize1982
rename V8202 match1982
rename V8364 hometype1982
rename V8689 tfinc1981
rename V8203 state1982
rename V8353 sexofhead1982
rename V8723 headrace1982
rename V8690 headlabor1981
rename V8603 mrstat1982
rename V8727 wt1982
rename V8480 HU1981
rename V8401 heademp1981
rename V8273 wifelabor1981
rename V8538 wifeemploy1982
rename V8355 numchild1982
rename V8248 numadult1982
rename V8258 foodout1981
rename V8221 rent1982
rename V8217 hvalue1982
rename V8256 foodhome1981
rename V8260 stamps1981
gen mortpri = 0
gen mort = 0
keep HU heademp wifeemploy numadult $keeper
drop mort mortpri
foreach s in HU heademp {
	replace `s' = . if `s' ==8 | `s'==9 | `s'==0
	replace `s' = 0 if `s'==5
}
replace heademp = HU if heademp==.
drop HU

replace foodhome=. if foodhome>=9998
replace foodout =. if foodout>=9998
replace stamps=. if stamps>=9998

egen foodtot1981 = rowtotal(stamps foodhome foodout)
gen foodouttot1981 = foodout1

sort match
save $td\small1982, replace

use $root\fam_1981\fam_1981, clear
rename V7657 famsize1981
rename V7502 match1981
rename V7675 hometype1981
rename V8065 tfinc1980
rename V7503 state1981
rename V7659 sexofhead1981
rename V8099 headrace1981
rename V8066 headlabor1980
rename V7952 mrstat1981
rename V8103 wt1981
rename V7819 HU1980
rename V7739 heademp1980
rename V7580 wifelabor1980
rename V7879 wifeemploy1981
rename V7661 numchild1981
rename V7550 numadult1981
rename V7566 foodout1980
rename V7521 mort1981
rename V7525 rent1981
rename V7519 mortpri1981
rename V7517 hvalue1981
rename V7564 foodhome1980
rename V7568 stamps1980
keep HU heademp wifeemploy numadult $keeper
foreach s in HU heademp {
	replace `s' = . if `s' ==8 | `s'==9 | `s'==0
	replace `s' = 0 if `s'==5
}
replace heademp = HU if heademp==.
drop HU

replace foodhome=. if foodhome>=9998
replace foodout =. if foodout>=9998
replace stamps=. if stamps>=9998

egen foodtot1980 = rowtotal(stamps foodhome foodout)
gen foodouttot1980 = foodout1

sort match
save $td\small1981, replace

use $root\fam_1980\fam_1980, clear
rename V7066 famsize1980
rename V6902 match1980
rename V7084 hometype1980
rename V7412 tfinc1979
rename V6903 state1980
rename V7068 sexofhead1980
rename V7447 headrace1980
rename V7413 headlabor1979
rename V7261 mrstat1980
rename V7451 wt1980
rename V7171 HU1979
rename V7116 heademp1979
rename V6988 wifelabor1979
rename V7193 wifeemploy1980
rename V7070 numchild1980
rename V6958 numadult1980
rename V6974 foodout1979
rename V6921 mort1980
rename V6925 rent1980
rename V6919 mortpri1980
rename V6917 hvalue1980
rename V6972 foodhome1979
rename V6976 stamps1979
keep HU heademp wifeemploy numadult $keeper
foreach s in HU heademp {
	replace `s' = . if `s' ==8 | `s'==9 | `s'==0
	replace `s' = 0 if `s'==5
}
replace heademp = HU if heademp==.
drop HU

replace foodhome=. if foodhome>=9998
replace foodout =. if foodout>=9998
replace stamps=. if stamps>=9998

egen foodtot1979 = rowtotal(stamps foodhome foodout)
gen foodouttot1979 = foodout1

sort match
save $td\small1980, replace


use $root\fam_1979\fam_1979, clear
rename V6302 match1979
rename V6479 hometype1979
rename V6463 sexofhead1979
rename V6766 tfinc1978
rename V6461 famsize1979
rename V6303 state1979
rename V6802 headrace1979
rename V6767 headlabor1978
rename V6659 mrstat1979
rename V6805 wt1979
rename V6569 HU1978
rename V6513 heademp1978
rename V6398 wifelabor1978
rename V6591 wifeemploy1979
rename V6465 numchild1979
rename V6360 numadult1979
rename V6378 foodout1978
rename V6323 mort1979
rename V6326 rent1979
rename V6321 mortpri1979
rename V6319 hvalue1979
rename V6376 foodhome1978
rename V6372 paidstamp
rename V6374 bonusstamp
gen stamps1978 = paidstamp + bonusstamp if paidstamp<999 & bonusstamp<999
keep HU heademp wifeemploy numadult $keeper
foreach s in HU heademp {
	replace `s' = . if `s' ==8 | `s'==9 | `s'==0
	replace `s' = 0 if `s'==5
}
replace heademp = HU if heademp==.
drop HU

replace foodhome=. if foodhome>=9998
replace foodout =. if foodout>=9998
replace stamps=. if stamps>=9998

egen foodtot1978 = rowtotal(stamps foodhome foodout)
gen foodouttot1978 = foodout1

sort match
save $td\small1979, replace


use $root\fam_1978\fam_1978, clear
rename V5702 match1978
rename V5851 sexofhead1978
rename V5864 hometype1978
rename V6173 tfinc1977
rename V5849 famsize1978
rename V5703 state1978
rename V6209 headrace1978
rename V6174 headlabor1977
rename V6034 mrstat1978
rename V6212 wt1978
rename V5996 HU1977
rename V5902 heademp1977
rename V5788 wifelabor1977
rename V5853 numchild1978
rename V5779 numadult1978
rename V5772 foodout1977
rename V5721 mort1978
rename V5723 rent1978
rename V5719 mortpri1978
rename V5717 hvalue1978
rename V5770 foodhome1977
rename V5766 paidstamp
rename V5768 bonusstamp
gen stamps1977 = paidstamp + bonusstamp if paidstamp<999 & bonusstamp<999
keep HU heademp numadult $keeper
foreach s in HU heademp {
	replace `s' = . if `s' ==8 | `s'==9 | `s'==0
	replace `s' = 0 if `s'==5
}
replace heademp = HU if heademp==.
drop HU

replace foodhome=. if foodhome>=9998
replace foodout =. if foodout>=9998
replace stamps=. if stamps>=9998

egen foodtot1977 = rowtotal(stamps foodhome foodout)
gen foodouttot1977 = foodout1

sort match
save $td\small1978, replace


use $root\fam_1977\fam_1977, clear
rename V5202 match1977
rename V5351 sexofhead1977
rename V5364 hometype1977
rename V5626 tfinc1976
rename V5349 famsize1977
rename V5203 state1977
rename V5662 headrace1977
rename V5627 headlabor1976
rename V5502 mrstat1977
rename V5665 wt1977
rename V5469 HU1976
rename V5413 heademp1976
rename V5289 wifelabor1976
rename V5353 numchild1977
rename V5280 numadult1977
rename V5273 foodout1976
rename V5221 mort1977
rename V5225 rent1977
rename V5219 mortpri1977
rename V5217 hvalue1977
rename V5271 foodhome1976
rename V5267 paidstamp
rename V5269 bonusstamp
gen stamps1976 = paidstamp + bonusstamp if paidstamp<999 & bonusstamp<999
keep HU heademp numadult $keeper
foreach s in HU heademp {
	replace `s' = . if `s' ==8 | `s'==9 | `s'==0
	replace `s' = 0 if `s'==5
}
replace heademp = HU if heademp==.
drop HU

replace foodhome=. if foodhome>=9998
replace foodout =. if foodout>=9998
replace stamps=. if stamps>=9998

egen foodtot1976 = rowtotal(stamps foodhome foodout)
gen foodouttot1976 = foodout1

sort match
save $td\small1977, replace


use $root\fam_1976\fam_1976, clear
rename V4302 match1976
rename V4437 sexofhead1976
rename V4450 hometype1976
rename V5029 tfinc1975
rename V4435 famsize1976
rename V4303 state1976
rename V5096 headrace1976
rename V5031 headlabor1975
rename V4603 mrstat1976
rename V5099 wt1976
rename V4567 HU1975
rename V4502 heademp1975
rename V4379 wifelabor1975
rename V4841 wifeemploy1976
rename V4439 numchild1976
rename V4370 numadult1976
rename V4368 foodout1975
rename V4322 mort1976
rename V4326 rent1976
rename V4320 mortpri1976
rename V4318 hvalue1976
rename V4354 foodhome1975
rename V4357 paidstamp
rename V4359 bonusstamp
gen stamps1975 = paidstamp + bonusstamp if paidstamp<999 & bonusstamp<999
keep HU heademp wifeemploy numadult $keeper
foreach s in HU heademp {
	replace `s' = . if `s' ==8 | `s'==9 | `s'==0
	replace `s' = 0 if `s'==5
}
replace heademp = HU if heademp==.
drop HU

replace foodhome=. if foodhome>=9998
replace foodout =. if foodout>=9998
replace stamps=. if stamps>=9998

egen foodtot1975 = rowtotal(stamps foodhome foodout)
gen foodouttot1975 = foodout1

sort match
save $td\small1976, replace


use $root\fam_1975\fam_1975, clear
rename V3802 match1975
rename V3922 sexofhead1975
rename V3939 hometype1975
rename V4154 tfinc1974
rename V3920 famsize1975
rename V3803 state1975
rename V4204 headrace1975
rename V3863 headlabor1974
rename V4053 mrstat1975
rename V4224 wt1975
rename V3865 wifelabor1974
rename V3924 numchild1975
rename V3855 numadult1975
rename V3853 foodout1974
rename V3819 rent1975
rename V3817 hvalue1975
rename V3841 foodhome1974
rename V3844 paidstamp
rename V3846 bonusstamp
gen stamps1974 = paidstamp + bonusstamp if paidstamp<999 & bonusstamp<999
gen mortpri =0
gen mort = 0
keep numadult $keeper
drop mort mortpri

replace foodhome=. if foodhome>=9998
replace foodout =. if foodout>=9998
replace stamps=. if stamps>=9998

egen foodtot1974 = rowtotal(foodhome foodout)
gen foodouttot1974 = foodout1

sort match
save $td\small1975, replace


use $root\fam_1974\fam_1974, clear
rename V3402 match1974
rename V3509 sexofhead1974
rename V3522 hometype1974
rename V3676 tfinc1973
rename V3507 famsize1974
rename V3403 state1974
rename V3720 headrace1974
rename V3463 headlabor1973
rename V3598 mrstat1974
rename V3721 wt1974
rename V3465 wifelabor1973
rename V3511 numchild1974
rename V3455 numadult1974
rename V3445 foodout1973
rename V3419 rent1974
rename V3417 hvalue1974
rename V3441 foodhome1973
gen mort = 0
gen mortpri = 0
gen stamps = 0
keep numadult $keeper
drop mort mortpri stamps

replace foodhome=. if foodhome>=9998
replace foodout =. if foodout>=9998

egen foodtot1973 = rowtotal(foodhome foodout)
gen foodouttot1973 = foodout1

sort match
save $td\small1974, replace
