
** Import and Clean Age Group Data
* Data are downloaded from https://wonder.cdc.gov/mortSQL.html
* 1979-1998 data --> "ICD-9 Codes: All"
* 1999-2015 data --> "ICD-10 Codes: All"



if regexm(c(os),"Mac") == 1 {
	local mypath_1 = "`mypath'Age Brackets (CDC)/"
	}
	else if regexm(c(os),"Windows") == 1 local mypath_1 = "`mypath'Age Brackets (CDC)\"
	
	

import delimited "`mypath_1'Compressed Mortality, 1999-2015.txt"
drop notes statecode yearcode agegroup deaths cruderate
drop if year == .
drop if agegroup == "NS"
rename state statename
rename population pop_
gen agebracket = subinstr(agegroupcode,"-","to",.)
replace agebracket = subinstr(agebracket,"+","",.)
drop agegroupcode
label variable agebracket "Age Group Code"
destring pop_, replace
reshape wide pop_, i(statename year) j( agebracket ) string
order statename year pop_1 pop_1to4 pop_5to9 pop_10to14 pop_15to19 pop_20to24 pop_25to34 pop_35to44 pop_45to54 pop_55to64 pop_65to74 pop_75to84 pop_85
egen pop_all = rowtotal( pop_1 pop_1to4 pop_5to9 pop_10to14 pop_15to19 pop_20to24 pop_25to34 pop_35to44 pop_45to54 pop_55to64 pop_65to74 pop_75to84 pop_85)
quietly: save "`mypath_1'Age Brackets 1999-2015.dta", replace
clear

import delimited "`mypath_1'Compressed Mortality, 1979-1998.txt"
drop notes statecode yearcode agegroup deaths cruderate
drop if year == .
drop if agegroup == "NS"
rename state statename
rename population pop_
gen agebracket = subinstr(agegroupcode,"-","to",.)
replace agebracket = subinstr(agebracket,"+","",.)
drop agegroupcode
label variable agebracket "Age Group Code"
destring pop_, replace
reshape wide pop_, i(statename year) j( agebracket ) string
order statename year pop_1 pop_1to4 pop_5to9 pop_10to14 pop_15to19 pop_20to24 pop_25to34 pop_35to44 pop_45to54 pop_55to64 pop_65to74 pop_75to84 pop_85
egen pop_all = rowtotal( pop_1 pop_1to4 pop_5to9 pop_10to14 pop_15to19 pop_20to24 pop_25to34 pop_35to44 pop_45to54 pop_55to64 pop_65to74 pop_75to84 pop_85)
drop if year < 1982
quietly: save "`mypath_1'Age Brackets 1979-1998.dta", replace

append using "`mypath_1'Age Brackets 1999-2015.dta"

label variable pop_1 "State Population Less Than 1 Year Old"
label variable pop_5to9 "State Population Between 5 and 9 Years Old"
label variable pop_10to14 "State Population Between 10 and 14 Years Old"
label variable pop_15to19 "State Population Between 15 and 19 Years Old"
label variable pop_20to24 "State Population Between 20 and 24 Years Old"
label variable pop_25to34 "State Population Between 25 and 34 Years Old"
label variable pop_35to44 "State Population Between 35 and 44 Years Old"
label variable pop_45to54 "State Population Between 45 and 54 Years Old"
label variable pop_55to64 "State Population Between 55 and 64 Years Old"
label variable pop_65to74 "State Population Between 65 and 74 Years Old"
label variable pop_75to84 "State Population Between 75 and 84 Years Old"
label variable pop_85 "State Population Greater than 85 Years Old"
label variable pop_all "CDC Population Total"
replace statename = "District Of Columbia" if statename == "District of Columbia"

quietly: save "`mypath_1'Age Bracket Data 1982-2015.dta", replace

quietly: save "`mypath'Age Brackets 1982-2015.dta", replace



clear
