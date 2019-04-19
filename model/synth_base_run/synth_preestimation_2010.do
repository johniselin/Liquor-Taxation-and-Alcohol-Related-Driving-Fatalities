
/***********************************************************************
Author: Robert McClelland and John Iselin
Date: Spring 2017 (Updated January 2019)

Illinois Liquor tax increase and alcohol-related accidents. 

Part 1: Pre-Estimation Tests

Part 1: Pre-Estimation Tests

We are examining the effect of a 1999 and 2009 Alcohol Tax Increase in Illinois. 

This set of do-files constructs a dataset and runs through a set of pre- and 
post-estimation tests and models the effects of the tax change using the 
synthetic control method as described in Abadie, Diamond, and Hainmuller (2010).

This do-file is the first of three for the second tax change. This file creates 
the various datasets and a series of figures, from which we can determine which 
states are appropriate to include in our pool of donors, and which lagged values 
of the dependent variables should be used in our model. In the initial run the
preestimation do-files are run first and examined prior to running the full 
model to assure the right specifications are used for the SCM. 

Please refer to the READ ME file before running this do-file to be sure that
folders and datasets are correctly organized. 

Note: While the tax changes occured in 1999 and 2009, since the first year 
when the tax change were fully in effect fell in 2000 and 2010, those are 
the first years of the "treatment".

**************************************************************************/


/* If running w/o master do-file uncomment and  use filepath below

*** Set-Up ***
capture log close
clear matrix
clear all
set more off


** MAC vs PC Filepaths
if regexm(c(os),"Mac") == 1 local mypath = ".../"
else if regexm(c(os),"Windows") == 1 local mypath = "...\"
*/

if regexm(c(os),"Mac") == 1 {
	local mypath_share_narrow = "`mypath'/IL 2010 - share - narrow/"
	local mypath_drivers_narrow = "`mypath'/IL 2010 - drivers - narrow/"
	local mypath_logs = "`mypath'/Logs/"
	local mypath_data = "`mypath'/Data/"
	
	}
	else if regexm(c(os),"Windows") == 1 {
	local mypath_share_narrow = "`mypath'\IL 2010 - share - narrow\"
	local mypath_drivers_narrow = "`mypath'\IL 2010 - drivers - narrow\"
	local mypath_logs = "`mypath'\Logs\"
	local mypath_data = "`mypath'\Data\"
	}

	
cd "`mypath'"
log using "`mypath_logs'synth_alcohol_preestimation_2010", replace


global st_control AL ME MI MS MT NH NC OH OR PA UT VT VA WA WV WY
global st_tax CA DE NM NV NJ RI 
global st_never AK HI DC 

local vars_share share_alcohol youngshare oldshare liverdeaths_percap
local vars_drivers drivers_alcohol pipercap_deflated gasolinetax_deflated unempl youngshare oldshare liverdeaths_percap 

use "`mypath_data'alcohol_bac01.dta"
tsset state year

sum 
de

** 1. Create Datasets ***

*** Version 1: IL 2009 treatment with share_alcohol dependent variable
*** 			 Drop control states, high-tax states, and never-use states


use "`mypath_data'alcohol_bac01.dta"
tsset state year


foreach x of global st_control {
drop if stateabb == "`x'" 
}

foreach x of global st_tax {
drop if stateabb == "`x'" 
}

foreach x of global st_never {
drop if stateabb == "`x'" 
}

sum 
de

quietly: save "`mypath_share_narrow'alcohol_share_narrow.dta", replace
clear

clear


*** Version 3: IL 2009 treatment with drivers_alcohol dependent variable 
*** 			 Drop control states, high-tax states and never-use states
***				 Drop 2015 because of missing Driver Data

use "`mypath_data'alcohol_bac01.dta"
tsset state year


foreach x of global st_control {
drop if stateabb == "`x'" 
}

foreach x of global st_tax {
drop if stateabb == "`x'" 
}

foreach x of global st_never {
drop if stateabb == "`x'" 
}


sum 
de

quietly: save "`mypath_drivers_narrow'alcohol_drivers_narrow.dta", replace

clear



*** 2. Pre-Estimation Tests


*** V1: Share of Accidents Due to Alcohol, No Controls

local depvar share
local sizevar narrow

cd "`mypath_`depvar'_`sizevar''"

local vars `vars_`depvar''
di "`vars'"

use alcohol_`depvar'_`sizevar'


tabstat `vars' if year < 2009 & year > 1991, statistics(mean) by(statename)
tabstat `vars' if state == 17 & year > 1991, statistics(sum) by(year)


*** 2.1. Test averages of explanitory variables for pre-treatment period
* 			See where IL ranks against other states when expl. variables are averaged between 1982 and 1999
* 			Graph state values to determine the place of IL relative to other states. 	
* 			Table of each variables values
*			If IL is an outlier, drop variable

cd "`mypath_`depvar'_`sizevar''preestimation tests"

foreach x of local vars {

separate `x', by(stateabb == "IL")

graph bar (mean) `x'0 `x'1 if year < 2009 & year > 1991, ///
	nofill over(stateabb, sort (`x') label(labs( vsmall))) legend(off) xsize(8) ///
	title ("`x', Average State Values (1982-2008)")

graph export "`x'_bar.pdf", as(pdf) replace
	
drop `x'0 `x'1

}


*** 2.2: Plot IL in pre-treatment period to determine lag years
*			Select optimal lag years


xtline `depvar'_alcohol if state == 0 | state == 17, i(statename) t(year)  overlay ///
	title ("Share of Accidents Due to Alcohol, US and IL (1982-2015)")			///
	ytitle("Share of Accidents Due to Alcohol") xsize(8)
graph export "Alcoholshare_line_2015.pdf", as(pdf) replace

xtline `depvar'_alcohol if state == 0 & year < 2009 & year > 1991 | state == 17 & year < 2009 & year > 1991, i(statename) t(year)  overlay 	///
	title ("Share of Accidents Due to Alcohol, US and IL (1992-2008)") 							///
	ytitle("Share of Accidents Due to Alcohol") xsize(8)
graph export "Alcoholshare_line_2009.pdf", as(pdf) replace

clear


*** V3: Alcohol-Related Accidents per Driver, No Controls

local depvar drivers
local sizevar narrow

cd "`mypath_`depvar'_`sizevar''"

local vars `vars_`depvar''
di "`vars'"

use alcohol_`depvar'_`sizevar'


tabstat `vars' if year < 2009 & year > 1991, statistics(mean) by(statename)
tabstat `vars' if state == 17 & year > 1991, statistics(sum) by(year)


*** 2.1. Test averages of explanitory variables for pre-treatment period
* 			See where IL ranks against other states when expl. variables are averaged between 1982 and 1999
* 			Graph state values to determine the place of IL relative to other states. 	
* 			Table of each variables values
*			If IL is an outlier, drop variable

cd "`mypath_`depvar'_`sizevar''preestimation tests"

foreach x of local vars {

separate `x', by(stateabb == "IL")

graph bar (mean) `x'0 `x'1 if year < 2009, ///
	nofill over(stateabb, sort (`x') label(labs( vsmall))) legend(off) xsize(8) ///
	title ("`x', Average State Values (1982-2008)")

graph export "`x'_bar.pdf", as(pdf) replace
	
drop `x'0 `x'1

}


*** 2.2: Plot IL in pre-treatment period to determine lag years
*			Select optimal lag years


xtline `depvar'_alcohol if state == 0 | state == 17, i(statename) t(year)  overlay ///
	title ("Alcohol-Related Accidents per Driver, US and IL (1982-2015)")			///
	ytitle("Alcohol-Related Accidents per Driver") xsize(8)
graph export "Alcoholdrivers_line_2015.pdf", as(pdf) replace

xtline `depvar'_alcohol if state == 0 & year < 2009 | state == 17 & year < 2009, i(statename) t(year)  overlay 	///
	title ("Alcohol-Related Accidents per Driver, US and IL (1982-2008)")			///
	ytitle("Alcohol-Related Accidents per Driver") xsize(8)
graph export "Alcoholdrivers_line_2009.pdf", as(pdf) replace

clear

log close
