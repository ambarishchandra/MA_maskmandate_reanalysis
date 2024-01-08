*Code to read in raw data and generate Figure 1 in the paper

tempfile temp1
*Getting list of 72 districts studied by Cowger et al (source: DESE spreadsheet)
import delimited using ./data/nejm_unmasking_dates.csv, varnames(1) clear
replace district="Dover-Sherborn" if district=="DoverSherborn"
*Carlisle is marked as having an unmasking date of March 10, but it should be March 3
replace unmaskweek="March 3" if district=="Carlisle"
sort district
save `temp1'

import delimited using ./data/enrollmentbyracegender.csv, clear
rename districtname district
sort district

merge m:1 district using `temp1'
keep if _m ==3 //all 72 matched
drop _m
save ./data/race_by_district, replace

import delimited using ./data/weekly_city_town.csv, varnames(1) clear
keep citytown county population reportdate start_date end_date totalcasecounts twoweekcasecounts totaltestslasttwoweeks totalpositivetests
keep citytown county population reportdate totalpositivetests
drop if population=="*"
destring population, replace ignore(",")


gen district=citytown

replace district="Acton-Boxborough" if inlist(citytown,"Acton","Boxborough")
replace district="Ayer Shirley School District" if inlist(citytown,"Ayer","Shirley")
replace district="Whitman-Hanson" if inlist(citytown,"Whitman","Hanson")
replace district="Groton-Dunstable" if inlist(citytown,"Groton","Dunstable")
replace district="Nashoba" if inlist(citytown,"Bolton","Lancaster","Stow")

collapse (sum) totalpositivetests population, by(district reportdate)
sort district
merge m:1 district using `temp1'

drop if _m==1 //districts not studied by the NEJM article
drop if _m==2 //4 districts studied by NEJM article that don't map cleanly to towns: Concord-Carlisle, DoverSherborn, King Philip, Lincoln-Sudbury
drop _m

save ./data/nejm_data, replace


import delimited using "./data/MA_district_enrollment_bygrade", varnames(1) clear
rename district_name district
rename district_total enrollment
keep district county enrollment
destring enrollment, ignore(",") replace
drop if district==""
sort district
tempfile temp2 
save `temp2'

use ./data/nejm_data, clear
merge m:1 district using `temp2'
drop if _m==2 //in the enrollment dataset but not the 68 districts
drop _m //note _m==1 is zero

replace enrollment=enrollment/1000
label var enrollment "Student Enrollment (000s)"

*Merge in race data to plot enrollment and race by district
keep if reportdate=="2021-01-21"
sort district
merge 1:1 district using ./data/race_by_district
label var white "Fraction White"
gen district3 = district if inlist(district,"Boston","Chelsea")

*Move label position to 6 o'clock, only label Boston and Chelsea, mark them in red. 
graph twoway (scatter enrollment white if inlist(district,"Boston","Chelsea"), mlabel(district3) mlabposition(6) mcolor(red)) ///
(scatter enrollment white if ~inlist(district,"Boston","Chelsea"), mcolor(navy)), ///
graphregion(color(white)) bgcolor(white) subtitle("Student Enrollment and Fraction White, 68 school districts") legend(off)
graph export ./figures/enrollment_race2.png, replace

erase ./data/nejm_data.dta
erase ./data/race_by_district.dta
