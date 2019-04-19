
/***********************************************************************
Author: Robert McClelland and John Iselin
Date: Spring 2019

Illinois Liquor tax increase and alcohol-related accidents. 

We are examining the effect of a 2000 and 2009 Alcohol Tax Increase
In Illinois. This do-file constructs a dataset of state-year observations
from 1982 through 2015. This dataset will then be used to analyse the tax 
changes using the synthetic control method as described in Abadie, Diamond, 
and Hainmuller (2010).


Please refer to the READ ME file before running this do-file to be sure that
folders and datasets are correctly organized. In addition, before running this 
do-file, run the "Dataset Construction - Setup.do" do-file to create the correct
set of folders. In addition, please make sure that the data are correctly 
downloaded, named, and placed before running this do-file. In addition, create 
the folder you will be running the code in as well (see "FOR FINAL DATA" comment
below). 

This file is updated to restrict the data to 21+ individuals. 

**************************************************************************/


*** Set-Up ***
clear matrix
clear all
capture log close
set more off


** MAC vs PC Filepaths
if regexm(c(os),"Mac") == 1 {
	local mypath = "/Users/johniselin/Desktop/Desktop - John’s MacBook Pro/TPC/Illinois Alcohol Taxes and Drunk Driving/Results/Dataset Construction/"
	}
	else if regexm(c(os),"Windows") == 1 local mypath = ""

** FOR FINAL DATA --> Make sure that the filepath below exists for the final datasets
if regexm(c(os),"Mac") == 1 {
	local mypath_synth = "/Users/johniselin/Desktop/Desktop - John’s MacBook Pro/TPC/Illinois Alcohol Taxes and Drunk Driving/Results/Synth Run 01.16.2019/"
	}
	else if regexm(c(os),"Windows") == 1 local mypath_synth = ""
	

log using "`mypath'DatasetConstruction_BAC01_Log.smcl", replace
cd "`mypath'"



** FARS Data

do "Dataset Construction - FARS - BAC 01.do"

** Import and Clean Personal Income and Popuation Data

do "Dataset Construction - BEA.do"

** Import and Clean Driver Data 

do "Dataset Construction - FHWA Drivers.do"

** Import and Clean Disease Data

do "Dataset Construction - CDC Disease.do"

** Import and Clean Age Group Data

do "Dataset Construction - CDC Age.do"

** Import and Clean Gas Tax Data

do "Dataset Construction - FHWA Gas Tax.do"

** Import and Clearn Unemployment Data

do "Dataset Construction - SEM Unemployment.do"

** Import and Clean Price Index Data

do "Dataset Construction - PCE Deflator.do"

*** Combine seperate datasets

use "fars 21 plus 1982-2015", clear
sort statename year
merge 1:1 statename year using "Age Brackets 1982-2015.dta"
drop _merge
merge 1:1 statename year using "State Motor Fuel Tax 1982-2015.dta"
drop _merge
merge 1:1 statename year using "Liver Mortality 1982-2015.dta"
drop _merge
merge 1:1 statename year using "drivers 1982-2015.dta"
drop _merge
merge 1:1 statename year using "pi_pop 1982-2015.dta"
drop _merge


*** Clean Dataset - Sums

gen pop_15to24 = pop_15to19 + pop_20to24
label variable pop_15to24 "Population Aged 15 to 24"

gen pop_65plus = pop_65to74 + pop_75to84 + pop_85
label variable pop_65plus "Population Aged  65 and Up"

replace pi = pi *1000
label variable pi "Personal Income"

quietly: save "Dataset BAC 01 (1982-2015).dta", replace

*** US Variable generated from state and DC Totals

collapse (sum) pop_65plus pop_15to24 st_case bac_limit bac_pos pop_1 pop_1to4 pop_5to9 pop_10to14 pop_15to19 pop_20to24 pop_25to34 pop_35to44 pop_45to54 pop_55to64 pop_65to74 pop_75to84 pop_85 pop_all liverdeaths drivers pi population, by (year)
gen state = 0
gen statename = "United States"
gen stateabb = "US"
 
quietly: save "Dataset US BAC 01 (1982-2015).dta", replace
clear
use "Dataset BAC 01 (1982-2015).dta", 
append using "Dataset US BAC 01 (1982-2015).dta"
quietly: save "Dataset BAC 01 (1982-2015).dta", replace

** Merge in rates and PCE Deflator after including the US
merge m:1  year using "PCE 1982-2015.dta"
drop _merge
merge 1:1 statename year using "unemployment 1982-2015.dta"
drop _merge

** Clean Dataset - Ratios

gen share_alcohol = bac_limit / st_case

gen share_alcohol_pos = bac_pos / st_case

label variable share_alcohol "Share of Total Driving Fatal Accidents Due to Alcohol"

gen drivers_alcohol = bac_limit / drivers

label variable drivers_alcohol "Alcohol-Related Accidents per Driver"

gen youngshare = pop_15to24 / pop_all 
label variable youngshare "Share of the Population Aged 15 to 24"

gen oldshare = pop_65plus / pop_all
label variable oldshare "Share of the Population Aged 65 and Up"

gen pipercap = pi/ population
label variable pipercap "Personal Income Per Capita"

gen liverdeaths_percap = liverdeaths * 100000 / population
label variable liverdeaths_percap "Liver Deaths per 100,000 People"

label variable unempl "Unemployment Rate (Average of Monthly Rates)"
label variable cpi_pce "Personal Consumption Expenditures - Price Index" 
label variable liverdeaths "Liver Deaths"
label variable suppressed "Liver Deaths - Suppressed Observations"

keep state statename stateabb year share_alcohol drivers_alcohol youngshare oldshare pipercap liverdeaths_percap unempl cpi_pce gasolinetax
order state statename stateabb year share_alcohol drivers_alcohol youngshare oldshare pipercap unempl gasolinetax liverdeaths_percap cpi_pce 

** Inflation-Adjusted Values for personal income per capita and gas tax

gen _base = cpi_pce if year == 2015
egen cpi_base = max(_base)
local variables_to_deflate pipercap gasolinetax
foreach var of varlist `variables_to_deflate '{
qui gen `var'_deflated = `var' * (cpi_base / cpi_pce)
label var `var'_deflated "`var' deflated by cpi"
}
drop _base cpi_base

quietly: save "alcohol_bac01.dta", replace
quietly: save "`mypath_synth'alcohol_bac01.dta", replace
*export excel "Dataset (1982-2015).xlsx", firstrow replace 
sum
de

clear

* Create dataset using no-borders IL 


use "fars - no borders - BAC 01 - 1982-2015.dta", clear
sort statename year
merge 1:1 statename year using "Age Brackets 1982-2015.dta"
drop _merge
merge 1:1 statename year using "State Motor Fuel Tax 1982-2015.dta"
drop _merge
merge 1:1 statename year using "Liver Mortality 1982-2015.dta"
drop _merge
merge 1:1 statename year using "drivers 1982-2015.dta"
drop _merge
merge 1:1 statename year using "pi_pop 1982-2015.dta"
drop _merge


*** Clean Dataset - Sums

gen pop_15to24 = pop_15to19 + pop_20to24
label variable pop_15to24 "Population Aged 15 to 24"

gen pop_65plus = pop_65to74 + pop_75to84 + pop_85
label variable pop_65plus "Population Aged  65 and Up"

replace pi = pi *1000
label variable pi "Personal Income"

quietly: save "Dataset - no borders - BAC 01 (1982-2015).dta", replace

*** US Variable generated from state and DC Totals
append using "Dataset US BAC 01 (1982-2015).dta"
quietly: save "Dataset BAC 01 (1982-2015).dta", replace

** Merge in rates and PCE Deflator after including the US
merge m:1  year using "PCE 1982-2015.dta"
drop _merge
merge 1:1 statename year using "unemployment 1982-2015.dta"
drop _merge

** Clean Dataset - Ratios

gen share_alcohol = bac_limit / st_case

gen share_alcohol_pos = bac_pos / st_case

label variable share_alcohol "Share of Total Driving Fatal Accidents Due to Alcohol"

gen drivers_alcohol = bac_limit / drivers

label variable drivers_alcohol "Alcohol-Related Accidents per Driver"

gen youngshare = pop_15to24 / pop_all 
label variable youngshare "Share of the Population Aged 15 to 24"

gen oldshare = pop_65plus / pop_all
label variable oldshare "Share of the Population Aged 65 and Up"

gen pipercap = pi/ population
label variable pipercap "Personal Income Per Capita"

gen liverdeaths_percap = liverdeaths * 100000 / population
label variable liverdeaths_percap "Liver Deaths per 100,000 People"

label variable unempl "Unemployment Rate (Average of Monthly Rates)"
label variable cpi_pce "Personal Consumption Expenditures - Price Index" 
label variable liverdeaths "Liver Deaths"
label variable suppressed "Liver Deaths - Suppressed Observations"

keep state statename stateabb year share_alcohol drivers_alcohol youngshare oldshare pipercap liverdeaths_percap unempl cpi_pce gasolinetax
order state statename stateabb year share_alcohol drivers_alcohol youngshare oldshare pipercap unempl gasolinetax liverdeaths_percap cpi_pce 

** Inflation-Adjusted Values for personal income per capita and gas tax

gen _base = cpi_pce if year == 2015
egen cpi_base = max(_base)
local variables_to_deflate pipercap gasolinetax
foreach var of varlist `variables_to_deflate '{
qui gen `var'_deflated = `var' * (cpi_base / cpi_pce)
label var `var'_deflated "`var' deflated by cpi"
}
drop _base cpi_base

quietly: save "alcohol_noborders_bac01.dta", replace
quietly: save "`mypath_synth'alcohol_noborders_bac01.dta", replace
*export excel "Dataset (1982-2015).xlsx", firstrow replace 
sum
de

clear


* Create dataset using All-borders IL 


use "fars - all borders - 21 only - 1982-2015.dta", clear
sort statename year
merge 1:1 statename year using "Age Brackets 1982-2015.dta"
drop _merge
merge 1:1 statename year using "State Motor Fuel Tax 1982-2015.dta"
drop _merge
merge 1:1 statename year using "Liver Mortality 1982-2015.dta"
drop _merge
merge 1:1 statename year using "drivers 1982-2015.dta"
drop _merge
merge 1:1 statename year using "pi_pop 1982-2015.dta"
drop _merge


*** Clean Dataset - Sums

gen pop_15to24 = pop_15to19 + pop_20to24
label variable pop_15to24 "Population Aged 15 to 24"

gen pop_65plus = pop_65to74 + pop_75to84 + pop_85
label variable pop_65plus "Population Aged  65 and Up"

replace pi = pi *1000
label variable pi "Personal Income"

quietly: save "Dataset - all borders - BAC 01 - (1982-2015).dta", replace

*** US Variable generated from state and DC Totals
append using "Dataset US BAC 01 (1982-2015).dta"
quietly: save "Dataset BAC 01 (1982-2015).dta", replace

** Merge in rates and PCE Deflator after including the US
merge m:1  year using "PCE 1982-2015.dta"
drop _merge
merge 1:1 statename year using "unemployment 1982-2015.dta"
drop _merge

** Clean Dataset - Ratios

gen share_alcohol = bac_limit / st_case

gen share_alcohol_pos = bac_pos / st_case

label variable share_alcohol "Share of Total Driving Fatal Accidents Due to Alcohol"

gen drivers_alcohol = bac_limit / drivers

label variable drivers_alcohol "Alcohol-Related Accidents per Driver"

gen youngshare = pop_15to24 / pop_all 
label variable youngshare "Share of the Population Aged 15 to 24"

gen oldshare = pop_65plus / pop_all
label variable oldshare "Share of the Population Aged 65 and Up"

gen pipercap = pi/ population
label variable pipercap "Personal Income Per Capita"

gen liverdeaths_percap = liverdeaths * 100000 / population
label variable liverdeaths_percap "Liver Deaths per 100,000 People"

label variable unempl "Unemployment Rate (Average of Monthly Rates)"
label variable cpi_pce "Personal Consumption Expenditures - Price Index" 
label variable liverdeaths "Liver Deaths"
label variable suppressed "Liver Deaths - Suppressed Observations"

keep state statename stateabb year share_alcohol drivers_alcohol youngshare oldshare pipercap liverdeaths_percap unempl cpi_pce gasolinetax
order state statename stateabb year share_alcohol drivers_alcohol youngshare oldshare pipercap unempl gasolinetax liverdeaths_percap cpi_pce 

** Inflation-Adjusted Values for personal income per capita and gas tax

gen _base = cpi_pce if year == 2015
egen cpi_base = max(_base)
local variables_to_deflate pipercap gasolinetax
foreach var of varlist `variables_to_deflate '{
qui gen `var'_deflated = `var' * (cpi_base / cpi_pce)
label var `var'_deflated "`var' deflated by cpi"
}
drop _base cpi_base

quietly: save "alcohol_allborders_bac01.dta", replace
quietly: save "`mypath_synth'alcohol_allborders_bac01.dta", replace
*export excel "Dataset (1982-2015).xlsx", firstrow replace 
sum
de

clear


log close
