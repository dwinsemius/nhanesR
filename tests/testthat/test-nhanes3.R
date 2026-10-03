# tests/testthat/test-nhanes3.R  (offline: a tiny synthetic file in the real .sas format)

make_nh3_fixture <- function() {
  dir <- tempfile("nh3"); dir.create(dir)
  sas <- file.path(dir, "demo.sas")
  writeLines(c(
    '    FILENAME DEMO "D:\\DEMO.DAT" LRECL=19;',
    '    *** LRECL includes 2 positions for CRLF, assuming use of PC SAS;',
    '',
    '    DATA WORK;',
    '      INFILE DEMO MISSOVER;',
    '',
    '      LENGTH',
    '        SEQN      5',
    '        HSSEX     3',
    '      ;',
    '',
    '      INPUT',
    '        SEQN      1-5',
    '        HSSEX     6',
    '        HSAGEIR   7-8',
    '        BMPWT     9-13',
    '        NAME      $ 14-17',
    '      ;',
    '',
    '      LABEL',
    '        SEQN     = "Sequence number"',
    '        HSSEX    = "Sex"',
    '        HSAGEIR  = "Age at interview (screener)"',
    '        BMPWT    = "Weight (kg)"',
    '        NAME     = "A character column"',
    '      ;',
    '    RUN;'), sas)
  dat <- file.path(dir, "demo.dat")
  # SEQN(1-5) HSSEX(6) HSAGEIR(7-8) BMPWT(9-13) NAME(14-17)
  writeLines(c("0000113407250ABCD",      # id 1, sex 1, age 34, weight 7250, ABCD
               "0000226588888EFGH",      # id 2, sex 2, age 65, weight 88888 = blank but applicable
               "0000319099999IJKL"),     # id 3, sex 1, age 90, weight 99999 = don't know
             dat)
  list(dir = dir, sas = sas, dat = dat)
}

test_that("nhanes3_files lists the files and CDC addresses", {
  f <- nhanes3_files()
  expect_true(all(c("exam", "adult", "youth", "lab", "lab2") %in% f$file))
  expect_equal(f$sas_url[f$file == "lab2"], "https://wwwn.cdc.gov/nchs/data/nhanes3/2a/lab2.sas")
  expect_equal(f$dat_url[f$file == "exam"], "https://wwwn.cdc.gov/nchs/data/nhanes3/1a/exam.dat")
  expect_equal(f$codebook_url[f$file == "adult"], "https://wwwn.cdc.gov/nchs/data/nhanes3/1a/adult-acc.pdf")
})

test_that("nhanes3_layout parses positions, labels and types, and checks the record length", {
  fx <- make_nh3_fixture()
  L <- nhanes3_layout(fx$sas)
  expect_s3_class(L, "nhanes3_layout")
  expect_equal(L$var, c("SEQN", "HSSEX", "HSAGEIR", "BMPWT", "NAME"))
  expect_equal(L$start, c(1L, 6L, 7L, 9L, 14L)); expect_equal(L$end, c(5L, 6L, 8L, 13L, 17L))
  expect_equal(L$width, c(5L, 1L, 2L, 5L, 4L))
  expect_equal(L$type, c("numeric", "numeric", "numeric", "numeric", "character"))
  expect_equal(L$label[L$var == "HSAGEIR"], "Age at interview (screener)")
  expect_equal(attr(L, "lrecl"), 19L)
  # a layout that does not cover the record is refused
  bad <- file.path(fx$dir, "bad.sas")
  writeLines(sub("LRECL=19", "LRECL=25", readLines(fx$sas)), bad)
  expect_error(nhanes3_layout(bad), "does not cover the whole record")
})

test_that("a ';' at the end of the last LABEL line and a DOS end-of-file mark are handled (as in the adult file)", {
  fx <- make_nh3_fixture()
  s <- readLines(fx$sas)
  i <- grep('NAME     = "A character column"', s, fixed = TRUE)
  s[i] <- paste0(s[i], ";")
  s <- s[-(i + 1L)]                                      # the lone ';' that used to close the block
  odd <- file.path(fx$dir, "odd.sas")
  writeLines(c(s, "", "\032"), odd)
  L <- nhanes3_layout(odd)
  expect_equal(L$var, c("SEQN", "HSSEX", "HSAGEIR", "BMPWT", "NAME"))
  expect_equal(L$label[L$var == "NAME"], "A character column")          # not lost, no stray ';'
  expect_false(anyNA(L$label))
})

test_that("pattern keeps variables whose name or label matches", {
  fx <- make_nh3_fixture()
  expect_equal(nhanes3_layout(fx$sas, pattern = "^BMP")$var, "BMPWT")                   # by name
  expect_equal(nhanes3_layout(fx$sas, pattern = "weight")$var, "BMPWT")                  # by label, any case
  expect_equal(nhanes3_layout(fx$sas, pattern = "age|sex")$var, c("HSSEX", "HSAGEIR"))
  expect_equal(nrow(nhanes3_layout(fx$sas, pattern = "zzz")), 0L)
  expect_output(print(nhanes3_layout(fx$sas)), "5 variables")
})

test_that("nhanes3_read reads only the chosen columns, adds SEQN, and keeps widths and labels", {
  fx <- make_nh3_fixture()
  x <- nhanes3_read(fx$sas, vars = c("BMPWT", "NAME"), dat_file = fx$dat)
  expect_equal(names(x), c("SEQN", "BMPWT", "NAME"))                       # the ID comes first, uninvited
  expect_equal(x$SEQN, c(1, 2, 3)); expect_equal(x$BMPWT, c(7250, 88888, 99999))
  expect_equal(x$NAME, c("ABCD", "EFGH", "IJKL")); expect_type(x$NAME, "character")
  expect_equal(attr(x, "width"), c(SEQN = 5, BMPWT = 5, NAME = 4))
  expect_equal(attr(x, "var_labels")[["BMPWT"]], "Weight (kg)")
  expect_equal(names(nhanes3_read(fx$sas, vars = "BMPWT", dat_file = fx$dat, id = NULL)), "BMPWT")
  expect_equal(nrow(nhanes3_read(fx$sas, vars = "BMPWT", dat_file = fx$dat, n_max = 2)), 2L)
})

test_that("recode turns all-8s and all-9s of the field's width into NA, only where asked", {
  fx <- make_nh3_fixture()
  x <- suppressMessages(nhanes3_read(fx$sas, vars = c("HSAGEIR", "BMPWT"), recode = "BMPWT", dat_file = fx$dat))
  expect_equal(x$BMPWT, c(7250, NA, NA))
  expect_equal(x$HSAGEIR, c(34, 65, 90))                                  # not recoded: nobody asked
  expect_false(anyNA(x$HSAGEIR))
  expect_message(nhanes3_read(fx$sas, vars = "BMPWT", recode = "BMPWT", dat_file = fx$dat), "set to NA")
})

test_that("bad requests fail with a clear message", {
  fx <- make_nh3_fixture()
  expect_error(nhanes3_read(fx$sas, vars = "NOPE", dat_file = fx$dat), "Not in the layout")
  expect_error(nhanes3_read(fx$sas, dat_file = fx$dat), "vars.*required")            # not interactive
  expect_error(nhanes3_read(fx$sas, vars = "BMPWT", recode = "HSSEX", dat_file = fx$dat), "not being read")
  expect_error(nhanes3_read(fx$sas, vars = "NAME", recode = "NAME", dat_file = fx$dat), "character")
  expect_error(nhanes3_read(fx$sas, vars = "BMPWT"), "dat_file")                      # a custom .sas needs its .dat
  expect_error(nhanes3_read(fx$sas, vars = "BMPWT", dat_file = file.path(fx$dir, "missing.dat")), "not found")
  expect_error(nhanes3_layout("nope"), "not a known NHANES III file")
})

test_that("nhanes3_download uses the cache and does not touch the network when files are present", {
  tmp <- tempfile("cache"); dir.create(tmp)
  old <- options(nhanesR.cache_dir = tmp, nhanesR.verbose = FALSE); on.exit(options(old), add = TRUE)
  d <- file.path(tmp, "nhanes3"); dir.create(d, recursive = TRUE)
  for (f in c("adult.sas", "adult.dat", "adult-acc.pdf")) writeLines("x", file.path(d, f))
  p <- nhanes3_download("adult")
  expect_named(p, c("sas", "dat", "codebook"))
  expect_true(all(file.exists(p)))
  expect_equal(basename(p[["codebook"]]), "adult-acc.pdf")
  expect_equal(unname(nhanes3_download("adult", what = "sas")), file.path(d, "adult.sas"))
})
