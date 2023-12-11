import delimited "/Users/anewhouse@middlebury.edu/Library/CloudStorage/Dropbox/Data 1 Prospectus/df_cleaned.csv", numericcols (4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25) clear


set showbaselevels on
stset years_active, id(id) failure(success)
gen log_gdppc = log(gdppc)


stcrreg i.sec_defect log_gdppc repression i.sdirect i.cold_war i.any_pi camp_size camp_support regime_support i.prim_meth i.prim_meth##i.any_pi, compete(failure) noshow nolog

stcurve, cif at(prim_meth = (0,1) any_pi = (0,1)) legend(label(1 "Nonviolent, No Inst.") label(2 "Nonviolent, Inst.") label(3 "Violent, No Inst.") label(4 "Violent, Inst.") ring(0) bplacement(seast)) title("Competing Risks Regression," "Any Parallel Institutions") subtitle("Differences not significant")

//
// stcrreg i.sec_defect repression i.cold_war i.pi_courts i.pi_education i.pi_new_media i.pi_trad_media i.pi_police camp_size camp_support regime_support i.prim_meth i.prim_meth##i.pi_education, compete(failure) noshow nolog
//
// stcurve, cif at(prim_meth = (0,1) pi_education = (0,1)) legend(label(1 "Nonviolent, No Inst.") label(2 "Nonviolent, Inst.") label(3 "Violent, No Inst.") label(4 "Violent, Inst.") ring(0) bplacement(seast)) title("Competing Risks Regression," "Presence of Education Institutions") subtitle("Coefficients are significant for violent campaigns")
//
// stcrreg i.sec_defect repression i.cold_war i.pi_courts i.pi_education i.pi_new_media i.pi_trad_media i.pi_police camp_size camp_support regime_support i.prim_meth i.prim_meth##i.pi_soc_welfare, compete(failure) noshow nolog
//
// stcurve, cif at(prim_meth = (0,1) pi_soc_welfare = (0,1)) legend(label(1 "Nonviolent, No Inst.") label(2 "Nonviolent, Inst.") label(3 "Violent, No Inst.") label(4 "Violent, Inst.") ring(0) bplacement(seast)) subtitle("Coefficients are significant for violent campaigns")
//
//
// // 
// stcrreg i.sec_defect repression i.cold_war i.pi_courts i.pi_education i.pi_new_media i.pi_trad_media i.pi_police camp_size camp_support regime_support i.prim_meth i.prim_meth##i.pi_courts, compete(failure) noshow nolog
//
// stcurve, cif at(prim_meth = (0,1) pi_courts = (0,1)) legend(label(1 "Nonviolent, No Courts") label(2 "Nonviolent, Courts") label(3 "Violent, No Courts") label(4 "Violent, Courts") ring(0) bplacement(neast))
//

//
// stcrreg i.sec_defect repression i.cold_war i.pi_courts i.pi_education i.pi_new_media i.pi_trad_media i.pi_police camp_size camp_support regime_support i.prim_meth i.prim_meth##i.pi_trad_media, compete(failure) noshow nolog
//
// stcurve, cif at(prim_meth = (0,1) pi_trad_media = (0,1)) legend(label(1 "Nonviolent, No Traditional Media") label(2 "Nonviolent, Traditional Media") label(3 "Violent, No Traditional Media") label(4 "Violent, Traditional Media") ring(0) bplacement(neast))
//
//
//
// stcrreg i.sec_defect repression i.cold_war i.pi_courts i.pi_education i.pi_new_media i.pi_trad_media i.pi_police camp_size camp_support regime_support i.prim_meth i.prim_meth##i.pi_new_media, compete(failure) noshow nolog
//
// stcurve, cif at(prim_meth = (0,1) pi_new_media = (0,1)) legend(label(1 "Nonviolent, No New Media") label(2 "Nonviolent, New Media") label(3 "Violent, No New Media") label(4 "Violent, New Media") ring(0) bplacement(neast))



//
// stcrreg log_gdppc i.colony_bool i.sec_defect repression i.sdirect i.cold_war i.prim_meth i.pi_education i.prim_meth##i.pi_education, compete(failure) noshow nolog
//
// estimates store m1
// outreg2 using results, replace ctitle(Model 1) stats(coef se) bdec(2) e(N_sub N_fail N_clust chi2 ll)label paren title("Social Welfare")
//
// stcrreg log_gdppc i.colony_bool i.sec_defect repression i.sdirect i.cold_war i.prim_meth i.pi_soc_welfare i.prim_meth##i.pi_soc_welfare, compete(failure) noshow nolog
//
// estimates store m2
//
// outreg2 using results, tex append ctitle(Model 2) stats(coef se) bdec(2) e(N_sub N_fail N_clust chi2 ll)label paren title("Social Welfare")


// stcrreg log_gdppc i.colony_bool i.sec_defect repression i.sdirect i.cold_war i.pi_courts i.pi_education i.pi_new_media i.pi_trad_media i.pi_police camp_size camp_support regime_support i.indiscrim, compete(failure) noshow nolog
//
// estimates store m1
//
// stcrreg i.colony_bool i.sec_defect repression i.cold_war i.pi_courts i.pi_education i.pi_new_media i.pi_trad_media i.pi_police i.pi_pol_party i.pi_armed_wing camp_size camp_support regime_support i.prim_meth i.prim_meth##i.pi_education i.prim_meth##i.pi_new_media i.prim_meth##i.pi_trad_media i.prim_meth##i.pi_soc_welfare i.prim_meth##i.pi_police i.prim_meth##i.pi_pol_party, compete(failure) noshow nolog
// //
// estimates store m2
//
//
// outreg2 using results, tex replace stats(coef se) bdec(2) e(N_sub N_fail N_clust chi2 ll)label paren title("Base Case")

