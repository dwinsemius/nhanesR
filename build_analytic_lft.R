library(nhanesR)

# ── Download ALT (LBXSATSI) — 8 cycles, 2003–2018 ────────────────────────────
cat("Downloading ALT...\n")
alt_cycles <- c("2003-2004","2005-2006","2007-2008","2009-2010",
                "2011-2012","2013-2014","2015-2016","2017-2018")
alt_raw <- nhanes_download_analyte("alanine", cycles = alt_cycles,
                                   component = "Laboratory")
alt_df <- do.call(rbind, lapply(alt_raw, function(df) {
  data.frame(SEQN = as.character(df$SEQN), ALT = df$LBXSATSI,
             stringsAsFactors = FALSE)
}))
cat("ALT rows:", nrow(alt_df), " non-missing:", sum(!is.na(alt_df$ALT)), "\n")

# ── Download AST (LBXSASSI) — 7 cycles; 2007-2008 absent from CDC catalog ────
cat("Downloading AST...\n")
ast_cycles <- c("2003-2004","2005-2006","2009-2010","2011-2012",
                "2013-2014","2015-2016","2017-2018")
ast_raw <- nhanes_download_analyte("aspartate", cycles = ast_cycles,
                                   component = "Laboratory")
ast_df <- do.call(rbind, lapply(ast_raw, function(df) {
  data.frame(SEQN = as.character(df$SEQN), AST = df$LBXSASSI,
             stringsAsFactors = FALSE)
}))
cat("AST rows:", nrow(ast_df), " non-missing:", sum(!is.na(ast_df$AST)), "\n")

# ── Download ALP — 5 cycles; 2005–2012 absent (CDC stopped reporting) ─────────
# Variable name changed: LBDSAPSI (2001-2002) → LBXSAPSI (2003+ )
cat("Downloading ALP...\n")
alp_cycles <- c("2001-2002","2003-2004","2013-2014","2015-2016","2017-2018")
alp_raw <- nhanes_download_analyte("alkaline phosphatase", cycles = alp_cycles,
                                   component = "Laboratory")
alp_df <- do.call(rbind, lapply(alp_raw, function(df) {
  v <- intersect(c("LBXSAPSI","LBDSAPSI"), names(df))
  data.frame(SEQN = as.character(df$SEQN), ALP = df[[v[1]]],
             stringsAsFactors = FALSE)
}))
cat("ALP rows:", nrow(alp_df), " non-missing:", sum(!is.na(alp_df$ALP)), "\n")

# ── Merge into analytic_survival.rds ─────────────────────────────────────────
base <- readRDS("analytic_survival.rds")
base$SEQN <- as.character(base$SEQN)

# Drop any existing columns (idempotent re-run)
base <- base[, setdiff(names(base), c("ALT","AST","ALP"))]

base <- merge(base, alt_df, by = "SEQN", all.x = TRUE)
base <- merge(base, ast_df, by = "SEQN", all.x = TRUE)
base <- merge(base, alp_df, by = "SEQN", all.x = TRUE)

cat("\nCoverage after merge (non-missing / total rows):\n")
cat("  ALT:", sum(!is.na(base$ALT)), "/", nrow(base), "\n")
cat("  AST:", sum(!is.na(base$AST)), "/", nrow(base), "\n")
cat("  ALP:", sum(!is.na(base$ALP)), "/", nrow(base), "\n")

cat("\nCycles with ALT data:\n")
print(sort(table(base$cycle[!is.na(base$ALT)])))
cat("\nCycles with ALP data:\n")
print(sort(table(base$cycle[!is.na(base$ALP)])))

saveRDS(base, "analytic_survival.rds")
cat("\nSaved analytic_survival.rds:", nrow(base), "rows x", ncol(base), "cols\n")
