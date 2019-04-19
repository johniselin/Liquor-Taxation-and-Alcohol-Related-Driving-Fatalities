/***********************************************************************
Author: Robert McClelland and John Iselin
Date: Summer 2018

Illinois Liquor tax increase and alcohol-related accidents. 

Set-Up File Paths


We are examining the effect of a 1999 and 2009 Alcohol Tax Increase
In Illinois. This set of do-files constructs a dataset and runs 
through a set of pre- and post-estimation tests and models the
effects of the tax change using the synthetic control method as 
described in Abadie, Diamond, and Hainmuller (2010).

This do-file creates the filepaths necessary to run the rest of the code. 

Note: While the tax changes occured in 1999 and 2009, since the first year 
when the tax change were fully in effect fell in 2000 and 2010, those are 
the first years of the "treatment".

After running this code, remember to place the do-files and data-sets as 
specified in the READ-ME file. 

**************************************************************************/


*** Set-Up ***
capture log close
clear matrix
clear all
set more off


** MAC vs PC Filepaths
if regexm(c(os),"Mac") == 1 local mypath = ".../"
else if regexm(c(os),"Windows") == 1 local mypath = "...\"

if regexm(c(os),"Mac") == 1 {
	local mypath_logs = "`mypath'/Logs/"
	local mypath_data = "`mypath'/Data/"
	
}
else if regexm(c(os),"Windows") == 1 {
	local mypath_logs = "`mypath'\Logs\"
	local mypath_data = "`mypath'\Data\"
	}

** Create filepaths
** Note - Comment out 2010 if you are just running through the 2000 code

	local depvar share drivers
	local sizevar narrow
	local yearvar 2000 2010

if regexm(c(os),"Mac") == 1 {
	


	foreach a of local yearvar {
		foreach b of local depvar {
			foreach c of local sizevar {
			local mypath_1 
			local mypath_1 "`mypath'/IL `a' - `b' - `c'/"
			di "`mypath_1'"
			mkdir "`mypath_1'"
			mkdir "`mypath_1'placebo tests"
			mkdir "`mypath_1'preestimation tests"
			mkdir "`mypath_1'postestimation tests"
		
			}
		}
	}
}
	
	else if regexm(c(os),"Windows") == 1 {
	

	foreach a of local yearvar {
		foreach b of local depvar {
			foreach c of local sizevar {
			local mypath_1 
			local mypath_1 "`mypath'\IL `a' - `b' - `c'/"
			di "`mypath_1'"
			mkdir "`mypath_1'"
			mkdir "`mypath_1'placebo tests"
			mkdir "`mypath_1'preestimation tests"
			mkdir "`mypath_1'postestimation tests"
			}
		}
	}
}
	

	
