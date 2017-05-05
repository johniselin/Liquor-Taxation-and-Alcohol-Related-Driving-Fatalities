/***********************************************************************
Author: Robert McClelland and John Iselin
Date: Spring 2017

Illinois Liquor tax increase and alcohol-related accidents. 

Monte Carlo Power Test

We are examining the effect of a 2000 and 2009 Alcohol Tax Increase
In Illinois. This do-file runs a set of Monte Carlo simulations to determine
if the synthetic control methodology - paired with our data - can detect a 
policy shock similar in magnitude to that found in Wagenaar, Livingston and 
Staras (2015).

Run this file after running "synth_setup.do" and placing all datasets as 
directed in the READ-ME File. 

**************************************************************************/


clear matrix
clear all
capture log close
set more off



** MAC vs PC Filepaths
if regexm(c(os),"Mac") == 1 {
	local mypath = "/Users/johniselin/Box Sync/LiquorTax/Data/Synth/"
	
	}
	else if regexm(c(os),"Windows") == 1 local mypath = "D:\Users\JIselin\Box Sync\LiquorTax\Data\Synth\"


cd "`mypath'"
log using "synth_montecarlo", replace


** Local Variables used in MC
local size 100
local effect 0.74


** Data
use "alcohol.dta", clear

xtset state year

set matsize 1000

* Monte Carlo using narrowly defined list of states
keep if inlist(state,0,4,5,8,9,12,13,16,18,20,21,22,24,25,27,29,31,32,34,38,40,45,46,47,48,55)

* The Monte Carlo estimates a fixed effects model. The year dummies are the average 
* trend across all states. The error term is divided into two pieces, a state effect
* and a iid random effect. In each simulation state 0 (US) is created using the average
* trend across all states plus a randomly selected state effect plus a normally
* distributed error with mean zero and the same standard deviation as the iid
* error in the fixed effects model

quietly: xtreg share_alcohol i.year , fe vce(cluster state)
predict state_mc, xb
predict state_fe, u
predict residual, e
summ residual
gen sd=r(sd)


gen state_fe_tmp=.
gen state_fe_mc=.

set seed 123


** Assuming no treatment effect, calculating the ratio of the root mean squared
** prediction error. 

** Note: Code below based on synth documentation availible in synth help file.
** 		See here for more detail: https://web.stanford.edu/~jhain/synthpage.html

capture mat drop PE

tempname resmat
        forvalues i = 1/`size' {
	di `i'
	quietly: replace state_fe_tmp = state_fe[trunc(1+_N*uniform())]
	quietly: replace state_fe_mc = state_fe_tmp[_N]
	quietly: replace share_alcohol=state_fe_mc + state_mc + rnormal(0,sd) if state==0
	quietly: replace share_alcohol=share_alcohol*1 if state==0 & year >1999	
	quietly: synth share_alcohol share_alcohol(1982) share_alcohol(1983) share_alcohol(1984) 	///
	share_alcohol(1985) share_alcohol(1986) share_alcohol(1987) share_alcohol(1988)	///
	share_alcohol(1989) share_alcohol(1990) share_alcohol(1991) share_alcohol(1992) ///
	share_alcohol(1993) share_alcohol(1994) share_alcohol(1995) share_alcohol(1996) ///
	share_alcohol(1997) share_alcohol(1998) share_alcohol(1999),  ///
	trunit(0) trperiod(2000) xperiod(1982(1)1999) 
	matrix  PE = nullmat(PE) \ (e(Y_treated)-e(Y_synthetic))'
     local names `"`names' `"`i'"'"'
	         }
       
mat rownames PE = `names'
mat colnames PE=`YEAR'

matlist PE , row("Simulation")
		
mat pre_PE=PE[.,1..colnumb(PE,"1999")]
mat post_PE=PE[.,colnumb(PE,"1999")+1..colsof(PE)]
		
mat pre_MSPE=vecdiag(pre_PE*pre_PE')/colsof(pre_PE)
mat post_MSPE=vecdiag(post_PE*post_PE')/colsof(post_PE)
		
mata: rat_MSPE = st_matrix("post_MSPE"):/st_matrix("pre_MSPE")
mata: rat_RMSPE=rat_MSPE:^5

mata: st_matrix("rat_RMSPE_null",rat_RMSPE')
mat list rat_RMSPE_null
		
		
** Assuming the treatment seen in Wagenaar, Livingston and Staras 2015, 
** calculating the ratio of the root mean squared prediction error. 	
	
	mat drop PE	
		
        forvalues i = 1/`size' {
	di `i'
	quietly: replace state_fe_tmp = state_fe[trunc(1+_N*uniform())]
	quietly: replace state_fe_mc = state_fe_tmp[_N]
	quietly: replace share_alcohol=state_fe_mc + state_mc + rnormal(0,sd) if state==0
	quietly: replace share_alcohol=share_alcohol*`effect' if state==0 & year >1999	
	quietly: synth share_alcohol share_alcohol(1982) share_alcohol(1983) share_alcohol(1984) 	///
	share_alcohol(1985) share_alcohol(1986) share_alcohol(1987) share_alcohol(1988)	///
	share_alcohol(1989) share_alcohol(1990) share_alcohol(1991) share_alcohol(1992) ///
	share_alcohol(1993) share_alcohol(1994) share_alcohol(1995) share_alcohol(1996) ///
	share_alcohol(1997) share_alcohol(1998) share_alcohol(1999),   ///
	trunit(0) trperiod(2000) xperiod(1982(1)1999)
	matrix  PE = nullmat(PE) \ (e(Y_treated)-e(Y_synthetic))'
        }
    
mat rownames PE = `names'
mat colnames PE=`YEAR'
matlist PE , row("Simulation")
		
mat pre_PE=PE[.,1..colnumb(PE,"1999")]
mat post_PE=PE[.,colnumb(PE,"1999")+1..colsof(PE)]
		
mat pre_MSPE=vecdiag(pre_PE*pre_PE')/colsof(pre_PE)
mat post_MSPE=vecdiag(post_PE*post_PE')/colsof(post_PE)
		
mata: rat_MSPE = st_matrix("post_MSPE"):/st_matrix("pre_MSPE")
mata: rat_RMSPE=rat_MSPE:^5

mata: st_matrix("rat_RMSPE",rat_RMSPE')
mat list rat_RMSPE
		

** Print results of matric and show summary statistics

clear
svmat rat_RMSPE
svmat rat_RMSPE_null

sum, d

qui: save mc_power, replace
clear

log close
