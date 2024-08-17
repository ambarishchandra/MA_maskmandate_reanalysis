*Code to make a table and run regressions of diff-in-diffs
*Both in levels and in ratios (log cases per capita)
*THIS CODE IS FOR STAFF+STUDENTS , AS OPPOSED TO DIFF-IN-DIFF.DO WHICH IS FOR STUDENTS ONLY


tempfile temp1 temp2 temp3 temp4

*Getting student enrollment numbers
import delimited using "./data/MA_district_enrollment_bygrade", varnames(1) clear
rename district_name district
rename district_total enrollment
keep district enrollment county charter voctech
replace charter=0 if charter==.
replace voctech=0 if voctech==.
destring enrollment, ignore(",") replace
drop if district==""
drop if district=="State Totals"
sort district
save `temp1'

*Getting staff numbers by district (source: https://profiles.doe.mass.edu/statereport/teacherbyracegender.aspx)
import delimited using ./data/staff_by_district.csv, varnames(1) clear
destring staff, ignore(",") replace
rename staff staff_fte
sort district
save `temp2'

*Getting list of districts that are vocational/technical, to drop
import delimited using "./data/MA_district_enrollment_bygrade", varnames(1) clear
rename district_name district
keep district county charter voctech
replace charter=0 if charter==.
replace voctech=0 if voctech==.
drop if district==""
drop if district=="State Totals"
sort district
save `temp3'


*Getting weekly positive covid cases (source: DESE spreadsheet)
import delimited using ./data/nejm_covid_reports.csv, varnames(1) clear
keep reportdate name staff students
rename name district
sort district 
merge m:1 district using `temp1'
keep if _m==3 
drop _m
sort district 
merge m:1 district using `temp2'
keep if _m==3 
drop _m
sort district 
merge m:1 district using `temp3'
keep if _m==3 
drop _m

gen date=date(reportdate,"MDY")

*Now dealing with the four holiday weeks (Nov, Dec, Feb, Apr)
*DESE reported two week totals in each of the following weeks. Cowger et al assumed constant case rates for the two weeks.
sort date
expand 2 if inlist(reportdate,"12-02-2021","01-06-2022","03-03-2022","04-28-2022"), gen(new)

replace students=students/2 if reportdate=="12-02-2021" 
replace staff=staff/2 if reportdate=="12-02-2021" 
replace reportdate="11-25-2021" if reportdate=="12-02-2021" & new

replace students=students/2 if reportdate=="01-06-2022" 
replace staff=staff/2 if reportdate=="01-06-2022" 
replace reportdate="12-30-2021" if reportdate=="01-06-2022" & new

replace students=students/2 if reportdate=="03-03-2022" 
replace staff=staff/2 if reportdate=="03-03-2022" 
replace reportdate="02-24-2022" if reportdate=="03-03-2022" & new

replace students=students/2 if reportdate=="04-28-2022" 
replace staff=staff/2 if reportdate=="04-28-2022" 
replace reportdate="04-21-2022" if reportdate=="04-28-2022" & new

replace date=22609 if date==22616 & new
replace date=22644 if date==22651 & new
replace date=22700 if date==22707 & new
replace date=22756 if date==22763 & new

drop new
sort date

************** ONLY KEEP REGULAR SCHOOLS *****************
drop if charter==1 
drop if voctech==1
drop charter voctech

save ./data/nejm_extended_data_staffstudents, replace

**************************************************************************************************
*A: District level analysis 

*Make 3 groups: 
*1. Boston and Chelsea
*2. Unmask week=march 3
*3. Unmask week=march 10
*4. Unmask week=march 17
*5. 217 other districts in the remainder of the state
*6. Same as 3 except Northampton, Amherst-Pelham, Brookline and Springfield

*Getting list of 72 districts studied by Cowger et al (source: DESE spreadsheet)
import delimited using ./data/nejm_unmasking_dates.csv, varnames(1) clear
*rename ïdistrict district
replace district="Dover-Sherborn" if district=="DoverSherborn"
*Carlisle is marked in Ryan Bagwell's spreadsheet as having an unmasking date of March 10, but it should be March 3 according to Cowger et al.
replace unmaskweek="March 3" if district=="Carlisle"
sort district
tempfile temp4
save `temp4'

use ./data/nejm_extended_data_staffstudents, clear
sort district
merge m:1 district using `temp4'
gen nejm_sample=_m==3
drop _m

gen group=0
replace group=1 if inlist(district,"Boston","Chelsea")
replace group=2 if unmaskweek=="March 3"
replace group=3 if unmaskweek=="March 10"
replace group=4 if unmaskweek=="March 17"
replace group=5 if ~nejm_sample


gen staff_case_percap=staff/staff_fte*1000
gen staffstud_percap=(students+staff)/(enrollment+staff_fte)*1000
gen stud_case_percap=students/enrollment*1000
save ./data/district_weekly_cases_percap_staffstudents, replace
