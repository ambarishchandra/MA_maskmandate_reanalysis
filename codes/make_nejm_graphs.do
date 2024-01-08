*Code to replicate NEJM graphs and then extend the time period back to the Fall of 2021
*Also to eliminate the 7 districts that appear to be double counted
*The dataset used below was made by replicate_nejm.do

use ./data/data_for_graphs, clear

label var stud_av "Weekly Covid-19 Cases per 1000"

*NEJM figure starts in January 2022 for some reason, and also appears to cut off cases*averages at 30 cases.
keep if date>22671 //Jan 26, 2022.

*Next two lines force the y-range to be below 30 cases, to match the NEJM figure.
drop if stud_av>30 & reportdate=="01-27-2022"
replace stud_av=30 if stud_av>30

graph twoway  ///
(scatter stud_av date if (unmaskweek=="March 3"), connect(line) msymbol(oh)) (scatter stud_av date if (unmaskweek=="March 10"), connect(line) msymbol(oh)) ///
(scatter stud_av date if unmaskweek=="March 17", connect(line) msymbol(oh)) (scatter stud_av date if unmaskweek=="Never", connect(line) mcolor(black) lcolor(black) msymbol(oh)), ///
 ysc(r(0 30)) legend(order(1 "March 3" 2 "March 10" 3 "March 17" 4 "Never") pos(3) col(1) size(small) subtitle("Mandate End"))  ///
 xla(22693 "February" 22721 "March" 22756 "April" 22784 "May" 22812 "June", angle(45)) xtitle("") ///
 graphregion(color(white)) bgcolor(white) subtitle("Students, January-June 2022") yla(0(5)30) yscale(range(0 30) titlegap(2))

graph export ./figures/students1.png, replace 
 
use ./data/data_for_graphs, clear
keep if date>22550 //Sept 27, 2021

label var stud_av "Weekly Covid-19 Cases per 1000"

graph twoway ///
(scatter stud_av date if unmaskweek=="March 3", connect(line) msymbol(oh)) (scatter stud_av date if unmaskweek=="March 10", connect(line) msymbol(oh)) ///
(scatter stud_av date if unmaskweek=="March 17", connect(line) msymbol(oh)) (scatter stud_av date if unmaskweek=="Never", mcolor(black) connect(line) lcolor(black) msymbol(oh)), ///
 ysc(r(0 30)) legend(order(1 "March 3" 2 "March 10" 3 "March 17" 4 "Never") pos(3) col(1) size(small) subtitle("Mandate End")) ///
 xla( 22574  "October" 22630 "December" 22693 "February" 22756 "April"  22812 "June", angle(45)) xtitle("") ///
 graphregion(color(white)) bgcolor(white) subtitle("Students, September 2021--June 2022") yscale(range(0 40) titlegap(2))
 
graph export ./figures/students2.png, replace 
  
