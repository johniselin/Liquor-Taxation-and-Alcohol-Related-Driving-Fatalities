** Import and Clean Disease Data
* Data are downloaded from https://wonder.cdc.gov/mortSQL.html
* We use alcoholic cirrhosis of liver (571.2) (see Nelson 2013)
* 1979-1998 data --> "ICD-9 Codes: 571.2 (Alcoholic cirrhosis of liver)"
* 1999-2015 data --> "ICD-10 Codes: K70.3 (Alcoholic cirrhosis of liver)"



if regexm(c(os),"Mac") == 1 {
	local mypath_1 = "`mypath'Mortality (CDC)/"
	}
	else if regexm(c(os),"Windows") == 1 local mypath_1 = "`mypath'Mortality (CDC)\"
	
	
import delimited "`mypath_1'Compressed Mortality, 1999-2015.txt"
drop notes statecode yearcode population cruderate
drop if year == .
rename state statename
gen suppressed = 0
replace suppressed = 1 if deaths == "Suppressed"
replace deaths = "0" if deaths == "Suppressed"
destring deaths, gen(liverdeaths)
drop deaths
quietly: save "`mypath_1'Liver Mortality 1999-2015.dta", replace
clear

import delimited "`mypath_1'Compressed Mortality, 1979-1998.txt"
drop notes statecode yearcode population cruderate
drop if year == .
rename state statename
gen suppressed = 0
replace suppressed = 1 if deaths == "Suppressed"
replace deaths = "0" if deaths == "Suppressed"
destring deaths, gen(liverdeaths)
drop deaths
drop if year <1982
quietly: save "`mypath_1'Liver Mortality 1982-1998.dta", replace

append using "`mypath_1'Liver Mortality 1999-2015.dta"
replace statename = "District Of Columbia" if statename == "District of Columbia"

quietly: save "`mypath'Liver Mortality 1982-2015.dta", replace

quietly: save "`mypath_1'Liver Mortality Data 1982-2015.dta", replace

clear
