/***********************************************************************
Author: Robert McClelland and John Iselin
Date: Spring 2017

Illinois Liquor tax increase and alcohol-related accidents. 

Set-Up File Paths for Dataset Construction

We are examining the effect of a 2000 and 2009 Alcohol Tax Increase in Illinois. 
This do-file creates the filepaths necessary to run the rest of the code. This 
dataset will then be used to analyse the tax changes using the synthetic control 
method as described in Abadie, Diamond, and Hainmuller (2010).

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
	local mypath = "/Users/johniselin/Box Sync/LiquorTax/Data/Test/"
	}
	else if regexm(c(os),"Windows") == 1 local mypath = "D:\Users\JIselin\Box Sync\LiquorTax\Data\Test\"


cd "`mypath'"


** Create filepaths
	mkdir "`mypath'Age Brackets (CDC)"
	mkdir "`mypath'Mortality (CDC)"
	mkdir "`mypath'PCE Deflator (BEA)"
	mkdir "`mypath'Gas Taxes (FHWA)"
	mkdir "`mypath'Unemployment (SEM)"
	mkdir "`mypath'Licensed Drivers (FHWA)"
	mkdir "`mypath'Personal Income (BEA)"
	mkdir "`mypath'FARS Data (NBER)"
	
	
