#' nhanesR: Download, Parse, and Analyze NHANES Data with Mortality Linkage
#'
#' Tools for downloading and organizing National Health and Nutrition Examination
#' Survey (NHANES) public-use data files and the National Center for Health Statistics
#' (NCHS) Public-Use Linked Mortality Files, with structured local caching, codebook
#' access, survey-aware merging, survival-analysis data preparation, NHIS download and
#' mortality linkage, and descriptive mortality-rate tabulation.
#'
#' @section Vignettes:
#' Start with `vignette("nhanesR-overview", package = "nhanesR")`. All of them are listed
#' by `browseVignettes("nhanesR")`.
#' \itemize{
#'   \item `nhanesR-overview`: Getting Started with nhanesR.
#'   \item `nhanes-mortality-workflow`: NHANES Mortality Linkage, a complete workflow.
#'   \item `nhanes-iii`: NHANES III (1988-1994), fixed-width files, cotinine and mortality.
#'   \item `analyte-harmonization`: Navigating variable name changes and analyte gaps.
#'   \item `uacr-bridging`: Urinary albumin-to-creatinine ratio across NHANES cycles.
#'   \item `survey-weighted-survival`: Survey-weighted survival analysis, fusing `svycoxph`
#'     and `rms`.
#'   \item `survival-framework-comparison`: Comparing Cox, piecewise-exponential and
#'     mgcv-Poisson survival frameworks.
#' }
#' Vignettes are built when the package is installed from a built tarball (for example
#' `R CMD build` then `R CMD INSTALL`, or `devtools::install(build_vignettes = TRUE)`); an
#' install straight from the source directory leaves them out.
#'
#' @section Main groups of functions:
#' \itemize{
#'   \item Discovery: [nhanes_cycles()], [nhanes_manifest()], [nhanes_search_variables()],
#'     [nhanes_variable_map()].
#'   \item Download, harmonize, stack and merge: [nhanes_download()],
#'     [nhanes_download_analyte()], [nhanes_harmonize()], [nhanes_stack()], [nhanes_merge()].
#'   \item Mortality linkage: [nhanes_mortality_download()], [nhanes_mortality_parse()],
#'     [nhanes_mortality_link()], and the NHIS counterparts [nhis_download()] and
#'     [nhis_mortality_link()].
#'   \item Survival preparation and summaries: [nhanes_survival_prep()],
#'     [nhanes_followup_summary()], [nhanes_ucod_labels()].
#'   \item Survey-weighted Cox models: [svycph_fuse()], [weighted_basehaz()],
#'     [svycph_set_basehaz()].
#'   \item Descriptive rates: [mortality_tabulation()], [tabulation_grid()].
#' }
#'
#' @seealso Useful links: <https://dwinsemius.github.io/nhanesR/> and
#'   <https://github.com/dwinsemius/nhanesR>.
#' @keywords internal
"_PACKAGE"
