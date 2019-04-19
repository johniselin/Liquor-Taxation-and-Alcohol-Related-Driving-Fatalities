** Import and clean FARS Data
* Data are downloaded from http://www.nber.org/data/fars.html
* Download the PERSON and MIPER files from 1982 - 2015
* We used the NBER version of the FIPS data

* Edited to get 21+ Only




if regexm(c(os),"Mac") == 1 {
	local mypath_1 = "`mypath'FARS Data (NBER)/"
	}
	else if regexm(c(os),"Windows") == 1 local mypath_1 = "`mypath'FARS Data (NBER)\"


* Person File

use "`mypath_1'person_2015.dta"
gen year = 2015

forvalues i = 1982/2014 {
append using "`mypath_1'person_`i'.dta", force
replace year = `i' if year == .
keep state st_case year ve_forms veh_no per_no per_typ county month day age sex drinking alc_det hispanic race atst_typ alc_res drugs test_res 


}

quietly: save "`mypath_1'person_1982-2015.dta", replace
clear


* MIPER File

use "`mypath_1'miper_2015.dta"
gen year = 2015


forvalues i = 1982/2014 {
append using "`mypath_1'miper_`i'.dta", force
replace year = `i' if year == .

}

quietly: save "`mypath_1'miper_1982-2015.dta", replace
clear


use "`mypath_1'person_1982-2015.dta", clear
merge 1:1 st_case veh_no per_no year using "`mypath_1'miper_1982-2015.dta" 

drop if per_typ != 1
drop if _merge != 3
drop _merge

*** Age Exclusion
drop if age < 21
*** Age Exclusion

egen bac_imputed = rowmean(p1-p10)

gen alc_res_2 = alc_res
replace alc_res_2 = test_res if year < 1991

replace  alc_res_2 = 950 if alc_res_2 == 995
replace  alc_res_2 = 960 if alc_res_2 == 996
replace  alc_res_2 = 970 if alc_res_2 == 997
replace  alc_res_2 = 980 if alc_res_2 == 998
replace  alc_res_2 = 990 if alc_res_2 == 999

replace alc_res_2 = alc_res_2 /10 if year == 2015

replace alc_res_2 = round(alc_res_2) if year == 2015


* Positive BAC
gen bac_pos = 1 if alc_res_2 > 0 & alc_res_2 < 95
replace bac_pos = 0 if bac_pos == .
tab bac_pos


* BAC over .08 data
gen bac_limit = 1 if alc_res_2 > 8 & alc_res_2 < 95
replace bac_limit = 0 if bac_limit == .
tab bac_limit


* Police Reported Alcohol Use
gen police = 1 if drinking == 1
replace police = 0 if police == .

order state year st_case alc_res_2 bac_imputed
keep state year county st_case bac_imputed ve_forms veh_no per_no
gen bac_pos = 1 if bac_imputed > 0
gen bac_limit = 1 if bac_imputed > 8

replace bac_pos = 0 if bac_pos == .
replace bac_limit = 0 if bac_limit == .

quietly: save "`mypath_1'miper_person_1982-2015_21only.dta", replace 

* Create collpased dataset with the following per state and year
* Count total accidents
* Count accidents with positive BAC
* Count accidents with BAC equal to or greater than 0.08 


collapse (count) ve_forms (max) bac_pos bac_limit, by ( year state st_case)

drop ve_forms

collapse (count) st_case (sum) bac_limit bac_pos , by (year state)

sort year state st_case
merge m:1 state using "`mypath_1'State Names.dta"
drop _merge
replace statename = proper(statename)

quietly: save "`mypath_1'Driving Fatalities Data 21 plus 1982-2015.dta", replace

quietly: save "`mypath'fars 21 plus 1982-2015.dta", replace

clear

* Create collpased dataset with the following per state and year
* New IL definition without border counties
* Count total accidents
* Count accidents with positive BAC
* Count accidents with BAC equal to or greater than 0.08 

* Use county codes from the General Service Administration
* Geographic Location Codes (GLCs)
* https://www.gsa.gov/portal/content/102761

import excel "`mypath_1'GLCs_for_the_USA_and_DC_(1).xlsx", sheet("Sheet 1") cellrange(A2) firstrow

rename StateName statename
rename StateAbbreviation stateabb
rename StateCode state
rename CityNameCountyName countyname
rename CountyCode county
destring state, replace

keep if state == 17
keep if CityCode == ""
drop Territory CityCode


gen border = 0
replace border = 1 if county == "001"
replace border = 1 if county == "003"
replace border = 1 if county == "007"
replace border = 1 if county == "013"
replace border = 1 if county == "015"
replace border = 1 if county == "023"
replace border = 1 if county == "031"
replace border = 1 if county == "033"
replace border = 1 if county == "045"
replace border = 1 if county == "047"
replace border = 1 if county == "059"
replace border = 1 if county == "067"
replace border = 1 if county == "069"
replace border = 1 if county == "071"
replace border = 1 if county == "075"
replace border = 1 if county == "077"
replace border = 1 if county == "083"
replace border = 1 if county == "085"
replace border = 1 if county == "091"
replace border = 1 if county == "097"
replace border = 1 if county == "101"
replace border = 1 if county == "111"
replace border = 1 if county == "119"
replace border = 1 if county == "127"
replace border = 1 if county == "131"
replace border = 1 if county == "133"
replace border = 1 if county == "149"
replace border = 1 if county == "151"
replace border = 1 if county == "153"
replace border = 1 if county == "157"
replace border = 1 if county == "161"
replace border = 1 if county == "163"
replace border = 1 if county == "177"
replace border = 1 if county == "181"
replace border = 1 if county == "183"
replace border = 1 if county == "185"
replace border = 1 if county == "193"
replace border = 1 if county == "195"
replace border = 1 if county == "197"
replace border = 1 if county == "201"
destring county, replace
quietly: save "`mypath_1'counties.dta", replace
clear

use "`mypath_1'miper_person_1982-2015_21only.dta"
merge m:1 state county using "`mypath_1'counties.dta" 

drop _merge

drop if border == 1

collapse (count) ve_forms (max) bac_pos bac_limit, by ( year state st_case)

drop ve_forms

collapse (count) st_case (sum) bac_limit bac_pos , by (year state)

sort year state st_case
merge m:1 state using "`mypath_1'State Names.dta"
drop _merge
replace statename = proper(statename)

quietly: save "`mypath'fars - no borders - 21 only - 1982-2015.dta", replace

clear


* Create collpased dataset with the following per state and year
* New IL definition with only border counties
* Count total accidents
* Count accidents with positive BAC
* Count accidents with BAC equal to or greater than 0.08 

* Use county codes from the General Service Administration
* Geographic Location Codes (GLCs)
* https://www.gsa.gov/portal/content/102761


use "`mypath_1'miper_person_1982-2015_21only.dta"
merge m:1 state county using "`mypath_1'counties.dta" 

drop _merge

drop if border == 0

collapse (count) ve_forms (max) bac_pos bac_limit, by ( year state st_case)

drop ve_forms

collapse (count) st_case (sum) bac_limit bac_pos , by (year state)

sort year state st_case
merge m:1 state using "`mypath_1'State Names.dta"
drop _merge
replace statename = proper(statename)

quietly: save "`mypath'fars - all borders - 21 only - 1982-2015.dta", replace

clear

