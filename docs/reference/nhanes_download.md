# Download and cache NHANES XPT data files

Downloads one or more NHANES component files in SAS transport (XPT)
format from the CDC website, parses them into R data frames, attaches
variable labels, and caches the results locally as RDS files.

## Usage

``` r
nhanes_download(file_code, cycles, refresh = FALSE, add_cycle_col = TRUE)
```

## Arguments

- file_code:

  Character. The NHANES file code(s), without suffix or extension (e.g.
  `"DEMO"`, `"BPX"`, `"TRIGLY"`). Case-insensitive. Can be a vector to
  download multiple files.

- cycles:

  Character. One or more cycle labels (e.g. `"2015-2016"`). See
  [`nhanes_cycles()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_cycles.md).
  If multiple cycles are given, the same file code is downloaded for
  each.

- refresh:

  Logical. Re-download and re-parse even if cached? Default `FALSE`.

- add_cycle_col:

  Logical. Add a `cycle` column to each returned data frame? Default
  `TRUE`. Required for
  [`nhanes_mortality_link()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_mortality_link.md).

## Value

If a single file_code and single cycle are requested, a data frame. If
multiple file_codes or cycles are requested, a named list of data frames
with names of the form `"{file_code}_{cycle}"`.

## Details

### Finding valid file codes

File codes are the base names CDC assigns to each data file, without the
cycle-letter suffix or `.xpt` extension. For example, the Demographics
file is always `"DEMO"`, and the blood pressure examination file is
`"BPX"`.

Use
[`nhanes_manifest()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_manifest.md)
to browse all files available for a given cycle and component. The
`file_name` column of the manifest shows the full CDC name including the
cycle suffix (e.g. `"TCHOL_I"`); strip the trailing underscore-letter to
get the base code for `nhanes_download()`:

    m <- nhanes_manifest("2015-2016", "Laboratory")
    m[, c("file_name", "description")]

    # Base codes ready for nhanes_download():
    sub("_[A-Z]$", "", m$file_name)

Note that some analyte file names changed across cycles (e.g. total
cholesterol: `LAB13` -\> `L13_B` -\> `TCHOL_D` onward). For those cases,
use
[`nhanes_download_analyte()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download_analyte.md)
instead, which looks up the correct CDC filename for each cycle
automatically via the variable catalog.

### Invalid file codes

File codes are not validated before the download attempt. If an unknown
code is supplied, CDC returns HTTP 200 with an HTML error page rather
than a 404. nhanesR detects this via the `Content-Type` header and
aborts with a message directing you to
[`nhanes_manifest()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_manifest.md)
to confirm the correct name.

### Variable label encoding

NHANES XPT files were produced by SAS, which writes variable labels in
the system locale of the generating server — typically Latin-1 (ISO
8859-1). Some biochemistry files (notably `BIOPRO` and its predecessors
`L40_C` onward) use the Latin-1 byte `0xB5` for the micro prefix in SI
unit strings such as `umol/L`. That byte is not valid UTF-8, so any
downstream code that runs regular expressions over label attributes will
receive an `"unable to translate ... to a wide string"` warning and the
label will be skipped.

nhanesR guards against this internally by passing labels through
`iconv(..., to = "UTF-8", sub = "")` before pattern matching in
[`nhanes_harmonize()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_harmonize.md).
If you read label attributes directly in your own code, apply the same
conversion:

    labels <- iconv(
      vapply(df, function(col) attr(col, "label") %||% "", character(1L)),
      to = "UTF-8", sub = ""
    )

## See also

[`nhanes_manifest()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_manifest.md)
to browse available file codes;
[`nhanes_download_analyte()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download_analyte.md)
for analytes whose file name changed across cycles;
[`nhanes_cycles()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_cycles.md)
for valid cycle labels.

## Examples

``` r
# \donttest{
# Browse available Laboratory files for a cycle, then download by base code
m <- nhanes_manifest("2015-2016", "Laboratory")
m[, c("file_name", "description")]   # see what's available
#>       file_name
#> 1  AMDGYD_I Doc
#> 2  ALB_CR_I Doc
#> 3   SSAGP_I Doc
#> 4    APOB_I Doc
#> 5    UADM_I Doc
#> 6    UTAS_I Doc
#> 7   UTASS_I Doc
#> 8  BFRPOL_I Doc
#> 9  CHLMDA_I Doc
#> 10   SSCT_I Doc
#> 11 SSCLTY_I Doc
#> 12    HDL_I Doc
#> 13 TRIGLY_I Doc
#> 14  TCHOL_I Doc
#> 15   CRCO_I Doc
#> 16    CBC_I Doc
#> 17 CUSEZN_I Doc
#> 18    COT_I Doc
#> 19   UCOT_I Doc
#> 20  UCOTS_I Doc
#> 21   DEET_I Doc
#> 22 SSDEET_I Doc
#> 23  SSEVD_I Doc
#> 24  ETHOX_I Doc
#> 25 FASTQX_I Doc
#> 26 FERTIN_I Doc
#> 27   SSFR_I Doc
#> 28  FLDEP_I Doc
#> 29  UFLDE_I Doc
#> 30  FLDEW_I Doc
#> 31 FOLATE_I Doc
#> 32 FOLFMS_I Doc
#> 33 FORMAL_I Doc
#> 34    GHB_I Doc
#> 35 SSGLYP_I Doc
#> 36   HEPA_I Doc
#> 37  HEPBD_I Doc
#> 38 HEPB_S_I Doc
#> 39   HEPC_I Doc
#> 40   HEPE_I Doc
#> 41    HSV_I Doc
#> 42  HSCRP_I Doc
#> 43    HIV_I Doc
#> 44  ORHPV_I Doc
#> 45   HPVP_I Doc
#> 46 HPVSWC_I Doc
#> 47 HPVSWR_I Doc
#> 48    INS_I Doc
#> 49    UIO_I Doc
#> 50   SSKL_I Doc
#> 51   PBCD_I Doc
#> 52    UHG_I Doc
#> 53  IHGEM_I Doc
#> 54     UM_I Doc
#> 55    UMS_I Doc
#> 56 SSMHHT_I Doc
#> 57 SSNEON_I Doc
#> 58 PCBPOL_I Doc
#> 59   OGTT_I Doc
#> 60    OPD_I Doc
#> 61  PERNT_I Doc
#> 62 PERNTS_I Doc
#> 63   PFAS_I Doc
#> 64  EPHPP_I Doc
#> 65   SSPT_I Doc
#> 66 PSTPOL_I Doc
#> 67 PHTHTE_I Doc
#> 68    GLU_I Doc
#> 69 DOXPOL_I Doc
#> 70    PAH_I Doc
#> 71   PAHS_I Doc
#> 72 POOLTF_I Doc
#> 73 UCPREG_I Doc
#> 74 UPHOPM_I Doc
#> 75    TST_I Doc
#> 76    UAS_I Doc
#> 77   UASS_I Doc
#> 78 BIOPRO_I Doc
#> 79    TFR_I Doc
#> 80  TRICH_I Doc
#> 81 UCFLOW_I Doc
#> 82    VID_I Doc
#> 83   UVOC_I Doc
#> 84  UVOCS_I Doc
#> 85  VOCWB_I Doc
#> 86 VOCWBS_I Doc
#>                                                                                                                               description
#> 1                                                                                                                Acrylamide & Glycidamide
#> 2                                                                                                            Albumin & Creatinine - Urine
#> 3                                                                                             Alpha-1-Acid Glycoprotein - Serum (Surplus)
#> 4                                                                                                                        Apolipoprotein B
#> 5                                                                                                               Aromatic Diamines - Urine
#> 6                                                                                                                 Arsenic - Total - Urine
#> 7                                                                                                Arsenic - Total - Urine - Special Sample
#> 8                                                                                     Brominated Flame Retardants (BFRs) - Pooled Samples
#> 9                                                                                                                       Chlamydia - Urine
#> 10               Chlamydia Pgp3 (plasmid gene product 3) ELISA (enzyme linked immunosorbent assay) and multiplex bead array (MBA) results
#> 11                                                                                                 Chlorinated Tyrosine – Serum (Surplus)
#> 12                                                                                           Cholesterol - High-Density Lipoprotein (HDL)
#> 13                                                                          Cholesterol - Low - Density Lipoprotein (LDL) & Triglycerides
#> 14                                                                                                                    Cholesterol - Total
#> 15                                                                                                                      Chromium & Cobalt
#> 16                                                                            Complete Blood Count with 5-Part Differential - Whole Blood
#> 17                                                                                                        Copper, Selenium & Zinc - Serum
#> 18                                                                                                   Cotinine and Hydroxycotinine - Serum
#> 19                                                            Cotinine, Hydroxycotinine, & Other Nicotine Metabolites and Analogs - Urine
#> 20                                           Cotinine, Hydroxycotinine, & Other Nicotine Metabolites and Analogs - Urine - Special Sample
#> 21                                                                                                                DEET Metabolite - Urine
#> 22                                                                                                     DEET Metabolites - Urine - Surplus
#> 23                                                                                             Enterovirus D68 (EV-D68) - Serum (Surplus)
#> 24                                                                                                                         Ethylene Oxide
#> 25                                                                                                                  Fasting Questionnaire
#> 26                                                                                                                               Ferritin
#> 27                                                                                                     Flame Retardants - Urine (Surplus)
#> 28                                                                                                                      Fluoride - Plasma
#> 29                                                                                                                       Fluoride - Urine
#> 30                                                                                                                       Fluoride - Water
#> 31                                                                                                                           Folate - RBC
#> 32                                                                                              Folate Forms - Total & Individual - Serum
#> 33                                                                                                                           Formaldehyde
#> 34                                                                                                                        Glycohemoglobin
#> 35                                                                                                    Glyphosate (GLYP) - Urine (Surplus)
#> 36                                                                                                                            Hepatitis A
#> 37                                                                 Hepatitis B: Core antibody, Surface antigen, and Hepatitis D: antibody
#> 38                                                                                                          Hepatitis B: Surface Antibody
#> 39                                                                                    Hepatitis C: RNA (HCV-RNA) and Hepatitis C Genotype
#> 40                                                                                                      Hepatitis E: IgG & IgM Antibodies
#> 41                                                                                                   Herpes Simplex Virus Type-1 & Type-2
#> 42                                                                                           High-Sensitivity C-Reactive Protein (hs-CRP)
#> 43                                                                                                                      HIV Antibody Test
#> 44                                                                                                Human Papillomavirus (HPV) - Oral Rinse
#> 45                                                                      Human Papillomavirus (HPV) DNA - Penile Swabs: Roche Linear Array
#> 46                                                                   Human Papillomavirus (HPV) DNA - Vaginal Swab: Roche Cobas High-Risk
#> 47                                                                      Human Papillomavirus (HPV) DNA - Vaginal Swab: Roche Linear Array
#> 48                                                                                                                                Insulin
#> 49                                                                                                                         Iodine - Urine
#> 50                                                                                                               Klotho - Serum (Surplus)
#> 51                                                                             Lead, Cadmium, Total Mercury, Selenium & Manganese - Blood
#> 52                                                                                                             Mercury: Inorganic - Urine
#> 53                                                                                           Mercury: Inorganic, Ethyl and Methyl - Blood
#> 54                                                                                                                         Metals - Urine
#> 55                                                                                                        Metals - Urine - Special Sample
#> 56 Mono-2-ethyl-5-hydroxyhexyl terephthalate, mono-2-ethyl-5-carboxypentyl terephthalate, and monooxoisononyl phthalate - Urine (Surplus)
#> 57                                                                                                       Neonicotinoids - Urine - Surplus
#> 58                          Non-dioxin-like Polychlorinated Biphenyls & Mono-ortho-substituted Polychlorinated Biphenyls - Pooled Samples
#> 59                                                                                                            Oral Glucose Tolerance Test
#> 60                                                                   Organophosphate Insecticides - Dialkyl Phosphate Metabolites - Urine
#> 61                                                                                             Perchlorate, Nitrate & Thiocyanate - Urine
#> 62                                                                            Perchlorate, Nitrate & Thiocyanate - Urine - Special Sample
#> 63                                                                                                     Perfluoroalkyl and Polyfluoroalkyl
#> 64                                                                           Personal Care and Consumer Product Chemicals and Metabolites
#> 65                                                                                                Pertussis and tetanus – Serum (Surplus)
#> 66                                                                                Pesticides - Organochlorine Pesticides - Pooled Samples
#> 67                                                                                        Phthalates and Plasticizers Metabolites - Urine
#> 68                                                                                                                 Plasma Fasting Glucose
#> 69         Polychlorinated dibenzo-p-dioxins (PCDDs), Dibenzofurans (PCDFs) & Coplanar Polychlorinated Biphenyls (cPCBs) - Pooled Samples
#> 70                                                                                         Polycyclic Aromatic Hydrocarbons (PAH) - Urine
#> 71                                                                        Polycyclic Aromatic Hydrocarbons (PAH) - Urine - Special Sample
#> 72                                                                                                   Pooled-Sample Technical Support File
#> 73                                                                                                                 Pregnancy Test - Urine
#> 74                                                                        Pyrethroids, Herbicides, & Organophosphorus Metabolites - Urine
#> 75                                                                                                            Sex Steroid Hormone - Serum
#> 76                                                                                                             Speciated Arsenics - Urine
#> 77                                                                                            Speciated Arsenics - Urine - Special Sample
#> 78                                                                                                          Standard Biochemistry Profile
#> 79                                                                                                                   Transferrin Receptor
#> 80                                                                                                                    Trichomonas - Urine
#> 81                                                                                                                        Urine Flow Rate
#> 82                                                                                                                              Vitamin D
#> 83                                                                                    Volatile Organic Compound (VOC) Metabolites - Urine
#> 84                                                                   Volatile Organic Compound (VOC) Metabolites - Urine - Special Sample
#> 85                                                                            Volatile Organic Compounds and Trihalomethanes/MTBE - Blood
#> 86                                                           Volatile Organic Compounds and Trihalomethanes/MTBE – Blood – Special Sample
bpx <- nhanes_download("BPX", "2015-2016")

# Single file, single cycle
demo <- nhanes_download("DEMO", "2015-2016")

# Multiple cycles (returns list)
demos <- nhanes_download("DEMO", c("2013-2014", "2015-2016", "2017-2018"))

# Multiple files, single cycle
files <- nhanes_download(c("DEMO", "BPX", "TRIGLY"), "2015-2016")
# }
```
