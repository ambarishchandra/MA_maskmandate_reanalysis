*Code to create a CSV file for use by R, in order to produce a graph of cumulative community infections for the four groups of districts studied by Cowger et al.
*Most of the code is repeated from read_data.do, with some additional manipulation at the end to make it easy to use ggplot in R.

tempfile temp3
*Getting list of 72 districts studied by Cowger et al (source: DESE spreadsheet)
import delimited using ./data/nejm_unmasking_dates.csv, varnames(1) clear
replace district="Dover-Sherborn" if district=="DoverSherborn"
*Carlisle is marked as having an unmasking date of March 10, but it should be March 3
replace unmaskweek="March 3" if district=="Carlisle"
sort district
save `temp3'

import delimited using ./data/weekly_city_town.csv, varnames(1) clear
keep citytown county population reportdate start_date end_date totalcasecounts twoweekcasecounts totaltestslasttwoweeks totalpositivetests
keep citytown county population reportdate totalpositivetests
drop if population=="*"
destring population, replace ignore(",")


gen district=citytown

replace district="Acton-Boxborough" if inlist(citytown,"Acton","Boxborough")
replace district="Ayer Shirley School District" if inlist(citytown,"Ayer","Shirley")
replace district="Whitman-Hanson" if inlist(citytown,"Whitman","Hanson")
replace district="Groton-Dunstable" if inlist(citytown,"Groton","Dunstable")
replace district="Nashoba" if inlist(citytown,"Bolton","Lancaster","Stow")

collapse (sum) totalpositivetests population, by(district reportdate)
sort district
merge m:1 district using `temp3'

drop if _m==1 //districts not studied by the NEJM article
drop if _m==2 //4 districts studied by NEJM article that don't map cleanly to towns: Concord-Carlisle, DoverSherborn, King Philip, Lincoln-Sudbury
drop _m

gen group=0
replace group=1 if unmask=="March 3"
replace group=2 if unmask=="March 10"
replace group=3 if unmask=="March 17"
drop unmaskweek

collapse (sum) totalpositivetests population , by(reportdate group)
bysort group (reportdate population): gen cumul_cases=sum(totalpositivetests)
gen frac=cumul_cases/population

keep  frac group reportdate
reshape wide frac, i(reportdate) j(group)

gen date=date(reportdate,"YMD")
gen year=year(date)
gen month=month(date)

keep reportdate year month frac* 
export delimited using ./data/4group_data.csv, replace