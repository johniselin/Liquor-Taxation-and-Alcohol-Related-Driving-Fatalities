
/***********************************************************************
Author: Robert McClelland and John Iselin
Date: Spring 2017

Illinois Liquor tax increase and alcohol-related accidents. 

Part 3: Post-Estimation Tests


We are examining the effect of a 2000 and 2009 Alcohol Tax Increase
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

For the 2000 IL tax change, there will be two versions of the model, one for 
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

Make sure that the filepaths are created as outlined in the READ-ME file.

**************************************************************************/



*** Set-Up ***
capture log close
clear matrix
clear all
set more off


** MAC vs PC Filepaths
if regexm(c(os),"Mac") == 1 {
	local mypath = "/Users/johniselin/Box Sync/LiquorTax/Data/Synth/"
	
	}
	else if regexm(c(os),"Windows") == 1 local mypath = "D:\Users\JIselin\Box Sync\LiquorTax\Data\Synth\"

cd "`mypath'"
log using "synth_alcohol_poestestimation_2000", replace


*** Loop over the following to create V1 - V4:
*** V1: Share of Accidents Due to Alcohol, No Controls (share, narrow)
*** V2: Share of Accidents Due to Alcohol, With Controls (share, controls)
*** V3: Alcohol-Related Accidents per Driver, No Controls (drivers, narrow)
*** V4: Alcohol-Related Accidents per Driver, With Controls (drivers, control)

local depvar share drivers
local sizevar narrow controls


foreach a of local depvar {
	foreach b of local sizevar {	
	
		if regexm(c(os),"Mac") == 1 {
			local mypath_`a'_`b' = "`mypath'IL 2000 - `a' - `b'/"
	
	}
	else if regexm(c(os),"Windows") == 1 local mypath_`a'_`b' = "`mypath'IL 2000 - `a' - `b'\"
	

}
}	

* List of explanitory variables
local vars_share youngshare oldshare liverdeaths_percap
local vars_drivers pipercap_deflated gasolinetax_deflated unempl youngshare oldshare liverdeaths_percap 

* List choice of lags based on synth_preestimation results
* 1983, 1985, 1991, 1993, and 1999


foreach a of local depvar {

	foreach b of local sizevar {

*** 1. Set Up 

cd "`mypath_`a'_`b''"

local vars `vars_`a''
di "`vars'"
local states ``b'_states'
di "`states'"
local states_1 ``b'_states_1'
di "`states_1'"

use alcohol_`a'_`b'
tsset state year
			

drop if state==0

cd "`mypath_`a'_`b''postestimation tests"		
		
*** 2. Vary lags used in model		
			

** Original Code - 1983, 1985, 1991, 1993, 1999

synth `a'_alcohol `vars' ///
	`a'_alcohol(1983) `a'_alcohol(1985) `a'_alcohol(1991) `a'_alcohol(1993) `a'_alcohol(1999), ///
	trunit(17) trperiod(2000) xperiod(1982(1)1999) fig keep(original) replace
graph export original.pdf, replace 


** Second set of lags - 1982, 1984, 1990, 1992, 1998
synth `a'_alcohol `vars' ///
	`a'_alcohol(1982) `a'_alcohol(1984) `a'_alcohol(1990) `a'_alcohol(1992) `a'_alcohol(1998), ///
	trunit(17) trperiod(2000) xperiod(1982(1)1999) fig keep(lags_v2) replace
graph export lags_v2.pdf, replace 


** Third set of lags - 1982, 1983, 1989, 1991, 1997
synth `a'_alcohol `vars' ///
	`a'_alcohol(1982) `a'_alcohol(1983) `a'_alcohol(1989) `a'_alcohol(1991) `a'_alcohol(1997), ///
	trunit(17) trperiod(2000) xperiod(1982(1)1999) fig keep(lags_v3) replace
graph export lags_v3.pdf, replace 

** Smooth lags using tssmooth

tssmooth ma `a'_alcohol_sm= `a'_alcohol, window (2 1 2)
synth `a'_alcohol `vars' ///
	`a'_alcohol_sm(1984) `a'_alcohol_sm(1989) `a'_alcohol_sm(1994) `a'_alcohol_sm(1999), ///
	trunit(17) trperiod(2000) xperiod(1982(1)1999) fig keep(lags_smooth) replace
graph export lags_smooth.pdf, replace 



clear

	foreach file in original lags_v2 lags_v3 lags_smooth {
		use "`file'"
		drop if _time==.
		drop _Co_Number _W_Weight
		quietly: save "`file'_short", replace
	}
clear

use original_short
rename _Y_synthetic _original_synth
local file lags_v2 lags_v3 

	foreach x of local file {
	merge 1:1 _time _Y_treated using `x'_short, keepusing(_Y_synthetic)
	rename _Y_synthetic _`x'_synth
	drop _merge

}

order _time, first
quietly: save lag_test, replace
clear


*** 3. Vary the pre-intervention time period
		

cd "`mypath_`a'_`b''"	

use alcohol_`a'_`b'
tsset state year
drop if state==0

cd "`mypath_`a'_`b''postestimation tests"		

	
*** 1982-1999***
*** See "original.dta" 	   

***1985-1999***

synth `a'_alcohol `vars' ///
	`a'_alcohol(1985) `a'_alcohol(1991) `a'_alcohol(1993) `a'_alcohol(1999), ///
	trunit(17) trperiod(2000) xperiod(1985(1)1999)  keep(85_99) replace


***1990-1999***
synth `a'_alcohol `vars' ///
	`a'_alcohol(1991) `a'_alcohol(1993) `a'_alcohol(1999), ///
	trunit(17) trperiod(2000) xperiod(1985(1)1999)  keep(90_99) replace

***1994-1999***
synth `a'_alcohol `vars' ///
	`a'_alcohol(1994) `a'_alcohol(1999), ///
	trunit(17) trperiod(2000) xperiod(1985(1)1999)  keep(94_99) replace


clear
foreach file in original 85_99 90_99 94_99 {
	use "`file'"
	drop if _time==.
	drop _Co_Number _W_Weight
	quietly: save "`file'_short", replace
}
clear

use original_short
rename _Y_synthetic _82_synth
merge 1:1 _time _Y_treated using 85_99_short, keepusing(_Y_synthetic)
rename _Y_synthetic _85_synth
drop _merge
merge 1:1 _time _Y_treated using 90_99_short, keepusing(_Y_synthetic)
rename _Y_synthetic _90_synth
drop _merge
merge 1:1 _time _Y_treated using 94_99_short, keepusing(_Y_synthetic)
rename _Y_synthetic _94_synth
drop _merge
order _time, first
quietly: save timeperiod_test, replace
clear



*** 4. In turn drop individual states used in the synthetic IL
*			 With each state, examine why it might be important and included 
cd "`mypath_`a'_`b''"	
use donorstate_weights
keep state weight_`a'_`b'
drop if weight_`a'_`b' == .
keep if weight_`a'_`b' > 0
levelsof state, local(leaveoneout)
clear




* DESIGNATE states used to construct IL below	


foreach x of local leaveoneout {
cd "`mypath_`a'_`b''"		
use alcohol_`a'_`b'.dta
tsset state year
drop if state == 0 
drop if state == `x'
cd "`mypath_`a'_`b''postestimation tests"	

synth `a'_alcohol `vars' ///
	`a'_alcohol(1983) `a'_alcohol(1985) `a'_alcohol(1991) `a'_alcohol(1993) `a'_alcohol(1999), ///
	trunit(17) trperiod(2000) xperiod(1982(1)1999) fig keep(no_`x') replace
graph export "no_`x'.pdf", replace 

clear 

}
cd "`mypath_`a'_`b''postestimation tests"	

clear
foreach x of local leaveoneout{
	use "no_`x'"
	drop if _time==.
	drop _Co_Number _W_Weight
	quietly: save "no_`x'_short", replace
}
clear

use original_short

rename _Y_synthetic _allin_synth

foreach x of local leaveoneout {
merge 1:1 _time _Y_treated using "no_`x'_short", keepusing(_Y_synthetic)
rename _Y_synthetic _no_`x'_synth
drop _merge

}

order _time, first
quietly: save leave_one_out, replace
clear

}
}

log close
