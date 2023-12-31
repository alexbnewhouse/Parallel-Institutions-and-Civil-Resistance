library(tidyverse)
library(haven)
colonies <- read_csv("COLDAT_colonies.csv")
df <- haven::read_dta("NAVCO2-1_ForPublication.dta") 
gdp <- readxl::read_xlsx("mpd2020.xlsx", sheet = "Full data" )

gdp_wb <- read_csv("worldbank_gdp.csv") %>% 
  select(Year, PNG_2011, MDV_2011) %>% 
  pivot_longer(cols = c(PNG_2011, MDV_2011), names_to = "country", values_to = "gdppc") %>% 
  mutate(loc_cow = case_when(country == "PNG_2011" ~ 910,
                             country == "MDV_2011" ~ 781)) %>% 
  select(-country, year = Year)


df <- df %>% 
  mutate(across(starts_with("pi_"), ~ case_when(. >= 0 ~ .,
                                                . < 0 ~ NA)))
df <- df %>% 
  mutate(in_media = na_if(in_media, -99)) %>% 
  mutate(repression = na_if(repression, -99)) %>% 
  mutate(camp_support = na_if(camp_support, -99)) %>% 
  mutate(camp_size = na_if(camp_size, -99)) %>% 
  mutate(regime_support = na_if(regime_support, -99)) %>% 
  mutate(indiscrim = na_if(indiscrim, -99)) %>% 
  mutate(prim_meth = na_if(prim_meth, -99)) %>% 
  mutate(sec_defect = na_if(sec_defect, -99)) %>% 
  mutate(sdirect = na_if(sdirect, -99)) %>% 
  mutate(prim_meth = case_when(prim_meth == 0 ~ 1,
                               TRUE ~ 0))

df <- df %>% 
  mutate(loc_cow = case_when(location == "Palestine" ~ 666,
                             location == "Aruba" ~ 1000, 
                             location == "Western Sahara" ~ 600, 
                             TRUE ~ loc_cow)) 

gdp <- gdp %>%
  mutate(loc_cow = countrycode::countrycode(countrycode, origin = "iso3c", destination = "cown"))

gdp <- gdp %>% 
  mutate(loc_cow = case_when(countrycode == "CSK" ~ 315,
                             countrycode == "HKG" ~ 997,
                             countrycode == "PSE" ~ 666,
                             countrycode == "SRB" ~ 345,
                             countrycode == "SUN" ~ 365,
                             countrycode == "YUG" ~ 345,
                             TRUE ~ loc_cow))

gdp <- gdp %>% 
  select(loc_cow, year, gdppc)

gdp <- gdp %>% 
  group_by(loc_cow, year) %>% 
  summarize(gdppc = sum(gdppc))

df <- df %>% 
  left_join(gdp, by = c("loc_cow", "year"))



colonies %>% 
  pivot_longer(cols = ends_with("_max"), names_to = "colonizer", values_to = "start_year", names_repair = "unique") %>% 
  select(country, colonizer, start_year) %>% 
  arrange(country, colonizer) %>% 
  filter(!is.na(start_year)) -> colonies_long


colonies_long %>% 
  rename(year = start_year) %>%
  mutate(colonizer_name = str_extract(colonizer, "(?<=[a-z]{1,16}\\.).*(?=\\_max)")) %>%
  mutate(start_year = case_when(grepl("colstart", colonizer) ~ year)) %>% 
  mutate(end_year = case_when(grepl("colend", colonizer) ~ year)) %>% 
  group_by(country, colonizer_name) %>% 
  summarize(start_year = mean(start_year, na.rm = TRUE), end_year = mean(end_year, na.rm = TRUE)) -> colonies_long


colonies_long$year <- mapply(seq,colonies_long$start_year,colonies_long$end_year,SIMPLIFY=FALSE)

colonies_long %>% 
  unnest(year) %>% 
  select(-start_year, -end_year) %>% 
  mutate(colony = countrycode::countrycode(colonizer_name, origin = "country.name", destination = "cown")) -> colonies_long 

colonies_long <- colonies_long %>% 
  mutate(cown = countrycode::countrycode(country, origin = "country.name", destination = "cown")) 

df <- df %>% 
  left_join(colonies_long %>% select(-country, -colonizer_name), by = c("year" = "year", "loc_cow" = "cown"))

df <- df %>% 
  mutate(colony = case_when(is.na(colony) ~ 0,
                            TRUE ~ colony)) 


df <- df %>% mutate(cyearplus = cyear + 1)

df %>% 
  group_by(id) %>% 
  mutate(final_year = case_when(cyear == max(cyear) ~ 1,
                                TRUE ~ 0)) %>% 
  ungroup() -> df

df <- df %>% 
  group_by(id) %>% 
  mutate(years_active = row_number()) 

df <- df %>%
  mutate(years_plus = years_active + 1)

df <- df %>% 
  mutate(end_status = case_when(success == 1 ~ 2,
                                (success == 0 & final_year == 1) ~ 1,
                                TRUE ~ 0)) 


colony_boolean <- colonies_long %>% 
  distinct(cown) %>% 
  mutate(colony_bool = TRUE)

df <- df %>% 
  left_join(colony_boolean %>% select(cown, colony_bool), by = c("loc_cow" = "cown")) %>% 
  mutate(colony_bool = case_when(is.na(colony_bool) ~ FALSE,
                                 TRUE ~ colony_bool))

polity <- readxl::read_xls("p5v2018.xls")

polity <- polity %>% 
  mutate(polity = case_when(polity < -10 ~ NA,
                            TRUE ~ polity))

polity <- polity %>% 
  mutate(cown = countrycode::countrycode(country, origin = "country.name", destination = "cown")) %>%
  mutate(cown = case_when(grepl("serbia", country, ignore.case = TRUE) ~ 345,
                          TRUE ~ cown))



xrcomp <- polity %>% 
  select(country, year, xrcomp) %>% 
  mutate(cown = countrycode::countrycode(country, origin = "country.name", destination = "cown")) %>%
  mutate(cown = case_when(grepl("serbia", country, ignore.case = TRUE) ~ 345,
                          TRUE ~ cown)) %>% 
  select(cown, year, xrcomp)

df <- df %>% 
  left_join(xrcomp, by = c("loc_cow" = "cown", "year"="year"))

df <- df %>% distinct() 

df <- df %>% 
  mutate(colony = factor(colony, ordered = FALSE)) %>% 
  mutate(colony = relevel(colony, ref = "0"))

agg_df <- df %>% 
  group_by(id) %>% 
  summarise(end_status = max(end_status), loc_cow = max(loc_cow),  repression = mean(repression), length_camp = n(), success = max(success), regime_support = round(median(regime_support)), 
            camp_support = round(median(camp_support)), camp_size = round(median(camp_size)), pi_armed_wing = mean(pi_armed_wing), pi_police = mean(pi_police), pi_education = mean(pi_education), 
            pi_soc_welfare = mean(pi_soc_welfare), pi_trad_media = mean(pi_trad_media), pi_new_media = mean(pi_new_media), pi_courts = mean(pi_courts),
            colony = max(colony_bool), gdppc = mean(gdppc), prim_meth = mean(prim_meth), sec_defect = mean(sec_defect), xrcomp = mean(xrcomp), in_media = mean(in_media), indiscrim = mean(indiscrim), sdirect = mean(sdirect))


library(plm)
library(fixest)
agg_df <- agg_df %>%
  #drop_na() %>% 
  mutate(loc_cow = factor(loc_cow)) %>% 
  mutate(end_status = case_when(end_status == 2 ~ 1,
                                TRUE ~ 0))

model_int <- fixest::feols(length_camp ~ log(gdppc) + colony + prim_meth + sec_defect + repression + in_media + indiscrim + camp_support + camp_size + regime_support + sdirect + 
                             pi_education + pi_police + pi_soc_welfare + pi_trad_media + pi_new_media + pi_courts + sec_defect + 
                             prim_meth * pi_education + prim_meth * pi_soc_welfare +
                             prim_meth * pi_trad_media + prim_meth * pi_new_media + prim_meth * pi_courts + prim_meth * pi_police | loc_cow, data = agg_df)


summary(model_int)

model_random <- lm(length_camp ~ log(gdppc) + colony + prim_meth + sec_defect + repression + in_media + indiscrim + camp_support + camp_size + regime_support + sdirect + 
                     pi_education + pi_police + pi_soc_welfare + pi_trad_media + pi_new_media + pi_courts + sec_defect + 
                     prim_meth * pi_education + prim_meth * pi_soc_welfare +
                     prim_meth * pi_trad_media + prim_meth * pi_new_media + prim_meth * pi_courts + prim_meth * pi_police, data = agg_df)

model_int_1 <-  fixest::feols(length_camp ~ log(gdppc) + colony + prim_meth + sec_defect + repression + in_media + indiscrim + camp_support + camp_size + regime_support + sdirect + 
                                pi_education + pi_police + pi_soc_welfare + pi_trad_media + pi_new_media + pi_courts + sec_defect + 
                                prim_meth * pi_education + prim_meth * pi_soc_welfare | loc_cow, data = agg_df)

model_fe <-  fixest::feols(length_camp ~ log(gdppc) + colony + prim_meth + sec_defect + repression + in_media + indiscrim + camp_support + camp_size + regime_support + sdirect + 
                             pi_education + pi_police + pi_soc_welfare + pi_trad_media + pi_new_media + pi_courts + sec_defect | loc_cow, data = agg_df)


model_no_controls <- feols(length_camp ~ prim_meth +
                             pi_education + pi_police + pi_soc_welfare + pi_trad_media + pi_new_media + pi_courts +
                             prim_meth * pi_education + prim_meth * pi_soc_welfare +
                             prim_meth * pi_trad_media + prim_meth * pi_new_media + prim_meth * pi_courts + prim_meth * pi_police| loc_cow, data = agg_df, panel.id = ~id + loc_cow)



fixest::etable(model_fe, model_int_1, model_int, model_no_controls, tex = TRUE, headers = c("No Interactions", "Educ and Soc Wel Ints", "All Ints", "No Controls"), 
               dict = c("log(gdppc)" = "Log(GDP Per Capita)", prim_meth = "Violence of Campaign", sec_defect = "Security Force Defections", repression = "Repression",
                        in_media = "Media Coverage of Campaign", indiscrim = "Indiscriminate Violence by State", camp_support = "Campaign Support", cap_size = "Campaign Size", camp_support = "Support of Campaign by State", sdirect = "International Sanctions Against State",
                        pi_education = "Parallel Education", pi_police = "Parallel Police", pi_soc_welfare = "Parallel Social Welfare", pi_trad_media = "Parallel Traditional Media", pi_new_media = "Parallel New Media", pi_courts = "Parallel Courts",
                        "Violence * Education", "Violence * Social Welfare", "Violence * Traditional Media", "Violence * New Media", "Violence * Courts", "Violence * Police"))



model2 <- glm(end_status ~ length_camp + log(gdppc) + colony + prim_meth + sec_defect + repression + in_media + indiscrim + camp_support + camp_size + regime_support + sdirect + 
                pi_education + pi_police + pi_soc_welfare + pi_trad_media + pi_new_media + pi_courts + sec_defect + prim_meth * pi_education + prim_meth * pi_soc_welfare +
                prim_meth * pi_trad_media + prim_meth * pi_new_media + prim_meth * pi_courts + prim_meth * pi_police, data = agg_df, family = "binomial")

model_int <- feglm(success ~ log(gdppc) + colony + prim_meth + sec_defect + repression + in_media + indiscrim + camp_support + camp_size + regime_support + sdirect + 
                     pi_education + pi_police + pi_soc_welfare + pi_trad_media + pi_new_media + pi_courts + sec_defect + 
                     prim_meth * pi_education + prim_meth * pi_soc_welfare +
                     prim_meth * pi_trad_media + prim_meth * pi_new_media + prim_meth * pi_courts + prim_meth * pi_police | loc_cow, data = agg_df, family = "binomial")

model_random <- feglm(success ~ log(gdppc) + colony + prim_meth + sec_defect + repression + in_media + indiscrim + camp_support + camp_size + regime_support + sdirect + 
                        pi_education + pi_police + pi_soc_welfare + pi_trad_media + pi_new_media + pi_courts + sec_defect + 
                        prim_meth * pi_education + prim_meth * pi_soc_welfare +
                        prim_meth * pi_trad_media + prim_meth * pi_new_media + prim_meth * pi_courts + prim_meth * pi_police, data = agg_df, family = "binomial")

model_int_1 <-  feglm(success ~ log(gdppc) + colony + prim_meth + sec_defect + repression + in_media + indiscrim + camp_support + camp_size + regime_support + sdirect + 
                        pi_education + pi_police + pi_soc_welfare + pi_trad_media + pi_new_media + pi_courts + sec_defect + 
                        prim_meth * pi_education + prim_meth * pi_soc_welfare | loc_cow, data = agg_df, family = "binomial")

model_fe <-  feglm(success ~ log(gdppc) + colony + prim_meth + sec_defect + repression + in_media + indiscrim + camp_support + camp_size + regime_support + sdirect + 
                     pi_education + pi_police + pi_soc_welfare + pi_trad_media + pi_new_media + pi_courts + sec_defect | loc_cow, data = agg_df, family = "binomial")

model_no_controls <- feglm(success ~ prim_meth +
                             pi_education + pi_police + pi_soc_welfare + pi_trad_media + pi_new_media + pi_courts +
                             prim_meth * pi_education + prim_meth * pi_soc_welfare +
                             prim_meth * pi_trad_media + prim_meth * pi_new_media + prim_meth * pi_courts + prim_meth * pi_police| loc_cow, data = agg_df, panel.id = ~id + loc_cow, family = "binomial")


fixest::etable(model_fe, model_int_1, model_int, model_no_controls, tex = TRUE, headers = c("No Interactions", "Educ and Soc Wel Ints", "All Ints", "No Controls"), 
               dict = c("log(gdppc)" = "Log(GDP Per Capita)", prim_meth = "Violence of Campaign", sec_defect = "Security Force Defections", repression = "Repression",
                        in_media = "Media Coverage of Campaign", indiscrim = "Indiscriminate Violence by State", camp_support = "Campaign Support", camp_size = "Campaign Size", camp_support = "Campaign Support", sdirect = "International Sanctions Against State",
                        pi_education = "Parallel Education", pi_police = "Parallel Police", pi_soc_welfare = "Parallel Social Welfare", pi_trad_media = "Parallel Traditional Media", pi_new_media = "Parallel New Media", pi_courts = "Parallel Courts",
                        "Violence * Education", "Violence * Social Welfare", "Violence * Traditional Media", "Violence * New Media", "Violence * Courts", "Violence * Police"))





summary(model2)

pFtest(model1, model_random)

library(RColorBrewer)
nb.cols <- 25
mycolors <- colorRampPalette(brewer.pal(8, "Dark2"))(nb.cols)

broom::tidy(model2, conf.int = TRUE) %>% 
  mutate(term = case_when(term == "sec_defect" ~ "Security Force Defections",
                          term == "repression" ~ "Repression",
                          term == "regime_support" ~ "Regime Support for Campaign", 
                          term == "prim_meth" ~ "Violent Campaign",
                          term == "in_media" ~ "Media Coverage of Campaign",
                          term == "log(gdppc)" ~ "Log(GDP Per Capita)",
                          term == "indiscrim" ~ "Indiscriminate Violence Against Campaign",
                          term == "camp_support" ~ "Campaign Support",
                          term == "camp_size" ~ "Campaign Size",
                          term == "pi_education" ~ "Parallel Education",
                          term == "pi_police" ~ "Parallel Law Enforcement",
                          term == "pi_trad_media" ~ "Parallel Traditional Media",
                          term == "pi_new_media" ~ "Parallel New Media",
                          term == "pi_soc_welfare" ~ "Parallel Social Welfare",
                          term == "pi_courts" ~ "Parallel Judicial System",
                          term == "sdirect" ~ "Sanctions Against Regime",
                          term == "length_camp" ~ "Campaign Length",
                          term == "colony" ~ "Past Colonial History",
                          TRUE ~ term)) %>%
  ggplot(aes(estimate, term, xmin = conf.low, xmax = conf.high, height = 0, color = term, shape = p.value)) +
  geom_point() +
  geom_vline(xintercept = 0, lty = 4) +
  geom_errorbarh() +
  guides(color = "none") + 
  labs(x = "Effect on Log Odds of Success",
       y = "Independent Variable",
       title = "Coefficient Plot for Logistic Regression on Success of Campaign",
       shape = "P Value") + 
  theme_minimal() + 
  scale_color_manual(values=mycolors) + 
  scale_shape_binned(breaks = c(.001, .01, .05, .1, 1))


# model2 <- lm(length_camp~ repression + camp_support + regime_support + sec_defect + in_media + camp_size + 
#                pi_police + pi_educ + pi_socwel + pi_tradmedia + pi_newmedia + pi_dispute + pi_army + colony + log(gdppc) + prim_meth, agg_df)
# 

#summary(model2)

library(survival)

failures <- df %>% 
  filter(end_status == 1) %>%
  select(id)

df <- df %>% 
  mutate(across(starts_with("pi_"), ~ factor(.))) %>% 
  mutate(across(starts_with("pi_"), ~ relevel(., ref = '0')))

df <- df %>% 
  mutate(prim_meth =factor(prim_meth))

df <- df %>% 
  mutate(prim_meth = relevel(prim_meth, ref = '0'))

just_successes <- df %>% 
  filter(!id %in% failures$id)

just_failures <- df %>% 
  filter(id %in% failures$id)

model <- coxph(Surv(time = years_active, time2 = years_plus, event = success) ~ log(gdppc) + colony_bool + prim_meth + repression + in_media + indiscrim + camp_support + camp_size + regime_support + pi_armed_wing + pi_education + pi_police + pi_soc_welfare + pi_trad_media + pi_new_media + pi_courts + sec_defect + prim_meth * pi_trad_media + prim_meth * pi_new_media + prim_meth * pi_courts + prim_meth * pi_education + prim_meth * pi_police + prim_meth * pi_soc_welfare, data = just_successes, cluster = id)


model_ph <- coxph(Surv(time = years_active, time2 = years_plus, event = final_year) ~ log(gdppc) + colony_bool + prim_meth + repression + 
                         in_media + indiscrim + sdirect +
                         camp_support + camp_size + regime_support + pi_education + pi_police + pi_soc_welfare + 
                         pi_trad_media + pi_new_media + pi_courts + sec_defect, data = df, cluster = id)

model_ph_int_1 <- coxph(Surv(time = years_active, time2 = years_plus, event = final_year) ~ log(gdppc) + colony_bool + prim_meth + repression + 
                         in_media + indiscrim + sdirect +
                         camp_support + camp_size + regime_support + pi_education + pi_police + pi_soc_welfare + 
                         pi_trad_media + pi_new_media + pi_courts + sec_defect + 
                         prim_meth * pi_education + 
                         prim_meth * pi_soc_welfare, data = df, cluster = id)

model_ph_full <- coxph(Surv(time = years_active, time2 = years_plus, event = final_year) ~ log(gdppc) + colony_bool + prim_meth + repression + 
                  in_media + indiscrim + sdirect +
                  camp_support + camp_size + regime_support + pi_education + pi_police + pi_soc_welfare + 
                  pi_trad_media + pi_new_media + pi_courts + sec_defect + 
                  prim_meth * pi_trad_media + prim_meth * pi_new_media + 
                  prim_meth * pi_courts + prim_meth * pi_education + prim_meth * pi_police + 
                  prim_meth * pi_soc_welfare, data = df, cluster = id)

model_ph_no_controls <- coxph(Surv(time = years_active, time2 = years_plus, event = final_year) ~ prim_meth + pi_education + pi_police + pi_soc_welfare + 
                         pi_trad_media + pi_new_media + pi_courts + 
                         prim_meth * pi_trad_media + prim_meth * pi_new_media + 
                         prim_meth * pi_courts + prim_meth * pi_education + prim_meth * pi_police + 
                         prim_meth * pi_soc_welfare, data = df, cluster = id)

stargazer::stargazer(model_ph, model_ph_int_1, model_ph_full, model_ph_no_controls, covariate.labels = c("Log(GDP Per Capita", "Colonial History", "Campaign Violence", "Repression",
                                                                                                         "Media Coverage of Campaign", "Indiscriminate Violence by State", "International Sanctions Against Regime", "Campaign Support",
                                                                                                         "Campaign Size", "Reigme Support of Campaign", "Parallel Education", "Parallel Police", "Parallel Social Welfare",
                                                                                                         "Parallel Traditional Media", "Parallel New Media", "Parallel Courts", "Security Force Defections", "Violence $\\times$ Traditional Media", "Violence $\\times$ New Media", "Violence $\\times$ Courts", "Violence $\\times$ Education", 
                                                                                                         "Violence $\\times$ Police", "Violence $\\times$ Social Welfare"))

stargazer::stargazer(model, model2, title = "Preliminary Cox Proportional Hazard Models with NAVCO Variables", header = FALSE)


library(nnet)
df$end_status <- as.factor(df$end_status)
df$colony_bool <- as.factor(df$colony_bool)

mn_mod <-  multinom(end_status ~ log(gdppc) + colony_bool + years_active + prim_meth + repression + in_media + indiscrim + sdirect +
                      camp_support + camp_size + regime_support + pi_education + pi_police + pi_soc_welfare + pi_trad_media + pi_new_media + pi_courts + sec_defect, data = df, family = "multinomial")

mn_mod_int_1 <-  multinom(end_status ~ log(gdppc) + colony_bool + years_active + prim_meth + repression + in_media + indiscrim + sdirect +
                            camp_support + camp_size + regime_support + pi_education + pi_police + pi_soc_welfare + pi_trad_media + pi_new_media + pi_courts + sec_defect +
                            prim_meth * pi_education + prim_meth * pi_soc_welfare, data = df, family = "multinomial")

mn_mod_no_controls <-  multinom(end_status ~ prim_meth + pi_education + pi_police + pi_soc_welfare + pi_trad_media + pi_new_media + pi_courts +
                                  prim_meth * pi_trad_media + prim_meth * pi_new_media + prim_meth * pi_courts + prim_meth * pi_education + prim_meth * pi_police + prim_meth * pi_soc_welfare, data = df, family = "multinomial")

mn_mod_full <- multinom(end_status ~ log(gdppc) + colony_bool + years_active + prim_meth + repression + 
                          in_media + indiscrim + sdirect +
                          camp_support + camp_size + regime_support + pi_education + pi_police + pi_soc_welfare + 
                          pi_trad_media + pi_new_media + pi_courts + sec_defect + 
                          prim_meth * pi_trad_media + prim_meth * pi_new_media + 
                          prim_meth * pi_courts + prim_meth * pi_education + prim_meth * pi_police + 
                          prim_meth * pi_soc_welfare, data = df, family = "multinomial")

stargazer::stargazer(mn_mod, mn_mod_full, covariate.labels = c("Log(GDP Per Capita", "Colonial History", "Years Active", "Campaign Violence", "Repression",
                                                               "Media Coverage of Campaign", "Indiscriminate Violence by State", "International Sanctions Against Regime", "Campaign Support",
                                                               "Campaign Size", "Reigme Support of Campaign", "Parallel Education", "Parallel Police", "Parallel Social Welfare",
                                                               "Parallel Traditional Media", "Parallel New Media", "Parallel Courts", "Security Force Defections", "Violence $\\times$ Traditional Media", "Violence $\\times$ New Media", "Violence $\\times$ Courts", "Violence $\\times$ Education", 
                                                               "Violence $\\times$ Police", "Violence $\\times$ Social Welfare"))


stargazer::stargazer(mn_mod_int_1, mn_mod_no_controls, covariate.labels = c("Log(GDP Per Capita", "Colonial History", "Years Active", "Campaign Violence", "Repression",
                                                               "Media Coverage of Campaign", "Indiscriminate Violence by State", "International Sanctions Against Regime", "Campaign Support",
                                                               "Campaign Size", "Reigme Support of Campaign", "Parallel Education", "Parallel Police", "Parallel Social Welfare",
                                                               "Parallel Traditional Media", "Parallel New Media", "Parallel Courts", "Security Force Defections", "Violence $\\times$ Traditional Media", "Violence $\\times$ New Media", "Violence $\\times$ Courts", "Violence $\\times$ Education", 
                                                               "Violence $\\times$ Police", "Violence $\\times$ Social Welfare"))


broom::tidy(mn_mod, conf.int = TRUE) %>% 
  knitr::kable() %>% 
  kableExtra::kable_styling("basic", full_width = FALSE)

broom::tidy(mn_mod, conf.int = TRUE, exponentiate = TRUE) %>%
  filter(y.level == 2) %>%
  knitr::kable() %>%
  kableExtra::kable_styling("basic", full_width = FALSE)

library(sjPlot)
plot_model(mn_mod, dot.size = 2, grid = TRUE, show.values = FALSE, title = "Coefficient Plot")

stargazer::stargazer(mn_mod)

library(interactions)
library(ggstance)
tt <- broom::tidy(mn_mod_full,conf.int=TRUE)
tt <- tt %>% 
  filter(term!="(Intercept)")  %>% 
  filter(term!="prim_meth1:pi_police1")

tt %>% 
  #filter(!term %in% c("repression", "indiscrim", "sdirect", "camp_support", "years_active", "sec_defect", "regime_support", "in_media", "colony_boolTRUE", "log(gdppc)", "camp_size")) %>%  
  mutate(term = case_when(term == "prim_meth1" ~ "Violent Campaign",
                          term == "pi_education1" ~ "Parallel Education",
                          term == "pi_police1" ~ "Parallel Law Enforcement",
                          term == "pi_trad_media1" ~ "Parallel Traditional Media",
                          term == "pi_new_media1" ~ "Parallel New Media",
                          term == "pi_soc_welfare1" ~ "Parallel Social Welfare",
                          term == "pi_courts1" ~ "Parallel Judicial System",
                          term == "sdirect1" ~ "Sanctions Against Regime",
                          term == "prim_meth1:pi_trad_media1" ~ "Violent Campaign * Traditional Media",
                          term == "prim_meth1:pi_new_media1" ~ "Violent Campaign * New Media",
                          term == "prim_meth1:pi_courts1" ~ "Violent Campaign * Judicial System",
                          term == "prim_meth1:pi_education1" ~ "Violent Campaign * Education",
                          term == "prim_meth1:pi_soc_welfare1" ~ "Violent Campaign * Social Welfare",
                          term == "prim_meth1:pi_police1" ~ "Violent Campaign * Law Enforcement",
                          term == "log(gdppc)" ~ "Log(GDP Per Capita)",
                          term == "years_active" ~ "Years Active",
                          term == "in_media" ~ "Media Coverage",
                          term == "indiscrim" ~ "Indiscriminate Violence by State",
                          term == "sdirect" ~ "International Sanctions Against State",
                          term == "sec_defect" ~ "Security Force Defections",
                          term == "regime_support" ~ "Regime Support of Campaign",
                          term == "colony_boolTRUE" ~ "Colonial History",
                          term == "camp_support" ~ "Campaign Support",
                          term == "camp_size" ~ "Campaign Size",
                          term == "repression" ~ "Repression",
                          TRUE ~ term)) %>%
  mutate(y.level = case_when(y.level == 2 ~ "Success",
                             y.level == 1 ~ "Failure")) %>%
  ggplot(aes(estimate, term, xmin = conf.low, xmax = conf.high, height = 0, color = y.level, shape=p.value)) +
  ggstance::geom_pointrangeh(position=position_dodgev(height=0.75)) +
  geom_vline(xintercept = 0, lty = 4) +
  ggstance::geom_errorbarh(position=position_dodgev(height=0.75), height = .5) +
  labs(x = "Effect on Outcome Rate",
       y = "Independent Variable",
       title = "Coefficient Plot for Multinomial Logit/Competing Risks",
       shape = "P Value") + 
  facet_wrap(vars(y.level)) + 
  guides(color = "none") +
  scale_shape_binned(breaks = c(.001,.05,.1))


ggplot(tt, aes(x=estimate,y=term,colour=y.level))+
  geom_pointrangeh(aes(xmin=conf.low,
                       xmax=conf.high),
                   position=position_dodgev(height=0.75))



df %>% 
  mutate(cold_war = case_when(year <= 1991 ~ 1,
                              year > 1991 ~ 0)) %>%
  mutate(colony_bool = case_when(colony_bool == TRUE ~ 1,
                                 TRUE ~ 0)) %>% 
  mutate(failure = case_when(end_status == 1 ~ 1,
                             TRUE ~ 0)) %>%
  mutate(any_pi = case_when((pi_education == 1 |
                               pi_soc_welfare == 1 |
                               pi_trad_media == 1 |
                               pi_new_media == 1 |
                               pi_police == 1 |
                               pi_courts == 1 |
                               pi_armed_wing == 1 |
                               pi_pol_wing == 1 | 
                               pi_pol_party == 1) ~ 1,
                            TRUE ~ 0)) %>%
  select(id, years_active, years_plus, gdppc, colony_bool, prim_meth, sec_defect, 
         regime_support, repression, camp_support, camp_size, sdirect, indiscrim, 
         cold_war, pi_education, pi_soc_welfare, pi_trad_media, pi_new_media, pi_police, pi_armed_wing, pi_courts, pi_pol_party, any_pi, in_media, failure, success) %>% 
  write_csv("df_cleaned.csv")





library(lmtest)

dwtest(lm(success ~ log(gdppc) + colony + prim_meth + sec_defect + repression + in_media + indiscrim + camp_support + camp_size + regime_support + sdirect + 
            pi_education + pi_police + pi_soc_welfare + pi_trad_media + pi_new_media + pi_courts + sec_defect, data = df)) 


## Residuals

data.frame("No Interactions" = resid(model_fe)) %>% 
  rownames_to_column(var = "index") %>% 
  mutate("All Interactions" = resid(model_int)) %>%
  mutate("Education and Social Welfare Interactions" = resid(model_int_1)) %>%
  mutate(index = as.numeric(index)) %>% 
  rename("No Interactions" = `No.Interactions`) %>%
  pivot_longer(cols = c(`No Interactions`, `Education and Social Welfare Interactions`, `All Interactions`), names_to = "Model", values_to = "Residual") %>%
  ggplot() + 
  geom_point(aes(x = index, y = Residual, color = Model)) + 
  facet_wrap(~Model) +
  scale_x_continuous(breaks = seq(0, 200, 50)) +
  labs(
    x = "Observation Number",
    y = "Residual Value",
    title = "Residual Plots for Fixed-Effects Linear Regression"
  ) + 
  guides(color="none")


