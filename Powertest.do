/***********************************************************************
Author: Robert McClelland and John Iselin
Date: Spring 2017

Illinois Liquor tax increase and alcohol-related accidents. 

Monte Carlo Power Test

We are examining the effect of a 1999 and 2009 Alcohol Tax Increase
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
if regexm(c(os),"Mac") == 1 local mypath = "---/"
else if regexm(c(os),"Windows") == 1 local mypath = "D:\Users\JIselin\Box Sync\Illinois Alcohol Taxes and Drunk Driving\Results\Synth Run 06.12.2017\"


cd "`mypath'"
log using "powertest_montecarlo", replace


** Local Variables used in MC
local year 2000
local year2 = `year' - 1
local size 1000
** Assuming the treatment seen in Wagenaar, Livingston, and Staras 2015 (in percent)
local effects 100 74
local state = "4,5,8,13,16,18,20,21,22,24,25,27,29,31,38,45,46,47,48,55"
local depvar share 


* The Monte Carlo estimates a fixed effects model. The year dummies are the average 
* trend across all states. The error term is divided into two pieces, a state effect
* and a iid random effect. In each simulation state 0 (US) is created using the average
* trend across all states plus a randomly selected state effect plus a normally
* distributed error with mean zero and the same standard deviation as the iid
* error in the fixed effects model


set seed 02232017


foreach a of local depvar {
	
	** Data
	use "alcohol.dta", clear
	xtset state year
	set matsize 1000

	* Monte Carlo using narrowly defined list of states
	keep if inlist(state,`state')

	
	quietly: xtreg `a'_alcohol i.year , fe vce(cluster state)
	predict state_mc, xb
	predict state_fe, u
	predict residual, e
	summ residual
	gen sd=r(sd)


	gen state_fe_tmp=.
	gen state_fe_mc=.	

	foreach b of local effects {
	

	** Assuming no treatment effect, calculating the ratio of the root mean squared
	** prediction error. 

	** Note: Code below based on synth documentation availible in synth help file.
	** 		See here for more detail: https://web.stanford.edu/~jhain/synthpage.html


	local lags_2000 `a'_alcohol(1982) `a'_alcohol(1983) `a'_alcohol(1984) ///
	`a'_alcohol(1985) `a'_alcohol(1986) `a'_alcohol(1987) `a'_alcohol(1988) ///
	`a'_alcohol(1989) `a'_alcohol(1990) `a'_alcohol(1991) `a'_alcohol(1992) ///
	`a'_alcohol(1993) `a'_alcohol(1994) `a'_alcohol(1995) `a'_alcohol(1996) ///
	`a'_alcohol(1997) `a'_alcohol(1998) 
	local lags_2010 `a'_alcohol(1982) `a'_alcohol(1983) `a'_alcohol(1984) 	///
	`a'_alcohol(1985) `a'_alcohol(1986) `a'_alcohol(1987) `a'_alcohol(1988)	///
	`a'_alcohol(1989) `a'_alcohol(1990) `a'_alcohol(1991) `a'_alcohol(1992) ///
	`a'_alcohol(1993) `a'_alcohol(1994) `a'_alcohol(1995) `a'_alcohol(1996) ///
	`a'_alcohol(1997) `a'_alcohol(1998) `a'_alcohol(1999) `a'_alcohol(2000) ///	
	`a'_alcohol(2001) `a'_alcohol(2002) `a'_alcohol(2003) `a'_alcohol(2004) ///
	`a'_alcohol(2005) `a'_alcohol(2006) `a'_alcohol(2007) `a'_alcohol(2008) 

	capture mat drop PE
	local names
	tempname resmat
		forvalues i = 1/`size' {
			di `i'	
			quietly: replace state_fe_tmp = state_fe[trunc(1+_N*uniform())]
			quietly: replace state_fe_mc = state_fe_tmp[_N]
			quietly: expand 2 if state == 4 , gen(tag)
			quietly: replace state = 0 if tag == 1
			
			quietly: replace `a'_alcohol=state_fe_mc + state_mc + rnormal(0,sd) if state==0
			quietly: replace `a'_alcohol=`a'_alcohol*(`b'/100) if state==0 & year > (`year2')	
			
			quietly: synth `a'_alcohol `lags_`year'', ///
			trunit(0) trperiod(`year') xperiod(1982(1)`year2') 
			
			matrix  PE = nullmat(PE) \ (e(Y_treated)-e(Y_synthetic))'
			local names `"`names' `"`i'"'"'
			quietly: drop if state == 0
			drop tag
		}
       
	mat rownames PE = `names'
	mat colnames PE=`YEAR'

	matlist PE , row("Simulation")
				
	mat post_PE=PE[.,colnumb(PE,"`year2'")+1..colsof(PE)]
			
	mat post_MSPE=vecdiag(post_PE*post_PE')/colsof(post_PE)

	mata: post_MSPE = st_matrix("post_MSPE")
			
	mata: st_matrix("`a'_post_MSPE_`b'",post_MSPE')

	}
	clear
}	
		
clear

foreach a of local depvar {
	foreach b of local effects {
		svmat `a'_post_MSPE_`b'
		
		forvalues x = 1/10 { 
			qui: sum `a'_post_MSPE_`b'1 if _n <= `size'/10 * `x', d
			matrix  postMSPE_`a'_`b' = nullmat(postMSPE_`a'_`b') \ r(mean),r(sd),r(skewness),r(kurtosis)'
		}	
		
			qui: sum `a'_post_MSPE_`b'1, d
			matrix postMSPE_sum_`a'_`b' = nullmat(postMSPE_sum_`a'_`b') \ r(p1),r(p5),r(p10),r(p25),r(p50),r(p75),r(p90),r(p95),r(p99)'
	
	}
}

sum, d

qui: save powertestdata, replace
clear

** To compare moments across sample sizes, uncomment below:
/*
** Save statistics by sample size

local rows 100 200 300 400 500 600 700 800 900 1000
local columns mean sd skewness kurtosis
local percent p1 p5 p10 p25 p75 p90 p95 p99

foreach a of local depvar {
	foreach b of local effects {
	
	mat rownames postMSPE_`a'_`b' = `rows'
	mat colnames postMSPE_`a'_`b' =`columns'
	mat list postMSPE_`a'_`b'
	svmat postMSPE_`a'_`b',  names(col) 
	gen n = _n *100
	order n
	export excel using "`mypath'Powertest.xlsx", sheet("postMSPE_`a'_`b'_data") sheetmodify  firstrow(var) 
	clear 
	
	
	clear
	}
}

foreach a of local depvar {
	foreach b of local effects {
	svmat postMSPE_sum_`a'_`b'
	
	
	}
}

export excel using "`mypath'Powertest.xlsx", sheet("postMSPE_sum_data") sheetmodify  firstrow(var) 
clear

*/
log close
