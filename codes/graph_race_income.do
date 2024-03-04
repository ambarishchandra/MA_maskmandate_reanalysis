*Code to graph the 72 districts studied by Cowger et al according to race and income.

*Written, Jan 22 2024.

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



use ./data/nejm_extended_data, clear //created by extend_nejm.do
sort district reportdate
merge m:1 district using `temp1'
*All matched from Master. 135 from using not matched, these are all vocational, technical or certain charter schools that had already been dropped from master.
drop if _m==2
drop _m
drop ncesdistrictid statedistrictid countyname
sort district
merge m:1 district using `temp2'
*All matched from using. Those not matched from master are not nejm districts
replace nejm=0 if _m==1
drop _m

sort district
merge m:1 district using `temp3'
drop if _m==2 //all from using, charter voctech already dropped
drop _m

sort district
merge m:1 district using `temp4'
drop if _m==2 //using data
*There are 6 districts from master that weren't matched. These are probably the ones that had missing (i.e. undisclosed) data in the original ACS medinc dataset
drop _m

label var white "Fraction White"
label var medinc "Median Family Income"
gen district3 = district if inlist(district,"Boston","Chelsea")

graph twoway (scatter medinc white if inlist(district,"Boston","Chelsea"), mlabel(district3) mlabposition(9) mcolor(red)) ///
(scatter medinc white if ~inlist(district,"Boston","Chelsea")&nejm, mcolor(navy)), ///
graphregion(color(white)) bgcolor(white) subtitle("Median Family Income and Fraction White, 72 school districts") legend(off)
graph export ./figures/medinc_race.png, replace

