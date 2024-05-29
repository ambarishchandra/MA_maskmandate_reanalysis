*Code to combine parts of massmap.do and diff-in-diff_regressions.do
*to make a single table with demographics, cases and diffs/ratios



use ./data/district_weekly_cases_percap_staffstudents, clear

****** A:   TABLE OF MEANS PRE/POST BY GROUP ******
*Key reporting dates
*Sept 16, 2021: date=22539
*June 23 2022: date=22819
*March 3 2022: date=22707

keep if date>=22539 & date<=22819 //only the 2021-22 school year

gen post=date>22707

sort district
merge m:1 district using ./data/distance_demographics
*4 districts not matched, all in master.
*3 are regional school districts (charters?)
*The fourth is Worthington
drop if _m==1
drop _m
drop nejm_sample //same as nejm

*How many districts have problematic data by Cowger et al metric?
gen missdat=(students==0 & staff==0)
bysort district: egen nmissdat=sum(missdat)

table district if dropped, stat(mean nmissdat)
table district if nejm, stat(mean nmissdat)
*King Philip is 11 should have been dropped
*Dover, DoverSherborn, Carlisle and Winchester are 9 or 10

table district if ~nejm & km<50, stat(mean nmissdat)
unique district if ~nejm &~dropped & km<50
unique district if ~nejm &~dropped & nmissdat<=10 & km<50
unique district if ~nejm &~dropped & km<65
unique district if ~nejm &~dropped & nmissdat<=10 & km<65
*35 districts within 50km, down to 29 if cowger criteria

*Drop if nmissdat>10. Comment out if want full state
drop if nmissdat>10 & district~="King Philip" //dropping districts with >10 missing weeks but keeping King Philip to match Cowger.
*drop if nmissdat>10


save ./data/did_reg_data, replace

use ./data/did_reg_data, clear


******************************************************
**************USING DISTRICT-WEEK LEVEL DATA**********


*Make regression tables using district-week level data

gen treat=inlist(district,"Boston","Chelsea")
gen controlcowger=nejm & ~treat
gen control1=~nejm & km<50
gen control2=~nejm & km<65
gen control3=~nejm & km<80
gen control4=~nejm & km>80
gen post_treat=post*treat

table  post if controlcowger, statistic(mean stud_case_percap) statistic(mean staff_case_percap) nformat(%9.2f) nototal
table  post if control1, statistic(mean stud_case_percap) statistic(mean staff_case_percap) nformat(%9.2f) nototal
table  post if control2, statistic(mean stud_case_percap) statistic(mean staff_case_percap) nformat(%9.2f) nototal
table  post if control3, statistic(mean stud_case_percap) statistic(mean staff_case_percap) nformat(%9.2f) nototal
table  post if control4, statistic(mean stud_case_percap) statistic(mean staff_case_percap) nformat(%9.2f) nototal


reg stud_case_percap treat post post_treat if (treat|controlcowger)
lincom 0-post_treat
reg staff_case_percap treat post post_treat if (treat|controlcowger)
lincom 0-post_treat

reg stud_case_percap treat post post_treat if (treat|control1)
lincom 0-post_treat
reg staff_case_percap treat post post_treat if (treat|control1)
lincom 0-post_treat

reg stud_case_percap treat post post_treat if (treat|control2)
lincom 0-post_treat
reg staff_case_percap treat post post_treat if (treat|control2)
lincom 0-post_treat

reg stud_case_percap treat post post_treat if (treat|control3)
lincom 0-post_treat
reg staff_case_percap treat post post_treat if (treat|control3)
lincom 0-post_treat

reg stud_case_percap treat post post_treat if (treat|control4)
lincom 0-post_treat
reg staff_case_percap treat post post_treat if (treat|control4)
lincom 0-post_treat

gen studperK=stud_case_percap/1000 //Normalize to between 0 and 1
gen staffperK=staff_case_percap/1000 //Normalize to between 0 and 1

*Original Cowger control group
glm studperK treat post post_treat if (treat|controlcowger), family(binomial) link(logit)
lincom 0-post_treat
glm staffperK treat post post_treat if (treat|controlcowger), family(binomial) link(logit)
lincom 0-post_treat

*Less than 50km
glm studperK treat post post_treat if (treat|control1), family(binomial) link(logit)
lincom 0-post_treat
glm staffperK treat post post_treat if (treat|control1), family(binomial) link(logit)
lincom 0-post_treat

*Less than 80km
glm studperK treat post post_treat if (treat|control3), family(binomial) link(logit)
lincom 0-post_treat
glm staffperK treat post post_treat if (treat|control3), family(binomial) link(logit)
lincom 0-post_treat

*Rest of state
glm studperK treat post post_treat if (treat|control4), family(binomial) link(logit)
lincom 0-post_treat
glm staffperK treat post post_treat if (treat|control4), family(binomial) link(logit)
lincom 0-post_treat

*************REGRESSIONS IN LEVELS AND LOGS TO GET DIFFERENCES AND RATIOS**********
collapse (sum) students staff enrollment staff_fte,by(date reportdate newgroup) 
gen stud_case_percap=students/enrollment*1000
gen staff_case_percap=staff/staff_fte*1000

gen post=date>22707
table newgroup post, statistic(mean stud_case_percap) nformat(%9.2f) nototal
bysort newgroup: ttest stud_case_percap, by( post)

table newgroup post, statistic(mean staff_case_percap) nformat(%9.2f) nototal
bysort newgroup: ttest staff_case_percap, by( post)

