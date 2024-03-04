*Code to replicate the NEJM figures in Figure 1.
*Written by AC, Jan 7, 2023
*This code generates an intermediate datset (data_for_graphs) that will then be used by make_nejm_graphs.do to produce the actual graphs.


tempfile temp1 temp2 temp3


*Getting staff numbers by district (source: https://profiles.doe.mass.edu/statereport/teacherbyracegender.aspx)
import delimited using ./data/staff_by_district.csv, varnames(1) clear
*rename ïdistrict district 
destring staff, ignore(",") replace
rename staff staff_fte
sort district
save `temp1'

*Getting student enrollment numbers
import delimited using "./data/MA_district_enrollment_bygrade", varnames(1) clear
*rename ïorg_code code
rename district_name district
rename district_total enrollment
keep district enrollment county
destring enrollment, ignore(",") replace
drop if district==""
sort district
save `temp2'

*Getting unmasking dates for the 72 districts (source: DESE spreadsheet)
import delimited using ./data/nejm_unmasking_dates.csv, varnames(1) clear
*rename ïdistrict district
replace district="Dover-Sherborn" if district=="DoverSherborn"
*Carlisle is marked in Ryan Bagwell's spreadsheet as having an unmasking date of March 10, but it should be March 3
replace unmaskweek="March 3" if district=="Carlisle"
sort district

merge 1:1 district using `temp1'
drop if _m==2 //329 districts that were not part of the 72 studied. Note: zero _m==1
drop _m

sort district
merge 1:1 district using `temp2'
drop if _m==2 //328 districts that were not part of the 72 studied. Note: zero _m==1
drop _m
save `temp3'

*Getting weekly positive covid cases (source: DESE spreadsheet)
import delimited using ./data/nejm_covid_reports.csv, varnames(1) clear
keep reportdate name students staff
rename name district
sort district 
merge m:1 district using `temp3'
drop if _m==1 //not among the 72 districts. Note: zero _m==2
drop _m

gen date=date(reportdate,"MDY")

*Now dealing with the four holiday weeks (Nov, Dec, Feb, Apr)
*DESE reported two week totals in each of the following weeks. Cowger et al assumed constant case rates for the two weeks.
*We create a duplicate observation for those weeks, then assign each week half the total cases for the two-week period. 
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

replace date=22609 if date==22616 & new //Dec 2, 2021
replace date=22644 if date==22651 & new //Jan 6, 2022
replace date=22700 if date==22707 & new //Mar 3, 2022
replace date=22756 if date==22763 & new //Apr 28, 2022

drop new
sort date

*Collapse everything to the group level (unmasking date)
collapse (sum) students staff staff_fte enrollment,by(date reportdate unmaskweek) 

gen studstaff_cases=students+staff
gen studstaff_pop=enrollment+staff_fte

gen stud_case_percap=students/enrollment*1000
gen staff_case_percap=staff/staff_fte*1000
gen studstaff_percap=studstaff_cases/studstaff_pop*1000

*Make lagged values
sort unmaskweek date  
forvalues i=1/3 {
by unmaskweek: gen stud_case_percap_L`i' = stud_case_percap[_n-`i']
by unmaskweek: gen staff_case_percap_L`i' = staff_case_percap[_n-`i']
by unmaskweek: gen studstaff_percap_L`i' = studstaff_percap[_n-`i']

}

*Construct moving averages
gen stud_av=(stud_case_percap_L1+stud_case_percap_L2+stud_case_percap_L3)/3
gen staff_av=(staff_case_percap_L1+staff_case_percap_L2+staff_case_percap_L3)/3
gen studstaff_av=(studstaff_percap_L1+studstaff_percap_L2+studstaff_percap_L3)/3

save ./data/data_for_graphs, replace





