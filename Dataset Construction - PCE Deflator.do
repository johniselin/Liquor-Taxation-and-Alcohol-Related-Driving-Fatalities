
** Import and Clean Price Indexes for Personal Consumption Expenditures
* Data are downloaded from: https://www.bea.gov/itable/
* We downloaded National Data, Table 2.3.4. Price Indexes for Personal Consumption Expenditures by Major Type of Product, All years

* Data cleaning


if regexm(c(os),"Mac") == 1 {
	local mypath_1 = "`mypath'PCE Deflator (BEA)/"
	}
	else if regexm(c(os),"Windows") == 1 local mypath_1 = "`mypath'PCE Deflator (BEA)\"
	
	


import excel "`mypath_1'download.xls", sheet("Sheet0") cellrange(A6)

drop if C == ""
destring B-CL, replace ignore("---")
drop A
xpose, clear
keep v1 v2
rename v1 year
rename v2 cpi_pce
drop if year == .
drop if year < 1982
drop if year > 2015

* This is the final PCE Price Index file
quietly: save "`mypath_1'Price Index - PCE 1982-2015.dta", replace

quietly: save "`mypath'PCE 1982-2015.dta", replace


export excel using "`mypath_1'Price Index - PCE (1982-2015).xlsx", firstrow(variables) replace



clear
