Code and Data Documentation for “Mask mandates and COVID-19: A Re-analysis of the Boston school mask study”

Ambarish Chandra, Tracy Beth Høeg, Shamez Ladhani, Vinay Prasad and Ram Duriseti.

This document provides detailed code and data, as well as step-by-step instructions, for replicating the following figures and tables in Chandra et al.

Figure 1: Map of School Districts in Massachusetts

Figure 2: Demographic Data on NEJM school Districts

Figure 3a and b. Replication and Extension of Figure 1B from Cowger et al.

Figure 4: Student case rates reported by districts, aggregated by Massachusetts counties.

Figure 5. Cumulative community cases by district mask policy

Figure 6: Analysis of the relationship between community case rates from 12/1/2020 through 2/27/2022 and case rates post 2/27/2022 through 6/22/2022.

Table 1. Case rate changes from pre- to post-March 3rd 2023 by multiple baseline time periods.

Table 2: DiD analysis between different “treatment” groups by testing population

Note that some figures use the same datasets as those used for making prior figures (e.g. Figure 4 reuses the same datasets that were needed to produce Figure 3). The document provides standalone instructions for reproducing each table and figure in the paper. This is done to facilitate replication of whichever table or figure researchers may be interested in, without needing to generate all results in the paper.

Notes on executing the codes:

Place “codes”, “data” and “figures” at the same level of folder hierarchy.

Execute all codes from the root folder.

Graphs will be saved to the “figures” subfolder, which the user needs to create.

The final tables require additional formatting that is not shown here.

Stata codes were created and tested using Stata Version 18.

R codes were created and tested using R Version 4.2.3


Figure 1: Map of School Districts in Massachusetts

Dataset(s) required:

nces_ma_district_bos_distances_A.csv: Dataset on MA school districts with distance from Boston obtained from: from https://nces.ed.gov/ccd/districtsearch/

enrollmentbyracegender.csv: Race and Gender data for 398 MA school districts.

district_medinc.csv: Median Income for 296 MA school districts.

fulldat.dta: List of MA school districts that satisfies Cowger et al criteria of having 10 or fewer weeks with zero reported cases. 

nejm_unmasking_dates.csv: List of 72 districts studied by Cowger et al, with dates on which mask mandates ended.

MA_district_enrollment_bygrade.csv: Number of students enrolled, by grade, in each of 398 MA school districts.

SCHOOLDISTRICTS_POLY.shp and related files: polygon shapefiles of MA school districts.

Code(s) required:

massmap.do: saves district_data_for_map2.csv, which is an intermediate file to be read in by R.

map_50.R: Reads in district_data_for_map2.csv and creates the required map, saving in "massmap50b.png"


Figure 2: Demographic Data on NEJM school Districts

Dataset(s) required:

nces_ma_district_bos_distances_A.csv: Dataset on MA school districts with distance from Boston obtained from: from https://nces.ed.gov/ccd/districtsearch/

enrollmentbyracegender.csv: Race and Gender data for 398 MA school districts.

district_medinc.csv: Median Income for 296 MA school districts.

nejm_unmasking_dates.csv: List of 72 districts studied by Cowger et al, with dates on which mask mandates ended.


Code(s) required:

graph_race_income.do: Read in raw data, creates and saves a graph (medinc_race.png) showing median income and fraction white for all districts, which is Figure 2 in the paper.


Figure 3a and 3b: Replication and Extension of Figure 1B from Cowger et al

Dataset(s) required:

nejm_unmasking_dates.csv: List of 72 districts studied by Cowger et al, with dates on which mask mandates ended.

MA_district_enrollment_bygrade.csv: Number of students enrolled, by grade, in each of 398 MA school districts.

Nejm_covid_reports.csv: Weekly positive Covid-19 cases, separately for students and staff, for 398 MA school districts.


Code(s) required:

Replicate_nejm.do: reads in district level data on Staff FTE and student enrollment, unmasking dates, weekly covid cases. Smooths out missing data for holiday weeks, constructs three-week moving averages, saves an intermediate dataset: data_for_graphs.dta

Make_nejm_graphs.do: starts with data_for_graphs.dta, makes graphs to replicate Figure in Cowger et al, for Figure 3a in the paper (students1.png). Also extends back to the start of the school year for Figure 3b (students2.png).

Figure 4: Student case rates reported by districts, aggregated by Massachusetts counties.

Dataset(s) required:

MA_district_enrollment_bygrade.csv: Number of students enrolled, by grade, in each of 398 MA school districts.

Nejm_covid_reports.csv: Weekly positive Covid-19 cases, separately for students and staff, for 398 MA school districts.

Code(s) required:

Extend_nejm.do: Aggregates weekly district-level covid-19 case rates to the county level, for each of MA’s 14 counties, and then produces a graph (counties3.png) which is Figure 4 in the paper.

Figure 5. Cumulative community cases by district mask policy

Dataset(s) required: 

weekly_city_town.csv: Weekly Covid-19 case reports for all MA cities and towns. 

nejm_unmasking_dates.csv: List of 72 districts studied by Cowger et al, with dates on which mask mandates ended.

Code(s) required: 

Make_4group_data.do: Reads in community case data, assigns cases to school districts based on district to town mapping, saves an intermediate dataset (4group_data.csv) containing weekly cumulative cases per capita for each of the four groups of school districts studied by Cowger et al. 

Cumulative_graph_4district_groups.R: R code to read in the intermediate dataset (4group_data.csv) described above and create a graph plotting cumulative infections per capita for each of the four groups of school districts, saving plot_cumulative_4group.pdf which is Figure 5 in the paper.

Figure 6: Analysis of the relationship between community case rates from 12/1/2020 through 2/27/2022 and case rates post 2/27/2022 through 6/22/2022.

Dataset(s) required:

pre_post_data.csv: Dataset of school districts with two constructed variables: (i) Total cases per capita reported by each school district in the period March–June 2022, i.e. after the end of the statewide mask mandate. (ii) The ratio of cases prior to the end of the statewide mandate, i.e. December 2020 to February 2022, to cases after the end of the mandate.

Code(s) required:

Graph_pre_post_by_group.do: Creates a graph, stratified by the four groups of districts by mask policy, with the following information: a scatter plot, and the associated fitted regression line, of the log of each of the two variables in the dataset as described above. The graph is saved in regs_by_group.png, which is Figure 6 in the paper.

Table 1. Case rate changes from pre- to post-March 3rd 2023 by multiple baseline time periods.

Dataset(s) required:

student_weekly_cases_percap_bygroup.csv. This data was pulled from the dataset of school districts (pre_post_data.csv) with the constructed variable of average weekly cases per capita in different time periods before intervention removal and then the 6 weeks and 12 weeks after interventional removal. 3 different pre-mandate removal weekly averages were calculated according to 3 different start dates to mandate removal intervals: September 16th to mandate removal, December 2nd to mandate removal, and January 27th to mandate removal.

Code(s) required: None outside of formulas in the spreadsheet cells

Table 2: Characteristics of masking districts and various control groups which dropped mask mandates; Logit-Link Regression analysis.

Dataset(s) required:

Staff_by_district.csv: Number of full-time equivalent staff members for each of 398 MA school districts.

Nejm_covid_reports.csv: Weekly positive Covid-19 cases, separately for students and staff, for 398 MA school districts.

nces_ma_district_bos_distances_A.csv: Dataset on MA school districts with distance from Boston obtained from: from https://nces.ed.gov/ccd/districtsearch/

enrollmentbyracegender.csv: Race and Gender data for 398 MA school districts.

district_medinc.csv: Median Income for 296 MA school districts.

nejm_unmasking_dates.csv: List of 72 districts studied by Cowger et al, with dates on which mask mandates ended.

MA_district_enrollment_bygrade.csv: Number of students enrolled, by grade, in each of 398 MA school districts.

SCHOOLDISTRICTS_POLY.shp: polygon shapefile of MA school districts.

Code(s) required:

massmap.do: From Figure 1, this creates an intermediate dataset, distance_demgraphics.dta that is required by the next code.

summary and logit table.do: Merges in all the demographic data, enrollment and staffing data, and weekly case data in the datasets above. Creates various subgroups corresponding to the control groups used in the paper. Then creates data used in the upper panel of Table 2 (demographics and distance). Also estimates logit link regressions for the lower panel of Table 2.
