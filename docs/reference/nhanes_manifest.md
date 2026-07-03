# List available files for a NHANES cycle and component

Queries the CDC NHANES data page for a given cycle and component,
returning a data frame of available files with their download URLs and
documentation links.

## Usage

``` r
nhanes_manifest(cycle, component, refresh = FALSE)
```

## Arguments

- cycle:

  Character. A cycle string, e.g. `"2015-2016"`. See
  [`nhanes_cycles()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_cycles.md)
  for valid values.

- component:

  Character. One of `"Demographics"`, `"Dietary"`, `"Examination"`,
  `"Laboratory"`, `"Questionnaire"`. Case-insensitive.

- refresh:

  Logical. Force re-query of CDC website even if cached? Default
  `FALSE`.

## Value

A tibble with columns:

- cycle:

  Cycle label.

- component:

  Component name.

- file_name:

  File code (e.g. `"DEMO_I"`).

- description:

  Plain-text description from CDC.

- xpt_url:

  Direct URL to the XPT data file.

- doc_url:

  URL to the HTML documentation/codebook page.

- date_published:

  Date published, if available.

## Details

Results are cached locally for the session to avoid repeated HTTP
requests. Use `refresh = TRUE` to force re-query.

## See also

[`nhanes_cycles()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_cycles.md)
for valid cycle labels;
[`nhanes_download()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download.md)
to download a file by its base code;
[`nhanes_search_variables()`](https://dwinsemius.github.io/nhanesR/reference/nhanes_search_variables.md)
to search the variable catalog by keyword.

## Examples

``` r
# \donttest{
nhanes_manifest("2015-2016", "Laboratory")
#>        cycle  component    file_name
#> 1  2015-2016 Laboratory AMDGYD_I Doc
#> 2  2015-2016 Laboratory ALB_CR_I Doc
#> 3  2015-2016 Laboratory  SSAGP_I Doc
#> 4  2015-2016 Laboratory   APOB_I Doc
#> 5  2015-2016 Laboratory   UADM_I Doc
#> 6  2015-2016 Laboratory   UTAS_I Doc
#> 7  2015-2016 Laboratory  UTASS_I Doc
#> 8  2015-2016 Laboratory BFRPOL_I Doc
#> 9  2015-2016 Laboratory CHLMDA_I Doc
#> 10 2015-2016 Laboratory   SSCT_I Doc
#> 11 2015-2016 Laboratory SSCLTY_I Doc
#> 12 2015-2016 Laboratory    HDL_I Doc
#> 13 2015-2016 Laboratory TRIGLY_I Doc
#> 14 2015-2016 Laboratory  TCHOL_I Doc
#> 15 2015-2016 Laboratory   CRCO_I Doc
#> 16 2015-2016 Laboratory    CBC_I Doc
#> 17 2015-2016 Laboratory CUSEZN_I Doc
#> 18 2015-2016 Laboratory    COT_I Doc
#> 19 2015-2016 Laboratory   UCOT_I Doc
#> 20 2015-2016 Laboratory  UCOTS_I Doc
#> 21 2015-2016 Laboratory   DEET_I Doc
#> 22 2015-2016 Laboratory SSDEET_I Doc
#> 23 2015-2016 Laboratory  SSEVD_I Doc
#> 24 2015-2016 Laboratory  ETHOX_I Doc
#> 25 2015-2016 Laboratory FASTQX_I Doc
#> 26 2015-2016 Laboratory FERTIN_I Doc
#> 27 2015-2016 Laboratory   SSFR_I Doc
#> 28 2015-2016 Laboratory  FLDEP_I Doc
#> 29 2015-2016 Laboratory  UFLDE_I Doc
#> 30 2015-2016 Laboratory  FLDEW_I Doc
#> 31 2015-2016 Laboratory FOLATE_I Doc
#> 32 2015-2016 Laboratory FOLFMS_I Doc
#> 33 2015-2016 Laboratory FORMAL_I Doc
#> 34 2015-2016 Laboratory    GHB_I Doc
#> 35 2015-2016 Laboratory SSGLYP_I Doc
#> 36 2015-2016 Laboratory   HEPA_I Doc
#> 37 2015-2016 Laboratory  HEPBD_I Doc
#> 38 2015-2016 Laboratory HEPB_S_I Doc
#> 39 2015-2016 Laboratory   HEPC_I Doc
#> 40 2015-2016 Laboratory   HEPE_I Doc
#> 41 2015-2016 Laboratory    HSV_I Doc
#> 42 2015-2016 Laboratory  HSCRP_I Doc
#> 43 2015-2016 Laboratory    HIV_I Doc
#> 44 2015-2016 Laboratory  ORHPV_I Doc
#> 45 2015-2016 Laboratory   HPVP_I Doc
#> 46 2015-2016 Laboratory HPVSWC_I Doc
#> 47 2015-2016 Laboratory HPVSWR_I Doc
#> 48 2015-2016 Laboratory    INS_I Doc
#> 49 2015-2016 Laboratory    UIO_I Doc
#> 50 2015-2016 Laboratory   SSKL_I Doc
#> 51 2015-2016 Laboratory   PBCD_I Doc
#> 52 2015-2016 Laboratory    UHG_I Doc
#> 53 2015-2016 Laboratory  IHGEM_I Doc
#> 54 2015-2016 Laboratory     UM_I Doc
#> 55 2015-2016 Laboratory    UMS_I Doc
#> 56 2015-2016 Laboratory SSMHHT_I Doc
#> 57 2015-2016 Laboratory SSNEON_I Doc
#> 58 2015-2016 Laboratory PCBPOL_I Doc
#> 59 2015-2016 Laboratory   OGTT_I Doc
#> 60 2015-2016 Laboratory    OPD_I Doc
#> 61 2015-2016 Laboratory  PERNT_I Doc
#> 62 2015-2016 Laboratory PERNTS_I Doc
#> 63 2015-2016 Laboratory   PFAS_I Doc
#> 64 2015-2016 Laboratory  EPHPP_I Doc
#> 65 2015-2016 Laboratory   SSPT_I Doc
#> 66 2015-2016 Laboratory PSTPOL_I Doc
#> 67 2015-2016 Laboratory PHTHTE_I Doc
#> 68 2015-2016 Laboratory    GLU_I Doc
#> 69 2015-2016 Laboratory DOXPOL_I Doc
#> 70 2015-2016 Laboratory    PAH_I Doc
#> 71 2015-2016 Laboratory   PAHS_I Doc
#> 72 2015-2016 Laboratory POOLTF_I Doc
#> 73 2015-2016 Laboratory UCPREG_I Doc
#> 74 2015-2016 Laboratory UPHOPM_I Doc
#> 75 2015-2016 Laboratory    TST_I Doc
#> 76 2015-2016 Laboratory    UAS_I Doc
#> 77 2015-2016 Laboratory   UASS_I Doc
#> 78 2015-2016 Laboratory BIOPRO_I Doc
#> 79 2015-2016 Laboratory    TFR_I Doc
#> 80 2015-2016 Laboratory  TRICH_I Doc
#> 81 2015-2016 Laboratory UCFLOW_I Doc
#> 82 2015-2016 Laboratory    VID_I Doc
#> 83 2015-2016 Laboratory   UVOC_I Doc
#> 84 2015-2016 Laboratory  UVOCS_I Doc
#> 85 2015-2016 Laboratory  VOCWB_I Doc
#> 86 2015-2016 Laboratory VOCWBS_I Doc
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
#>    xpt_url
#> 1     <NA>
#> 2     <NA>
#> 3     <NA>
#> 4     <NA>
#> 5     <NA>
#> 6     <NA>
#> 7     <NA>
#> 8     <NA>
#> 9     <NA>
#> 10    <NA>
#> 11    <NA>
#> 12    <NA>
#> 13    <NA>
#> 14    <NA>
#> 15    <NA>
#> 16    <NA>
#> 17    <NA>
#> 18    <NA>
#> 19    <NA>
#> 20    <NA>
#> 21    <NA>
#> 22    <NA>
#> 23    <NA>
#> 24    <NA>
#> 25    <NA>
#> 26    <NA>
#> 27    <NA>
#> 28    <NA>
#> 29    <NA>
#> 30    <NA>
#> 31    <NA>
#> 32    <NA>
#> 33    <NA>
#> 34    <NA>
#> 35    <NA>
#> 36    <NA>
#> 37    <NA>
#> 38    <NA>
#> 39    <NA>
#> 40    <NA>
#> 41    <NA>
#> 42    <NA>
#> 43    <NA>
#> 44    <NA>
#> 45    <NA>
#> 46    <NA>
#> 47    <NA>
#> 48    <NA>
#> 49    <NA>
#> 50    <NA>
#> 51    <NA>
#> 52    <NA>
#> 53    <NA>
#> 54    <NA>
#> 55    <NA>
#> 56    <NA>
#> 57    <NA>
#> 58    <NA>
#> 59    <NA>
#> 60    <NA>
#> 61    <NA>
#> 62    <NA>
#> 63    <NA>
#> 64    <NA>
#> 65    <NA>
#> 66    <NA>
#> 67    <NA>
#> 68    <NA>
#> 69    <NA>
#> 70    <NA>
#> 71    <NA>
#> 72    <NA>
#> 73    <NA>
#> 74    <NA>
#> 75    <NA>
#> 76    <NA>
#> 77    <NA>
#> 78    <NA>
#> 79    <NA>
#> 80    <NA>
#> 81    <NA>
#> 82    <NA>
#> 83    <NA>
#> 84    <NA>
#> 85    <NA>
#> 86    <NA>
#>                                                                     doc_url
#> 1  https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/AMDGYD_I.htm
#> 2  https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/ALB_CR_I.htm
#> 3   https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/SSAGP_I.htm
#> 4    https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/APOB_I.htm
#> 5    https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/UADM_I.htm
#> 6    https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/UTAS_I.htm
#> 7   https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/UTASS_I.htm
#> 8  https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/BFRPOL_I.htm
#> 9  https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/CHLMDA_I.htm
#> 10   https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/SSCT_I.htm
#> 11 https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/SSCLTY_I.htm
#> 12    https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/HDL_I.htm
#> 13 https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/TRIGLY_I.htm
#> 14  https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/TCHOL_I.htm
#> 15   https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/CRCO_I.htm
#> 16    https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/CBC_I.htm
#> 17 https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/CUSEZN_I.htm
#> 18    https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/COT_I.htm
#> 19   https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/UCOT_I.htm
#> 20  https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/UCOTS_I.htm
#> 21   https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/DEET_I.htm
#> 22 https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/SSDEET_I.htm
#> 23                                                                     <NA>
#> 24  https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/ETHOX_I.htm
#> 25 https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/FASTQX_I.htm
#> 26 https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/FERTIN_I.htm
#> 27   https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/SSFR_I.htm
#> 28  https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/FLDEP_I.htm
#> 29  https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/UFLDE_I.htm
#> 30  https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/FLDEW_I.htm
#> 31 https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/FOLATE_I.htm
#> 32 https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/FOLFMS_I.htm
#> 33 https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/FORMAL_I.htm
#> 34    https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/GHB_I.htm
#> 35 https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/SSGLYP_I.htm
#> 36   https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/HEPA_I.htm
#> 37  https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/HEPBD_I.htm
#> 38 https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/HEPB_S_I.htm
#> 39   https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/HEPC_I.htm
#> 40   https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/HEPE_I.htm
#> 41    https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/HSV_I.htm
#> 42  https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/HSCRP_I.htm
#> 43    https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/HIV_I.htm
#> 44  https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/ORHPV_I.htm
#> 45   https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/HPVP_I.htm
#> 46 https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/HPVSWC_I.htm
#> 47 https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/HPVSWR_I.htm
#> 48    https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/INS_I.htm
#> 49    https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/UIO_I.htm
#> 50   https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/SSKL_I.htm
#> 51   https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/PBCD_I.htm
#> 52    https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/UHG_I.htm
#> 53  https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/IHGEM_I.htm
#> 54     https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/UM_I.htm
#> 55    https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/UMS_I.htm
#> 56 https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/SSMHHT_I.htm
#> 57 https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/SSNEON_I.htm
#> 58 https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/PCBPOL_I.htm
#> 59   https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/OGTT_I.htm
#> 60    https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/OPD_I.htm
#> 61  https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/PERNT_I.htm
#> 62 https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/PERNTS_I.htm
#> 63   https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/PFAS_I.htm
#> 64  https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/EPHPP_I.htm
#> 65   https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/SSPT_I.htm
#> 66 https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/PSTPOL_I.htm
#> 67 https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/PHTHTE_I.htm
#> 68    https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/GLU_I.htm
#> 69 https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/DOXPOL_I.htm
#> 70    https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/PAH_I.htm
#> 71   https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/PAHS_I.htm
#> 72 https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/POOLTF_I.htm
#> 73 https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/UCPREG_I.htm
#> 74 https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/UPHOPM_I.htm
#> 75    https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/TST_I.htm
#> 76    https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/UAS_I.htm
#> 77   https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/UASS_I.htm
#> 78 https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/BIOPRO_I.htm
#> 79    https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/TFR_I.htm
#> 80  https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/TRICH_I.htm
#> 81 https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/UCFLOW_I.htm
#> 82    https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/VID_I.htm
#> 83   https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/UVOC_I.htm
#> 84  https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/UVOCS_I.htm
#> 85  https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/VOCWB_I.htm
#> 86 https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/VOCWBS_I.htm
#>            date_published
#> 1           December 2019
#> 2       Updated June 2019
#> 3          September 2023
#> 4            January 2019
#> 5            October 2018
#> 6   Updated February 2022
#> 7   Updated February 2022
#> 8   Updated November 2020
#> 9           December 2017
#> 10     Updated April 2022
#> 11           January 2023
#> 12         September 2017
#> 13           January 2019
#> 14         September 2017
#> 15         September 2017
#> 16   Updated January 2020
#> 17          December 2018
#> 18             April 2019
#> 19         September 2019
#> 20         September 2019
#> 21            August 2019
#> 22     Updated April 2022
#> 23              Withdrawn
#> 24       Updated May 2023
#> 25         September 2017
#> 26               May 2019
#> 27              July 2022
#> 28  Updated November 2019
#> 29          November 2022
#> 30  Updated November 2019
#> 31          February 2019
#> 32          February 2019
#> 33           January 2020
#> 34         September 2017
#> 35          November 2022
#> 36         September 2017
#> 37   Updated January 2026
#> 38         September 2017
#> 39 Updated September 2017
#> 40         September 2017
#> 41          December 2017
#> 42               May 2019
#> 43         September 2017
#> 44           January 2019
#> 45    Updated August 2021
#> 46          November 2018
#> 47          November 2018
#> 48              June 2018
#> 49              June 2018
#> 50             April 2021
#> 51           January 2018
#> 52              June 2018
#> 53              June 2018
#> 54              June 2018
#> 55              June 2018
#> 56     Updated April 2022
#> 57     Updated April 2022
#> 58  Updated November 2020
#> 59              June 2018
#> 60            August 2021
#> 61          February 2020
#> 62          February 2020
#> 63         September 2018
#> 64           January 2019
#> 65              June 2022
#> 66  Updated November 2020
#> 67           October 2018
#> 68    Updated August 2020
#> 69              July 2024
#> 70              July 2020
#> 71              July 2020
#> 72            August 2019
#> 73         September 2017
#> 74               May 2023
#> 75          November 2018
#> 76              June 2018
#> 77              June 2018
#> 78         September 2017
#> 79               May 2019
#> 80         September 2017
#> 81         September 2017
#> 82            August 2021
#> 83  Updated November 2021
#> 84  Updated November 2021
#> 85         September 2018
#> 86         September 2018
nhanes_manifest("2015-2016", "Demographics")
#>       cycle    component  file_name                              description
#> 1 2015-2016 Demographics DEMO_I Doc Demographic Variables and Sample Weights
#>   xpt_url
#> 1    <NA>
#>                                                                  doc_url
#> 1 https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2015/DataFiles/DEMO_I.htm
#>   date_published
#> 1 September 2017
# }
```
