*Code to make a table showing case rates, differences and RRRs for Table 1 in the paper

use ./data/district_weekly_cases_percap_staffstudents, clear

****** A:   TABLE OF MEANS PRE/POST BY GROUP ******
*Key reporting dates
*Sept 16, 2021: date=22539
*June 23 2022: date=22819
*March 3 2022: date=22707

keep if date>=22539 & date<=22819 //only the 2021-22 school year

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
*There are is one treatment group, with two districts: Boston and Chelsea.
*There are multiple control groups, based on the districts studied by Cowger et al, as well as based on distance
*District studied by Cowger et al have the nejm variable equal to 1.
*The km variable contains distance, in kilometres, from Boston

gen treat=inlist(district,"Boston","Chelsea")
gen control1=nejm & ~treat //i.e. in the NEJM paper, but not treatment districts
gen control2=~nejm & km<50 //i.e. not in the NEJM paper, and within 50km of Boston
gen control3=~nejm & km<80 //i.e. not in the NEJM paper, and within 80km of Boston
gen control4=~nejm & km>80 //i.e. not in the NEJM paper, and beyond 80km of Boston
*Define a variable, called post, to denote all observations after the statewide mask mandate ended
gen post=date>22707 //Date the statewide mask mandate ended, i.e. March 3 2022
gen post_treat=post*treat //This is the interaction of post mandate, and being in the treatment group.

*Getting mean case rates for each group
table  post if treat, statistic(mean stud_case_percap) statistic(mean staff_case_percap) nformat(%9.2f) nototal
table  post if control1, statistic(mean stud_case_percap) statistic(mean staff_case_percap) nformat(%9.2f) nototal
table  post if control2, statistic(mean stud_case_percap) statistic(mean staff_case_percap) nformat(%9.2f) nototal
table  post if control3, statistic(mean stud_case_percap) statistic(mean staff_case_percap) nformat(%9.2f) nototal
table  post if control4, statistic(mean stud_case_percap) statistic(mean staff_case_percap) nformat(%9.2f) nototal


*Now running DiD regressions to get standard errors and CIs
*The lincom command is run on the negative of the estimated coefficient because we define the diff-in-diff as the change relative to Boston/Chelsea.
*Note these are regular (unclustered) SEs
forvalues i=1/4 {
qui reg stud_case_percap treat post post_treat if (treat|control`i')
lincom 0-post_treat
qui reg staff_case_percap treat post post_treat if (treat|control`i')
lincom 0-post_treat
}

*Same as above, but with clustered SEs.
forvalues i=1/4 {
qui reg stud_case_percap treat post post_treat if (treat|control`i'), vce(cluster district)
lincom 0-post_treat
qui reg staff_case_percap treat post post_treat if (treat|control`i'), vce(cluster district)
lincom 0-post_treat
}


*Running poisson model. First, round the case numbers to integers (we have fractional case numbers due to holiday weeks)
gen stud_round=round(students,1) //round the case numbers to make them integers
gen staff_round=round(staff,1) //round the case numbers to make them integers

forvalues i=1/4 {
qui poisson stud_round treat##post if (treat|control`i'), exposure(enrollment) vce(cluster district)
lincom (_b[0.treat#1.post] - _b[0.treat#0.post]) - (_b[1.treat#1.post] - _b[1.treat#0.post] ), irr
qui poisson staff_round treat##post if (treat|control`i'), exposure(staff_fte) vce(cluster district)
lincom (_b[0.treat#1.post] - _b[0.treat#0.post]) - (_b[1.treat#1.post] - _b[1.treat#0.post] ), irr
}

*Now with regular (unclustered SEs)
forvalues i=1/4 {
qui poisson stud_round treat##post if (treat|control`i'), exposure(enrollment)
lincom (_b[0.treat#1.post] - _b[0.treat#0.post]) - (_b[1.treat#1.post] - _b[1.treat#0.post] ), irr
qui poisson staff_round treat##post if (treat|control`i'), exposure(staff_fte)
lincom (_b[0.treat#1.post] - _b[0.treat#0.post]) - (_b[1.treat#1.post] - _b[1.treat#0.post] ), irr
}

*Clustered SEs are actually smaller, but this is what Annals stats team recommends using. 