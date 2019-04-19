/***********************************************************************
Author: Robert McClelland and John Iselin
Date: Spring 2017 (Edited January 2018)

Illinois Liquor tax increase and alcohol-related accidents. 

Part 3: Post-Estimation Tests


We are examining the effect of a 1999 and 2009 Alcohol Tax Increase
In Illinois. This do-file takes a constructed dataset and runs 
through a set of pre- and post-estimation tests and models the
effects of the tax change using the synthetic control method as 
described in Abadie, Diamond, and Hainmuller (2010).

This do-file is the third of three. This file takes the datasets created, 
in synth_preestimation and runs through a series of post-estimation tests
for each version of the data (discibed below) - once with all pre-treatment
dependent variable lags, and once with our selected explanetory variables 
plus lags selected based on our preestimation tests. 

Please refer to the READ ME file before running this do-file to be sure that
folders and datasets are correctly organized. 

For the 1999 IL tax change, there will be two versions of the model, one for 
each dependent variable: the share of total accidents with BAC values over 0.08 
(share_alcohol) and the total number of accidents with BAC values over 0.08 
divided by the number of drivers (drivers_alcohol). For each of these dependent 
variables, we run the model over our set of donor states, which is all 50 states 
plus DC minus states with large liquor tax changes, states with liquor control 
as opposed to or in addition to taxes, and Alaska, DC, and Hawaii. As a 
sensitivity analysis we also will re-run the models over a second set of donor 
states where we add back in states with liquor control boards.

Make sure that the synth program in installed:

ssc install synth

Note: While the tax changes occured in 1999 and 2009, since the first year 
when the tax change were fully in effect fell in 2000 and 2010, those are 
the first years of the "treatment".

Make sure that the filepaths are created as outlined in the READ-ME file by 
running synth_setup.do.

**************************************************************************/



*** Set-Up ***
capture log close
clear matrix
clear all
set more off


** MAC vs PC Filepaths

if regexm(c(os),"Mac") == 1 local mypath = "/Users/johniselin/Desktop/Desktop - John’s MacBook Pro/TPC/Illinois Alcohol Taxes and Drunk Driving/Results/Synth Run 01.05.2019 21 Plus/"
else if regexm(c(os),"Windows") == 1 local mypath = "...\"

if regexm(c(os),"Mac") == 1 local mypath_nb = "/Users/johniselin/Desktop/Desktop - John’s MacBook Pro/TPC/Illinois Alcohol Taxes and Drunk Driving/Results/Synth Run 01.05.2019 21 Plus/No Borders/"
else if regexm(c(os),"Windows") == 1 local mypath_nb = "...\"

if regexm(c(os),"Mac") == 1 {
	local mypath_logs = "`mypath'/Logs/"
	local mypath_data = "`mypath'/Data/"
	
	}
else if regexm(c(os),"Windows") == 1 {
	local mypath_logs = "`mypath'\Logs\"
	local mypath_data = "`mypath'\Data\"
	}

	
cd "`mypath_nb'"
log using "`mypath_logs'synth_alcohol_postestimation_nb_21plus_2000", replace


*** Loop over the following to create V1 - V4:
*** V1: Share of Accidents Due to Alcohol, No Controls (share, narrow)
*** V3: Alcohol-Related Accidents per Driver, No Controls (drivers, narrow)


local depvar share
local sizevar narrow 

foreach a of local depvar {
	foreach b of local sizevar {	
	
		if regexm(c(os),"Mac") == 1 {
			local mypath_`a'_`b' = "`mypath_nb'IL 2000 - `a' - `b'/"
	
	}
	else if regexm(c(os),"Windows") == 1 local mypath_`a'_`b' = "`mypath_nb'IL 2000 - `a' - `b'\"
	

}
}	

* List of explanitory variables
local vars_share youngshare oldshare liverdeaths_percap
local vars_drivers pipercap_deflated gasolinetax_deflated unempl youngshare oldshare liverdeaths_percap 


foreach a of local depvar {

	foreach b of local sizevar {

*** 1. Set Up 

cd "`mypath_`a'_`b''"

local vars1 `vars_`a'' `a'_alcohol(1993) `a'_alcohol(1995) `a'_alcohol(1998)
local vars2 `vars_`a'' 
di "`vars1'"
di "`vars2'"
local states ``b'_states'
di "`states'"
local states_1 ``b'_states_1'
di "`states_1'"


*** 3. Vary the pre-intervention time period
		

cd "`mypath_`a'_`b''"	

*** 1992-1998***

use all_lags 	   


cd "`mypath_`a'_`b''postestimation tests"		

save all_lags, replace

clear

cd "`mypath_`a'_`b''"	
use alcohol_`a'_`b'
tsset state year
drop if state==0

cd "`mypath_`a'_`b''postestimation tests"	
***1990-1998***

synth `a'_alcohol `a'_alcohol(1990) `a'_alcohol(1991) `a'_alcohol(1992) ///
	  `a'_alcohol(1993) `a'_alcohol(1994) `a'_alcohol(1995) `a'_alcohol(1996) ///
	`a'_alcohol(1997) `a'_alcohol(1998), trunit(17) trperiod(2000) ///
	 xperiod(1990(1)1998) mspeperiod(1990(1)1998) resultsperiod(1990(1)2009) ///
	 keep(90_98) replace

***1988-1998***
synth `a'_alcohol `a'_alcohol(1988) `a'_alcohol(1989) ///
	`a'_alcohol(1990) `a'_alcohol(1991) `a'_alcohol(1992) ///
	`a'_alcohol(1993) `a'_alcohol(1994) `a'_alcohol(1995) `a'_alcohol(1996) ///
	`a'_alcohol(1997) `a'_alcohol(1998), ///
		trunit(17) trperiod(2000) xperiod(1988(1)1998) mspeperiod(1988(1)1998) ///
	 resultsperiod(1988(1)2009) keep(88_98) replace

***1986-1998***
synth `a'_alcohol `a'_alcohol(1986) `a'_alcohol(1987) `a'_alcohol(1988) `a'_alcohol(1989) ///
	`a'_alcohol(1990) `a'_alcohol(1991) `a'_alcohol(1992) ///
	`a'_alcohol(1993) `a'_alcohol(1994) `a'_alcohol(1995) `a'_alcohol(1996) ///
	`a'_alcohol(1997) `a'_alcohol(1998), ///
	 trunit(17) trperiod(2000) xperiod(1986(1)1998) mspeperiod(1986(1)1998) ///
	 resultsperiod(1986(1)2009) keep(86_98) replace


clear
foreach file in all_lags 90_98 88_98 86_98 {
	use "`file'"
	drop if _time==.
	drop _Co_Number _W_Weight
	quietly: save "`file'_short", replace
}
clear

use all_lags_short
rename _Y_synthetic _92_synth
merge 1:1 _time _Y_treated using 90_98_short, keepusing(_Y_synthetic)
rename _Y_synthetic _90_synth
drop _merge
merge 1:1 _time _Y_treated using 88_98_short, keepusing(_Y_synthetic)
rename _Y_synthetic _88_synth
drop _merge
merge 1:1 _time _Y_treated using 86_98_short, keepusing(_Y_synthetic)
rename _Y_synthetic _86_synth
drop _merge
order _time, first
sort _time
quietly: save timeperiod_test, replace
export excel using "`mypath_nb'Analysis_`a'_`b'_2000.xlsx", sheet("Pre-Treatment Test - Data") sheetmodify  firstrow(var)
clear



*** 4. In turn drop individual states used in the synthetic IL
*			 With each state, examine why it might be important and included 
	
use "`mypath_data'donorstate_weights_nb_21plus_2000.dta"
keep state weight_`a'_`b'
drop if weight_`a'_`b' == .
keep if weight_`a'_`b' > 0
levelsof state, local(leaveoneout)
di `leaveoneout'
clear




* DESIGNATE states used to construct IL below	


foreach x of local leaveoneout {
cd "`mypath_`a'_`b''"		
use alcohol_`a'_`b'.dta
tsset state year
drop if state == 0 
drop if state == `x'
cd "`mypath_`a'_`b''postestimation tests"	

synth `a'_alcohol `a'_alcohol(1992) ///
	`a'_alcohol(1993) `a'_alcohol(1994) `a'_alcohol(1995) `a'_alcohol(1996) ///
	`a'_alcohol(1997) `a'_alcohol(1998), ///
	trunit(17) trperiod(2000) xperiod(1992(1)1998) mspeperiod(1992(1)1998) ///
	 resultsperiod(1992(1)2009) fig keep(no_`x') replace
graph export "no_`x'.pdf", replace 

clear 

}
	
foreach x of local leaveoneout{
	use "no_`x'"
	drop if _time==.
	drop _Co_Number _W_Weight
	quietly: save "no_`x'_short", replace
}
clear

use all_lags_short

rename _Y_synthetic _allin_synth

foreach x of local leaveoneout {
merge 1:1 _time _Y_treated using "no_`x'_short", keepusing(_Y_synthetic)
rename _Y_synthetic _no_`x'_synth
drop _merge

}

order _time, first
quietly: save leave_one_out, replace
export excel using "`mypath_nb'Analysis_`a'_`b'_2000.xlsx", sheet("Leave-One-Out - Data") sheetmodify  firstrow(var)
clear

}
}

log close
