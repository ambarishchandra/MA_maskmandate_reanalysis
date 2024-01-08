*Code to make a table of diff-in-diffs
*Both in levels and in ratios (log cases per capita)


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

*Getting list of 72 districts studied by Cowger et al (source: DESE spreadsheet)
import delimited using ./data/nejm_unmasking_dates.csv, varnames(1) clear
replace district="Dover-Sherborn" if district=="DoverSherborn"
*Carlisle is marked as having an unmasking date of March 10, but it should be March 3 according to Cowger et al.
replace unmaskweek="March 3" if district=="Carlisle"
sort district
save `temp4'

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
merge m:1 district using `temp4'
gen nejm_sample=_m==3
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

************** ONLY KEEP REGULAR SCHOOLS *****************
drop if charter==1 
drop if voctech==1
drop charter voctech


*Make 3 groups: 
*1. Boston and Chelsea
*2. Unmask week=march 3
*3. Unmask week=march 10
*4. Unmask week=march 17
*5. 217 other districts in the remainder of the state

gen group=0
replace group=1 if inlist(district,"Boston","Chelsea")
replace group=2 if unmaskweek=="March 3"
replace group=3 if unmaskweek=="March 10"
replace group=4 if unmaskweek=="March 17"
replace group=5 if ~nejm_sample

keep if date>=22539 & date<=22819 //only the 2021-22 school year; Sep 16, 2021 to 23 June, 2022.

*Now making 'supergroups'. 
*Supergroup 1 is Boston and Chelsea, mask mandates maintained throughout
*Supergroup 2 is the other districts studied by Cowger et al
*Supergroup 3 is the set of all other districts in MA 
gen supergroup=1 if group==1 //Boston, Chelsea
replace supergroup=2 if inlist(group,2,3,4) //70 other districts in Greater Boston
replace supergroup=3 if group==5 //217 other districts in MA

collapse (sum) students staff enrollment staff_fte,by(date reportdate supergroup) 
gen staff_case_percap=staff/staff_fte*1000
gen staffstud_percap=(students+staff)/(enrollment+staff_fte)*1000
gen stud_case_percap=students/enrollment*1000
gen post=date>22707 //March 3, 2022

*Now generating data for tables. 
*First, the mean cases per capita for each group, pre- and post- March 3 2022
table supergroup post, statistic(mean staffstud_percap) nformat(%9.2f) nototal
table supergroup post, statistic(mean stud_case_percap) nformat(%9.2f) nototal
table supergroup post, statistic(mean staff_case_percap) nformat(%9.2f) nototal

*Now the standard devations, needed to compute p-values
table supergroup post, statistic(sd staffstud_percap) nformat(%9.2f) nototal
table supergroup post, statistic(sd stud_case_percap) nformat(%9.2f) nototal
table supergroup post, statistic(sd staff_case_percap) nformat(%9.2f) nototal

*Now the count of observations, needed to compute p-values
table supergroup post, statistic(count staffstud_percap) nformat(%9.2f) nototal
table supergroup post, statistic(count stud_case_percap) nformat(%9.2f) nototal
table supergroup post, statistic(count staff_case_percap) nformat(%9.2f) nototal

*Taking logs of cases per capita to get ratios
gen log_stud=log(stud_case_percap)
gen log_staff=log(staff_case_percap)
gen log_studstaff=log(staffstud_percap)

table supergroup post, statistic(mean log_studstaff) nformat(%9.2f) nototal
table supergroup post, statistic(mean log_stud) nformat(%9.2f) nototal
table supergroup post, statistic(mean log_staff) nformat(%9.2f) nototal

*Note: the remaining values in Table 2 are not calculated in this code. Interested users will need to manually calculate the differences, and the differences in those differences, using Excel or some other spreadsheet program.

*An alternative is to calculate the D-i-D estimates in a Regression framework as we show below.
*E.g. regress student cases per capita in each group on indicators for treatment, post-intervention, and their interaction
*This will generate the same results as using the Table command above.

*Defining BosChel as treatment group and other two groups as successive control groups.
gen treat=supergroup==1
gen control1=supergroup==2
gen control2=supergroup==3
gen post_treat=post*treat

*Verify that the coefficient on post_treat in each regression below matches the diff-in-diff calculated manually

*First, students
reg stud_case_percap treat post post_treat if (treat|control1)
reg stud_case_percap treat post post_treat if (treat|control2)

*Next, staff
reg staff_case_percap treat post post_treat if (treat|control1)
reg staff_case_percap treat post post_treat if (treat|control2)

*Finally, students+staff
reg staffstud_percap treat post post_treat if (treat|control1)
reg staffstud_percap treat post post_treat if (treat|control2)


