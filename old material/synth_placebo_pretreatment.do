
/***********************************************************************
Author: Robert McClelland and John Iselin
Date: Summer 2017

Illinois Liquor tax increase and alcohol-related accidents. 

Suppl: Placebo Tests for varied pre-treatment period

Make sure that the synth program in installed:

ssc install synth

Note: While the tax changes occured in 1999 and 2009, since the first year 
when the tax change were fully in effect fell in 2000 and 2010, those are 
the first years of the "treatment".

Make sure that the filepaths are created as outlined in the READ-ME file by 
running synth_setup.do.

**************************************************************************/


*** Set-Up ***
clear matrix
clear all
capture log close
set more off


** MAC vs PC Filepaths
if regexm(c(os),"Mac") == 1 local mypath = "---/"
else if regexm(c(os),"Windows") == 1 local mypath = "---\"


cd "`mypath'"
log using "synth_alcohol_model_suppl_2000", replace


*** Loop over the following to create V1 - V4:
*** V1: Share of Accidents Due to Alcohol, No Controls (share, narrow)
*** V2: Share of Accidents Due to Alcohol, With Controls (share, controls)
*** V3: Alcohol-Related Accidents per Driver, No Controls (drivers, narrow)
*** V4: Alcohol-Related Accidents per Driver, With Controls (drivers, control)

local depvar drivers
local sizevar narrow controls

foreach a of local depvar {

	foreach b of local sizevar {	
		if regexm(c(os),"Mac") == 1 {
			local mypath_`a'_`b' = "`mypath'IL 2000 - `a' - `b'/"
	
	}
	else if regexm(c(os),"Windows") == 1 local mypath_`a'_`b' = "`mypath'IL 2000 - `a' - `b'\"
	

}
}	


* List of states included in donor pool (..._states_1 is just the first state)
global st_control AL ME MI MS MT NH NC OH OR PA UT VT VA WA WV WY
global st_tax CA CT DE FL IA NJ NM NV NY OK RI 
global st_never AK HI DC 


local narrow_states 4 5 8 13 16 18 20 21 22 24 25 27 29 31 38 45 46 47 48 55
local narrow_states_1 4
local controls_states 1 4 5 8 13 16 18 20 21 22 23 24 25 26 27 28 29 30 31 33 ///
	37 38 39 41 42 45 46 47 48 50 51 53 54 55 56 
local controls_states_1 1

* List of explanitory variables
local vars_share youngshare oldshare liverdeaths_percap
local vars_drivers pipercap_deflated gasolinetax_deflated unempl youngshare oldshare liverdeaths_percap 

* List choice of lags based on synth_preestimation results
* 1983, 1985, 1991, 1993, and 1998


foreach a of local depvar {

	foreach b of local sizevar {


cd "`mypath_`a'_`b''"

local vars1 `vars_`a'' `a'_alcohol(1983) `a'_alcohol(1985) `a'_alcohol(1991) `a'_alcohol(1993) `a'_alcohol(1998)
local vars2 `vars_`a'' 
local vars_labels `vars_`a'' `a'_alcohol_1983 `a'_alcohol_1985 `a'_alcohol_1991 `a'_alcohol_1993 `a'_alcohol_1998
di "`vars1'"
di "`vars2'"
di "`vars_labels'"
local states ``b'_states'
di "`states'"
local states_1 ``b'_states_1'
di "`states_1'"

use alcohol_`a'_`b'
tsset state year

* Note: Drop US First
drop if state == 0




*** Run Model with Explanatory variables + appropriate outcome lags
	

synth `a'_alcohol `vars2' ///
	`a'_alcohol(1991) `a'_alcohol(1993) `a'_alcohol(1998), ///
	trunit(17) trperiod(2000) xperiod(1990(1)1998)  keep(90_98) replace
graph export original.pdf, replace 
ereturn list
matrix list e(V_matrix)
matrix a = e(V_matrix)
clear

use original
drop if _time==.
gen IL_diff=_Y_synthetic-_Y_treated
drop _Co_Number _W_Weight _Y_treated _Y_synthetic
save IL_short, replace
clear


*** 3. Placebo Tests (In-Time and In-Place)

use alcohol_`a'_`b'
tsset state year

*Exclude Illinois and the US*
drop if state==17
drop if state==0
*Placebo states*
tempname placebo_mat		

****  In-space placebo test  ****

cd "`mypath_`a'_`b''placebo tests"

** Original Model

local names
foreach x of local states {
	synth `a'_alcohol `vars2' ///
	`a'_alcohol(1991) `a'_alcohol(1993) `a'_alcohol(1998), ///
	trunit(`x') trperiod(2000) xperiod(1990(1)1998)  keep(`x'placebo) replace

    matrix `placebo_mat' = nullmat(`placebo_mat') \ e(RMSPE)
    local names `"`names' `"`x'"'"'
}
mat colnames `placebo_mat' = "RMSPE"
mat rownames `placebo_mat' = `names'
matlist `placebo_mat' , row("Treated Unit")

clear

foreach x of local states {
	use `x'placebo
	drop if _time==.
	gen synth`x'_diff=_Y_synthetic-_Y_treated
	drop _Co_Number _W_Weight _Y_treated _Y_synthetic
	save `x'placebo_short, replace
}
clear

use `states_1'placebo_short

foreach x of local states {
	merge 1:1 _time using `x'placebo_short, keepusing(synth`x'_diff)
	drop _merge
}
cd "`mypath_`a'_`b''"
merge 1:1 _time using IL_short, keepusing(IL_diff)
drop _merge
order _time, first
save placebo_data, replace
clear


}

}

clear

log close
