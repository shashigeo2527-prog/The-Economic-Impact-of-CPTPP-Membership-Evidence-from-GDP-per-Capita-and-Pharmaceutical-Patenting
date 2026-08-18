# The Economic Impact of CPTPP Membership
### Evidence from GDP per Capita and Pharmaceutical Patenting

**Author:** Shashi Kulkarni
**Affiliation:** Gokhale Institute of Politics and Economics, Pune

---

## Overview

This project estimates the causal economic effect of CPTPP (Comprehensive and Progressive Agreement for Trans-Pacific Partnership) membership using a staggered-adoption Difference-in-Differences design. It examines two outcomes:

1. **GDP per capita** — a broad test of whether trade liberalisation translated into aggregate economic gains.
2. **Pharmaceutical patent grants** — a narrower, more targeted test, motivated by the fact that most of the 22 provisions suspended when TPP became CPTPP related to pharmaceutical IP protections (patent-term adjustment/restoration, undisclosed test data protection, expanded patentable subject matter).

## Research Questions

- Did CPTPP membership cause a change in GDP per capita among member countries?
- Did CPTPP membership cause a change in pharmaceutical patent grants, given the IP provisions dropped between TPP and CPTPP?

## Background

- TPP originated in 2005 with the "Pacific-4" (Brunei, Chile, New Zealand, Singapore) and grew to 12 countries by 2017.
- The US withdrew in January 2017; the remaining 11 members signed the renegotiated CPTPP in Santiago, Chile on 8 March 2018, dropping 22 of 600+ TPP provisions (mostly pharma-related IP rules).
- CPTPP entered into force in stages: 2018 (6 founding ratifiers), 2019 (Vietnam), 2021 (Peru), 2022 (Malaysia, Chile), 2023 (Brunei); the UK acceded in 2024.
- CPTPP represents ~13% of global GDP (>USD 10 trillion) and ~500 million consumers.

## Data

- **Panel structure:** Country-year panel, 2005–2024, 39 variables, 26 countries.
- **Treatment group (11):** Australia, Brunei, Canada, Chile, Japan, Malaysia, Mexico, New Zealand, Peru, Singapore, Vietnam.
- **Control group (15):** Italy, India, Spain, Poland, Brazil, Argentina, Thailand, Colombia, Indonesia, Philippines, Germany, South Korea, France, United Kingdom.
- **Sources:**
  - World Bank World Development Indicators (WDI) API — GDP per capita, population, merchandise trade share of GDP, FDI inflows, health expenditure per capita, R&D expenditure (% GDP), researchers per million, scientific journal articles, high-tech exports.
  - WIPO IP Statistics Data Center — pharmaceutical and biotechnology patent grants.
  - EPO Technology Dashboard 2025 — European patent applications by applicant origin.
  - World Bank IP indicators.

## Methodology

Standard two-period / two-way fixed-effects DiD is biased under **staggered treatment adoption** (members ratified in different years: 2018, 2019, 2021, 2022, 2023). This project instead uses the **Callaway & Sant'Anna (2021) estimator**, which:

- Assigns each treated country to a cohort based on its actual ratification year.
- Compares each cohort only against "not-yet-treated" countries at each time horizon.
- Produces group-time average treatment effects, `ATT(g,t)`, which are aggregated into:
  - An overall average treatment effect on the treated (ATT)
  - A dynamic event-study aggregation (effect by years since treatment)
  - A group/cohort-level aggregation

## Key Results

### GDP per capita
- Parallel trends hold overall, though the 2019 (Vietnam) cohort shows significant pre-trends and is excluded from clean interpretation.
- Post-treatment ATT(g,t) is statistically insignificant for every cohort.
- Simple aggregate ATT: **0.0273**; dynamic ATT: **0.0297** — both statistically indistinguishable from zero.
- **Conclusion: no statistically detectable effect of CPTPP on GDP per capita.**

### Pharmaceutical patent grants
- Overall aggregate ATT: **0.269** (SE 0.153, p = 0.079) — borderline significant at 10%, implying a ~30.9% increase (95% CI: −3.0% to +76.5%).
- Under a stricter, better-matched control group, the effect falls to a statistically insignificant ~16.9% increase.
- The cleanest cohort (2018, 6 founding members, no pre-trend issues) shows **zero significant effects**, pre- or post-treatment.
- The positive aggregate result is driven almost entirely by small, low patent-count, noisy cohorts (Vietnam, Peru, Malaysia, Brunei, Chile), where signs flip year to year.
- Results overlap with the COVID-19 pandemic period, a plausible confound for the 2020–2021 patent spike.
- **Conclusion: no robust evidence that CPTPP caused an increase in pharmaceutical patent activity.**

## Overall Conclusion

Over 2005–2024, CPTPP membership shows **no credible, robust evidence of causally improving GDP per capita or pharmaceutical patent activity** among its members. The GDP null is a genuinely clean result; the patent findings are a fragile, borderline-significant signal concentrated in low-volume, noisy cohorts rather than the best-identified (2018) cohort — providing a stronger basis for scepticism about CPTPP's short-run economic impact.

## References

- Callaway, B., & Sant'Anna, P. H. C. (2021). Difference-in-differences with multiple time periods. *Journal of Econometrics*, 225(2), 200–230.
- World Bank. (2024). *World Development Indicators* [Data set]. https://databank.worldbank.org/source/world-development-indicators
- World Intellectual Property Organization. (2024). *WIPO IP Statistics Data Center* [Data set]. https://www3.wipo.int/ipstats/
- European Patent Office. (2025). *EPO Technology Dashboard*. https://www.epo.org/en/about-us/statistics
- World Bank. (2024). *Intellectual property indicators*.
- New Zealand Ministry of Foreign Affairs and Trade. (2018). *CPTPP: Text and resources*. https://www.mfat.govt.nz/en/trade/free-trade-agreements/free-trade-agreements-in-force/cptpp/
- Office of the United States Trade Representative. (2017). *Statement on the U.S. withdrawal from the Trans-Pacific Partnership*.
