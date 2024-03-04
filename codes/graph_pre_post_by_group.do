*Code to plot pre vs post cases by mask mandate end date

import delimited using ./data/pre_post_data.csv, varnames(1) clear

gen logy=log(post_cases)
gen logx=log(proportion)

gen group=""
replace group="Mar 03, R{superscript:2}=0.51" if unmas=="03-Mar"
replace group="Mar 10, R{superscript:2}=0.66" if unmas=="10-Mar"
replace group="Mar 17, R{superscript:2}=0.35" if unmas=="17-Mar"
replace group="Never, R{superscript:2}=NA" if unmas=="Never"
  
*Duplicate all obs to get a "total" group to add R-sq  
expand 2, gen(newvar)
sort newvar
drop newvar
*Next line applied to duplicate observations
replace group="Total, R{superscript:2}=0.55" in 69/136
 
twoway scatter logy logx || lfit logy logx ||, by(group, row(1) legend(off) note("")) ///
 xtitle("Log(Pre Mandate-end Cases/Post Mandate-end Cases)") ytitle("Log(Post Mandate-end Cases per capita)") 
 

graph export ./figures/regs_by_group.png, replace



