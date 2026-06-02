library(nhanesR)
library(haven)

# ── Early cycles: 1999-2000 (Lab18) and 2001-2002 (L40_B) ────────────────────
# LBXSGTSI, LBXSATSI, LBXSASSI, LBXSAPSI/LBDSAPSI are present in these files
# but absent from the CDC online variable catalog, so nhanes_variable_map() and
# nhanes_download_analyte() cannot find them. Download directly via XPT URL.
# 1999-2000: suffix is empty; 2001-2002: file already contains the _B suffix so
# the nhanesR URL builder would produce L40_B_B.xpt (404) — must use raw URL.

cat("Downloading early cycles (Lab18, L40_B) directly...\n")
lab18 <- read_xpt(url(
  "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/1999/DataFiles/Lab18.xpt"))
l40b  <- read_xpt(url(
  "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2001/DataFiles/L40_B.xpt"))

early_df <- rbind(
  data.frame(SEQN = as.character(lab18$SEQN),
             GGT  = lab18$LBXSGTSI,
             ALT  = lab18$LBXSATSI,
             AST  = lab18$LBXSASSI,
             ALP  = lab18$LBXSAPSI,
             stringsAsFactors = FALSE),
  data.frame(SEQN = as.character(l40b$SEQN),
             GGT  = l40b$LBXSGTSI,
             ALT  = l40b$LBXSATSI,
             AST  = l40b$LBXSASSI,
             ALP  = l40b$LBDSAPSI,
             stringsAsFactors = FALSE)
)
cat("Early rows:", nrow(early_df),
    " GGT non-NA:", sum(!is.na(early_df$GGT)), "\n")

# ── Download GGT (LBXSGTSI) — 2003–2018 via catalog ─────────────────────────
cat("Downloading GGT (2003-2018)...\n")
ggt_cycles <- c("2003-2004","2005-2006","2007-2008","2009-2010",
                "2011-2012","2013-2014","2015-2016","2017-2018")
ggt_raw <- nhanes_download_analyte("glutamyl", cycles = ggt_cycles,
                                   component = "Laboratory")
ggt_df <- do.call(rbind, lapply(ggt_raw, function(df) {
  data.frame(SEQN = as.character(df$SEQN), GGT = df$LBXSGTSI,
             stringsAsFactors = FALSE)
}))

# ── Download ALT (LBXSATSI) — 2003–2018 ─────────────────────────────────────
cat("Downloading ALT (2003-2018)...\n")
alt_cycles <- c("2003-2004","2005-2006","2007-2008","2009-2010",
                "2011-2012","2013-2014","2015-2016","2017-2018")
alt_raw <- nhanes_download_analyte("alanine", cycles = alt_cycles,
                                   component = "Laboratory")
alt_df <- do.call(rbind, lapply(alt_raw, function(df) {
  data.frame(SEQN = as.character(df$SEQN), ALT = df$LBXSATSI,
             stringsAsFactors = FALSE)
}))

# ── Download AST (LBXSASSI) — 7 cycles; 2007-2008 absent from CDC catalog ────
cat("Downloading AST (2003-2018 excl. 2007-2008)...\n")
ast_cycles <- c("2003-2004","2005-2006","2009-2010","2011-2012",
                "2013-2014","2015-2016","2017-2018")
ast_raw <- nhanes_download_analyte("aspartate", cycles = ast_cycles,
                                   component = "Laboratory")
ast_df <- do.call(rbind, lapply(ast_raw, function(df) {
  data.frame(SEQN = as.character(df$SEQN), AST = df$LBXSASSI,
             stringsAsFactors = FALSE)
}))

# ── Download ALP — 2003–2004 + 2013–2018; gap 2005–2012 (CDC stopped) ────────
# 2001-2002 covered in early_df above
cat("Downloading ALP (2003-2004, 2013-2018)...\n")
alp_cycles <- c("2003-2004","2013-2014","2015-2016","2017-2018")
alp_raw <- nhanes_download_analyte("alkaline phosphatase", cycles = alp_cycles,
                                   component = "Laboratory")
alp_df <- do.call(rbind, lapply(alp_raw, function(df) {
  v <- intersect(c("LBXSAPSI","LBDSAPSI"), names(df))
  data.frame(SEQN = as.character(df$SEQN), ALP = df[[v[1]]],
             stringsAsFactors = FALSE)
}))

# ── Combine early + catalog rows ─────────────────────────────────────────────
ggt_all <- rbind(early_df[, c("SEQN","GGT")], ggt_df)
alt_all <- rbind(early_df[, c("SEQN","ALT")], alt_df)
ast_all <- rbind(early_df[, c("SEQN","AST")], ast_df)
alp_all <- rbind(early_df[, c("SEQN","ALP")], alp_df)

# ── Merge into analytic_survival.rds ─────────────────────────────────────────
base <- readRDS("analytic_survival.rds")
base$SEQN <- as.character(base$SEQN)

# Drop any existing columns (idempotent re-run)
base <- base[, setdiff(names(base), c("GGT","ALT","AST","ALP"))]

base <- merge(base, ggt_all, by = "SEQN", all.x = TRUE)
base <- merge(base, alt_all, by = "SEQN", all.x = TRUE)
base <- merge(base, ast_all, by = "SEQN", all.x = TRUE)
base <- merge(base, alp_all, by = "SEQN", all.x = TRUE)

cat("\nCoverage after merge (non-missing / total rows):\n")
for (v in c("GGT","ALT","AST","ALP"))
  cat(sprintf("  %-4s %d / %d\n", v, sum(!is.na(base[[v]])), nrow(base)))

cat("\nGGT by cycle:\n")
print(sort(table(base$cycle[!is.na(base$GGT)])))

saveRDS(base, "analytic_survival.rds")
cat("\nSaved analytic_survival.rds:", nrow(base), "rows x", ncol(base), "cols\n")
