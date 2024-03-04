*Code to combine parts of massmap.do and diff-in-diff_regressions.do
*to make a single table with demographics, cases and diffs/ratios


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
*rename ïdistrict district
replace district="Dover-Sherborn" if district=="DoverSherborn"
*Carlisle is marked in Ryan Bagwell's spreadsheet as having an unmasking date of March 10, but it should be March 3 according to Cowger et al.
replace unmaskweek="March 3" if district=="Carlisle"
sort district
tempfile temp4
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

gen staff_case_percap=staff/staff_fte*1000
gen staffstud_percap=(students+staff)/(enrollment+staff_fte)*1000
gen stud_case_percap=students/enrollment*1000

keep if date>=22539 & date<=22819 //only the 2021-22 school year

gen post=date>22707

sort district
merge m:1 district using ./data/distance_demographics
*4 districts not matched, all in master.
*3 are regional school districts (charters)
*The fourth is Worthington
drop if _m==1
drop _m
drop nejm_sample //same as nejm

*How many districts have problematic data by Cowger et al metric?
gen missdat=(students==0 & staff==0)
bysort district: egen nmissdat=sum(missdat)


unique district if ~nejm &~dropped & km<50
unique district if ~nejm &~dropped & nmissdat<=10 & km<50
unique district if ~nejm &~dropped & km<65
unique district if ~nejm &~dropped & nmissdat<=10 & km<65
unique district if nmissdat<=10
*35 districts within 50km, down to 29 if cowger criteria
*61 districts within 65km, down to 52 if cowger criteria

*Drop if nmissdat>10. Comment out if want full state
drop if nmissdat>10

save ./data/did_reg_data, replace

*Make new groups
gen newgroup=.
replace newgroup=1 if inlist(district,"Boston","Chelsea")
replace newgroup=2 if nejm & newgroup~=1
replace newgroup=3 if ~nejm & km<80 
replace newgroup=4 if ~nejm & km>80

******PROGRESSIVELY UNCOMMENT NEXT 2 LINES FOR CLOSER DISTRICT GROUPS********
*drop if ~nejm & km>65 & km<80
*drop if ~nejm & km>50 & km<80


table newgroup, stat (mean medinc white) stat(median km)

unique district if newgroup==1
unique district if newgroup==2
unique district if newgroup==3
unique district if newgroup==4

table newgroup if date==22539, stat(sum enrollment staff_fte) nototal


*************REGRESSIONS IN LEVELS AND LOGS TO GET DIFFERENCES AND RATIOS**********
collapse (sum) students staff enrollment staff_fte,by(date reportdate newgroup) 
gen stud_case_percap=students/enrollment*1000
gen staff_case_percap=staff/staff_fte*1000

gen post=date>22707
table newgroup post, statistic(mean stud_case_percap) nformat(%9.2f) nototal
bysort newgroup: ttest stud_case_percap, by( post)

table newgroup post, statistic(mean staff_case_percap) nformat(%9.2f) nototal
bysort newgroup: ttest staff_case_percap, by( post)


***************************************************************
use ./data/did_reg_data, clear


gen treat=inlist(district,"Boston","Chelsea")
gen control1=nejm & ~treat
gen control2=~nejm & km<50
gen control3=~nejm & km<65
gen control4=~nejm & km<80
gen control5=~nejm & km>80


gen log_cases_percap=log(stud_case_percap)
gen post_treat=post*treat

label var treat "Mandate districts"
label var post "Post Mar 2022"
label var post_treat "Post*Mandate"
label var stud_case_percap "Cases per 1000"
label var log_cases "Log(Cases per 1000)"

eststo clear

foreach x in "stud" "staff"{
	
reg `x'_case_percap treat post post_treat if (treat|control1)
eststo `x'lev1
reg `x'_case_percap treat post post_treat if (treat|control2)
eststo `x'lev2
reg `x'_case_percap treat post post_treat if (treat|control3)
eststo `x'lev3
reg `x'_case_percap treat post post_treat if (treat|control4)
eststo `x'lev4
reg `x'_case_percap treat post post_treat if (treat|control5)
eststo `x'lev5

gen `x'_caseK=`x'_case_percap/1000 //Normalize to between 0 and 1
glm `x'_caseK treat post post_treat if (treat|control1), family(binomial) link(logit)
eststo `x'link1
glm `x'_caseK treat post post_treat if (treat|control2), family(binomial) link(logit)
eststo `x'link2
glm `x'_caseK treat post post_treat if (treat|control3), family(binomial) link(logit)
eststo `x'link3
glm `x'_caseK treat post post_treat if (treat|control4), family(binomial) link(logit)
eststo `x'link4
glm `x'_caseK treat post post_treat if (treat|control5), family(binomial) link(logit)
eststo `x'link5

}

foreach x in "stud" "staff"{


esttab `x'lev1 `x'lev2 `x'lev3 `x'lev4 `x'lev5 using "./`x'did.txt", label ci replace nomtitles nonumbers noobs keep(post_treat) nonotes nolines brackets tab

esttab `x'link1 `x'link2 `x'link3 `x'link4 `x'link5 using "./`x'did.txt", label ci append nomtitles nonumbers noobs keep(post_treat) nonotes nolines brackets tab

}


erase ./data/did_reg_data