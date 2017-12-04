
** Import and Clean Unemployment Data
* Data are downloaded from: http://apps.urban.org/features/state-economic-monitor/historical.html
* We downloaded Unemployment Rate (percent, seasonally adjusted), Monthly unemployment rates from January 1976 to January 2017.



if regexm(c(os),"Mac") == 1 {
	local mypath_1 = "`mypath'Unemployment (SEM)/"
	}
	else if regexm(c(os),"Windows") == 1 local mypath_1 = "`mypath'Unemployment (SEM)\"
	
	

* Data cleaning


import excel "`mypath_1'unemployment_historical.xlsx", sheet("TABLE") cellrange(A5) firstrow

gen year =  substr(A,-4,4) 
drop if A == "Invalid data manipulation"
destring year, replace
drop A


rename * s_*
rename s_year year
collapse (mean) s_*, by (year)

reshape long s_, i(year) j(statename) string
rename s_ unempl
drop if year < 1982
drop if year > 2015

replace statename = "District of Columbia" if statename == "DistrictofColumbia"
replace statename = "New Hampshire" if statename == "NewHampshire"
replace statename = "New Jersey" if statename == "NewJersey"
replace statename = "New Mexico" if statename == "NewMexico"
replace statename = "New York" if statename == "NewYork"
replace statename = "New York" if statename == "NewYork"
replace statename = "North Carolina" if statename == "NorthCarolina"
replace statename = "North Dakota" if statename == "NorthDakota"
replace statename = "South Carolina" if statename == "SouthCarolina"
replace statename = "South Dakota" if statename == "SouthDakota"
replace statename = "United States" if statename == "UnitedStates"
replace statename = "West Virginia" if statename == "WestVirginia"
replace statename = "Rhode Island" if statename == "RhodeIsland"
 
replace statename = proper(statename)
replace statename = trim(statename)

 
* This is the final Unemployment Data file with data on unemployment by state and year
quietly: save "`mypath_1'Unemployment Data 1982-2015.dta", replace

* This is the final Unemployment Data file with data on unemployment by state and year
quietly: save "`mypath'unemployment 1982-2015.dta", replace
clear
