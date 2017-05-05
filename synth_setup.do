/***********************************************************************
Author: Robert McClelland and John Iselin
Date: Spring 2017

Illinois Liquor tax increase and alcohol-related accidents. 

Set-Up File Paths


We are examining the effect of a 2000 and 2009 Alcohol Tax Increase
In Illinois. This set of do-files constructs a dataset and runs 
through a set of pre- and post-estimation tests and models the
effects of the tax change using the synthetic control method as 
described in Abadie, Diamond, and Hainmuller (2010).

This do-file creates the filepaths necessary to run the rest of the code. 

After running this code, remember to place the do-files and data-sets as 
specified in the READ-ME file. 

**************************************************************************/


*** Set-Up ***
capture log close
clear matrix
clear all
set more off

** MAC vs PC Filepaths
if regexm(c(os),"Mac") == 1 {
	local mypath = "/Users/johniselin/Box Sync/LiquorTax/Data/Synth/"
	}
	else if regexm(c(os),"Windows") == 1 local mypath = "D:\Users\JIselin\Box Sync\LiquorTax\Data\Synth\"

	

** Create filepaths
** Note - Comment out 2009 if you are just running through the 2000 code

	local depvar share drivers
	local sizevar narrow controls
	local yearvar 2000 2009

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
	

	
