*Code to read in the CDC restricted case data for Mass, using the Dec 1 2022 release
*Written by AC, Jan 10, 2023

import delimited using ./data/cdc_data_dec1_2022.csv, varnames(1) clear
drop v1
collapse(sum) cases, by(county date kids)
gen date2=date(date,"YMD")
drop date
rename date2 date

sort county date kids
reshape wide cases, i(county date) j(kids)
rename cases0 adults
rename cases1 kids
*Code cases as zero if missing since a county only shows up if there are positive cases
replace adults=0 if adults==.
replace kids=0 if kids==.
sort county date

rename county fips
merge m:1 fips using ./data/MA_county_fips_codes
drop _m //all matched

replace county = subinstr(county, " ", "", .)
sort county
merge m:1 county using ./data/MA_county_pop
drop _m //all matched

gen total=adults+kids
gen cases_percap=total/pop*100000

bysort fips (date county pop): gen cumul_cases=sum(total)
gen frac=cumul_cases/pop

keep  frac county date
reshape wide frac, i(date) j(county) string

keep date fracSUFFOLK fracNORFOLK fracMIDDLESEX
gen year=year(date)
gen month=month(date)
gen day=day(date)
sort date
export delimited using ./data/cdc_3masscounties.csv, replace

