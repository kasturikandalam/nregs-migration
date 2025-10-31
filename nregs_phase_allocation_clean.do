/*******************************************************************************
Title: NREGS Phase Allocation and Backwardness Ranking Analysis
Author: Kasturi Kandalam
Created: 08/09/2023
Last Updated: 29/11/2023

Description: 
This script analyzes the relationship between district-level backwardness rankings
and NREGS phase allocation in India. It merges data on backwardness indicators
(3-parameter and 5-parameter indices) with actual phase-wise NREGS allocation
to assess how well the backwardness ranking predicted program rollout.
*******************************************************************************/

clear all
set more off

if (c(username) == "kastu") {
    global main "D:\ma_gdrive\ma_thesis\thesis_datawork"
    global dofolder "$main\do"
    global projectdata "$main\nss64_mergeddata"
    global logfile "$main\log_files"
    global texoutputs "$main\texoutputs"
    global task_force "$main\task_force_data"
}

********************************************************************************
* PART 1: IMPORT AND CLEAN BACKWARDNESS RANK DATA
********************************************************************************

* Import 5-parameter backwardness index
import excel "${task_force}\5index.xlsx", sheet("Sheet3") firstrow clear

* Standardize state and district names (uppercase)
replace District = upper(District)
rename District district
replace State = upper(State)
rename State state

* Merge with 3-parameter index
merge 1:1 state district using "${task_force}\3_index.dta"
assert _merge == 3  // All should match
drop _merge

********************************************************************************
* PART 2: RENAME VARIABLES FOR CLARITY
********************************************************************************

* 5-parameter index variables
rename p_TotalSCage1991Census fivep_scst_pop
rename p_TotalSCage1991Census_I fivep_scst_pop_index
rename p_AgriWagesRsday199619 fivep_agriwagesperday
rename p_AgriWagesRsday19961 fivep_agriwagesperday_index
rename p_OutputAgriWorker19901993 fivep_outputperagriworker
rename I fivep_outputperagriworker_index
rename p_OutputNASRsHa19901 fivep_outputperhectare
rename K fivep_outputperhectare_index
rename p_PovertyRatioinage19931 fivep_povrate
rename M fivep_povrate_index
rename p_CompositeindexCol5811 fivep_compositeindex
rename p_ActualRank fivepara_rank

* 3-parameter index variables
rename p_TotalSCSTPopinage199 threep_scst_pop
rename E threep_scst_pop_index
rename p_AgriWagesRsday199697 threep_agriwagesperday
rename G threep_agriwagesperday_index
rename p_OutputAgriWorkerRsAgW threep_outputperagriwork
rename I_01 threep_outputperagriworkindex
rename p_CompIndexCol5811 threep_compositeindex
rename three_iactualrank threepara_rank

destring threep_compositeindex, replace

save "${task_force}\3p_5pindex.dta", replace

********************************************************************************
* PART 3: MERGE WITH PHASE-WISE NREGS ALLOCATION
********************************************************************************

use "${task_force}\3p_5pindex.dta", clear

merge 1:1 state district using "${main}\nrega_phases_data\mnrega_dist_phases.dta"

* Drop small states/UTs not in main analysis
drop if inlist(state, "MIZORAM", "ARUNACHAL PRADESH", "JAMMU AND KASHMIR", ///
    "UTTRANCHAL", "GOA", "A&N ISLAND", "TRIPURA", "SIKKIM", "MEGHALAYA", ///
    "MANIPUR", "NAGALAND", "HIMACHAL PRADESH", "D&N HAVELI", "DAMAN & DIU")

tab _merge
drop if _merge == 2
drop _merge

save "${main}\3p5p_phases.dta", replace

********************************************************************************
* PART 4: CREATE STATE IDENTIFIERS
********************************************************************************

use "${main}\3p5p_phases.dta", clear

rename state state_str
gen state = .

* Encode states
replace state = 1 if state_str == "JAMMU AND KASHMIR"
replace state = 2 if state_str == "HIMACHAL PRADESH"
replace state = 3 if state_str == "PUNJAB"
replace state = 4 if state_str == "CHANDIGARH"
replace state = 5 if state_str == "UTTRANCHAL"
replace state = 6 if state_str == "HARYANA"
replace state = 7 if state_str == "Delhi"
replace state = 8 if state_str == "RAJASTHAN"
replace state = 9 if state_str == "UTTAR PRADESH"
replace state = 10 if state_str == "BIHAR"
replace state = 11 if state_str == "SIKKIM"
replace state = 12 if state_str == "ARUNACHAL PRADESH"
replace state = 13 if state_str == "NAGALAND"
replace state = 14 if state_str == "MANIPUR"
replace state = 15 if state_str == "MIZORAM"
replace state = 16 if state_str == "TRIPURA"
replace state = 17 if state_str == "MEGHALAYA"
replace state = 18 if state_str == "ASSAM"
replace state = 19 if state_str == "WEST BENGAL"
replace state = 20 if state_str == "JHARKHAND"
replace state = 21 if state_str == "ORISSA"
replace state = 22 if state_str == "CHATTISGARH"
replace state = 23 if state_str == "MADHYA PRADESH"
replace state = 24 if state_str == "GUJARAT"
replace state = 25 if state_str == "DAMAN & DIU"
replace state = 26 if state_str == "D&N HAVELI"
replace state = 27 if state_str == "MAHARASHTRA"
replace state = 28 if state_str == "ANDHRA PRADESH"
replace state = 29 if state_str == "KARNATAKA"
replace state = 30 if state_str == "GOA"
replace state = 31 if state_str == "LAKSHADWEEP"
replace state = 32 if state_str == "KERALA"
replace state = 33 if state_str == "TAMIL NADU"
replace state = 34 if state_str == "PUDUCHERRY"
replace state = 35 if state_str == "A&N ISLAND"

label define state ///
    1  "Jammu & Kashmir" ///
    2  "Himachal Pradesh" ///
    3  "Punjab" ///
    4  "Chandigarh" ///
    5  "Uttarakhand" ///
    6  "Haryana" ///
    7  "Delhi" ///
    8  "Rajasthan" ///
    9  "Uttar Pradesh" ///
    10 "Bihar" ///
    11 "Sikkim" ///
    12 "Arunachal Pradesh" ///
    13 "Nagaland" ///
    14 "Manipur" ///
    15 "Mizoram" ///
    16 "Tripura" ///
    17 "Meghalaya" ///
    18 "Assam" ///
    19 "West Bengal" ///
    20 "Jharkhand" ///
    21 "Orissa" ///
    22 "Chattisgarh" ///
    23 "Madhya Pradesh" ///
    24 "Gujarat" ///
    25 "Daman & Diu" ///
    26 "Dadra & Nagar Haveli" ///
    27 "Maharashtra" ///
    28 "Andhra Pradesh" ///
    29 "Karnataka" ///
    30 "Goa" ///
    31 "Lakshadweep" ///
    32 "Kerala" ///
    33 "Tamil Nadu" ///
    34 "Pondicherry" ///
    35 "A & N Islands"
    
label values state state

********************************************************************************
* PART 5: PREDICT PHASE ALLOCATION BASED ON BACKWARDNESS RANK
********************************************************************************

sort state district

* Count districts in each phase by state
by state: egen nodistsphase1 = sum(phase <= 1)
by state: egen nodistsphase1_2 = sum(phase <= 2)

* Rank districts within state by backwardness
by state: egen backwardrankwithinstate = rank(threepara_rank)

sort backwardrankwithinstate

* Predict Phase 1 allocation
gen predictedphase_1 = .
replace predictedphase_1 = 1 if backwardrankwithinstate <= nodistsphase1

* Check prediction success for Phase 1
gen success_rate_phase1 = .
replace success_rate_phase1 = 1 if predictedphase_1 == phase

* Predict Phase 2 allocation
gen predictedphase_2 = .
replace predictedphase_2 = 2 if backwardrankwithinstate <= nodistsphase1_2

* Check prediction success for Phase 2
gen success_rate_phase2 = .
replace success_rate_phase2 = 2 if predictedphase_2 == phase

* Predict Phase 3 allocation (residual)
gen predictedphase_3 = .
replace predictedphase_3 = 3 if missing(predictedphase_1) & missing(predictedphase_2)

* Check prediction success for Phase 3
gen success_rate_phase3 = .
replace success_rate_phase3 = 3 if predictedphase_3 == phase

********************************************************************************
* PART 6: CREATE NORMALIZED RANKS FOR VISUALIZATION
********************************************************************************

* Note: Normalized ranks (norm_rank_p12, norm_rank_p23) created manually
* to account for state-specific cutoffs between phases

save "${task_force}\w_threshold_clean.dta", replace

********************************************************************************
* PART 7: VISUALIZATION
********************************************************************************

use "${task_force}\w_threshold_clean.dta", clear

* Set graph scheme
set scheme tab3

* Scatter plots: Phase vs. Normalized Rank (Phase 1-2 cutoff)
scatter phase norm_rank_p12, by(state) ///
    title("NREGS Phase Allocation by Backwardness Rank") ///
    subtitle("By State") ///
    xtitle("Normalized Backwardness Rank (Phase 1-2 Cutoff)") ///
    ytitle("Actual Phase")
    
graph export "${texoutputs}\phase_rank_bystate_p12.png", replace

scatter phase norm_rank_p12 ///
    title("NREGS Phase Allocation by Backwardness Rank") ///
    subtitle("All India") ///
    xtitle("Normalized Backwardness Rank (Phase 1-2 Cutoff)") ///
    ytitle("Actual Phase")
    
graph export "${texoutputs}\phase_rank_allindia_p12.png", replace

* Scatter plots: Phase vs. Normalized Rank (Phase 2-3 cutoff)
scatter phase norm_rank_p23, by(state) ///
    title("NREGS Phase Allocation by Backwardness Rank") ///
    subtitle("By State") ///
    xtitle("Normalized Backwardness Rank (Phase 2-3 Cutoff)") ///
    ytitle("Actual Phase")
    
graph export "${texoutputs}\phase_rank_bystate_p23.png", replace

scatter phase norm_rank_p23 ///
    title("NREGS Phase Allocation by Backwardness Rank") ///
    subtitle("All India") ///
    xtitle("Normalized Backwardness Rank (Phase 2-3 Cutoff)") ///
    ytitle("Actual Phase")
    
graph export "${texoutputs}\phase_rank_allindia_p23.png", replace
