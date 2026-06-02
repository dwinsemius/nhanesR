# R/zzz.R
# Package load hook for nhanesR
# Cache directory management lives in nhanes_cache.R
# HTTP helpers live in nhanes_http.R

# Suppress R CMD CHECK "no visible binding" notes for internal sysdata objects.
utils::globalVariables(c(
  ".nhanes_cycles", ".nhanes_iii",
  ".lmf_registry",  ".lmf_colspec", ".ucod_labels",
  ".early_biopro_catalog"
))

#' @keywords internal
.onLoad <- function(libname, pkgname) {
  op <- options()
  op_nhanesR <- list(
    nhanesR.cache_dir = .nhanes_rappdirs_user_data("nhanesR"),
    nhanesR.verbose   = TRUE,
    nhanesR.timeout   = 120L
  )
  toset <- !(names(op_nhanesR) %in% names(op))
  if (any(toset)) options(op_nhanesR[toset])
  invisible()
}

# Lightweight cross-platform user data directory resolution.
# Avoids a hard dependency on the rappdirs package.
.nhanes_rappdirs_user_data <- function(appname) {
  sys <- .Platform$OS.type
  if (sys == "windows") {
    base <- Sys.getenv(
      "APPDATA",
      unset = file.path(Sys.getenv("USERPROFILE"), "AppData", "Roaming")
    )
    file.path(base, appname)
  } else if (Sys.info()[["sysname"]] == "Darwin") {
    file.path(path.expand("~"), "Library", "Application Support", appname)
  } else {
    xdg <- Sys.getenv(
      "XDG_DATA_HOME",
      unset = file.path(path.expand("~"), ".local", "share")
    )
    file.path(xdg, appname)
  }
}
