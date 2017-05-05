
** Import and Clean Gas Tax Data
* Data are downloaded from https://www.fhwa.dot.gov/policyinformation/statistics.cfm/
* Highway Statistics Series, gasoline tax as of December 31 of that year.
* 1990-1995 --> Highway Statistics Summary To 1995, State motor fuel taxes and related receipts, 1950-1995 (Table MF-201A) (downloaded as "mf205", recreated)
* 1996-1999 --> Individual Highways Statistics Publications, State tax rates on motor fuel (downloaded as "mf121t" (1996), "mf121t_1997" (1997), "mf121t" (1998 and 1999), recreated)
* 2000-2015 --> Highway Statistics 2015, 8.2.3. State tax rates on motor fuel 1998-2015 (downloaded as "mf205", renamed)


if regexm(c(os),"Mac") == 1 {
	local mypath_1 = "`mypath'Gas Taxes (FHWA)/"
	}
	else if regexm(c(os),"Windows") == 1 local mypath_1 = "`mypath'Gas Taxes (FHWA)\"
	

* 2000-2015
import excel "`mypath_1'\State Motor-Fuel Rates (2000-2015).xlsx", sheet("GASOLINE") cellrange(A11:T63) firstrow
drop T
foreach v of var B-S {  
capture rename `v' y_`: var label `v'' 
 }
rename STATE statename
gen test = subinstr(statename," ","",.)
replace statename = "District Of Columbia" if statename == "Dist. of Col."
replace statename = test if test == "Alaska"
replace statename = "California" if test == "California(4)"
drop if statename == ""
drop test
replace y_2013 = "22" if statename == "South Dakota"
replace y_2014 = "22" if statename == "South Dakota"
destring y_1993-y_2015, replace
reshape long y_, i(statename) j(year)
rename y_ gasolinetax
label variable gasolinetax "Gasoline Tax - Cents per Gallon"
drop if year < 2000
quietly: save "`mypath_1'State Motor Fuel Tax (2000-2015).dta", replace
clear

* 1996 - 1997

local year 1996  
foreach x of local year {
import excel "`mypath_1'State Motor-Fuel Rates (`x').xlsx", sheet("A") cellrange(A1:C78) 
rename A statename
rename B gasolinetax
rename C effectivedate
label variable gasolinetax "Gasoline Tax - Cents per Gallon)"
gen byte notnumeric = real( gasolinetax )==.
drop if notnumeric == 1
drop notnumeric
destring gasolinetax, replace
drop if statename == "STATE" | statename == "Mean" | statename == "Weighted Avg." | statename == "Federal Tax" 
replace statename = subinstr( statename, "*", "",1)
replace statename = strrtrim(statename)
replace statename = "District Of Columbia" if statename == "Dist. of Col."
replace statename = statename[_n-1] if missing(statename)
sort statename
quietly by statename:  gen dup = cond(_N==1,0,_n)
bysort statename : egen t = max(dup)
keep if(dup == t)
drop dup t effectivedate
gen year = `x'
quietly: save "`mypath_1'State Motor Fuel Tax (`x').dta", replace
clear

}

local year 1997  
foreach x of local year {
import excel "`mypath_1'State Motor-Fuel Rates (`x').xlsx", sheet("A") cellrange(A1:C79) 
rename A statename
rename B gasolinetax
rename C effectivedate
label variable gasolinetax "Gasoline Tax - Cents per Gallon)"
gen byte notnumeric = real( gasolinetax )==.
drop if notnumeric == 1
drop notnumeric
destring gasolinetax, replace
drop if statename == "STATE" | statename == "Mean" | statename == "Weighted Avg." | statename == "Federal Tax" 
replace statename = subinstr( statename, "*", "",1)
replace statename = strrtrim(statename)
replace statename = "District Of Columbia" if statename == "Dist. of Col."
replace statename = statename[_n-1] if missing(statename)
sort statename
quietly by statename:  gen dup = cond(_N==1,0,_n)
bysort statename : egen t = max(dup)
keep if(dup == t)
drop dup t effectivedate
gen year = `x'
quietly: save "`mypath_1'State Motor Fuel Tax (`x').dta", replace
clear

}


* 1998 - 1999

local year 1998 1999
foreach x of local year {
import excel "`mypath_1'State Motor-Fuel Rates (`x').xlsx", sheet("A") cellrange(A5:C75) 
rename A statename
rename B gasolinetax
rename C effectivedate
label variable gasolinetax "Gasoline Tax - Cents per Gallon)"
gen byte notnumeric = real( gasolinetax )==.
drop if notnumeric == 1
drop notnumeric
destring gasolinetax, replace
drop if statename == "STATE" | statename == "Mean" | statename == "Weighted Avg." | statename == "Federal Tax" 
replace statename = subinstr( statename, "*", "",1)
replace statename = strrtrim(statename)
replace statename = "District Of Columbia" if statename == "Dist. of Col."
replace statename = statename[_n-1] if missing(statename)
sort statename
quietly by statename:  gen dup = cond(_N==1,0,_n)
bysort statename : egen t = max(dup)
keep if(dup == t)
drop dup t effectivedate
gen year = `x'
quietly: save "`mypath_1'State Motor Fuel Tax (`x').dta", replace
clear

}





* 1982-1995
import excel "`mypath_1'State Motor-Fuel Rates (1981-1995).xlsx", sheet("A") cellrange(A9:P63) firstrow

foreach v of var B-P {  
capture rename `v' y_`: var label `v'' 
 }
 
rename STATE statename
drop y_1981
drop if statename == "" | statename == "State Average  2/"
replace statename = "District Of Columbia" if statename == "Dist. of Col."
destring y_1982-y_1995, replace ignore("^")
sort statename
reshape long y_, i(statename) j(year)
rename y_ gasolinetax
label variable gasolinetax "Gasoline Tax - Cents per Gallon"

quietly: save "`mypath_1'State Motor Fuel Tax (1982-1995).dta", replace
clear

* Combine motor fuel datasets

use "`mypath_1'State Motor Fuel Tax (1982-1995).dta"
append using "`mypath_1'State Motor Fuel Tax (1996).dta"
append using "`mypath_1'State Motor Fuel Tax (1997).dta"
append using "`mypath_1'State Motor Fuel Tax (1998).dta"
append using "`mypath_1'State Motor Fuel Tax (1999).dta"
append using "`mypath_1'State Motor Fuel Tax (2000-2015).dta"
sort state year

quietly: save "`mypath_1'State Motor Fuel Tax Data 1982-2015.dta", replace

quietly: save "`mypath'State Motor Fuel Tax 1982-2015.dta", replace

clear

