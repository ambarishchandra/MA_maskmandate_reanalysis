*Code to extend the NEJM study to include districts beyond the 72 studied. 
*Written by AC, Jan 18, 2023


tempfile temp2 temp3

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
save `temp2'


*Getting weekly positive covid cases (source: DESE spreadsheet)
import delimited using ./data/nejm_covid_reports.csv, varnames(1) clear
keep reportdate name students 
rename name district
sort district 
merge m:1 district using `temp2'
keep if _m==3 
drop _m

gen date=date(reportdate,"MDY")

*Now dealing with the four holiday weeks (Nov, Dec, Feb, Apr)
*DESE reported two week totals in each of the following weeks. Cowger et al assumed constant case rates for the two weeks.
*We create a duplicate observation for those weeks, then assign each week half the total cases for the two-week period. 
sort date
expand 2 if inlist(reportdate,"12-02-2021","01-06-2022","03-03-2022","04-28-2022"), gen(new)

replace students=students/2 if reportdate=="12-02-2021" 
replace reportdate="11-25-2021" if reportdate=="12-02-2021" & new

replace students=students/2 if reportdate=="01-06-2022" 
replace reportdate="12-30-2021" if reportdate=="01-06-2022" & new

replace students=students/2 if reportdate=="03-03-2022" 
replace reportdate="02-24-2022" if reportdate=="03-03-2022" & new

replace students=students/2 if reportdate=="04-28-2022" 
replace reportdate="04-21-2022" if reportdate=="04-28-2022" & new

replace date=22609 if date==22616 & new //Dec 2, 2021
replace date=22644 if date==22651 & new //Jan 6, 2022
replace date=22700 if date==22707 & new //Mar 3, 2022
replace date=22756 if date==22763 & new //Apr 28, 2022

drop new
sort date

************** ONLY KEEP REGULAR SCHOOLS *****************
drop if charter==1 
drop if voctech==1
drop charter voctech

save ./data/nejm_extended_data, replace

*Make county level graph
use ./data/nejm_extended_data, clear
*Collapse everything to the county level
collapse (sum) students enrollment,by(date reportdate county) 
gen stud_case_percap=students/enrollment*1000

*Make lagged values
sort county date  
forvalues i=1/3 {
by county: gen stud_case_percap_L`i' = stud_case_percap[_n-`i']
}

*Construct moving averages
gen stud_av=(stud_case_percap_L1+stud_case_percap_L2+stud_case_percap_L3)/3

label var stud_av "Weekly Covid-19 Cases per 1000"
 keep if date>22550 //Sept 27, 2021

  graph twoway ///
(line stud_av date if county=="Suffolk", lcolor(red)) (line stud_av date if county=="Essex", lcolor(gs8)) ///
(line stud_av date if county=="Norfolk", lcolor(gs8)) (line stud_av date if county=="Middlesex", lcolor(gs8)) ///
(line stud_av date if county=="Barnstable", lcolor(gs8)) (line stud_av date if county=="Berkshire", lcolor(gs8)) ///
(line stud_av date if county=="Bristol", lcolor(gs8)) (line stud_av date if county=="Dukes", lcolor(gs8)) ///
(line stud_av date if county=="Franklin", lcolor(gs8)) (line stud_av date if county=="Hampden", lcolor(gs8)) ///
(line stud_av date if county=="Hampshire", lcolor(gs8)) (line stud_av date if county=="Plymouth", lcolor(gs8)) ///
(line stud_av date if county=="Worcester"), xla( 22568  "October" 22629 "December" 22691 "February" 22750 "April"  22811 "June", angle(45)) ///
xtitle("") graphregion(color(white)) bgcolor(white) subtitle("Students in all MA school districts, September 2021 - June 2022") yscale(range(0 40) titlegap(2)) ///
xline(22707, lpattern(dash) lcolor(blue)) text(20 22712 "March 3", orient(vertical)) ///
legend(order(1 "Boston, Chelsea" 2 "12 Other counties"))
 
graph export ./figures/counties3.png, replace 

erase ./data/nejm_extended_data.dta
	

