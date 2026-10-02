## ============================================================
## NHANES III (1988-1994) assembly: exam + adult questionnaire + serum
## cotinine + 2019 public-use linked mortality, all downloaded from NCHS.
## Written 2026-09-30. Output: nhanes3_pooled.rds (gitignored), one row
## per adult (17+) with both an exam and an adult interview.
##
## Why: NHANES III never-smokers have ~26 years median follow-up and
## about as many deaths as all 1999-2018 never-smokers combined, which
## helps the thin 20-55 by-sex panels (HISTORY.md, 2026-09-30).
##
## Sources (fixed-width .dat + SAS layout .sas; cached in nhanes3_raw/):
##   https://wwwn.cdc.gov/nchs/data/nhanes3/1a/exam.dat   (LRECL 6235)
##   https://wwwn.cdc.gov/nchs/data/nhanes3/1a/adult.dat  (LRECL 3348)
##   https://wwwn.cdc.gov/nchs/data/nhanes3/2a/lab2.dat   (LRECL 1297)
##     -- serum cotinine COP. The COP column in 1a/lab.dat is blank for
##        everyone; the values were released in the second lab file.
##   https://ftp.cdc.gov/pub/Health_Statistics/NCHS/datalinkage/
##     linked_mortality/NHANES_III_MORT_2019_PUBLIC.dat
## Codebooks: <file>-acc.pdf in the same directories.
##
## Minimal cleaning only, as in assemble_nhis_data.R: "blank but
## applicable" / "don't know" codes (all-8s / all-9s for the field's
## width) set to NA, units matched to the NHANES pipeline, and helper
## variables added. No age, smoking or eligibility filtering -- that is
## analysis-specific.
## ============================================================

suppressMessages(library(dplyr))
RAW <- "nhanes3_raw"
dir.create(RAW, showWarnings = FALSE)
options(timeout = 900)

nh3 <- "https://wwwn.cdc.gov/nchs/data/nhanes3/"
files <- c(exam.dat = "1a/exam.dat", exam.sas = "1a/exam.sas",
           adult.dat = "1a/adult.dat", adult.sas = "1a/adult.sas",
           lab2.dat = "2a/lab2.dat", lab2.sas = "2a/lab2.sas")
urls <- c(setNames(paste0(nh3, files), names(files)),
          NHANES_III_MORT_2019_PUBLIC.dat = paste0("https://ftp.cdc.gov/pub/Health_Statistics/NCHS/",
                                                   "datalinkage/linked_mortality/NHANES_III_MORT_2019_PUBLIC.dat"))
for (f in names(urls)) {
    dest <- file.path(RAW, f)
    if (!file.exists(dest)) { cat("downloading", f, "\n"); download.file(urls[[f]], dest, mode = "wb", quiet = TRUE) }
}

## Column layout from the SAS INPUT block ("VAR 1-5" or "VAR 15"; "$" marks character)
sas_layout <- function(sas_file) {
    s <- readLines(sas_file, warn = FALSE)
    s <- s[(grep("^\\s*INPUT\\s*$", s)[1] + 1):length(s)]
    s <- s[seq_len(grep("^\\s*;\\s*$", s)[1] - 1)]
    m <- regmatches(s, regexec("^\\s*([A-Z][A-Z0-9_]*)\\s+(\\$?)\\s*([0-9]+)(-([0-9]+))?\\s*$", s))
    m <- m[lengths(m) == 6]
    L <- data.frame(var = vapply(m, `[`, "", 2), char = vapply(m, `[`, "", 3) == "$",
                    start = as.integer(vapply(m, `[`, "", 4)))
    L$end <- ifelse(nzchar(vapply(m, `[`, "", 6)), as.integer(vapply(m, `[`, "", 6)), L$start)
    lrecl <- as.integer(sub(".*LRECL\\s*=\\s*([0-9]+).*", "\\1", grep("LRECL\\s*=", readLines(sas_file, warn = FALSE), value = TRUE)[1]))
    stopifnot(max(L$end) == lrecl - 2)          # layout covers the whole record (LRECL counts CRLF)
    L
}
read_nh3 <- function(stem, vars) {
    L <- sas_layout(file.path(RAW, paste0(stem, ".sas")))
    miss <- setdiff(vars, L$var)
    if (length(miss)) stop(stem, ": not in layout: ", paste(miss, collapse = ", "))
    L <- L[match(vars, L$var), ]
    x <- readr::read_fwf(file.path(RAW, paste0(stem, ".dat")),
                         readr::fwf_positions(L$start, L$end, L$var),
                         col_types = readr::cols(.default = "d"), progress = FALSE)
    attr(x, "width") <- setNames(L$end - L$start + 1, L$var)
    x
}
## all-8s (blank but applicable) and all-9s (don't know) for the field's width -> NA
recode_codes <- function(x, vars) {
    w <- attr(x, "width")
    for (v in vars) {
        codes <- as.numeric(c(strrep("8", w[[v]]), strrep("9", w[[v]])))
        n <- sum(x[[v]] %in% codes)
        if (n) cat(sprintf("  %-9s %6d set to NA (codes %s)\n", v, n, paste(codes, collapse = "/")))
        x[[v]][x[[v]] %in% codes] <- NA
    }
    x
}

cat("exam\n")
exam <- read_nh3("exam", c("SEQN", "HSSEX", "HSAGEIR", "DMARETHN", "SDPPHASE", "BMPHT", "BMPWT",
                           "BMPBMI", "BMPWAIST", "WTPFEX6", "SDPPSU6", "SDPSTRA6"))
exam <- recode_codes(exam, c("BMPHT", "BMPWT", "BMPBMI", "BMPWAIST"))

cat("adult\n")
adult <- read_nh3("adult", c("SEQN", "HAR1", "HAR3", "HAR4S", "HAR11R", "HAR16", "HAR24", "HAR27", "HFF1"))
adult <- recode_codes(adult, c("HAR1", "HAR3", "HAR4S", "HAR11R", "HAR16", "HAR24", "HAR27", "HFF1"))
## HAR4S (cigarettes/day now) has item-specific codes besides 888/999 (checked
## with nh3_codebook(), nhanes3_codebook.R): 666 = varies, 777 = less than 1/day.
## Keep the code in HAR4S_special and set the numeric value to NA.
adult$HAR4S_special <- ifelse(adult$HAR4S %in% 666, "varies", ifelse(adult$HAR4S %in% 777, "<1 per day", NA))
cat(sprintf("  %-9s %6d set to NA (codes 666/777, kept in HAR4S_special)\n", "HAR4S", sum(!is.na(adult$HAR4S_special))))
adult$HAR4S[!is.na(adult$HAR4S_special)] <- NA

cat("lab2\n")
lab2 <- read_nh3("lab2", c("SEQN", "COP"))
lab2 <- recode_codes(lab2, "COP")

mort <- readr::read_fwf(file.path(RAW, "NHANES_III_MORT_2019_PUBLIC.dat"),
    readr::fwf_cols(SEQN = c(1, 5), eligstat = c(15, 15), mortstat = c(16, 16),
                    ucod_leading = c(17, 19), diabetes_mort = c(20, 20), hyperten_mort = c(21, 21),
                    permth_int = c(43, 45), permth_exm = c(46, 48)),
    col_types = "iiiiiiii", na = c("", "."), progress = FALSE)

stopifnot(!anyDuplicated(exam$SEQN), !anyDuplicated(adult$SEQN), !anyDuplicated(lab2$SEQN), !anyDuplicated(mort$SEQN))
d <- exam %>% inner_join(adult, by = "SEQN") %>% left_join(lab2, by = "SEQN") %>% left_join(mort, by = "SEQN")

## ---- derived variables, NHANES-pipeline names/units ----
d <- d %>% mutate(
    Ht_m = BMPHT / 100, BMXHT = BMPHT, BMXWT = BMPWT, BMXWAIST = BMPWAIST, BMI = BMPBMI,
    age = HSAGEIR,                                   # top-coded at 90
    sex = factor(HSSEX, levels = 1:2, labels = c("Male", "Female")),
    cig_status = case_when(HAR1 == 2 ~ "Never",
                           HAR1 == 1 & HAR3 == 2 ~ "Former",
                           HAR1 == 1 & HAR3 == 1 ~ "Current"),
    cig_status = factor(cig_status, levels = c("Never", "Former", "Current")),
    other_tob = HAR16 %in% 1 | HAR24 %in% 1 | HAR27 %in% 1,   # skipped items count as "no"
    ## self-reported never-smoker, no other tobacco, cotinine <= 10 ng/mL or not measured
    never_conf = cig_status %in% "Never" & !other_tob & (is.na(COP) | COP <= 10),
    ## survival: origin = exam, months, deaths through 2019-12-31 (NA unless eligstat == 1).
    ## 454 linkage-eligible people have no permth_exm: the home-examined
    ## (median age 80, WTPFEX6 = 0, measured at home). They drop out of
    ## any MEC-weighted, exam-origin analysis; permth_int is available if needed.
    time = if_else(eligstat == 1, as.numeric(permth_exm), NA_real_),
    event = if_else(eligstat == 1, as.numeric(mortstat), NA_real_),
    survey_weight = WTPFEX6
)

cat("\nrows:", nrow(d), " (adults 17+ with exam and adult interview)\n")
print(table(cig_status = d$cig_status, never_conf = d$never_conf, useNA = "ifany"))
print(table(eligstat = d$eligstat, mortstat = d$mortstat, useNA = "ifany"))
print(summary(d[, c("Ht_m", "BMXWT", "BMI", "BMXWAIST", "age", "COP", "time")]))
cat("\nnever_conf, linkage-eligible, ages 20-55, by sex and baseline band:\n")
print(d %>% filter(never_conf, eligstat == 1, age >= 20, age <= 55) %>%
      mutate(band = if_else(age <= 40, "20-40", "40-55")) %>%
      count(sex, band, wt = NULL, name = "n") %>%
      left_join(d %>% filter(never_conf, eligstat == 1, age >= 20, age <= 55) %>%
                mutate(band = if_else(age <= 40, "20-40", "40-55")) %>%
                group_by(sex, band) %>% summarise(deaths = sum(event), .groups = "drop"),
                by = c("sex", "band")))

saveRDS(d, "nhanes3_pooled.rds")
cat("saved nhanes3_pooled.rds\n")
