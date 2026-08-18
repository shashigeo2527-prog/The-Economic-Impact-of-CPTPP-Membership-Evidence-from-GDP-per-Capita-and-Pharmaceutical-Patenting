# =========================================================
# VERY BASIC R CODE: CPTPP (treatment) vs non-CPTPP (control)
# =========================================================

# 1. Load packages -----------------------------------------------------
# install.packages(c("plm", "ggplot2"))   # run once if not installed
library(plm)      # for panel / diff-in-diff regression
library(ggplot2)  # for simple plots

# 2. Load data -----------------------------------------------------------
df <- read.csv("cptpp_panel_full.csv")

# Quick look
str(df)
summary(df)

# 3. Define treatment / control ------------------------------------------
# cptpp_member: 1 = treatment (CPTPP country), 0 = control (non-CPTPP)
#
# IMPORTANT FIX:
# The original "post_treatment" column is only ever 1 for CPTPP countries
# (based on each country's own ratification year). That means control
# countries NEVER have a "post" period, so DiD can't be estimated properly
# (R drops the interaction term due to collinearity/singularity).
#
# A real DiD needs ONE shared cutoff year applied to BOTH treated and
# control countries. CPTPP entered into force Dec 30, 2018, so we use
# 2019 as the first "post" year for everyone.
POST_CUTOFF <- 2019
df$post <- ifelse(df$year >= POST_CUTOFF, 1, 0)

table(df$cptpp_member)
table(df$post)
table(df$cptpp_member, df$post)   # should now have all 4 cells filled

# 4. Simple group comparison (mean outcome by group) ----------------------
aggregate(ln_gdp_per_capita ~ cptpp_member, data = df, mean, na.rm = TRUE)

# 5. Basic Difference-in-Differences regression ----------------------------
# outcome = ln_gdp_per_capita (swap in any outcome you like, e.g. ln_patent_apps_total)
# Use the new shared "post" variable (NOT the old post_treatment column)
did_model <- lm(ln_gdp_per_capita ~ cptpp_member * post, data = df)
summary(did_model)
# The coefficient on "cptpp_member:post" is now the actual DiD estimate.

# 6. DiD with panel fixed effects (country + year) -------------------------
did_fe <- plm(ln_gdp_per_capita ~ cptpp_member * post,
              data   = df,
              index  = c("iso3", "year"),
              model  = "within",
              effect = "twoways")
summary(did_fe)
# Note: with twoway fixed effects, "cptpp_member" (time-invariant) and
# "post" (country-invariant) get absorbed by the fixed effects, so only
# the interaction term "cptpp_member:post" survives - that IS your DiD estimate.

# 8. Callaway-Sant'Anna staggered-adoption DiD -----------------------------
# Why: our simple 2019-cutoff DiD forces every treated country into the
# same treatment year, which is wrong (CPTPP countries ratified in 2018,
# 2019, 2021, 2022, 2023 - staggered). The CS estimator:
#   - lets each country have its OWN treatment year (gname)
#   - never uses an "already-treated" country as a control for a
#     "not-yet-treated" comparison (avoids the bias that plagues
#     naive two-way fixed effects with staggered timing)
#   - never-treated countries (control) get gname = 0

# install.packages("did")   # run once if not installed
library(did)

# gname must be numeric, with 0 = never treated
df$gname <- ifelse(df$cptpp_member == 1, df$cptpp_ratification_year, 0)

# att_gt requires idname to be NUMERIC - convert country codes (iso3) to numbers
df$id_num <- as.numeric(as.factor(df$iso3))

cs_out <- att_gt(
  yname         = "ln_gdp_per_capita",  # outcome
  tname         = "year",               # time variable
  idname        = "id_num",             # unit (country) id - numeric version of iso3
  gname         = "gname",              # first treatment year (0 = never treated)
  data          = df,
  control_group = "notyettreated",      # use not-yet-treated countries as controls
  panel         = TRUE
)

summary(cs_out)          # group-time ATT(g,t) estimates

# 9. Aggregate the group-time estimates into single summary numbers --------
# a) Overall average treatment effect on the treated (single headline number)
cs_simple <- aggte(cs_out, type = "simple")
summary(cs_simple)

# b) Event-study style: effect by years since treatment (dynamic effects)
cs_dynamic <- aggte(cs_out, type = "dynamic")
summary(cs_dynamic)
ggdid(cs_dynamic) +
  labs(title = "Callaway-Sant'Anna Event-Study: Effect of CPTPP over Time")

# c) Calendar-time effects (effect by actual year, pooled across cohorts)
cs_calendar <- aggte(cs_out, type = "calendar")
summary(cs_calendar)

# 10. Same analysis, but for the PHARMA sector outcome ----------------------
# CPTPP includes IP provisions specifically relevant to pharma patenting,
# so this is a more targeted test than broad GDP per capita.
# Outcome: ln_wipo_pharma_grants (log of pharmaceutical patent grants)

cs_out_pharma <- att_gt(
  yname         = "ln_wipo_pharma_grants",
  tname         = "year",
  idname        = "id_num",
  gname         = "gname",
  data          = df,
  control_group = "notyettreated",
  panel         = TRUE
)

summary(cs_out_pharma)   # group-time ATT(g,t) - check pre-trends here too

cs_simple_pharma <- aggte(cs_out_pharma, type = "simple")
summary(cs_simple_pharma)     # headline ATT for pharma

cs_dynamic_pharma <- aggte(cs_out_pharma, type = "dynamic")
summary(cs_dynamic_pharma)    # event-study for pharma
ggdid(cs_dynamic_pharma) +
  labs(title = "Callaway-Sant'Anna Event-Study: Effect of CPTPP on Pharma Patent Grants")

# 11. Pharma effect BY COHORT (group) ---------------------------------------
# All 11 CPTPP members in this data were also original TPP signatories
# (2016) - CPTPP = TPP minus the US after US withdrawal in 2017. So there
# is no "TPP vs non-TPP" split within CPTPP members here; what DOES vary is
# WHEN each country ratified CPTPP (2018 / 2019 / 2021 / 2022 / 2023),
# despite all having signed the original TPP together. This shows the
# pharma-patent effect SEPARATELY for each ratification cohort.

cs_group_pharma <- aggte(cs_out_pharma, type = "group")
summary(cs_group_pharma)
ggdid(cs_group_pharma) +
  labs(title = "Pharma Patent Effect by CPTPP Ratification Cohort",
       subtitle = "All groups were original TPP (2016) signatories; cohorts differ by ratification year")

# 12. Robustness check: restrict control group to HIGH-PATENT countries only
# ----------------------------------------------------------------------
# Rationale: many non-CPTPP control countries have near-zero pharma patent
# activity (e.g. Philippines, Indonesia, Colombia) and are not plausible
# counterfactuals for CPTPP members' pharma sectors. Restricting controls
# to countries with meaningfully high, comparable baseline pharma patenting
# gives a more credible comparison group.

# Compute each control country's PRE-TREATMENT (pre-2018) average pharma
# patent grants, then keep only "high-patent" controls (above median).
pre_period <- subset(df, cptpp_member == 0 & year < 2018 &
                        !is.na(wipo_pharma_grants))
control_avg <- aggregate(wipo_pharma_grants ~ iso3, data = pre_period, mean)
control_avg               # inspect - look for a natural high/low split

high_patent_cutoff <- median(control_avg$wipo_pharma_grants)
high_patent_controls <- control_avg$iso3[control_avg$wipo_pharma_grants >= high_patent_cutoff]
high_patent_controls      # the countries kept as controls

# Build the restricted dataset: all CPTPP (treated) countries + only the
# high-patent control countries
df_highctrl <- subset(df, cptpp_member == 1 | iso3 %in% high_patent_controls)
df_highctrl$id_num <- as.numeric(as.factor(df_highctrl$iso3))  # re-index ids

table(df_highctrl$cptpp_member)   # check sample sizes after restricting

# Re-run Callaway-Sant'Anna on this restricted sample
cs_out_pharma_highctrl <- att_gt(
  yname         = "ln_wipo_pharma_grants",
  tname         = "year",
  idname        = "id_num",
  gname         = "gname",
  data          = df_highctrl,
  control_group = "notyettreated",
  panel         = TRUE
)

summary(cs_out_pharma_highctrl)          # group-time table - check pre-trends

cs_simple_pharma_highctrl <- aggte(cs_out_pharma_highctrl, type = "simple")
summary(cs_simple_pharma_highctrl)       # headline ATT, high-patent controls only

cs_dynamic_pharma_highctrl <- aggte(cs_out_pharma_highctrl, type = "dynamic")
summary(cs_dynamic_pharma_highctrl)      # event-study, high-patent controls only
ggdid(cs_dynamic_pharma_highctrl) +
  labs(title = "Pharma Patent Effect of CPTPP - Controls Restricted to High-Patent Countries")


# 7. Simple visualization: trend of treatment vs control over time ---------
avg_by_year <- aggregate(ln_gdp_per_capita ~ year + cptpp_member,
                          data = df, mean, na.rm = TRUE)
avg_by_year$group <- ifelse(avg_by_year$cptpp_member == 1,
                             "CPTPP (Treatment)", "Non-CPTPP (Control)")

ggplot(avg_by_year, aes(x = year, y = ln_gdp_per_capita,
                         color = group, group = group)) +
  geom_line(linewidth = 1) +
  geom_point() +
  geom_vline(xintercept = POST_CUTOFF, linetype = "dashed") +
  labs(title = "Treatment vs Control Trend Over Time",
       subtitle = "Dashed line = shared post-treatment cutoff (2019)",
       x = "Year", y = "ln(GDP per capita)", color = "Group") +
  theme_minimal()

# This plot is also your basic "parallel trends" check: before the dashed
# line, the treatment and control lines should move roughly in parallel.
# If they clearly diverge BEFORE 2019, the DiD assumption is questionable.
