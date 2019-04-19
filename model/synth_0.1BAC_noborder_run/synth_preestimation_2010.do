
/***********************************************************************
Author: Robert McClelland and John Iselin
Date: Spring 2017 (Edited January 2018)

Illinois Liquor tax increase and alcohol-related accidents. 

Part 1: Pre-Estimation Tests


We are examining the effect of a 1999 and 2009 Alcohol Tax Increase
In Illinois. This set of do-files constructs a dataset and runs 
through a set of pre- and post-estimation tests and models the
effects of the tax change using the synthetic control method as 
described in Abadie, Diamond, and Hainmuller (2010).

This do-file is the first of three. This file creates the various datasets, 
and creates a series of figures, from which we can determine which states 
are appropriate to include in our pool of donor states, and which lagged 
values of the dependent variables we should use. 

Please refer to the READ ME file before running this do-file to be sure that
folders and datasets are correctly organized. 

For the 2009 IL tax change, there will be two versions of the model, one for 
each dependent variable: the share of total accidents with BAC values over 0.08 
(share_alcohol) and the total number of accidents with BAC values over 0.08 
divided by the number of drivers (drivers_alcohol). For each of these dependent 
variables, we run the model over our set of donor states, which is all 50 states 
plus DC minus states with large liquor tax changes, states with liquor control 
as opposed to or in addition to taxes, and Alaska, DC, and Hawaii. As a 
sensitivity analysis we also will re-run the models over a second set of donor 
states where we add back in states with liquor control boards.

Note: While the tax changes occured in 1999 and 2009, since the first year 
when the tax change were fully in effect fell in 2000 and 2010, those are 
the first years of the "treatment".

Make sure that the filepaths are created as outlined in the READ-ME file.

**************************************************************************/



*** Set-Up ***
capture log close
clear matrix
clear all
set more off


** MAC vs PC Filepaths
if regexm(c(os),"Mac") == 1 local mypath = "/Users/johniselin/Desktop/Desktop - John’s MacBook Pro/TPC/Illinois Alcohol Taxes and Drunk Driving/Results/Synth Run 01.16.2019/"
else if regexm(c(os),"Windows") == 1 local mypath = "...\"

if regexm(c(os),"Mac") == 1 local mypath_nb = "/Users/johniselin/Desktop/Desktop - John’s MacBook Pro/TPC/Illinois Alcohol Taxes and Drunk Driving/Results/Synth Run 01.16.2019/No Borders/"
else if regexm(c(os),"Windows") == 1 local mypath_nb = "...\"

if regexm(c(os),"Mac") == 1 {
	local mypath_share_narrow = "`mypath_nb'/IL 2010 - share - narrow/"
	local mypath_drivers_narrow = "`mypath_nb'/IL 2010 - drivers - narrow/"
	local mypath_logs = "`mypath'/Logs/"
	local mypath_data = "`mypath'/Data/"
	
	}
	else if regexm(c(os),"Windows") == 1 {
	local mypath_share_narrow = "`mypath_nb'\IL 2010 - share - narrow\"
	local mypath_drivers_narrow = "`mypath_nb'\IL 2010 - drivers - narrow\"
	local mypath_logs = "`mypath'\Logs\"
	local mypath_data = "`mypath'\Data\"
	}

	
cd "`mypath_nb'"
log using "`mypath_logs'synth_alcohol_preestimation_nb_2010", replace



global st_control AL ME MI MS MT NH NC OH OR PA UT VT VA WA WV WY
global st_tax CA DE NM NV NJ RI 
global st_never AK HI DC 

local vars_share share_alcohol 

use "`mypath_data'alcohol_noborders_bac01.dta"
tsset state year

sum 
de
clear

** 1. Create Datasets ***

*** Version 1: IL 2009 treatment with share_alcohol dependent variable
*** 			 Drop control states, high-tax states, and never-use states


use "`mypath_data'alcohol_noborders_bac01.dta"
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




*** 2. Pre-Estimation Tests


*** V1: Share of Accidents Due to Alcohol, No Controls

local depvar share
local sizevar narrow

cd "`mypath_`depvar'_`sizevar''"

local vars `vars_`depvar''
di "`vars'"

use alcohol_`depvar'_`sizevar'


tabstat `vars' if year < 2009 & year>1991, statistics(mean) by(statename)
tabstat `vars' if state == 17, statistics(sum) by(year)


*** 2.1. Test averages of explanitory variables for pre-treatment period
* 			See where IL ranks against other states when expl. variables are averaged between 1982 and 1999
* 			Graph state values to determine the place of IL relative to other states. 	
* 			Table of each variables values
*			If IL is an outlier, drop variable

cd "`mypath_`depvar'_`sizevar''preestimation tests"

foreach x of local vars {

separate `x', by(stateabb == "IL")

graph bar (mean) `x'0 `x'1 if year < 2009  & year>1991, ///
	nofill over(stateabb, sort (`x') label(labs( vsmall))) legend(off) xsize(8) ///
	title ("`x', Average State Values (1982-2008)")

graph export "`x'_bar.pdf", as(pdf) replace
	
drop `x'0 `x'1

}


*** 2.2: Plot IL in pre-treatment period to determine lag years
*			Select optimal lag years


xtline `depvar'_alcohol if state == 0 & year>1991 | state == 17 & year>1991, i(statename) t(year)  overlay ///
	title ("Share of Accidents Due to Alcohol, US and IL (1982-2015)")			///
	ytitle("Share of Accidents Due to Alcohol") xsize(8)
graph export "Alcoholshare_line_2015.pdf", as(pdf) replace

xtline `depvar'_alcohol if state == 0 & year < 2009  & year>1991| state == 17 & year < 2009 & year>1991, i(statename) t(year)  overlay 	///
	title ("Share of Accidents Due to Alcohol, US and IL (1982-2008)") 							///
	ytitle("Share of Accidents Due to Alcohol") xsize(8)
graph export "Alcoholshare_line_2009.pdf", as(pdf) replace

clear

log close
