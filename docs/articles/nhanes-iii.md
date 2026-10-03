# NHANES III (1988-1994): Fixed-Width Files, Cotinine, and Mortality

## Overview

NHANES III (1988-1994) predates the continuous survey. Its public-use
data are not per-cycle XPT files but a few large fixed-width `.dat`
files, each with a SAS program (`.sas`) giving the column positions.
`nhanesR` handles the NHANES III **mortality** file directly
(`nhanes_mortality_parse(cycles = "1988-1994")`); this vignette shows
how to read the survey files themselves and link them.

The example builds an adult analysis file with measured height, weight
and waist, cigarette smoking status checked against serum cotinine, and
mortality follow-up through 2019. NHANES III is worth the extra work for
survival analysis: participants have a median of about 27 years of
follow-up.

**None of the code chunks run automatically.** The exam file alone is
about 195 MB.

A complete, runnable version of this workflow (download, parse, recode,
link mortality, save an `.rds`) ships with the package:
`system.file("scripts", "assemble_nhanes3_data.R", package = "nhanesR")`.
Copy it to a working directory and run it there; it caches the raw files
in `./nhanes3_raw/` and writes `nhanes3_pooled.rds`.

## 1. Download the files

The main files are in `nhanes3/1a/`. Serum cotinine is in the *second*
laboratory file, `nhanes3/2a/lab2.dat`. The main `lab.dat` has a `COP`
column, but it is blank for every record.

`raw`` ``<-`` `[`file.path`](https://rdrr.io/r/base/file.path.html)`(`[`tempdir`](https://rdrr.io/r/base/tempfile.html)`(``)``, ``"nhanes3"``)`` `[`dir.create`](https://rdrr.io/r/base/files2.html)`(``raw``, showWarnings ``=`` ``FALSE``)`` `[`options`](https://rdrr.io/r/base/options.html)`(``timeout ``=`` ``900``)`` ``# default 60 s is too short`` `` ``base`` ``<-`` ``"https://wwwn.cdc.gov/nchs/data/nhanes3/"`` ``files`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``"1a/exam.dat"``, ``"1a/exam.sas"``, ``"1a/exam-acc.pdf"``,`` `` ``"1a/adult.dat"``, ``"1a/adult.sas"``, ``"1a/adult-acc.pdf"``,`` `` ``"2a/lab2.dat"``, ``"2a/lab2.sas"``, ``"2a/lab2-acc.pdf"``)`` ``for`` ``(``f`` ``in`` ``files``)`` ``{`` `` ``dest`` ``<-`` `[`file.path`](https://rdrr.io/r/base/file.path.html)`(``raw``, `[`basename`](https://rdrr.io/r/base/basename.html)`(``f``)``)`` `` ``if`` ``(``!`[`file.exists`](https://rdrr.io/r/base/files.html)`(``dest``)``)`` `[`download.file`](https://rdrr.io/r/utils/download.file.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``base``, ``f``)``, ``dest``, mode ``=`` ``"wb"``)`` ``}`

Each data file has a codebook alongside it, named `<file>-acc.pdf` (for
example `1a/exam-acc.pdf`). The codebooks list value labels and
missing-value codes; section 5 shows how to pull entries out of them.

## 2. Read column positions from the SAS program

Each `.sas` file has an `INPUT` block of lines like `SEQN 1-5` or
`HSSEX 15`. The helper below parses that block and checks it against the
record length (`LRECL`, which counts 2 bytes for the line ending).
[`SAScii::parse.SAScii()`](https://rdrr.io/pkg/SAScii/man/parse.SAScii.html)
produces the same layout.

`sas_layout`` ``<-`` ``function``(``sas_file``)`` ``{`` `` ``s`` ``<-`` `[`readLines`](https://rdrr.io/r/base/readLines.html)`(``sas_file``, warn ``=`` ``FALSE``)`` `` ``lrecl`` ``<-`` `[`as.integer`](https://rdrr.io/r/base/integer.html)`(`[`sub`](https://rdrr.io/r/base/grep.html)`(``".*LRECL\\s*=\\s*([0-9]+).*"``, ``"\\1"``,`` `` `[`grep`](https://rdrr.io/r/base/grep.html)`(``"LRECL\\s*="``, ``s``, value ``=`` ``TRUE``)``[``1``]``)``)`` `` ``s`` ``<-`` ``s``[``(`[`grep`](https://rdrr.io/r/base/grep.html)`(``"^\\s*INPUT\\s*$"``, ``s``)``[``1``]`` ``+`` ``1``)``:`[`length`](https://rdrr.io/r/base/length.html)`(``s``)``]`` `` ``s`` ``<-`` ``s``[`[`seq_len`](https://rdrr.io/r/base/seq.html)`(`[`grep`](https://rdrr.io/r/base/grep.html)`(``"^\\s*;\\s*$"``, ``s``)``[``1``]`` ``-`` ``1``)``]`` `` ``m`` ``<-`` `[`regmatches`](https://rdrr.io/r/base/regmatches.html)`(``s``, `[`regexec`](https://rdrr.io/r/base/grep.html)`(`` `` ``"^\\s*([A-Z][A-Z0-9_]*)\\s+\\$?\\s*([0-9]+)(-([0-9]+))?\\s*$"``, ``s``)``)`` `` ``m`` ``<-`` ``m``[`[`lengths`](https://rdrr.io/r/base/lengths.html)`(``m``)`` ``==`` ``5``]`` `` ``L`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(``var ``=`` `[`vapply`](https://rdrr.io/r/base/lapply.html)`(``m``, ``` `[` ```, ``""``, ``2``)``,`` `` start ``=`` `[`as.integer`](https://rdrr.io/r/base/integer.html)`(`[`vapply`](https://rdrr.io/r/base/lapply.html)`(``m``, ``` `[` ```, ``""``, ``3``)``)``)`` `` ``end`` ``<-`` `[`vapply`](https://rdrr.io/r/base/lapply.html)`(``m``, ``` `[` ```, ``""``, ``5``)`` `` ``L``$``end`` ``<-`` `[`ifelse`](https://rdrr.io/r/base/ifelse.html)`(`[`nzchar`](https://rdrr.io/r/base/nchar.html)`(``end``)``, `[`as.integer`](https://rdrr.io/r/base/integer.html)`(``end``)``, ``L``$``start``)`` `` `[`stopifnot`](https://rdrr.io/r/base/stopifnot.html)`(`[`max`](https://rdrr.io/r/base/Extremes.html)`(``L``$``end``)`` ``==`` ``lrecl`` ``-`` ``2``)`` `` ``L`` ``}`

## 3. Read only the columns you need

The exam file has more than 2,000 columns. Reading a handful by position
is fast; reading all of them is not.

`read_nh3`` ``<-`` ``function``(``stem``, ``vars``)`` ``{`` `` ``L`` ``<-`` ``sas_layout``(`[`file.path`](https://rdrr.io/r/base/file.path.html)`(``raw``, `[`paste0`](https://rdrr.io/r/base/paste.html)`(``stem``, ``".sas"``)``)``)`` `` `[`stopifnot`](https://rdrr.io/r/base/stopifnot.html)`(`[`all`](https://rdrr.io/r/base/all.html)`(``vars`` `[`%in%`](https://rdrr.io/r/base/match.html)` ``L``$``var``)``)`` `` ``L`` ``<-`` ``L``[`[`match`](https://rdrr.io/r/base/match.html)`(``vars``, ``L``$``var``)``, ``]`` `` ``x`` ``<-`` ``readr``::`[`read_fwf`](https://readr.tidyverse.org/reference/read_fwf.html)`(`[`file.path`](https://rdrr.io/r/base/file.path.html)`(``raw``, `[`paste0`](https://rdrr.io/r/base/paste.html)`(``stem``, ``".dat"``)``)``,`` `` ``readr``::`[`fwf_positions`](https://readr.tidyverse.org/reference/read_fwf.html)`(``L``$``start``, ``L``$``end``, ``L``$``var``)``,`` `` col_types ``=`` ``readr``::`[`cols`](https://readr.tidyverse.org/reference/cols.html)`(``.default ``=`` ``"d"``)``)`` `` `[`attr`](https://rdrr.io/r/base/attr.html)`(``x``, ``"width"``)`` ``<-`` `[`setNames`](https://rdrr.io/r/stats/setNames.html)`(``L``$``end`` ``-`` ``L``$``start`` ``+`` ``1``, ``L``$``var``)`` `` ``x`` ``}`` `` ``exam`` ``<-`` ``read_nh3``(``"exam"``, `[`c`](https://rdrr.io/r/base/c.html)`(``"SEQN"``, ``"HSSEX"``, ``"HSAGEIR"``, ``"DMARETHN"``,`` `` ``"BMPHT"``, ``"BMPWT"``, ``"BMPBMI"``, ``"BMPWAIST"``,`` `` ``"WTPFEX6"``, ``"SDPPSU6"``, ``"SDPSTRA6"``)``)`` ``adult`` ``<-`` ``read_nh3``(``"adult"``, `[`c`](https://rdrr.io/r/base/c.html)`(``"SEQN"``, ``"HAR1"``, ``"HAR3"``, ``"HAR16"``, ``"HAR24"``, ``"HAR27"``)``)`` ``lab2`` ``<-`` ``read_nh3``(``"lab2"``, `[`c`](https://rdrr.io/r/base/c.html)`(``"SEQN"``, ``"COP"``)``)`

Use the 6-year weights (`WTPFEX6`, `SDPPSU6`, `SDPSTRA6`) for the whole
survey. The `*1` and `*2` versions cover phase 1 (1988-1991) or phase 2
(1991-1994) alone.

### The same steps with the package functions

The helper code above is what `nhanesR` provides as functions, with
variable labels and a search added. You can stop after the layout, which
needs only the small `.sas` program, and decide which columns to read
before you download the large `.dat` file:

[`nhanes3_files`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_files.md)`(``)`` ``# the files and their CDC addresses`` `[`nhanes3_layout`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_layout.md)`(``"adult"``, pattern ``=`` ``"tall|weigh"``)`` ``# variables whose name or label matches`` `[`nhanes3_layout`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_layout.md)`(``"exam"``, pattern ``=`` ``"^BMP"``)`` ``# the body-measure variables, with labels`` `` ``x`` ``<-`` `[`nhanes3_read`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_read.md)`(``"exam"``, `[`c`](https://rdrr.io/r/base/c.html)`(``"HSSEX"``, ``"HSAGEIR"``, ``"BMPHT"``, ``"BMPWT"``, ``"WTPFEX6"``)``,`` `` recode ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"BMPHT"``, ``"BMPWT"``)``)`` ``# SEQN is always included`` `[`attr`](https://rdrr.io/r/base/attr.html)`(``x``, ``"var_labels"``)`` ``# the SAS labels travel with the data`

In an interactive session, leave `vars` out and
[`nhanes3_read()`](https://dwinsemius.github.io/nhanesR/reference/nhanes3_read.md)
offers the (optionally `pattern`-narrowed) list to pick from. `recode`
applies only to the variables you name, because IDs, weights and age
have no all-8s/all-9s codes and many items have special codes of their
own (section 5).

## 4. Missing-value codes

NHANES III stores “blank but applicable” as all 8s and “don’t know” as
all 9s, sized to the field: `8`/`9` for a one-character item, `88888`
for a five-character measurement. Left in place they look like real
values: an 88888 cotinine code makes the mean serum cotinine about
10,000 ng/mL.

`recode_codes`` ``<-`` ``function``(``x``, ``vars``)`` ``{`` `` ``w`` ``<-`` `[`attr`](https://rdrr.io/r/base/attr.html)`(``x``, ``"width"``)`` `` ``for`` ``(``v`` ``in`` ``vars``)`` ``{`` `` ``codes`` ``<-`` `[`as.numeric`](https://rdrr.io/r/base/numeric.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(`[`strrep`](https://rdrr.io/r/base/strrep.html)`(``"8"``, ``w``[[``v``]``]``)``, `[`strrep`](https://rdrr.io/r/base/strrep.html)`(``"9"``, ``w``[[``v``]``]``)``)``)`` `` ``x``[[``v``]``]``[``x``[[``v``]``]`` `[`%in%`](https://rdrr.io/r/base/match.html)` ``codes``]`` ``<-`` ``NA`` `` ``}`` `` ``x`` ``}`` ``exam`` ``<-`` ``recode_codes``(``exam``, `[`c`](https://rdrr.io/r/base/c.html)`(``"BMPHT"``, ``"BMPWT"``, ``"BMPBMI"``, ``"BMPWAIST"``)``)`` ``adult`` ``<-`` ``recode_codes``(``adult``, `[`c`](https://rdrr.io/r/base/c.html)`(``"HAR1"``, ``"HAR3"``, ``"HAR16"``, ``"HAR24"``, ``"HAR27"``)``)`` ``lab2`` ``<-`` ``recode_codes``(``lab2``, ``"COP"``)`

Check each variable’s codebook entry before applying this rule to it
(next section). Age (`HSAGEIR`) is top-coded at 90 and has no such
codes.

Missing serum cotinine is mostly missing *labs*, not a missing assay:
children under 4 were not eligible, and most people coded 88888 have no
serum results at all.

## 5. Look up variables in the codebook

The all-8s/all-9s rule is not the whole story. Many items have their own
special codes, and their width varies: cigarettes per day (`HAR4S`) uses
666 for “varies” and 777 for “less than 1 per day”; cigars per day
(`HAR25`) uses 77; cigarettes per day at the heaviest (`HAR7S`) uses
6666; age started smoking (`HAR2`) uses 000 for “never”. Left in place,
a 777 reads as 777 cigarettes a day.

The codebook PDFs are plain fixed-width text, one entry per variable:

              1336           Is your home drinking water bottled or
      HFE4                   from the tap (faucet)?
                      2443   1     Bottled (HFE7)
                        88   8     Blank but applicable

The helpers below (they need the `pdftools` package) return each
requested variable’s file position, question text, interviewer notes,
and a table of codes, labels and counts. Counts are for the whole file,
so they also show how many records each special code affects.

`if`` ``(``!`[`requireNamespace`](https://rdrr.io/r/base/ns-load.html)`(``"pdftools"``, quietly ``=`` ``TRUE``)``)`` `[`install.packages`](https://rdrr.io/r/utils/install.packages.html)`(``"pdftools"``)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`pdftools`](https://ropensci.r-universe.dev/pdftools)`)`` `` ``nh3_codebook_lines`` ``<-`` ``function``(``pdf``)`` ``{`` `` `[`unlist`](https://rdrr.io/r/base/unlist.html)`(`[`lapply`](https://rdrr.io/r/base/lapply.html)`(``pdftools``::`[`pdf_text`](https://docs.ropensci.org/pdftools//reference/pdftools.html)`(``pdf``)``, ``function``(``p``)`` ``{`` `` ``L`` ``<-`` `[`strsplit`](https://rdrr.io/r/base/strsplit.html)`(``p``, ``"\n"``, fixed ``=`` ``TRUE``)``[[``1``]``]`` `` ``h`` ``<-`` `[`grep`](https://rdrr.io/r/base/grep.html)`(``"^SAS name\\s+Counts"``, ``L``)`` ``# page header ends here`` `` ``if`` ``(`[`length`](https://rdrr.io/r/base/length.html)`(``h``)``)`` ``L`` ``<-`` ``L``[``-`[`seq_len`](https://rdrr.io/r/base/seq.html)`(``h``[``1``]`` ``+`` ``1``)``]`` `` ``L`` `` ``}``)``, use.names ``=`` ``FALSE``)`` ``}`` `` ``nh3_codebook`` ``<-`` ``function``(``pdf``, ``vars``, ``lines`` ``=`` ``nh3_codebook_lines``(``pdf``)``)`` ``{`` `` ``blank`` ``<-`` ``!`[`nzchar`](https://rdrr.io/r/base/nchar.html)`(`[`trimws`](https://rdrr.io/r/base/trimws.html)`(``lines``)``)`` `` ``is_val`` ``<-`` ``function``(``x``)`` `[`grepl`](https://rdrr.io/r/base/grep.html)`(``"^\\s*[0-9][0-9,]*\\s+\\S"``, ``x``)`` `` ``out`` ``<-`` `[`lapply`](https://rdrr.io/r/base/lapply.html)`(``vars``, ``function``(``v``)`` ``{`` `` ``i`` ``<-`` `[`grep`](https://rdrr.io/r/base/grep.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``"^\\s{0,8}"``, ``v``, ``"(\\s|$)"``)``, ``lines``)``[``1``]`` `` ``if`` ``(`[`is.na`](https://rdrr.io/r/base/NA.html)`(``i``)``)`` `[`return`](https://rdrr.io/r/base/function.html)`(``NULL``)`` `` ``## The entry ends at the first blank line after the value rows start`` `` ``## (earlier blank lines separate the question from interviewer notes),`` `` ``## or just before the next entry's position + name lines.`` `` ``end`` ``<-`` ``i``; ``seen`` ``<-`` ``FALSE``; ``k`` ``<-`` ``i`` ``+`` ``1`` `` ``while`` ``(``k`` ``<=`` `[`length`](https://rdrr.io/r/base/length.html)`(``lines``)``)`` ``{`` `` ``if`` ``(`[`grepl`](https://rdrr.io/r/base/grep.html)`(``"^\\s{0,8}[A-Z][A-Z0-9_]*(\\s|$)"``, ``lines``[``k``]``)`` ``&&`` ``k`` ``>`` ``i`` ``+`` ``1`` ``&&`` `` `[`grepl`](https://rdrr.io/r/base/grep.html)`(``"^\\s*[0-9]+(-[0-9]+)?\\s"``, ``lines``[``k`` ``-`` ``1``]``)``)`` ``{`` ``end`` ``<-`` ``k`` ``-`` ``2``; ``break`` ``}`` `` ``if`` ``(``blank``[``k``]``)`` ``{`` ``if`` ``(``seen``)`` ``break`` ``}`` ``else`` ``{`` ``end`` ``<-`` ``k``; ``if`` ``(``is_val``(``lines``[``k``]``)``)`` ``seen`` ``<-`` ``TRUE`` ``}`` `` ``k`` ``<-`` ``k`` ``+`` ``1`` `` ``}`` `` ``body`` ``<-`` ``if`` ``(``end`` ``>`` ``i``)`` ``lines``[``(``i`` ``+`` ``1``)``:``end``]`` ``else`` `[`character`](https://rdrr.io/r/base/character.html)`(``0``)`` `` ``first`` ``<-`` `[`which`](https://rdrr.io/r/base/which.html)`(``is_val``(``body``)``)``[``1``]`` `` ``pre`` ``<-`` ``if`` ``(``!`[`is.na`](https://rdrr.io/r/base/NA.html)`(``first``)`` ``&&`` ``first`` ``>`` ``1``)`` `[`trimws`](https://rdrr.io/r/base/trimws.html)`(``body``[`[`seq_len`](https://rdrr.io/r/base/seq.html)`(``first`` ``-`` ``1``)``]``)`` ``else`` `[`character`](https://rdrr.io/r/base/character.html)`(``0``)`` `` ``gap`` ``<-`` `[`which`](https://rdrr.io/r/base/which.html)`(``!`[`nzchar`](https://rdrr.io/r/base/nchar.html)`(``pre``)``)``[``1``]`` `` ``if`` ``(`[`is.na`](https://rdrr.io/r/base/NA.html)`(``gap``)``)`` ``gap`` ``<-`` `[`length`](https://rdrr.io/r/base/length.html)`(``pre``)`` ``+`` ``1`` `` ``desc`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(`[`sub`](https://rdrr.io/r/base/grep.html)`(``"^\\s*[0-9]+(-[0-9]+)?\\s*"``, ``""``, ``lines``[``i`` ``-`` ``1``]``)``,`` `` `[`sub`](https://rdrr.io/r/base/grep.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``"^\\s*"``, ``v``, ``"\\s*"``)``, ``""``, ``lines``[``i``]``)``, ``pre``[`[`seq_len`](https://rdrr.io/r/base/seq.html)`(``gap`` ``-`` ``1``)``]``)`` `` ``desc`` ``<-`` `[`sub`](https://rdrr.io/r/base/grep.html)`(``"\\s{2,}See note\\s*$"``, ``""``, `[`trimws`](https://rdrr.io/r/base/trimws.html)`(``desc``)``)`` `` ``notes`` ``<-`` ``pre``[`[`seq_along`](https://rdrr.io/r/base/seq.html)`(``pre``)`` ``>=`` ``gap``]`` `` ``## the name line can itself carry the first value row (" HAG17A 418 1 Yes")`` `` ``first_row`` ``<-`` `[`sub`](https://rdrr.io/r/base/grep.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``"^\\s*"``, ``v``)``, ``""``, ``lines``[``i``]``)`` `` ``if`` ``(``is_val``(``first_row``)``)`` ``{`` ``body`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``first_row``, ``body``)``; ``desc`` ``<-`` ``desc``[``-``2``]`` ``}`` `` ``m`` ``<-`` `[`regmatches`](https://rdrr.io/r/base/regmatches.html)`(``body``[``is_val``(``body``)``]``,`` `` `[`regexec`](https://rdrr.io/r/base/grep.html)`(``"^\\s*([0-9][0-9,]*)\\s+(\\S+)\\s*(.*?)\\s*$"``, ``body``[``is_val``(``body``)``]``, perl ``=`` ``TRUE``)``)`` `` ``tab`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(``count ``=`` `[`as.integer`](https://rdrr.io/r/base/integer.html)`(`[`gsub`](https://rdrr.io/r/base/grep.html)`(``","``, ``""``, `[`vapply`](https://rdrr.io/r/base/lapply.html)`(``m``, ``` `[` ```, ``""``, ``2``)``)``)``,`` `` code ``=`` `[`vapply`](https://rdrr.io/r/base/lapply.html)`(``m``, ``` `[` ```, ``""``, ``3``)``,`` `` label ``=`` `[`vapply`](https://rdrr.io/r/base/lapply.html)`(``m``, ``` `[` ```, ``""``, ``4``)``)`` `` ``b`` ``<-`` ``tab``$``code`` ``==`` ``"Blank"``; ``tab``$``label``[``b``]`` ``<-`` ``"Blank"``; ``tab``$``code``[``b``]`` ``<-`` ``""`` `` `[`list`](https://rdrr.io/r/base/list.html)`(``var ``=`` ``v``,`` `` position ``=`` `[`sub`](https://rdrr.io/r/base/grep.html)`(``"^\\s*([0-9]+(-[0-9]+)?).*$"``, ``"\\1"``, ``lines``[``i`` ``-`` ``1``]``)``,`` `` description ``=`` `[`paste`](https://rdrr.io/r/base/paste.html)`(``desc``[`[`nzchar`](https://rdrr.io/r/base/nchar.html)`(``desc``)``]``, collapse ``=`` ``" "``)``,`` `` notes ``=`` `[`paste`](https://rdrr.io/r/base/paste.html)`(``notes``[`[`nzchar`](https://rdrr.io/r/base/nchar.html)`(``notes``)``]``, collapse ``=`` ``" "``)``,`` `` values ``=`` ``tab``)`` `` ``}``)`` `` `[`names`](https://rdrr.io/r/base/names.html)`(``out``)`` ``<-`` ``vars`` `` ``if`` ``(`[`any`](https://rdrr.io/r/base/any.html)`(``lost`` ``<-`` `[`vapply`](https://rdrr.io/r/base/lapply.html)`(``out``, ``is.null``, `[`logical`](https://rdrr.io/r/base/logical.html)`(``1``)``)``)``)`` `` `[`warning`](https://rdrr.io/r/base/warning.html)`(``"not found: "``, `[`paste`](https://rdrr.io/r/base/paste.html)`(``vars``[``lost``]``, collapse ``=`` ``", "``)``)`` `` ``out``[``!``lost``]`` ``}`` `` ``## Codes made of a repeated 6, 7, 8 or 9 (666, 77, 8888 ...) -- each needs a`` ``## decision before the variable is used as a number`` ``nh3_special_codes`` ``<-`` ``function``(``cb``)`` ``{`` `` ``out`` ``<-`` `[`do.call`](https://rdrr.io/r/base/do.call.html)`(``rbind``, `[`lapply`](https://rdrr.io/r/base/lapply.html)`(``cb``, ``function``(``e``)`` ``{`` `` ``t`` ``<-`` ``e``$``values``[`[`grepl`](https://rdrr.io/r/base/grep.html)`(``"^(6+|7+|8+|9+)$"``, ``e``$``values``$``code``)``, ``]`` `` ``if`` ``(`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``t``)``)`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(``var ``=`` ``e``$``var``, ``t``, row.names ``=`` ``NULL``)`` `` ``}``)``)`` `` `[`rownames`](https://rdrr.io/r/base/colnames.html)`(``out``)`` ``<-`` ``NULL`` `` ``out`` ``}`

`cb`` ``<-`` ``nh3_codebook``(`[`file.path`](https://rdrr.io/r/base/file.path.html)`(``raw``, ``"adult-acc.pdf"``)``,`` `` `[`c`](https://rdrr.io/r/base/c.html)`(``"HAR1"``, ``"HAR3"``, ``"HAR4S"``, ``"HAR16"``, ``"HAR24"``, ``"HAR27"``)``)`` ``cb``$``HAR4S``$``values`` ``#> count code label`` ``#> 1 4656 001-140`` ``#> 2 59 666 Varies or varied`` ``#> 3 237 777 Less than 1 cigarette per day`` ``#> 4 51 888 Blank but applicable`` ``#> 5 5 999 Don't know`` ``#> 6 15042 Blank`` `` ``nh3_special_codes``(``cb``)`` ``#> var count code label`` ``#> 1 HAR1 16 8 Blank but applicable`` ``#> 2 HAR3 18 8 Blank but applicable`` ``#> 3 HAR4S 59 666 Varies or varied`` ``#> 4 HAR4S 237 777 Less than 1 cigarette per day`` ``#> 5 HAR4S 51 888 Blank but applicable`` ``#> 6 HAR4S 5 999 Don't know`` ``#> ...`

For yes/no items such as `HAR1` the table confirms the coding (1 = yes,
2 = no, 8 = blank but applicable). A wrapped question line that starts
with a number (`HAR23`: “…at least / 20 cigars in your entire life?”) is
misread as a value row, so glance at the full entry for anything
unexpected.

## 6. Smoking status, checked against cotinine

`HAR1` asks whether the person has smoked 100 or more cigarettes; only
those who say yes are asked `HAR3` (smoke now). Other tobacco items are
asked only of people who ever used that product, so a skipped item means
“no”.

`d`` ``<-`` `[`merge`](https://rdrr.io/r/base/merge.html)`(``exam``, ``adult``, by ``=`` ``"SEQN"``)`` ``# adults 17+ with an exam`` ``d`` ``<-`` `[`merge`](https://rdrr.io/r/base/merge.html)`(``d``, ``lab2``, by ``=`` ``"SEQN"``, all.x ``=`` ``TRUE``)`` `` ``d``$``cig_status`` ``<-`` `[`with`](https://rdrr.io/r/base/with.html)`(``d``, `[`ifelse`](https://rdrr.io/r/base/ifelse.html)`(``HAR1`` ``==`` ``2``, ``"Never"``,`` `` `[`ifelse`](https://rdrr.io/r/base/ifelse.html)`(``HAR1`` ``==`` ``1`` ``&`` ``HAR3`` ``==`` ``2``, ``"Former"``,`` `` `[`ifelse`](https://rdrr.io/r/base/ifelse.html)`(``HAR1`` ``==`` ``1`` ``&`` ``HAR3`` ``==`` ``1``, ``"Current"``, ``NA``)``)``)``)`` ``d``$``other_tob`` ``<-`` `[`with`](https://rdrr.io/r/base/with.html)`(``d``, ``HAR16`` `[`%in%`](https://rdrr.io/r/base/match.html)` ``1`` ``|`` ``HAR24`` `[`%in%`](https://rdrr.io/r/base/match.html)` ``1`` ``|`` ``HAR27`` `[`%in%`](https://rdrr.io/r/base/match.html)` ``1``)`` `` ``## serum cotinine > 10 ng/mL is the usual cutoff for active tobacco use`` `[`aggregate`](https://rdrr.io/r/stats/aggregate.html)`(``COP`` ``~`` ``cig_status``, data ``=`` ``d``,`` `` FUN ``=`` ``function``(``v``)`` `[`round`](https://rdrr.io/r/base/Round.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(``median ``=`` `[`median`](https://rdrr.io/r/stats/median.html)`(``v``)``, pct_over10 ``=`` ``100`` ``*`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``v`` ``>`` ``10``)``)``, ``2``)``)`

About 6% of self-reported never-smokers have cotinine above 10 ng/mL,
and about 13% of former smokers. A stricter never-smoker definition:

`d``$``never_conf`` ``<-`` `[`with`](https://rdrr.io/r/base/with.html)`(``d``, ``cig_status`` `[`%in%`](https://rdrr.io/r/base/match.html)` ``"Never"`` ``&`` ``!``other_tob`` ``&`` `` ``(`[`is.na`](https://rdrr.io/r/base/NA.html)`(``COP``)`` ``|`` ``COP`` ``<=`` ``10``)``)`

## 7. Link mortality

`nhanesR` downloads and parses the 2019 public-use Linked Mortality File
for NHANES III like any other cycle.

[`library`](https://rdrr.io/r/base/library.html)`(`[`nhanesR`](https://dwinsemius.github.io/nhanesR/)`)`` ``mort`` ``<-`` `[`nhanes_mortality_parse`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_parse.md)`(``cycles ``=`` ``"1988-1994"``)``[[``"1988-1994"``]``]`` `` ``d`` ``<-`` `[`merge`](https://rdrr.io/r/base/merge.html)`(``d``, ``mort``[``, `[`c`](https://rdrr.io/r/base/c.html)`(``"SEQN"``, ``"ELIGSTAT"``, ``"MORTSTAT"``, ``"UCOD_LEADING"``,`` `` ``"PERMTH_EXM"``, ``"PERMTH_INT"``)``]``,`` `` by ``=`` ``"SEQN"``, all.x ``=`` ``TRUE``)`` `[`table`](https://rdrr.io/r/base/table.html)`(``d``$``ELIGSTAT``, ``d``$``MORTSTAT``, useNA ``=`` ``"ifany"``)`` `` ``d`` ``<-`` ``d``[``d``$``ELIGSTAT`` `[`%in%`](https://rdrr.io/r/base/match.html)` ``1`` ``&`` ``!`[`is.na`](https://rdrr.io/r/base/NA.html)`(``d``$``PERMTH_EXM``)``, ``]`` ``d``$``time`` ``<-`` ``d``$``PERMTH_EXM`` ``# months from the exam`` ``d``$``event`` ``<-`` ``d``$``MORTSTAT`` ``# 1 = died by 2019-12-31`

`ELIGSTAT` is 2 for people under 18 at the survey (not linked) and 3
when there was too little identifying information. About 450 linkable
adults have no `PERMTH_EXM`: they were examined at home rather than in
the mobile exam centre, and have a zero MEC exam weight. `PERMTH_INT`
gives their follow-up from the interview if you need them.

## 8. Survey-weighted Cox model

[`library`](https://rdrr.io/r/base/library.html)`(`[`survey`](http://r-survey.r-forge.r-project.org/survey/)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`survival`](https://github.com/therneau/survival)`)`` ``d``$``Ht_m`` ``<-`` ``d``$``BMPHT`` ``/`` ``100`` ``des`` ``<-`` `[`svydesign`](https://rdrr.io/pkg/survey/man/svydesign.html)`(``ids ``=`` ``~``SDPPSU6``, strata ``=`` ``~``SDPSTRA6``, weights ``=`` ``~``WTPFEX6``,`` `` nest ``=`` ``TRUE``, data ``=`` ``d``[``d``$``WTPFEX6`` ``>`` ``0``, ``]``)`` ``fit`` ``<-`` `[`svycoxph`](https://rdrr.io/pkg/survey/man/svycoxph.html)`(`[`Surv`](https://rdrr.io/pkg/survival/man/Surv.html)`(``time``, ``event``)`` ``~`` ``HSAGEIR`` ``+`` `[`factor`](https://rdrr.io/r/base/factor.html)`(``HSSEX``)`` ``+`` ``BMPBMI`` ``+`` ``Ht_m``,`` `` design ``=`` `[`subset`](https://rdrr.io/r/base/subset.html)`(``des``, ``never_conf`` ``&`` ``!`[`is.na`](https://rdrr.io/r/base/NA.html)`(``BMPBMI``)``)``)`` `[`summary`](https://rdrr.io/r/base/summary.html)`(``fit``)`

## Notes

- Public-use mortality files add small perturbations to some follow-up
  times and causes of death for confidentiality. NCHS reports the effect
  on relative-risk estimates is negligible.
- `UCOD_LEADING` uses the same 10-category leading-cause recode as the
  continuous-NHANES files; see
  [`nhanes_ucod_labels()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_ucod_labels.md).
- NHANES III also has youth (`1a/youth.dat`) and first-laboratory
  (`1a/lab.dat`) files; the same reader works for them.
