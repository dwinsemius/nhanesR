# data-raw/build_registries.R
# Run once with: source("data-raw/build_registries.R")
# Builds internal sysdata.rda containing:
#   .nhanes_cycles      - all continuous NHANES cycles with metadata
#   .lmf_registry       - mortality file FTP locations and column specs
#   .lmf_colspec        - fixed-width column positions for .dat parsing

# ── Cycle registry ────────────────────────────────────────────────────────────
# Each row = one NHANES cycle
# url_path: the CDC path segment used in XPT URLs
# suffix:   the letter suffix appended to component file codes (e.g. DEMO_I)
# wt_2yr / wt_4yr: standard weight variable names for this cycle
# lmf_vintage: which public-use LMF release covers this cycle

.nhanes_cycles <- data.frame(
  cycle       = c("1999-2000", "2001-2002", "2003-2004", "2005-2006",
                  "2007-2008", "2009-2010", "2011-2012", "2013-2014",
                  "2015-2016", "2017-2018", "2017-2020"),
  begin_year  = c(1999, 2001, 2003, 2005, 2007, 2009, 2011, 2013, 2015,
                  2017, 2017),
  end_year    = c(2000, 2002, 2004, 2006, 2008, 2010, 2012, 2014, 2016,
                  2018, 2020),
  url_path    = c("1999-2000", "2001-2002", "2003-2004", "2005-2006",
                  "2007-2008", "2009-2010", "2011-2012", "2013-2014",
                  "2015-2016", "2017-2018", "2017-2020"),
  suffix      = c("", "_B", "_C", "_D", "_E", "_F", "_G", "_H",
                  "_I", "_J", "_P"),
  wt_mec_2yr  = c("WTMEC2YR", "WTMEC2YR", "WTMEC2YR", "WTMEC2YR",
                  "WTMEC2YR", "WTMEC2YR", "WTMEC2YR", "WTMEC2YR",
                  "WTMEC2YR", "WTMEC2YR", NA),
  wt_int_2yr  = c("WTINT2YR", "WTINT2YR", "WTINT2YR", "WTINT2YR",
                  "WTINT2YR", "WTINT2YR", "WTINT2YR", "WTINT2YR",
                  "WTINT2YR", "WTINT2YR", NA),
  wt_mec_4yr  = c(NA, "WTMEC4YR", NA, "WTMEC4YR", NA, "WTMEC4YR",
                  NA, "WTMEC4YR", NA, NA, NA),
  wt_prepan   = c(NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, "WTMECPRP"),
  pandemic_adj = c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
                   FALSE, FALSE, FALSE, TRUE),
  has_lmf_public = c(TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,
                     TRUE, TRUE, TRUE),
  lmf_vintage = rep("2019", 11),
  censor_date = rep("2019-12-31", 11),
  stringsAsFactors = FALSE
)

# NHANES III (separate structure, included for completeness)
.nhanes_iii <- data.frame(
  cycle        = "1988-1994",
  begin_year   = 1988,
  end_year     = 1994,
  url_path     = "nhanes3",
  suffix       = "",
  wt_mec_2yr   = NA_character_,
  wt_int_2yr   = NA_character_,
  wt_mec_4yr   = NA_character_,
  wt_prepan    = NA_character_,
  pandemic_adj = FALSE,
  has_lmf_public = TRUE,
  lmf_vintage  = "2019",
  censor_date  = "2019-12-31",
  stringsAsFactors = FALSE
)

# ── LMF file registry ─────────────────────────────────────────────────────────
# Maps each NHANES cycle to its exact FTP filename
# Follow-up is through December 31, 2019 for all public-use files

.lmf_registry <- data.frame(
  cycle    = c("1988-1994",
               "1999-2000", "2001-2002", "2003-2004", "2005-2006",
               "2007-2008", "2009-2010", "2011-2012", "2013-2014",
               "2015-2016", "2017-2018", "2017-2020"),
  filename = c("NHANES_III_MORT_2019_PUBLIC.dat",
               "NHANES_1999_2000_MORT_2019_PUBLIC.dat",
               "NHANES_2001_2002_MORT_2019_PUBLIC.dat",
               "NHANES_2003_2004_MORT_2019_PUBLIC.dat",
               "NHANES_2005_2006_MORT_2019_PUBLIC.dat",
               "NHANES_2007_2008_MORT_2019_PUBLIC.dat",
               "NHANES_2009_2010_MORT_2019_PUBLIC.dat",
               "NHANES_2011_2012_MORT_2019_PUBLIC.dat",
               "NHANES_2013_2014_MORT_2019_PUBLIC.dat",
               "NHANES_2015_2016_MORT_2019_PUBLIC.dat",
               "NHANES_2017_2018_MORT_2019_PUBLIC.dat",
               "NHANES_2017_2020_MORT_2019_PUBLIC.dat"),
  ftp_base = rep(
    "https://ftp.cdc.gov/pub/Health_Statistics/NCHS/datalinkage/linked_mortality/",
    12
  ),
  vintage      = rep("2019", 12),
  censor_date  = rep("2019-12-31", 12),
  follow_up_origin = rep("interview and exam", 12),
  stringsAsFactors = FALSE
)

# ── LMF fixed-width column specification ──────────────────────────────────────
# Source: CDC Public-Use LMF Data Dictionary (April 2022)
# https://www.cdc.gov/nchs/data/datalinkage/public-use-linked-mortality-files-data-dictionary.pdf
#
# col_start / col_end: 1-based character positions in the .dat file
# na_codes: values that should be treated as NA

.lmf_colspec <- data.frame(
  variable    = c("SEQN", "ELIGSTAT", "MORTSTAT", "UCOD_LEADING",
                  "DIABETES", "HYPERTEN", "PERMTH_INT", "PERMTH_EXM",
                  "WAGEGRP", "EDUCAT"),
  col_start   = c(1,  15,  16,  17,  20,  21,  43,  46,  64,  65),
  col_end     = c(6,  15,  16,  19,  20,  21,  45,  48,  64,  65),
  col_type    = c("i", "i", "i", "c", "i", "i", "d", "d", "i", "i"),
  label       = c(
    "Respondent sequence number",
    "Eligibility status for mortality follow-up",
    "Final mortality status",
    "Underlying cause of death (ICD-10 recode)",
    "Diabetes flag on death certificate",
    "Hypertension flag on death certificate",
    "Person months of follow-up from interview date",
    "Person months of follow-up from examination date",
    "Wage/earnings in year of survey (grouped)",
    "Education level"
  ),
  eligstat_note = c(
    NA, "1=eligible; 2=under 18; 3=insufficient identifying data",
    "0=assumed alive; 1=assumed deceased; NA=ineligible",
    "See ICD-10 recode table", NA, NA,
    "Months from interview to Dec 31 2019 or death",
    "Months from examination to Dec 31 2019 or death",
    NA, NA
  ),
  perturbed   = c(FALSE, FALSE, FALSE, TRUE, TRUE, TRUE, TRUE, TRUE,
                  FALSE, FALSE),
  stringsAsFactors = FALSE
)

# ── Cause-of-death leading cause recode ───────────────────────────────────────
# ICD-10 recode used in the public-use LMF UCOD_LEADING variable
# Source: CDC LMF documentation

.ucod_labels <- data.frame(
  code  = c("001", "002", "003", "004", "005", "006", "007", "008",
            "009", "010", "011"),
  label = c(
    "Diseases of heart",
    "Malignant neoplasms",
    "Chronic lower respiratory disease",
    "Accidents (unintentional injuries)",
    "Cerebrovascular disease",
    "Alzheimer's disease",
    "Diabetes mellitus",
    "Influenza and pneumonia",
    "Nephritis, nephrotic syndrome, and nephrosis",
    "All other causes",
    "Suicide"
  ),
  icd10_range = c(
    "I00-I09,I11,I13,I20-I51",
    "C00-C97",
    "J40-J47",
    "V01-X59,Y85-Y86",
    "I60-I69",
    "G30",
    "E10-E14",
    "J09-J18",
    "N00-N07,N17-N19,N25-N27",
    "All other",
    "U03,X60-X84,Y87.0"
  ),
  stringsAsFactors = FALSE
)

# ── Save to internal sysdata ───────────────────────────────────────────────────
usethis::use_data(
  .nhanes_cycles,
  .nhanes_iii,
  .lmf_registry,
  .lmf_colspec,
  .ucod_labels,
  internal  = TRUE,
  overwrite = TRUE
)

message("Internal registry data saved to R/sysdata.rda")
