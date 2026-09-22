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
                     TRUE, TRUE, FALSE),
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
               "2015-2016", "2017-2018"),
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
               "NHANES_2017_2018_MORT_2019_PUBLIC.dat"),
  ftp_base = rep(
    "https://ftp.cdc.gov/pub/Health_Statistics/NCHS/datalinkage/linked_mortality/",
    11
  ),
  vintage      = rep("2019", 11),
  censor_date  = rep("2019-12-31", 11),
  follow_up_origin = rep("interview and exam", 11),
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

# ── NHIS LMF file registry ─────────────────────────────────────────────────────
# Maps each NHIS survey year to its exact FTP filename. Unlike NHANES (one file
# per 2-year cycle), NCHS distributes one public-use LMF per NHIS survey YEAR.
# Follow-up is through December 31, 2019 for all public-use files.
#
# Verified 2026-09-21: all 33 URLs below return HTTP 200 (curl -sI), and the
# file list matches the FTP directory listing at
# https://ftp.cdc.gov/pub/Health_Statistics/NCHS/datalinkage/linked_mortality/
# exactly (33 NHIS_<year>_MORT_2019_PUBLIC.dat files, 1986-2018, no gaps).

.nhis_lmf_years_available <- as.character(1986:2018)

.nhis_lmf_registry <- data.frame(
  year     = .nhis_lmf_years_available,
  filename = paste0("NHIS_", .nhis_lmf_years_available, "_MORT_2019_PUBLIC.dat"),
  ftp_base = rep(
    "https://ftp.cdc.gov/pub/Health_Statistics/NCHS/datalinkage/linked_mortality/",
    length(.nhis_lmf_years_available)
  ),
  vintage      = rep("2019", length(.nhis_lmf_years_available)),
  censor_date  = rep("2019-12-31", length(.nhis_lmf_years_available)),
  stringsAsFactors = FALSE
)

# ── NHIS LMF fixed-width column specification ─────────────────────────────────
# Source: NCHS's own reference R read-in program, downloaded directly from the
# same FTP directory as the .dat files:
# https://ftp.cdc.gov/pub/Health_Statistics/NCHS/datalinkage/linked_mortality/R_ReadInProgramAllSurveys.R
# (confirmed genuine NCHS output, not a third-party transcription) and
# cross-checked against the companion codebook PDF's variable list:
# https://www.cdc.gov/nchs/data/datalinkage/public-use-linked-mortality-files-data-dictionary.pdf
#
# NHIS's LMF layout differs from NHANES's in real ways, not just the ID column:
# - PUBLICID (character, 14 wide) replaces SEQN as the join key.
# - No PERMTH_INT/PERMTH_EXM -- those are documented as NHANES-only. NHIS
#   provides DODQTR/DODYEAR (quarter/year of death) instead; constructing a
#   person-time variable requires the survey interview date from the NHIS
#   person/year file itself, which nhanesR does not download (see the "NHIS
#   raw-data download" scoping note in nhis_mortality.R's roxygen docs) --
#   nhis_mortality_link() surfaces the raw LMF fields only.
# - WGT_NEW / SA_WGT_NEW (eligibility-adjusted survey weights) replace the
#   NHANES weight variables, and are themselves partial: WGT_NEW is blank for
#   1986 (NCHS recommends the public-use file's own WTFA that year) and
#   SA_WGT_NEW only exists from 1997 (Sample Adult File redesign) onward.
#
# perturbed: UCOD_LEADING/DIABETES/HYPERTEN follow the same general NCHS
# public-use-LMF perturbation practice already recorded for the NHANES
# colspec above (same underlying LMF product line, same disclosure). DODQTR/
# DODYEAR's perturbation status is not confirmed from either source document
# read while building this registry -- left FALSE rather than guessed; revisit
# against the full NDI-linkage methods PDF if this matters for an analysis.

.nhis_lmf_colspec <- data.frame(
  variable    = c("PUBLICID", "ELIGSTAT", "MORTSTAT", "UCOD_LEADING",
                  "DIABETES", "HYPERTEN", "DODQTR", "DODYEAR",
                  "WGT_NEW", "SA_WGT_NEW"),
  col_start   = c(1,  15,  16,  17,  20,  21,  22,  23,  27,  35),
  col_end     = c(14, 15,  16,  19,  20,  21,  22,  26,  34,  42),
  col_type    = c("c", "i", "i", "c", "i", "i", "i", "i", "d", "d"),
  label       = c(
    "NHIS public-use ID",
    "Eligibility status for mortality follow-up",
    "Final mortality status",
    "Underlying cause of death (ICD-10 recode)",
    "Diabetes flag on death certificate",
    "Hypertension flag on death certificate",
    "Quarter of death",
    "Year of death",
    "Person-level sample weight, adjusted for linkage-ineligible respondents",
    "Sample Adult sample weight, adjusted for linkage-ineligible respondents"
  ),
  eligstat_note = c(
    NA, "1=eligible; 2=under 18; 3=insufficient identifying data",
    "0=assumed alive; 1=assumed deceased; NA=ineligible",
    "See ICD-10 recode table", NA, NA,
    "1=Jan-Mar; 2=Apr-Jun; 3=Jul-Sep; 4=Oct-Dec",
    "1986-2019", NA, NA
  ),
  perturbed   = c(FALSE, FALSE, FALSE, TRUE, TRUE, TRUE, FALSE, FALSE,
                  FALSE, FALSE),
  stringsAsFactors = FALSE
)

# ── NHIS Household/Person raw-data file registry ──────────────────────────────
# Two "core" NHIS survey files nhanesR downloads directly, per the user's
# request (2026-09-21): Household and Person. Both distributed as one .zip
# per year (unzips to a single fixed-width .DAT), 1986-2018, with a matching
# SAS input-syntax file at a parallel Program_Code URL parsed at runtime by
# the SAScii package (Suggests -- see R/nhis_data.R). SAScii verified
# directly against real 1986 and 1997 files before relying on it: correctly
# recovers skip/gap columns from the pre-1997 SAS (no explicit gap markers in
# the source) and the implied-decimal convention (e.g. a SAS "46-51 .1"
# column) in the post-1997 SAS, and round-tripped the actual 1986 HOUSEHLD.DAT
# (24,698 records, matching the year's own documentation exactly).
#
# Verified 2026-09-21: HEAD-checked all 33 years x 2 files x 2 URL types
# (zip + sas) = 132 URLs.
#
# Filename case is irrelevant to the actual requests -- confirmed directly by
# requesting known files in the opposite case from what the directory listing
# displayed (both directions) and getting HTTP 200 either way; the FTP host
# is Microsoft-IIS, case-insensitive on the backing filesystem. The registry
# below still records the case the listing shows, for clarity when reading
# it, not because it's load-bearing.
#
# One confirmed REAL gap, not a URL-pattern miss: 1989's Household .zip
# returns 404 -- despite 1989's own documentation (readme.txt) listing a
# Household file in its own file table (48,054 recs, same 335-byte record
# length as every other core file that year). The matching HOUSEHLD.SAS
# syntax file is still present (200) -- only the data file itself is
# missing from the current server. Checked every case/extension variant
# (.EXE/.exe/.ZIP/.zip, upper/lower filename) before concluding this is a
# genuine absence rather than a naming miss. Recorded as `available = FALSE`
# rather than silently retried or omitted from the registry.
#
# 2004 alone nests both the data zip and the SAS syntax file one directory
# deeper (.../2004/household/HOUSEHLD.zip, .../2004/household/HOUSEHLD.sas)
# -- every other year 1986-2018 is flat directly under the year directory.

.nhis_data_years <- as.character(1986:2018)

.nhis_data_registry <- data.frame(
  year      = rep(.nhis_data_years, each = 2),
  module    = rep(c("household", "person"), times = length(.nhis_data_years)),
  file_base = rep(c("HOUSEHLD", "PERSONSX"), times = length(.nhis_data_years)),
  stringsAsFactors = FALSE
)
.nhis_data_registry$subdir <- ifelse(
  .nhis_data_registry$year == "2004", .nhis_data_registry$module, NA_character_
)
.nhis_data_registry$available <- TRUE
.nhis_data_registry$available[.nhis_data_registry$year == "1989" &
                                 .nhis_data_registry$module == "household"] <- FALSE

# ── NHIS pre-1997 Household/Person placeholder-name crosswalk ─────────────────
# Produces .nhis_pre1997_crosswalk, 1986-1991 (see that script's own header
# for why the scope stops there, and R/nhis_data.R for how nhis_download()
# uses it). A separate file, not inlined here, because it carries its own
# substantial parsing logic (SAS INPUT-statement position parsing, PDF
# codebook page-boundary detection, label-block extraction) that earned its
# own file the same way the registries above didn't need one.
source("data-raw/build_nhis_pre1997_crosswalk.R")

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

# ── BIOPRO catalog supplement ─────────────────────────────────────────────────
# The CDC online variable catalog has indexing gaps for BIOPRO analytes in
# several cycles, confirmed by cross-checking XPT files against catalog pages:
#
#   Cycle       File      Variables missing from CDC catalog (data present + documented)
#   1999-2000   Lab18     ALL BIOPRO variables (full CMP panel)
#   2001-2002   L40_B     ALL BIOPRO variables (full CMP panel)
#   2005-2006   BIOPRO_D  LBXSAPSI (alkaline phosphatase only)
#   2007-2008   BIOPRO_E  LBXSASSI (AST) and LBXSAPSI (ALP)
#   2009-2010   BIOPRO_F  LBXSAPSI (alkaline phosphatase only)
#   2011-2012   BIOPRO_G  LBXSAPSI (alkaline phosphatase only)
#
# CDC documentation pages for all affected files include full methodology
# sections and no quality caveats — these are pure catalog indexing failures.
# The supplement patches all gaps so nhanes_variable_map() returns complete
# cycle coverage without requiring direct file downloads as workarounds.

.build_early_catalog <- function(xpt_url, cycle, file_name,
                                  component = "Laboratory") {
  df <- haven::read_xpt(url(xpt_url))
  labels <- vapply(df, function(col) {
    lab <- attr(col, "label")
    if (is.null(lab) || !nzchar(lab)) NA_character_
    else iconv(as.character(lab), to = "UTF-8", sub = "")
  }, character(1L))
  data.frame(
    variable_name = names(labels),
    variable_desc = unname(labels),
    file_name     = file_name,
    file_desc     = paste("NHANES", cycle,
                          "comprehensive metabolic panel (Lab18/L40 series)"),
    cycle         = cycle,
    component     = component,
    stringsAsFactors = FALSE
  )
}

cat("Downloading Lab18 (1999-2000) for BIOPRO supplement...\n")
.biopro_lab18 <- .build_early_catalog(
  "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/1999/DataFiles/Lab18.xpt",
  "1999-2000", "Lab18"
)

cat("Downloading L40_B (2001-2002) for BIOPRO supplement...\n")
.biopro_l40b <- .build_early_catalog(
  "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2001/DataFiles/L40_B.xpt",
  "2001-2002", "L40_B"
)

# For 2005-2012, only specific variables are missing from the catalog.
# Download target files and extract just the affected variables + labels.
.extract_vars <- function(xpt_url, cycle, file_name, vars,
                           component = "Laboratory") {
  df <- haven::read_xpt(url(xpt_url))
  vars_present <- intersect(vars, names(df))
  labels <- vapply(df[, vars_present, drop = FALSE], function(col) {
    lab <- attr(col, "label")
    if (is.null(lab) || !nzchar(lab)) NA_character_
    else iconv(as.character(lab), to = "UTF-8", sub = "")
  }, character(1L))
  data.frame(
    variable_name = vars_present,
    variable_desc = unname(labels),
    file_name     = file_name,
    file_desc     = paste("NHANES", cycle, "BIOPRO (catalog gap)"),
    cycle         = cycle,
    component     = component,
    stringsAsFactors = FALSE
  )
}

cat("Downloading BIOPRO_D (2005-2006) for ALP supplement row...\n")
.biopro_d <- .extract_vars(
  "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2005/DataFiles/BIOPRO_D.xpt",
  "2005-2006", "BIOPRO_D", c("LBXSAPSI")
)

cat("Downloading BIOPRO_E (2007-2008) for AST + ALP supplement rows...\n")
.biopro_e <- .extract_vars(
  "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2007/DataFiles/BIOPRO_E.xpt",
  "2007-2008", "BIOPRO_E", c("LBXSASSI", "LBXSAPSI")
)

cat("Downloading BIOPRO_F (2009-2010) for ALP supplement row...\n")
.biopro_f <- .extract_vars(
  "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2009/DataFiles/BIOPRO_F.xpt",
  "2009-2010", "BIOPRO_F", c("LBXSAPSI")
)

cat("Downloading BIOPRO_G (2011-2012) for ALP supplement row...\n")
.biopro_g <- .extract_vars(
  "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2011/DataFiles/BIOPRO_G.xpt",
  "2011-2012", "BIOPRO_G", c("LBXSAPSI")
)

# Combine all supplement rows; drop SEQN from early full-file downloads
.early_biopro_catalog <- rbind(
  .biopro_lab18[.biopro_lab18$variable_name != "SEQN", ],
  .biopro_l40b[.biopro_l40b$variable_name   != "SEQN", ],
  .biopro_d, .biopro_e, .biopro_f, .biopro_g
)
rownames(.early_biopro_catalog) <- NULL

cat("BIOPRO supplement:", nrow(.early_biopro_catalog),
    "rows across", length(unique(.early_biopro_catalog$cycle)), "cycles\n")

# ── Save to internal sysdata ───────────────────────────────────────────────────
usethis::use_data(
  .nhanes_cycles,
  .nhanes_iii,
  .lmf_registry,
  .lmf_colspec,
  .ucod_labels,
  .early_biopro_catalog,
  .nhis_lmf_registry,
  .nhis_lmf_colspec,
  .nhis_data_registry,
  .nhis_pre1997_crosswalk,
  internal  = TRUE,
  overwrite = TRUE
)

message("Internal registry data saved to R/sysdata.rda")
