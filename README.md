### Liquor-Taxation-and-Alcohol-Related-Driving-Fatalities
### Robert McClelland and John Iselin

In this research we will examine the effects of two separate increases in Illinois’ excise tax on liquor, one increase in 
2000 and a second increase in 2009 on alcohol-related driving fatalities. This read-me file explains both the construction 
of the dataset we will use and how we will estimate our model. Specifically, it will walk users through the file layout, downloading 
of related data, and use of two sets of Stata do-files. 

We will be using the synthetic control method as described in Abadie, 
Diamond, and Hainmuller (2010). For more information, please see:

[Synthetic Control Method](http://www.taxpolicycenter.org/publications/synthetic-control-method-tool-understand-state-policy )

For the 2000 tax change, there will be two versions of the model. First, there are two dependent variables, the share of total accidents 
with BAC values over 0.08 (share_alcohol) and the total number of accidents with BAC values over 0.08 divided by the number of
drivers (drivers_alcohol). 

#### Contents 

* "Dataset Construction - Master.do"
* "Dataset Construction - FARS.do"
* "Dataset Construction - BEA.do"
* "Dataset Construction - CDC Age.do"
* "Dataset Construction - CDC Disease.do"
* "Dataset Construction - FHWA Drivers.do"
* "Dataset Construction - FHWA Gas Tax.do"
* "Dataset Construction - PCE Deflator.do" 
* "Dataset Construction - SEM Unemployment.do"
* "State Names.dta"
* "alcohol.dta"
* "synth_preestimation.do"
* "synth_model.do"
* "synth_postestimation.do"


#### File Layout

The do files and data files attached can be placed into the following set of folders:

* Dataset Construction 
  * *All Dataset Construction do-files*
  * FARS Data (NBER)
    * State Names.dta"
  * Personal Income (BEA)
  * Age Brackets (CDC)
  * Mortality (CDC)
  * Licensed Drivers (FHWA)
  * Gas Taxes (FHWA)
  * PCE Deflator (BEA)
  * Unemployment (SEM)
* Synth
  * "synth_preestimation.do"
  * “synth_model.do”
  * “synth_postestimation.do”
  * “alcohol.dta”
  * IL 2000 - share - narrow
    * preestimation tests
    * placebo tests
    * postestimation tests
  * IL 2000 - share - controls
    * preestimation tests
    * placebo tests
    * postestimation tests
  * IL 2000 - drivers - narrow
    * preestimation tests
    * placebo tests
    * postestimation tests
  * IL 2000 - drivers - controls
    * preestimation tests
    * placebo tests
    * postestimation tests	

#### Dataset Construction Do-Files

* "Dataset Construction - Master.do"

This Do-File is the primary Stata do file used to construct our data. It calls up six individual do-files to clean 
the various data that are included in the final dataset. 

It produces several files summarizing the different data sources, but the main file is: 

“alcohol.dta”: This is an edited version of "Dataset (1982-2015)" with US added to make a total 
of 50 states plus DC and the US. A version of this file is saved in the synth folder. This file only includes the 
variables to be used in our model:


Variable | Discription | Observations | Mean | Std. Dev. | Min | Max 
---|---|---|---|---|---|---
state | State ID Number | 1768 |28.40385 |16.03127 |0 |56             
statename | State Name | 0 | . | . | . | .   
stateabb | State Abbreviation | 0 | . | . | . | . 
year | Year | 1768 | 1998.5 | 9.813484 | 1982 | 2015
share_alcohol | Share of Total Driving Fatal Accidents Due to Alcohol | 1768 | .3255083 | .0780679 | .0877863 | .6136364
drivers_alcohol |  Alcohol-Related Accidents per Driver | 1768 | .0000719 | .0000371 | 7.48e-06 | .0002763
youngshare | Share of the Population Aged 15 to 24 | 1768 | .1477704 | .014785 | .1168265 |.1982249
oldshare | Share of the Population Aged 65 and Up | 1768  |   .127017   |  .0207481  |  .0290261  |  .1944855
pipercap | Personal Income Per Capita | 1768   |  28090.19   |  11925.43  |  8346.565  |  73504.78
umempl | Unemployment Rate (Average of Monthly Rates) | 1768   |  6.028912    | 2.097897  |       2.3  |  17.79167
gasolinetax | Gasoline Tax - Cents per Gallon | 1734   |  18.83292    | 6.166292     |      5    |    50.5
liverdeaths_percap | Liver Deaths per 100,000 People | 1768 | 3.132203 | 1.383401 | 0 | 11.53664
cpi_pce | Personal Consumption Expenditures - Price Index | 1768 | 81.27959 | 17.59999 | 50.553 | 109.532
pipercap_deflated | pipercap deflated by cpi | 1768 | 36403.47 | 9077.556 | 18070.42 | 73504.78
gasolinetax_deflated | gasolinetax deflated by cpi | 1734 | 25.493 | 6.616087 | 7.526248 | 53.37474

This do-file calls up 8 separate do files, each of which operates in its own folder. Before running the do-file, 
make sure that all the file paths are correct and the following instructions for downloading data from online are 
followed, with the downloaded data files sitting in the correct folder. 

##### "Dataset Construction - FARS.do" 

This do-file imports and cleans FARS Data. Data are downloaded from http://www.nber.org/data/fars.html

This file operates within the "FARS Data (NBER)" folder, pulling in "miper_xxxx" and "person_xxxx" files 
from 1982 through 2015 to create a merged file: "miper_person_1982-2015" and a collapsed file with 
state-year observation: "fars 1982-2015" (it also creates "miper_1982-2015" and "person_1982-2015" 
that contained the merged individual year files. 

Download both the "miper_xxxx" and "person_xxxx" Stata files from the NBER website for 1982 through 
2015. When downloading, the files will be saved without the “_xxxx” ending, so this must be added manually. 

##### "Dataset Construction - BEA.do"

This do-file imports and cleans Personal Income and Population Data. Data are downloaded from https://www.bea.gov/itable/.  

This file operates within the "Personal Income (BEA)" Folder, and takes a downloaded csv file, "download.csv" and creates a Stata file with state-year data on population and personal income: " pi_pop 1982-2015.dta"

We used the interactive data option for regional data to download SA1 Personal Income Summary: Personal Income, Population, and Per Capita Personal Income. Make sure to download all areas and all years. 

##### "Dataset Construction - FHWA Drivers.do"

This file imports and cleans data on the number of drivers by state and year, downloaded from https://www.fhwa.dot.gov/policyinformation/statistics/2014/ and from https://www.fhwa.dot.gov/policyinformation/statistics/2015/ 

This file operates within the "Licensed Drivers (FHWA)" Folder, and takes a downloaded excel file, "d1201.xlsx" and creates a Stata file with state-year data on the count of drivers, “drivers 1982-2015". 

We downloaded FHA’s Highway Statistics 2014: Table 6.2.2. Licensed drivers, by State, 1949-2014 and the FHA’s Highway Statistics 2015: Table 6.3.3. Licensed Drivers, by State, sex, and age group. 

##### "Dataset Construction - CDC Disease.do"

This file imports and cleans CDC mortality data on alcoholic cirrhosis of liver (571.2) (see Nelson 2013) Data are downloaded from https://wonder.cdc.gov/mortSQL.html
	
This file operates within the "Mortality (CDC)" folder, and uses the two text files below to create a 
Stata file with state-year data on the count of deaths due to alcoholic cirrhosis of the liver, "Liver Mortality 1982-2015".

For 1979-1998, use "ICD-9 Codes: 571.2 (Alcoholic cirrhosis of liver)". This will create the file "Compressed Mortality, 1999-2015.txt". For 1999-2015, use "ICD-10 Codes: K70.3 (Alcoholic cirrhosis of liver)". This will create the file "Compressed Mortality, 1979-1998.txt". 

When downloading data from CDC Wonder, enter in the following:
1)	Group Results by “State” then “Year”
2)	Select all 50 states and DC (do not select “All* (The United States)”)
3)	Select “All Ages”, “All Years”, “All Genders”. “All Races”, and “All Origins”
4)	Use codes as listed above.
5)	Choose Export Results, Show Totals, Show Zero Values, and Show Suppressed Values

##### "Dataset Construction - CDC Age.do"

This file imports and cleans CDC data on the age distribution. Data are downloaded from https://wonder.cdc.gov/mortSQL.html

This file operates within the "Age Brackets (CDC)" folder, and uses the two text files below to create a Stata file with state-year data on the population by age: "Age Brackets 1982-2015.dta".

For 1979-1998 use "ICD-9 Codes: All". This will create the file "Compressed Mortality, 1999-2015.txt". For 1999-2015, use "ICD-10 Codes: All". This will create the file "Compressed Mortality, 1979-1998.txt".

When downloading data from CDC wonder, enter in the following:
1)	Group Results by “State” then “Year”
2)	Select all 50 states and DC (do not select “All* (The United States)”)
3)	Select all options listed for Age Group except the “All Ages” optionk, then “All Years”, “All Genders”. “All Races”, and “All Origins”
4)	Use codes as listed above.
5)	Choose Export Results, Show Totals, Show Zero Values, and Show Suppressed Values

##### "Dataset Construction - FHWA Gas Tax.do"

This file imports and cleans FHWA data on gasoline taxes. Data are downloaded from https://www.fhwa.dot.gov/policyinformation/statistics.cfm/

This file operates within the "Gas Taxes (FHWA)" folder and uses the excel Excel files below to create a Stata file with state-year data on gasoline tax rates: "State Motor Fuel Tax 1982-2015.dta".

For 1982 through 1995, see “Highway Statistics Summary To 1995”, Section 1: Motor Fuels, State motor fuel taxes and related receipts, 1950-1995 (Table MF-201A) (downloaded as "mf205"). Save this file as "State Motor-Fuel Rates (1981-1995).xlsx". For 1996 through 1999, see the individual Highways Statistics Publications by year, section 1: Motor Fuels: download State tax rates on motor fuel (downloaded as "mf121t" (1996), "mf121t_1997" (1997), "mf121t" (1998 and 1999)). Save these files as "State Motor-Fuel Rates (199Y).xlsx". For 2000 through 2015, use Highway Statistics 2015, table 8.2.3. State tax rates on motor fuel 1998-2015 (downloaded as "mf205". Save this file as "State Motor-Fuel Rates (2000-2015).xlsx"


##### "Dataset Construction - SEM Unemployment.do"

This file imports and cleans State Economic Monitor Data (originally from the BLS) on monthly unemployment rates by state. Data are downloaded from: http://apps.urban.org/features/state-economic-monitor/historical.html 

This file operates within the "Unemployment (SEM)" folder, and uses the excel file below to create a Stata file with state-year data on unemployment rates: "unemployment 1982-2015.dta" (annual rates calculated from average of monthly rates.

We downloaded Unemployment Rate (percent, seasonally adjusted), Monthly unemployment rates from January 1976 to January 2017. Downloaded as "unemployment_historical.xlsx"

##### "Dataset Construction - PCE Deflator"

This file imports and cleans BEA data on a price index based on personal consumption expenditures. Data are downloaded from: https://www.bea.gov/itable/ 

This file operates within the "PCE Deflator (BEA)" folder and creates an Excel file and Stata file: "PCE 1982-2015.dta" and "Price Index - PCE (1982-2015).xlsx".

We downloaded National Data, Table 2.3.4. Price Indexes for Personal Consumption Expenditures by Major Type of Product, All years. We use the total for all goods and services Price Index. 

#### Synthetic Control Model + Pre- and Post-Estimation

After setting up the folders as outlined above, you can run through the do-files in turn. 
It is important to not run them one after another, mainly because the results of the first 
affect the second, and the results of the second affect the third. 

##### “synth_preestimation.do”

This do-file has two main parts. First, it takes the “alcohol.dta” dataset and transforms it into four files, 
two for each version of the model we will be running. For the 2000 IL tax change, there will be two versions 
of the model, one for each dependent variable: the share of total accidents with BAC values over 0.08 (share_alcohol) 
and the total number of accidents with BAC values over 0.08 divided by the number of drivers (drivers_alcohol). For each
of these dependent variables, we run the model over our set of donor states, which is all 50 states plus DC minus states 
with large liquor tax changes, states with liquor control as opposed to or in addition to taxes, and Alaska, DC, and Hawaii. 
For sensitivity analysis we also will re-run the models over a second set of donor states where we add back in states with 
liquor control boards.

Second, it creates a set of pre-estimation figures and tables for each of the two versions of the model (and the sensitivity 
tests). We estimate each version on two donor pools (the larger pool is part of a sensitivity analysis described below). It 
shows the average for all the variables in that particular model by state for 1982 – 2000 and the average of all the variables 
across time for Illinois. It then creates a bar graph showing the average for all the variables in that particular model by 
state for 1982 – 2000, to allow us to look for outliers, and situations where IL is an outlier (if that is the case that 
variable should not be used in this model). Finally, it plots the dependent variable of the model for IL and the US in the 
pre-treatment period (1982-2000), and from this figure we can determine which lagged values of the dependent are appropriate 
to include in our model. 

Note: This file will only work if you have the file paths correctly assigned.

Note: This file is organized without loops, mainly due to the need to label figures properly. This means if you do make any 
major changes, you will have to check 8 places – 4 models * 2 sections. 


##### “synth_model.do”

This file takes the datasets created in synth_preestimation and runs through our model. The model is run twice for each 
version of the data (described above) - once with all pre-treatment dependent variable lags, and once with our selected 
explanatory variables plus lags selected based on our pre-estimation tests. This file also runs the versions through placebo 
tests, which run each potential donor state through the same model IL was run through, to determine if the IL result is different 
from that seen in other states. For each of the two models, this do-file also runs through the sensitivity analysis using the 
larger pool of donor states. 

The choice of lagged dependent variables for our model comes from the results of the pre-estimation tests, and is listed 
in the do-file. If you run the pre-estimation tests and decide on a different set, you have to go into the loop and change 
those years (not a local).

Note: This file loops over the four model/donor pool combinations, so to change the variables or states in the model you 
simply have to change the locals listed at the top.

Note: The donor states actually used in each version of the model and their weights are captured in a dataset at the end of 
this do-file. 

##### “synth_postestimation.do”

This do-file is the third of three. This file takes the datasets created in synth_preestimation and runs through a series 
of post-estimation tests for each version of the data. The tests are as follows. First, we vary the lags used in the model 
to determine if the results are sensitive to the chosen lags. Second, we vary the pre-intervention time period to determine 
if the results are sensitive to the starting point of our data. Third, we test the importance of each state used in the 
synthetic Illinois by sequentially drop each donor state selected by the synth code. Finally, to test the possibility that 
our results are due to a small number of potential donor states we enlarge the donor pool by including states with liquor 
control boards. 

Note: This file loops over the four model/donor pool combinations, so to change the variables or states in the model you 
simply have to change the locals listed at the top.

