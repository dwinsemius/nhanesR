# data-raw/build_nhis_pre1997_crosswalk.R
#
# Builds .nhis_pre1997_crosswalk: a placeholder-name -> descriptive-label
# table for NHIS Household/Person variables, 1986-1991, sourced by
# build_registries.R and baked into R/sysdata.rda alongside the other NHIS
# registries. Consumed by nhis_download() to attach labels post-parse.
#
# WHY THIS EXISTS: 1986-1996 NHIS SAS syntax files use NCHS's original
# placeholder variable scheme (HH_22, PX_24, ...) rather than descriptive
# names -- unlike 1997 onward, which has real names (SRVY_YR, HHX, ...)
# baked directly into the SAS syntax. The only source for what a placeholder
# actually MEANS is that year's own NHISCORE.PDF codebook, a typeset (not
# machine-readable) document.
#
# METHOD, verified against the real 1986 files before trusting it:
#   1. Parse each year's HOUSEHLD.SAS/PERSONSX.SAS via SAScii::parse.SAScii()
#      to get variable names + byte positions (same approach already used
#      for nhis_download() itself).
#   2. Parse that same year's NHISCORE.PDF (via pdftools::pdf_text(), no
#      external pdftotext binary needed) into (tape-location, item-number,
#      label) blocks -- the "Locations" column in the PDF is the SAME byte
#      position scheme as the SAS INPUT statement's start position.
#   3. Join the two by tape-location start position.
#
# SCOPE: 1986-1991 only, not the full 1986-1996 span originally discussed.
# Checked directly across all 11 years (not assumed uniform, despite the
# source documentation's own claim that these files were "administered each
# year (through 1996) without major modification" -- that claim does NOT
# hold at the byte-layout level): field count grows almost every year
# 1986-1994, 1992 abruptly shows a much larger source PDF (218 pages vs.
# ~167-176 for neighboring years) that this parser can no longer fully
# resolve (Household/Person match rates drop hard starting there), and
# 1995-1996 switch to a genuinely different structure (HHID/WEEKCODE/...
# replacing the HH_NN placeholder scheme entirely). 1986-1991 all matched
# essentially completely (45-49 of 48-49 Household vars, 99-105 of 99-105
# Person vars); 1992-1996 did not, AND -- checked directly, not assumed --
# every one of 1993's unmatched variables already carries a real descriptive
# SAS name (REGION, HEIGHT, WEIGHT, ...), not a placeholder, so the
# unresolved years matter far less than the match-rate drop alone suggests.
# Extending past 1991 is future work, not done here.

library(SAScii)
library(pdftools)

# -- Step 1: SAS variable positions --------------------------------------------

sas_positions <- function(sas_path) {
  spec <- parse.SAScii(sas_path)
  pos <- 1L
  starts <- integer(nrow(spec)); ends <- integer(nrow(spec))
  for (i in seq_len(nrow(spec))) {
    w <- abs(spec$width[i])
    starts[i] <- pos
    ends[i]   <- pos + w - 1L
    pos <- pos + w
  }
  spec$start <- starts
  spec$end   <- ends
  spec[!is.na(spec$varname), c("varname", "start", "end")]
}

# -- Step 2: NHISCORE.PDF location-block parser --------------------------------
# Ported from a Python prototype verified against the real 1986 files
# (46/47 -> 47/47 Household match after fixing two real bugs: gap columns
# must be included, not dropped, before computing cumulative byte positions;
# and a stray form-feed character at one page break was blocking the
# leading-whitespace match for a single row).
#
# Two further fixes applied here, after reviewing the first working example
# with the user (2026-09-22): the label's own text column is FIXED at
# character 37 throughout this document (verified directly across multiple
# item types, both first-line and continuation-line instances -- not
# assumed), which gives a reliable signal for two things a first pass
# missed:
#   1. Item-code prefixes beyond HH-/PX- (the Person section also uses
#      G-, L-, A-, B-, D- per question block, plus irregular forms like
#      "L-R" and "A-A2") were leaking into the label text instead of being
#      stripped into their own column.
#   2. Labels that wrap to a second physical line in the PDF (e.g.
#      "SHORT-STAY HOSPITAL EPISODE DAYS IN PAST" continuing as
#      "12 MONTHS)" on the next line) were truncated to just the first line.

LABEL_COL <- 37L

parse_nhiscore_pages <- function(pdf_path, first_page, last_page) {
  txt   <- pdf_text(pdf_path)
  pages <- txt[first_page:last_page]
  full  <- paste(pages, collapse = "\n")
  lines <- strsplit(full, "\n")[[1]]
  lines <- gsub("\f", "", lines, fixed = TRUE)

  skip_re <- paste0(
    "^\\s*(Locations|Tape)\\s*$|Item No\\.|",
    "^\\s*[0-9]+\\s+.*-\\s*[0-9]+\\s*-\\s*$|",
    "^\\s*NHIS PUBLIC USE TAPES|^\\s*HOUSEHOLD RECORD\\s*$|",
    "^\\s*PERSON RECORD\\s*$|^\\s*\\*"
  )
  loc_re  <- "^( {0,8})([0-9]+(?:-[0-9]+)?)\\s+(.*\\S)\\s*$"
  item_re <- "^([A-Z]{1,2}-[A-Za-z0-9]+|Master|Recode|Generated|-)\\b\\s*(.*)$"

  # A continuation line: non-blank, its first non-space character sits at
  # LABEL_COL, and it does NOT itself start a new location block.
  is_continuation <- function(line) {
    if (!nzchar(trimws(line))) return(FALSE)
    if (grepl(loc_re, line, perl = TRUE)) return(FALSE)
    if (nchar(line) < LABEL_COL) return(FALSE)
    prefix <- substr(line, 1L, LABEL_COL - 1L)
    char_at_col <- substr(line, LABEL_COL, LABEL_COL)
    nzchar(trimws(char_at_col)) && !nzchar(trimws(prefix))
  }

  rows <- vector("list", length(lines))
  n <- 0L
  i <- 1L
  while (i <= length(lines)) {
    line <- lines[i]
    if (!nzchar(trimws(line)) || grepl(skip_re, line, perl = TRUE)) {
      i <- i + 1L; next
    }
    m <- regmatches(line, regexec(loc_re, line, perl = TRUE))[[1]]
    if (length(m) == 0L) { i <- i + 1L; next }

    loc  <- m[3]
    rest <- m[4]
    im <- regmatches(rest, regexec(item_re, rest, perl = TRUE))[[1]]
    if (length(im) > 0L) {
      item_no <- im[2]; label_parts <- trimws(im[3])
    } else {
      item_no <- NA_character_; label_parts <- trimws(rest)
    }

    j <- i + 1L
    while (j <= length(lines) && is_continuation(lines[j])) {
      label_parts <- paste(label_parts, trimws(lines[j]))
      j <- j + 1L
    }
    i <- j

    label <- trimws(label_parts)
    if (!nzchar(label)) next
    n <- n + 1L
    rows[[n]] <- data.frame(loc = loc, item_no = item_no, label = label,
                             stringsAsFactors = FALSE)
  }
  do.call(rbind, rows[seq_len(n)])
}

loc_start <- function(loc) as.integer(sub("-.*", "", loc))

# -- Step 3: locate Household/Person section page boundaries per year ----------
# NOT taken from each year's table-of-contents index (checked directly and
# rejected: TOC formatting is inconsistent enough across years -- only
# 1986-1989 matched a simple "Household Record ... <page>" grep; 1990-1996
# came back empty, either a different TOC layout or a wrap the regex missed).
#
# Instead: every content page carries a repeating page-FOOTER naming its
# record type ("HOUSEHOLD RECORD" / "PERSON RECORD" / "CONDITION RECORD",
# alongside "NHIS PUBLIC USE TAPE(S) RECORDS" -- wording varies slightly by
# year, checked directly rather than assumed identical: 1986/1990 say "NHIS
# PUBLIC USE TAPES", 1996 says "NHIS PUBLIC USE TAPE RECORDS"). This is
# present on every page of a section, not just a single TOC line, and is far
# more robust to scan for. Verified against 1986's already-confirmed
# boundaries (Household 7-16, Person 17-38) before trusting it on any other
# year.

# SIMPLER AND MORE RELIABLE than matching "HOUSEHOLD RECORD"/"PERSON RECORD"
# footer text directly (tried first, rejected: false positives from summary
# phrases like "NUMBER OF CONDITION RECORDS FOR THE HOUSEHOLD" on a page
# that's still Household content, and false negatives on pages where the
# footer line wraps differently). Every one of the five NHIS core record
# types (10=Household, 20=Person, 30=Condition, 40=Doctor Visit,
# 50=Hospital) opens with its own "1-2    -    RECORD TYPE" block -- so the
# document has exactly 5 such blocks, in that fixed order, and their page
# numbers ARE the section boundaries directly. No text disambiguation needed.
#
# This directly overturned an earlier wrong assumption of mine: I originally
# took the table-of-contents page numbers at face value (Household 7, Person
# 17, Condition 39) without checking them against the document's actual
# physical page index. They're wrong -- checked directly by reading page 15's
# actual content, which turns out to already be Person's own copy of the
# record-type prefix (RECTYPE/YEAR/QUARTER/...), not page 17. The TOC's page
# numbers don't match this PDF's physical pagination (front-matter offset,
# not investigated further since this method sidesteps the question
# entirely). The earlier "shared prefix" Person fallback (below) was
# quietly compensating for this bug, not modeling a real documentation gap --
# kept as a defensive fallback, not removed, in case some other year's PDF
# really doesn't repeat the prefix under Person.

find_section_pages <- function(pdf_path) {
  txt <- pdf_text(pdf_path)
  rectype_pages <- which(vapply(
    txt, function(p) grepl("1-2\\s+-\\s+RECORD TYPE", p), logical(1)
  ))
  if (length(rectype_pages) < 3L) {
    stop("Expected at least 3 RECORD TYPE section starts (Household/Person/",
         "Condition), found ", length(rectype_pages), " in ", pdf_path)
  }
  list(household_first = rectype_pages[1], person_first = rectype_pages[2],
       condition_first = rectype_pages[3])
}

# Sanity check against 1986's directly-confirmed boundaries (7, 15, 41 --
# verified by reading the actual page content above, not the TOC) before
# relying on this for any other year.
.p1986_path <- "/tmp/nhis_crosswalk_cache/NHISCORE_1986.pdf"
if (!file.exists(.p1986_path)) {
  dir.create(dirname(.p1986_path), showWarnings = FALSE, recursive = TRUE)
  download.file("https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Dataset_Documentation/NHIS/1986/NHISCORE.pdf",
                .p1986_path, quiet = TRUE)
}
.check_1986 <- find_section_pages(.p1986_path)
stopifnot(
  "1986 Household boundary must match the directly-confirmed value (7)"  = .check_1986$household_first == 7,
  "1986 Person boundary must match the directly-confirmed value (15)"    = .check_1986$person_first == 15,
  "1986 Condition boundary must match the directly-confirmed value (41)" = .check_1986$condition_first == 41
)
cat("Boundary-finder verified against 1986's directly-confirmed values (7/15/41). Proceeding.\n")

build_year_crosswalk <- function(year, cache_dir = "/tmp/nhis_crosswalk_cache") {
  dir.create(cache_dir, showWarnings = FALSE, recursive = TRUE)
  hh_sas_path <- file.path(cache_dir, paste0("HOUSEHLD_", year, ".sas"))
  px_sas_path <- file.path(cache_dir, paste0("PERSONSX_", year, ".sas"))
  pdf_path    <- file.path(cache_dir, paste0("NHISCORE_", year, ".pdf"))

  if (!file.exists(hh_sas_path)) {
    download.file(
      sprintf("https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Program_Code/NHIS/%s/HOUSEHLD.SAS", year),
      hh_sas_path, quiet = TRUE
    )
  }
  if (!file.exists(px_sas_path)) {
    download.file(
      sprintf("https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Program_Code/NHIS/%s/PERSONSX.SAS", year),
      px_sas_path, quiet = TRUE
    )
  }
  if (!file.exists(pdf_path)) {
    download.file(
      sprintf("https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Dataset_Documentation/NHIS/%s/NHISCORE.pdf", year),
      pdf_path, quiet = TRUE
    )
  }

  hh_sas <- sas_positions(hh_sas_path)
  px_sas <- sas_positions(px_sas_path)

  bounds <- find_section_pages(pdf_path)
  hh_pdf <- parse_nhiscore_pages(pdf_path, bounds$household_first, bounds$person_first - 1L)
  px_pdf <- parse_nhiscore_pages(pdf_path, bounds$person_first, bounds$condition_first - 1L)

  hh_pdf$start <- loc_start(hh_pdf$loc)
  px_pdf$start <- loc_start(px_pdf$loc)
  hh_pdf <- hh_pdf[!duplicated(hh_pdf$start), ]
  px_pdf <- px_pdf[!duplicated(px_pdf$start), ]

  hh_crosswalk <- merge(hh_sas, hh_pdf[, c("start", "item_no", "label")],
                         by = "start", all.x = TRUE)
  px_crosswalk <- merge(px_sas, px_pdf[, c("start", "item_no", "label")],
                         by = "start", all.x = TRUE)

  # Shared record-prefix, documented once under Household and not repeated
  # under Person -- filled in directly rather than left NA.
  shared_labels <- setNames(hh_crosswalk$label, hh_crosswalk$varname)
  px_missing <- is.na(px_crosswalk$label) & px_crosswalk$varname %in% names(shared_labels)
  px_crosswalk$label[px_missing] <- shared_labels[px_crosswalk$varname[px_missing]]
  if ("PNUM" %in% px_crosswalk$varname) {
    px_crosswalk$label[px_crosswalk$varname == "PNUM"] <-
      "Person Number (Blank on Household Record)"
  }

  hh_crosswalk$year <- year; hh_crosswalk$module <- "household"
  px_crosswalk$year <- year; px_crosswalk$module <- "person"

  out <- rbind(
    hh_crosswalk[, c("year", "module", "varname", "start", "end", "item_no", "label")],
    px_crosswalk[, c("year", "module", "varname", "start", "end", "item_no", "label")]
  )
  attr(out, "hh_matched") <- sum(!is.na(hh_crosswalk$label))
  attr(out, "hh_total")   <- nrow(hh_crosswalk)
  attr(out, "px_matched") <- sum(!is.na(px_crosswalk$label))
  attr(out, "px_total")   <- nrow(px_crosswalk)
  out
}

# -- Run across 1986-1991 and report per-year match quality ---------------------

.nhis_pre1997_years <- as.character(1986:1991)
.nhis_pre1997_results <- vector("list", length(.nhis_pre1997_years))
names(.nhis_pre1997_results) <- .nhis_pre1997_years

for (.y in .nhis_pre1997_years) {
  cat(sprintf("Building NHIS pre-1997 crosswalk for %s...\n", .y))
  .nhis_pre1997_results[[.y]] <- build_year_crosswalk(.y)
  .r <- .nhis_pre1997_results[[.y]]
  cat(sprintf("  Household: %d/%d matched | Person: %d/%d matched\n",
              attr(.r, "hh_matched"), attr(.r, "hh_total"),
              attr(.r, "px_matched"), attr(.r, "px_total")))
}

.nhis_pre1997_crosswalk <- do.call(rbind, .nhis_pre1997_results)
rownames(.nhis_pre1997_crosswalk) <- NULL
cat(sprintf("\nNHIS pre-1997 crosswalk: %d rows across %d years (%d unmatched)\n",
            nrow(.nhis_pre1997_crosswalk), length(.nhis_pre1997_years),
            sum(is.na(.nhis_pre1997_crosswalk$label))))

rm(.y, .r, .nhis_pre1997_years, .nhis_pre1997_results)
