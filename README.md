Code and Data Documentation for “Mask mandates and COVID-19: A Re-analysis of the Boston school mask study”

Ambarish Chandra, Tracy Beth Høeg, Shamez Ladhani, Vinay Prasad and Ram Duriseti.

This document provides detailed code and data, as well as step-by-step instructions, for replicating the following figures and tables in Chandra et al.

Figure 1: Map of School Districts in Massachusetts

Figure 2: Replication and Extension of Figure 1B from Cowger et al.

Figure 3. Cumulative community cases by district mask policy


Table 1. Case Rates and relative differences for treatment and various control groups

Note that some figures use the same datasets as those used for making prior figures  The document provides standalone instructions for reproducing each table and figure in the paper. This is done to facilitate replication of whichever table or figure researchers may be interested in, without needing to generate all results in the paper.

Notes on executing the codes:

Place “codes”, “data” and “figures” at the same level of folder hierarchy.

Execute all codes from the root folder.

Graphs will be saved to the “figures” subfolder, which the user needs to create.

The final figures and tables require additional editing that is not shown here. Table 1 in particular requires Excel formulas to create the change values but these should be easy to work out. 

Stata codes were created and tested using Stata Version 18.

R codes were created and tested using R Version 4.2.3


**Figure 1: Map of School Districts in Massachusetts**

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

map_5080.R: Reads in district_data_for_map2.csv and creates the required map, saving in "massmap5080.png"


**Figure 2: Replication and Extension of Figure 1B from Cowger et al**

Dataset(s) required:

nejm_unmasking_dates.csv: List of 72 districts studied by Cowger et al, with dates on which mask mandates ended.

MA_district_enrollment_bygrade.csv: Number of students enrolled, by grade, in each of 398 MA school districts.

Nejm_covid_reports.csv: Weekly positive Covid-19 cases, separately for students and staff, for 398 MA school districts.


Code(s) required:

Replicate_nejm.do: reads in district level data on Staff FTE and student enrollment, unmasking dates, weekly covid cases. Smooths out missing data for holiday weeks, constructs three-week moving averages, saves an intermediate dataset: data_for_graphs.dta

Make_nejm_graphs.do: starts with data_for_graphs.dta, makes a graph to replicate Figure 1B in Cowger et al, extended back to the start of the school year.(newfig1.png). 


**Figure 3. Cumulative community cases by district mask policy**

Dataset(s) required: 

weekly_city_town.csv: Weekly Covid-19 case reports for all MA cities and towns. 

nejm_districts.dta: List of 72 districts studied by Cowger et al, with dates on which mask mandates ended.

Code(s) required: 

new_cumul_cases.do: Stata code to read in community case data, assign cases to school districts based on district to town mapping and create a graph plotting cumulative infections per capita for each of the four groups of school districts, saving new_cumul.png which is Figure 3 in the paper.


**Table 1. Case rate changes from pre- to post-March 3rd 2023 by multiple baseline time periods.**

Dataset(s) required:

student_weekly_cases_percap_bygroup.csv. This data was pulled from the dataset of school districts (pre_post_data.csv) with the constructed variable of average weekly cases per capita in different time periods before intervention removal and then the 6 weeks and 12 weeks after interventional removal. 3 different pre-mandate removal weekly averages were calculated according to 3 different start dates to mandate removal intervals: September 16th to mandate removal, December 2nd to mandate removal, and January 27th to mandate removal.

Code(s) required: None outside of formulas in the spreadsheet cells

**Table 2: Characteristics of masking districts and various control groups which dropped mask mandates; Logit-Link Regression analysis.**

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
