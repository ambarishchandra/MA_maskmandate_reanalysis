# MA_maskmandate_reanalysis

Code and Data Documentation for “Mask mandates and COVID-19: A Re-analysis of the Boston school mask study”

Tracy Beth Høeg, Ambarish Chandra, Ram Duriseti, Shamez Ladhani, and Vinay Prasad.

This document provides detailed code and data, as well as step-by-step instructions, for replicating the following figures and tables in Høeg et al.

Figure 1: Student Enrollment and District Population  

Figure 2a and b. Replication and Extension of Figure 1B from Cowger et al.  

Figure 3: Student case rates reported by districts, aggregated by Massachusetts counties.  

Figure 4. Cumulative community cases by district mask policy  

Figure 6: Analysis of the relationship between community case rates from 12/1/2020 through 2/27/2022 and case rates post 2/27/2022 through 6/22/2022.  

Table 1. Case rate changes from pre- to post-March 3rd 2023 by multiple baseline time periods.  

Table 2: DiD analysis between different “treatment” groups by testing population  

Figure 5. Cumulative cases per capita by county (data restricted)  


For Figure 5, we have provided our code and documentation but not the data. This is because these data are restricted by the Centers for Disease Control (CDC) and may not be posted publicly, although interested researchers may apply to the CDC for permission to access the data at https://data.cdc.gov/Case-Surveillance/COVID-19-Case-Surveillance-Restricted-Access-Detai/mbd7-r32t/about_data.

Note that some figures use the same datasets as those used for making prior figures (e.g. Figure 3 reuses the same datasets that were needed to produce Figure 2). The document provides standalone instructions for reproducing each table and figure in the paper. This is done to facilitate replication of whichever table or figure researchers may be interested in, without needing to generate all results in the paper.

Notes on executing the codes:
1. Place “codes”, “data” and “figures” at the same level of folder hierarchy.  
2. Execute all codes from the root folder.  
3. Graphs will be saved to the “figures” subfolder, which the user needs to create.  
4. The final tables require additional formatting that is not shown here.  
5. Stata codes were created and tested using Stata Version 18.  
6. R codes were created and tested using R Version 4.2.3  

**Figure 1: Student Enrollment and District Population**  
Dataset(s) required: 
enrollmentbyracegender.csv (provided): Race and Gender data for 398 MA school districts.
weekly_city_town.csv (provided): Weekly Covid-19 case reports for all MA cities and towns.
nejm_unmasking_dates.csv (provided): List of 72 districts studied by Cowger et al, with dates on which mask mandates ended.
MA_district_enrollment_bygrade.csv (provided): Number of students enrolled, by grade, in each of 398 MA school districts.
Code(s) required:
Read_data.do (provided): Read in raw data, creates and saves a graph (enrollment_race2.png) showing enrollment and fraction white for all districts, which is Figure 1 in the paper.

Figure 2a and 2b: Replication and Extension of Figure 1B from Cowger et al
Dataset(s) required: 
nejm_unmasking_dates.csv (provided): List of 72 districts studied by Cowger et al, with dates on which mask mandates ended.
MA_district_enrollment_bygrade.csv (provided): Number of students enrolled, by grade, in each of 398 MA school districts.
Nejm_covid_reports.csv (provided): Weekly positive Covid-19 cases, separately for students and staff, for 398 MA school districts.

Code(s) required:
Replicate_nejm.do (provided): reads in district level data on Staff FTE and student enrollment, unmasking dates, weekly covid cases. Smooths out missing data for holiday weeks, constructs three-week moving averages, saves an intermediate dataset: data_for_graphs.dta
Make_nejm_graphs.do (provided): starts with data_for_graphs.dta, makes graphs to replicate Figure in Cowger et al, for Figure 2a in the paper (students1.png). Also extends back to the start of the school year for Figure 2b (students2.png).

Figure 3: Student case rates reported by districts, aggregated by Massachusetts counties.
Dataset(s) required:
MA_district_enrollment_bygrade.csv (provided): Number of students enrolled, by grade, in each of 398 MA school districts.
Nejm_covid_reports.csv (provided): Weekly positive Covid-19 cases, separately for students and staff, for 398 MA school districts.

Code(s) required:
Extend_nejm.do (provided): Aggregates weekly district-level covid-19 case rates to the county level, for each of MA’s 14 counties, and then produces a graph (counties3.png) which is Figure 3 in the paper.


Figure 4. Cumulative community cases by district mask policy
Dataset(s) required:
weekly_city_town.csv (provided): Weekly Covid-19 case reports for all MA cities and towns.
nejm_unmasking_dates.csv (provided): List of 72 districts studied by Cowger et al, with dates on which mask mandates ended.

Code(s) required:
Make_4group_data.do (provided): Reads in community case data, assigns cases to school districts based on district to town mapping, saves an intermediate dataset (4group_data.csv) containing weekly cumulative cases per capita for each of the four groups of school districts studied by Cowger et al. The goal is to examine cumulative prior immunity in the communities associated with each school district.
Cumulative_graph_4district_groups.R (provided): R code to read in the intermediate dataset (4group_data.csv) described above and create a graph plotting cumulative infections per capita for each of the four groups of school districts, saving plot_cumulative_4group.pdf which is Figure 4 in the paper.

Figure 6: Analysis of the relationship between community case rates from 12/1/2020 through 2/27/2022 and case rates post 2/27/2022 through 6/22/2022.
Dataset(s) required:
pre_post_data.csv (provided): Dataset of school districts with two constructed variables: (i) Total cases per capita reported by each school district in the period March–June 2022, i.e. after the end of the statewide mask mandate. (ii) The ratio of cases prior to the end of the statewide mandate, i.e. December 2020 to February 2022, to cases after the end of the mandate. 

Code(s) required:
Graph_pre_post_by_group.do (provided): Creates a graph, stratified by the four groups of districts by mask policy, with the following information: a scatter plot, and the associated fitted regression line, of the log of each of the two variables in the dataset as described above. The graph is saved in regs_by_group.png, which is Figure 6 in the paper.

Table 1. Case rate changes from pre- to post-March 3rd 2023 by multiple baseline time periods.
Dataset(s) required:
“student_weekly_cases_percapy_bygroup.csv” (provided). This data was pulled from the dataset of school districts (pre_post_data.csv which is provided) with the constructed variable of average weekly cases per capita in different time periods before intervention removal and then the 6 weeks and 12 weeks after interventional removal. 3 different pre-mandate removal weekly averages were calculated according to 3 different start dates to mandate removal intervals: September 16th to mandate removal, December 2nd to mandate removal, and January 27th to mandate removal.

Code(s) required: None outside of formulas in the spreadsheet cells

Table 2: DiD analysis between different “treatment” groups by testing population
Dataset(s) required:
MA_district_enrollment_bygrade.csv (provided): Number of students enrolled, by grade, in each of 398 MA school districts.
Staff_by_district.csv (provided): Number of full-time equivalent staff members for each of 398 MA school districts.
Nejm_covid_reports.csv (provided): Weekly positive Covid-19 cases, separately for students and staff, for 398 MA school districts.
nejm_unmasking_dates.csv (provided): List of 72 districts studied by Cowger et al, with dates on which mask mandates ended.

Code(s) required:
Diff_in_diff.do: Merges in all the demographic data, enrollment and staffing data, and weekly case data in the datasets above, aggregates all data to the level of three groups: Boston and Chelsea (the treatment group), the other 70 districts studied by Cowger et al (Control group 1) and 217 remaining districts in MA (Control group 2). Calculates mean cases per capita for each group, before and after the end of the statewide mask mandate (March 3, 2022). The results need to be manipulated in a spreadsheet program to calculate the differences in differences shown in Table 2.

An alternative method shown in the same file is to estimate linear regressions of per-capita cases on (i) an indicator for being in the treatment group (ii) an indicator for being in the post-mandate period and (iii) the interaction of the first two terms. The coefficient on the interaction produces exactly the same estimate as the difference-in-differences calculated manually, with the added advantage that p-values and confidence intervals can be taken directly from the regression output rather than having to be calculated.

Figure 5. Cumulative cases per capita by county
Dataset(s) required:
CDC restricted data on daily reported infections by age group for all U.S. counties. The data are restricted and may not be publicly posted.

Code(s) required:
cdc_data.do (provided), which saves cdc_3masscounties.csv

cumulative_graph_3MA_counties.R (provided): Reads in cdc_3masscounties.csv and produces a graph (plot_cumulative_3MA_counties.png) showing cumulative infections per capita for three MA counties (Suffolk, Norfolk and Middlesex), which is Figure 5 in the paper.


