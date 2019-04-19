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
	

cd "`mypath'"

*do Powertest.do

cd "`mypath'"

do synth_preestimation_2000.do

cd "`mypath'"

do synth_preestimation_2010.do

cd "`mypath'"

do synth_model_2000.do

cd "`mypath'"

do synth_model_2010.do

cd "`mypath'"

do synth_postestimation_2000.do

cd "`mypath'"

do synth_postestimation_2010.do
