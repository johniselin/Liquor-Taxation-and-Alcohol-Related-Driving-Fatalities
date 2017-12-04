
** Import and Clean Personal Income and Popuation Data
* Data are downloaded from https://www.bea.gov/itable/
* We downloaded SA1 Personal Income Summary: Personal Income, Population, Per Capita Personal Income
* 1929-2015

if regexm(c(os),"Mac") == 1 {
	local mypath_1 = "`mypath'Personal Income (BEA)/"
	}
	else if regexm(c(os),"Windows") == 1 local mypath_1 = "`mypath'Personal Income (BEA)\"
	
	


* Data cleaning
import delimited "`mypath_1'download.csv", varnames(5) rowrange(6) colrange(1)

** NOTE: v5-v91 = 1929-2015, for each additional year add one to v91
foreach v of var v5-v92 { 
	capture rename `v' y_`: var label `v'' 
} 
drop y_1929-y_1981 y_2016
drop if linecode == 3
drop geofips
gen id = _n
drop if id > 104
reshape long y_, i(id) j(year)
drop id description
rename y_ amount
reshape wide amount, i(year geoname) j(linecode)
rename amount1 pi
rename amount2 population
label variable pi "Personal Income (thousands)"
label variable population "State population"
replace geoname = "Hawaii" if geoname == "Hawaii*"
replace geoname = "Alaska" if geoname == "Alaska*"
drop if geoname == "United States"
replace geoname = "District Of Columbia" if geoname == "District of Columbia"
rename geoname statename

* This is the final BEA file with data on personal income and population by state and year
quietly: save "`mypath_1'personal income and population data 1982-2015.dta", replace
quietly: save "`mypath'pi_pop 1982-2015.dta", replace


clear
