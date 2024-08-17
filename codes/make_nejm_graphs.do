*Code to replicate NEJM graphs and then extend the time period back to the Fall of 2021


 use ./data/data_for_graphs, clear
 keep if date>22550

label var stud_av "Weekly Covid-19 Cases per 1000"
 
gen upper = 30
 gen d2=date
 replace d2=date+2 if date==22819
 
 *Students
  graph twoway (area upper d2 if date>=22671, fcolor(gs14) lwidth(none none none none)) ///
(scatter stud_av date if unmaskweek=="March 3", mcolor(blue) connect(line) lcolor(blue) msymbol(oh)) (scatter stud_av date if unmaskweek=="March 10", mcolor(red) connect(line) lcolor(red) msymbol(oh)) ///
(scatter stud_av date if unmaskweek=="March 17", mcolor(green) connect(line) lcolor(green) msymbol(oh)) (scatter stud_av date if unmaskweek=="Never", mcolor(black) connect(line) lcolor(black) msymbol(oh))  (pci 0 22707 40 22707, lcolor(navy) lpattern(dash) text(20 22712 "March 3", orient(vertical))), ttext(32 22760 "Dates Shown in Cowger et al Fig 1B", size(small)) ysc(r(0 30)) legend(order(2 "March 3" 3 "March 10" 4 "March 17" 5 "Never") pos(10) ring(0) col(1) size(small) subtitle("Mandate End:", size(10pt))) ///
 xla( 22574  "Oct 2021" 22630 "Dec 2021" 22693 "Feb 2022" 22756 "Apr 2022"  22812 "Jun 2022", angle(45)) xtitle("") ///
 graphregion(color(white)) bgcolor(white) subtitle("Figure 2: Covid-19 Case Rates among Students, September 2021-June 2022" " ") yscale(range(0 40) titlegap(2)) ytitle("Weekly Covid-19 Cases per 1000") note("Shaded gray region denotes the period January–June 2022 shown in Cowger et al Fig 1B. The full figure corresponds" "to the entire 2021-2022 academic year. District groups are colored by mask mandate drop dates (or none shown in black).")
 
   graph export ./figures/newfig1.png, replace 
   
   *Staff
     graph twoway (area upper d2 if date>=22671, fcolor(gs14) lwidth(none none none none)) ///
(scatter staff_av date if unmaskweek=="March 3", mcolor(blue) connect(line) lcolor(blue) msymbol(oh)) (scatter staff_av date if unmaskweek=="March 10", mcolor(red) connect(line) lcolor(red) msymbol(oh)) ///
(scatter staff_av date if unmaskweek=="March 17", mcolor(green) connect(line) lcolor(green) msymbol(oh)) (scatter staff_av date if unmaskweek=="Never", mcolor(black) connect(line) lcolor(black) msymbol(oh))  (pci 0 22707 50 22707, lcolor(navy) lpattern(dash) text(20 22712 "March 3", orient(vertical))), ttext(32 22760 "Dates Shown in Cowger et al Fig 1B", size(small)) ysc(r(0 30)) legend(order(2 "March 3" 3 "March 10" 4 "March 17" 5 "Never") pos(10) ring(0) col(1) size(small) subtitle("Mandate End:", size(10pt))) ///
 xla( 22574  "October" 22630 "December" 22693 "February" 22756 "April"  22812 "June", angle(45)) xtitle("") ///
 graphregion(color(white)) bgcolor(white) subtitle("Figure S3: Covid-19 Case Rates among Staff, September 2021-June 2022" " ")  yscale(range(0 40) titlegap(2)) ytitle("Weekly Covid-19 Cases per 1000") note("Shaded gray region denotes the period January–June 2022 shown in Cowger et al Fig 1C. The full figure corresponds" "to the entire 2021-2022 academic year. District groups are colored by mask mandate drop dates (or none shown in black).")
 
   graph export ./figures/newfig2.png, replace 
