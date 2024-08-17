*Code to set up data to make Mass map

*Written, Jan 23 2024.

tempfile temp1 temp2 temp3 temp4
import delimited using ./data/nces_ma_district_bos_distances_A.csv, clear varnames(1)
rename districtname district
sort district
save `temp1'

import delimited ./data/enrollmentbyracegender.csv, clear
rename districtname district
keep district africanamerican asian hispanic white districtcode multiracenonhispanic
sort district
save `temp3'

*Getting list of 72 districts studied by Cowger et al (source: DESE spreadsheet)
import delimited using ./data/nejm_unmasking_dates.csv, varnames(1) clear
replace district="Dover-Sherborn" if district=="DoverSherborn"
*Carlisle is marked as having an unmasking date of March 10, but it should be March 3 according to Cowger et al.
replace unmaskweek="March 3" if district=="Carlisle"
sort district
gen nejm=1
save `temp2'

import delimited ./data/district_medinc.csv, clear
sort district
save `temp4'

use `temp1'
merge 1:1 district using `temp2'
*unmatched are all _m=1, these are non nejm districts
replace nejm=0 if nejm==.
drop _m
merge 1:1 district using `temp3'
drop if _m==2 //all from using
drop if _m==1 //33 districts, all are voctech
drop _m
merge 1:1 district using `temp4'
drop if _m==2 //all from using
drop if _m==1 //107 districts, all are voctech
drop _m

drop ncesdistrictid statedistrictid
tostring districtcode, replace
gen l=length(districtcode)
gen ORG8CODE="0"+districtcode
replace ORG8CODE="0"+ORG8CODE if l==6
replace ORG8CODE="00"+ORG8CODE if l==5
drop l
drop districtcode

keep district city km nejm white medinc ORG8CODE
sort ORG8CODE

drop if km=="#N/A"
destring km, replace
sort district
merge 1:1 district using ./data/fulldat
replace fulldat=0 if fulldat==.
drop _m
gen dropped=inlist(district,"Arlington","Bedford","Harvard","Scituate","Sherborn","Weston","Watertown") //these were the districts dropped by Cowger et al
sort district
save ./data/distance_demographics, replace

export delimited using "./data/district_data_for_map2.csv", replace