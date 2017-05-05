** Import and Clean Driver Data 
* Data are downloaded from https://www.fhwa.dot.gov/policyinformation/statistics/2014/
* Data are downloaded from https://www.fhwa.dot.gov/policyinformation/statistics/2015/
* We downloaded Highway Statistics 2014 Table 6.2.2. Licensed drivers, by State, 1949-2014 (most recent year of data)
*				Highway Statistics 2015 Table 6.3.3. Licensed drivers, by State, sex, and age group (for 2015)

if regexm(c(os),"Mac") == 1 {
	local mypath_1 = "Licensed Drivers (FHWA)/"
	}
	else if regexm(c(os),"Windows") == 1 local mypath_1 = "`mypath'Licensed Drivers (FHWA)\"
	
	


import excel "`mypath_1'dl201.xlsx", sheet("DL-201") firstrow

drop BP-ED
drop B-AH

 foreach v of var AI-BO { 
	capture rename `v' y_`: var label `v'' 
} 

drop if STATE == ""
reshape long y_, i(STATE) j(year)

rename STATE statename
gen test = subinstr(statename," ","",.)
drop if test == "Total"
replace statename = "United States" if test == "Total"
replace statename = "Alaska" if statename == "Alaska 2/"
replace statename = "District Of Columbia" if statename == "Dist. of Col."
replace statename = "Hawaii" if statename == "Hawaii 2/"
replace statename = test if test == "Colorado"
replace statename = test if test == "Massachusetts"
replace statename = test if test == "NewYork"
replace statename = "New York" if statename == "NewYork"
replace statename = test if test == "Oregon"
drop test
rename y_ drivers
label variable drivers "Licensed Drivers in a State"

quietly: save "`mypath_1'Drivers 1982-2014.dta", replace

clear 

import excel "`mypath_1'dl22.xls", sheet("TOTAL") cellrange(A14) firstrow

keep STATE TOTAL
drop if TOTAL == .
drop if STATE == ""
rename STATE statename
rename TOTAL drivers
replace statename = trim(statename)
replace statename = subinstr(statename," 2/", "",.)
replace statename = "United States" if statename == "Total"
replace statename = "District Of Columbia" if statename == "Dist. of Col."
replace statename = proper(statename)
label variable drivers "Licensed Drivers in a State"
gen year = 2015
quietly: save "`mypath_1'Drivers 2015.dta", replace

append using "`mypath_1'Drivers 1982-2014.dta"

drop if statename == "United States"
quietly: save "`mypath_1'Licensed Drivers 1982-2015.dta", replace

quietly: save "`mypath'drivers 1982-2015.dta", replace
clear
