*Code to make a table showing case rates and differences for Table 1 in the paper


use ./data/district_weekly_cases_percap_staffstudents, clear

****** A:   TABLE OF MEANS PRE/POST BY GROUP ******
*Key reporting dates
*Sept 16, 2021: date=22539
*June 23 2022: date=22819
*March 3 2022: date=22707

keep if date>=22539 & date<=22819 //only the 2021-22 school year

gen post=date>22707 //Date the statewide mkas mandate ended

sort district
merge m:1 district using ./data/distance_demographics
*4 districts not matched, all in master.
*3 are regional school districts (charters)
*The fourth is Worthington
drop if _m==1
drop _m
drop nejm_sample //same as nejm

save ./data/did_reg_data, replace

use ./data/did_reg_data, clear


******************************************************
**************USING DISTRICT-WEEK LEVEL DATA**********


*Make regression tables using district-week level data

*Define the treatment and control groups
gen treat=inlist(district,"Boston","Chelsea")
gen controlcowger=nejm & ~treat
gen control1=~nejm & km<50
gen control2=~nejm & km<65
gen control3=~nejm & km<80
gen control4=~nejm & km>80
gen post_treat=post*treat

*Getting mean case rates for each group
table  post if treat, statistic(mean stud_case_percap) statistic(mean staff_case_percap) nformat(%9.2f) nototal
table  post if controlcowger, statistic(mean stud_case_percap) statistic(mean staff_case_percap) nformat(%9.2f) nototal
table  post if control1, statistic(mean stud_case_percap) statistic(mean staff_case_percap) nformat(%9.2f) nototal
table  post if control2, statistic(mean stud_case_percap) statistic(mean staff_case_percap) nformat(%9.2f) nototal
table  post if control3, statistic(mean stud_case_percap) statistic(mean staff_case_percap) nformat(%9.2f) nototal
table  post if control4, statistic(mean stud_case_percap) statistic(mean staff_case_percap) nformat(%9.2f) nototal


*Now running DiD regressions to get standard errors and CIs
*The lincom command is run on the negative of the estimated coefficient because we define the diff-ind-iff as the change relative to Boston/Chelsea
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

