*Code to make a new graph of cumulative cases
*Mainly based on read_data, but some tweaks to adjust population
*numbers which otherwise change mid-sample

import delimited using ./data/nejm_unmasking_dates.csv, varnames(1) clear
*rename ïdistrict district
replace district="Dover-Sherborn" if district=="DoverSherborn"
*Carlisle is marked in Ryan Bagwell's spreadsheet as having an unmasking date of March 10, but it should be March 3
replace unmaskweek="March 3" if district=="Carlisle"
sort district
tempfile temp1
save `temp1'

import delimited using ./data/weekly_city_town.csv, varnames(1) clear
*rename ïcitytown citytown
keep citytown county population reportdate start_date end_date totalcasecounts twoweekcasecounts totaltestslasttwoweeks totalpositivetests
keep citytown county population reportdate totalpositivetests
drop if population=="*"
destring population, replace ignore(",")

*Population figures change mid-way through the sample (due to updated Census figures), which can cause cumulative cases to appear to decrease. Solution: use the average of the two population numbers for each district.
sort citytown reportdate
by citytown: egen av_pop=mean(population)
replace population=av_pop
drop av_pop

gen district=citytown

replace district="Acton-Boxborough" if inlist(citytown,"Acton","Boxborough")
replace district="Ayer Shirley School District" if inlist(citytown,"Ayer","Shirley")
replace district="Whitman-Hanson" if inlist(citytown,"Whitman","Hanson")
replace district="Groton-Dunstable" if inlist(citytown,"Groton","Dunstable")
replace district="Nashoba" if inlist(citytown,"Bolton","Lancaster","Stow")

collapse (sum) totalpositivetests population, by(district reportdate)
sort district
merge m:1 district using `temp1'

drop if _m==1 //districts not studied by the NEJM article
drop if _m==2 //4 districts studied by NEJM article that don't map cleanly to towns: Concord-Carlisle, DoverSherborn, King Philip, Lincoln-Sudbury
drop _m

save ./data/nejm_data_cumul_cases, replace

use ./data/nejm_data_cumul_cases, clear
replace unmasking_date="March 3" if district=="Carlisle"

gen group=0
replace group=1 if unmask=="March 3"
replace group=2 if unmask=="March 10"
replace group=3 if unmask=="March 17"
drop unmasking_date

collapse (sum) totalpositivetests population , by(reportdate group)
bysort group (reportdate population): gen cumul_cases=sum(totalpositivetests)
gen frac=cumul_cases/population

keep  frac group reportdate
reshape wide frac, i(reportdate) j(group)

gen date=date(reportdate,"YMD")
gen year=year(date)
gen month=month(date)

keep reportdate year month frac* 

gen date=date(reportdate,"YMD")

graph twoway (line frac0 date) (line frac3 date) (line frac2 date) (line frac1 date) (pcarrowi 0.4 22520 0.4 22620 (9) " time-varying confounder"), legend(label(1 "Never") label(2 "March 17") label(3 "March 10") label(4 "March 3") label (5 ""))  xla( 22295 "Jan 2021" 22454 "Jun 2021" 22604 "Nov 2021" 22763 "Apr 2021" 22933 "Oct 2022", angle(45)) xtitle("") ///
 graphregion(color(white)) bgcolor(white) subtitle("Cumulative Cases") xscale(range(22265 22965)) yscale(range(0 0.65) titlegap(2))
 
 
*graph twoway (line frac0 date, lcolor(black)) (line frac3 date, lcolor(sienna)) (line frac2 date, lcolor(red)) (line frac1 date, lcolor(lime)) (pcarrowi 0.47 22565 0.43 22680) (pci 0 22707 0.5 22707, lcolor(green) lpattern(dash) text(0.15 22722 "March 3: Statewide" "Mandate End", orient(vertical))) if date<22812, legend(order(1 "Never" 2 "March 17" 3 "March 10" 4 "March 3") subtitle("Mandate End:"))  xla( 22295 "Jan 2021" 22454 "Jun 2021" 22604 "Nov 2021" 22763 "Apr 2021", angle(45)) xtitle("") ttext(0.5 22300 "Boston/Chelsea had the highest rate" "of infections prior to the end of the" "statewide mask mandate which is" "a time-varying confounder.", place(se) just(left) )
 
  graph twoway (line frac0 date, lcolor(black)) (line frac3 date, lcolor(green)) (line frac2 date, lcolor(red)) (line frac1 date, lcolor(blue)) (pci 0 22707 0.5 22707, lcolor(navy) lpattern(dash) text(0.15 22722 "March 3: Statewide" "Mandate End", orient(vertical))) if date<22812, legend(order(1 "Never" 2 "March 17" 3 "March 10" 4 "March 3") subtitle("Mandate End:"))  xla( 22295 "Jan 2021" 22454 "Jun 2021" 22604 "Nov 2021" 22763 "Apr 2022", angle(45)) xtitle("") ytitle("Cumulative  Community Cases per Capita") ttext(0.5 22300 "Boston/Chelsea had the highest rate" "of increase in infections prior to the" "end of mask mandates which is a" "likely confounder.", place(se) just(left)) subtitle("Figure 3: Cumulative community cases by district mask policy" " ") note("The figure plots cumulative community cases of Covid-19 per capita for the four groups of school districts studied in" "Cowger et al, based on town level data from the Massachusetts Department of Public Health")
 
 graph export ./figures/new_cumul.png, replace