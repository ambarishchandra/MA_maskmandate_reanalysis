Code and Data Documentation for “Mask mandates and COVID-19: A Re-analysis of the Boston school mask study”

Ambarish Chandra, Tracy Beth Høeg, Shamez Ladhani, Vinay Prasad and Ram Duriseti.

This document provides detailed code and data, as well as step-by-step instructions, for replicating the following figures and tables in Chandra et al.

Figure 1: Map of School Districts in Massachusetts

Figure 2: Replication and Extension of Figure 1B from Cowger et al.

Figure 3. Cumulative community cases by district mask policy

Table 1. Case Rates and relative differences for treatment and various control groups


Notes on executing the codes:

Place “codes”, “data” and “figures” at the same level of folder hierarchy.

Execute all codes from the root folder.

Graphs will be saved to the “figures” subfolder, which the user needs to create.

The final figures and tables require additional editing that is not shown here. Table 1 in particular requires Excel formulas to create the change values but these should be easy to work out. 

Stata codes were created and tested using Stata Version 18.

R codes were created and tested using R Version 4.2.3


**Included Datasets**

nces_ma_district_bos_distances_A.csv: Dataset on MA school districts with distance from Boston obtained from: from https://nces.ed.gov/ccd/districtsearch/

enrollmentbyracegender.csv: Race and Gender data for 398 MA school districts.

district_medinc.csv: Median Income for 296 MA school districts.

fulldat.dta: List of MA school districts that satisfies Cowger et al criteria of having 10 or fewer weeks with zero reported cases. 

nejm_unmasking_dates.csv: List of 72 districts studied by Cowger et al, with dates on which mask mandates ended.

MA_district_enrollment_bygrade.csv: Number of students enrolled, by grade, in each of 398 MA school districts.

SCHOOLDISTRICTS_POLY.shp and related files: polygon shapefiles of MA school districts, stored in a subfolder of the data folder: "shape files"

Nejm_covid_reports.csv: Weekly positive Covid-19 cases, separately for students and staff, for 398 MA school districts.

weekly_city_town.csv: Weekly Covid-19 case reports for all MA cities and towns. 

staff_by_district.csv: Number of staff FTE in each MA school district





**Figure 1: Map of School Districts in Massachusetts**

Codes required:

massmap.do: saves district_data_for_map2.csv, which is an intermediate file to be read in by R. Also saves distance_demographics.dta which is an intermediate Stata file, that is needed to make Table 1 (see below).

map_5080.R: Reads in district_data_for_map2.csv and creates the required map, saving in "massmap5080.png"


**Figure 2: Replication and Extension of Figure 1B from Cowger et al**

Codes required:

Replicate_nejm.do: reads in district level data on Staff FTE and student enrollment, unmasking dates, weekly covid cases. Smooths out missing data for holiday weeks, constructs three-week moving averages, saves an intermediate dataset: data_for_graphs.dta

Make_nejm_graphs.do: starts with data_for_graphs.dta, makes a graph to replicate Figure 1B in Cowger et al, extended back to the start of the school year.(newfig1.png). 


**Figure 3. Cumulative community cases by district mask policy**

Code required: 

new_cumul_cases.do: Stata code to read in community case data, assign cases to school districts based on district to town mapping and create a graph plotting cumulative infections per capita for each of the four groups of school districts, saving new_cumul.png which is Figure 3 in the paper.


**Table 1. Case Rates and relative differences for treatment and various control groups.**

Codes required:

make_weekly_district_case_dataset.do: Merges in all the demographic data, enrollment and staffing data, and weekly case data in the datasets above. Saves an intermediate dataset: district_weekly_cases_percap_staffstudents.dta.

massmap.do: Saves distance_demographics.dta which is an intermediate dataset.

DiD table july 2024.do: Reads in district_weekly_cases_percap_staffstudents.dta, merges with distance_demographics.dta, and saves an intermediate dataset (did_reg_data.dta). It then reads in this intermediate dataset, and creates the various treatment and control groups used in the paper. It then calculates the mean case rates for each of these groups before and after the end of the statewide mask mandate, which are the values shown in the left panel of Table 1 in the paper. Next, it estimates linear regressions of case rates on dummy variables for treatment, post-intervention and their interaction to get the DiD estimates with the corresponding standard errors and confidence intervals which are also shown in Table 1. Finally, it estimate poisson regressions to obtain the ratio of rate ratios (RRRs), and associated CIs, shown in the right columns of Table 1. 

Note: the full table requires additional manipulation in Excel or another application.

