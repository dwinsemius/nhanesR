# NHANES-annotated variable descriptions

Attaches CDC plain-language descriptions as column labels via
[`NH_label`](https://dwinsemius.github.io/nhanesR/reference/NH_label.md),
then calls [`describe`](https://rdrr.io/pkg/Hmisc/man/describe.html).
This is a convenience wrapper; for repeated use prefer
[`NH_label()`](https://dwinsemius.github.io/nhanesR/reference/NH_label.md)
once so that labels persist across all subsequent Hmisc operations.

## Usage

``` r
NH_describe(x, descriptions = NULL, all_weights = FALSE, ...)
```

## Arguments

- x:

  A data frame of NHANES data, typically from
  [`nhanes_download_analyte`](https://dwinsemius.github.io/nhanesR/reference/nhanes_download_analyte.md).

- descriptions:

  Optional lookup passed through to
  [`NH_label`](https://dwinsemius.github.io/nhanesR/reference/NH_label.md).
  See that function for accepted forms.

- all_weights:

  Logical. If `FALSE` (default), columns whose names match `REP[0-9]+$`
  (balanced repeated replication weights such as `WTMREP01`–`WTMREP52`)
  are excluded from the output. Set to `TRUE` to include all weight
  columns.

- ...:

  Additional arguments passed to
  [`describe`](https://rdrr.io/pkg/Hmisc/man/describe.html).

## Value

An object of class `"describe"` with CDC descriptions embedded as
variable labels.

## Details

Replicate weights (variables matching `REP[0-9]+$`, e.g.
`WTMREP01`–`WTMREP52` and `WTIREP01`–`WTIREP52`) are suppressed by
default because they appear in NHANES DEMO files but are not needed for
Taylor-series linearization variance estimation, which is the standard
approach for NHANES analysis. Set `all_weights = TRUE` to include them.

## See also

[`NH_label`](https://dwinsemius.github.io/nhanesR/reference/NH_label.md)
to attach labels to a data frame for persistent use;
[`describe`](https://rdrr.io/pkg/Hmisc/man/describe.html) for the
underlying engine.

## Examples

``` r
# \donttest{
tc <- nhanes_download_analyte("total cholesterol", "2015-2016")
#> Created nhanesR cache directory:
#> /var/folders/68/vh2f8kzn09j8954r6q9100yh0000gn/T//Rtmp7zLR2U/nhanesR
#> Fetching variable catalog for Laboratory from CDC...
#> Found 6 unique variables matching "total cholesterol".
#> Warning: Both "2017-2018" and "2017-2020" are present. The 2017-2018 participants are
#> included in the 2017-2020 pandemic-adjusted file -- use one or the other in
#> pooled analyses to avoid double-counting.
#> ℹ Downloading TCHOL_I 2015-2016
#> ✔ Downloading TCHOL_I 2015-2016 [432ms]
#> 
NH_describe(tc)
#> NH_label(x, descriptions = descriptions) 
#> 
#>  4  Variables      8021  Observations
#> --------------------------------------------------------------------------------
#> SEQN : Respondent sequence number 
#>        n  missing distinct 
#>     8021        0     8021 
#> 
#> lowest : 83732 83733 83734 83735 83736, highest: 93697 93699 93700 93701 93702
#> --------------------------------------------------------------------------------
#> LBXTC : Total Cholesterol (mg/dL) 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     7256      765      257        1    180.3      178    45.47      122 
#>      .10      .25      .50      .75      .90      .95 
#>      132      150      176      204      234      254 
#> 
#> lowest :  77  80  81  84  85, highest: 393 415 433 540 545
#> --------------------------------------------------------------------------------
#> LBDTCSI : Total Cholesterol( mmol/L) 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     7256      765      257        1    4.661      4.6    1.176     3.15 
#>      .10      .25      .50      .75      .90      .95 
#>     3.41     3.88     4.55     5.28     6.05     6.57 
#> 
#> lowest : 1.99  2.07  2.09  2.17  2.2  , highest: 10.16 10.73 11.2  13.96 14.09
#> --------------------------------------------------------------------------------
#> cycle 
#>         n   missing  distinct     value 
#>      8021         0         1 2015-2016 
#>                     
#> Value      2015-2016
#> Frequency       8021
#> Proportion         1
#> --------------------------------------------------------------------------------

# Include replicate weights in the output
demo_list <- nhanes_download("DEMO", nhanes_cycles()[1:10, "cycle"])
#> Downloading DEMO for 1999-2000
#> ℹ Downloading DEMO 1999-2000
#> ✔ Downloading DEMO 1999-2000 [2.3s]
#> 
#> Downloading DEMO for 2001-2002
#> ℹ Downloading DEMO 2001-2002
#> ✔ Downloading DEMO 2001-2002 [554ms]
#> 
#> Downloading DEMO for 2003-2004
#> ℹ Downloading DEMO 2003-2004
#> ✔ Downloading DEMO 2003-2004 [499ms]
#> 
#> Downloading DEMO for 2005-2006
#> ℹ Downloading DEMO 2005-2006
#> ✔ Downloading DEMO 2005-2006 [607ms]
#> 
#> Downloading DEMO for 2007-2008
#> ℹ Downloading DEMO 2007-2008
#> ✔ Downloading DEMO 2007-2008 [419ms]
#> 
#> Downloading DEMO for 2009-2010
#> ℹ Downloading DEMO 2009-2010
#> ✔ Downloading DEMO 2009-2010 [549ms]
#> 
#> Downloading DEMO for 2011-2012
#> ℹ Downloading DEMO 2011-2012
#> ✔ Downloading DEMO 2011-2012 [488ms]
#> 
#> Downloading DEMO for 2013-2014
#> ℹ Downloading DEMO 2013-2014
#> ✔ Downloading DEMO 2013-2014 [405ms]
#> 
#> Downloading DEMO for 2015-2016
#> ℹ Downloading DEMO 2015-2016
#> ✔ Downloading DEMO 2015-2016 [677ms]
#> 
#> Downloading DEMO for 2017-2018
#> ℹ Downloading DEMO 2017-2018
#> ✔ Downloading DEMO 2017-2018 [494ms]
#> 
demo <- nhanes_stack(demo_list)
#> Stacked 101316 rows across 10 cycles: "1999-2000", "2001-2002", "2003-2004",
#> "2005-2006", "2007-2008", "2009-2010", "2011-2012", "2013-2014", "2015-2016",
#> and "2017-2018"
NH_describe(demo, all_weights = TRUE)
#> NH_label(x, descriptions = descriptions) 
#> 
#>  175  Variables      101316  Observations
#> --------------------------------------------------------------------------------
#> SEQN : Respondent sequence number 
#>        n  missing distinct 
#>   101316        0   101316 
#> 
#> lowest : 1     10    100   1000  10000, highest: 99995 99996 99997 99998 99999
#> --------------------------------------------------------------------------------
#> SDDSRVYR : Data Release Number 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>   101316        0       10     0.99    5.426      5.5    3.275        1 
#>      .10      .25      .50      .75      .90      .95 
#>        2        3        5        8        9       10 
#>                                                                       
#> Value          1     2     3     4     5     6     7     8     9    10
#> Frequency   9965 11039 10122 10348 10149 10537  9756 10175  9971  9254
#> Proportion 0.098 0.109 0.100 0.102 0.100 0.104 0.096 0.100 0.098 0.091
#> --------------------------------------------------------------------------------
#> RIDSTATR : Interview/Examination Status 
#>        n  missing distinct     Info     Mean 
#>   101316        0        2    0.129    1.955 
#>                       
#> Value          1     2
#> Frequency   4550 96766
#> Proportion 0.045 0.955
#> --------------------------------------------------------------------------------
#> RIDEXMON : Six month time period 
#>        n  missing distinct     Info     Mean 
#>    96766     4550        2    0.748    1.523 
#>                       
#> Value          1     2
#> Frequency  46118 50648
#> Proportion 0.477 0.523
#> --------------------------------------------------------------------------------
#> RIAGENDR : Gender 
#>        n  missing distinct     Info     Mean 
#>   101316        0        2     0.75    1.508 
#>                       
#> Value          1     2
#> Frequency  49893 51423
#> Proportion 0.492 0.508
#> --------------------------------------------------------------------------------
#> RIDAGEYR : Age in years at screening 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>   101316        0       86        1    31.13     30.5    28.17        1 
#>      .10      .25      .50      .75      .90      .95 
#>        2       10       24       52       70       78 
#> 
#> lowest :  0  1  2  3  4, highest: 81 82 83 84 85
#> --------------------------------------------------------------------------------
#> RIDAGEMN : Age in Months - Recode 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>    63085    38231     1020        1    339.3    324.5    321.2        8 
#>      .10      .25      .50      .75      .90      .95 
#>       19       98      233      560      795      884 
#> 
#> lowest :    0    1    2    3    4, highest: 1015 1016 1017 1018 1019
#> --------------------------------------------------------------------------------
#> RIDAGEEX : Exam Age in Months - Recode 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>    57874    43442     1020        1    351.7    338.5    317.5     13.0 
#>      .10      .25      .50      .75      .90      .95 
#>     31.0    118.2    248.0    572.0    797.0    884.0 
#> 
#> lowest :    0    1    2    3    4, highest: 1015 1016 1017 1018 1019
#> --------------------------------------------------------------------------------
#> RIDRETH1 : Ethnicity - Recode 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>   101316        0        5    0.925    2.896        3    1.378 
#>                                         
#> Value          1     2     3     4     5
#> Frequency  22449  8294 37432 23644  9497
#> Proportion 0.222 0.082 0.369 0.233 0.094
#> --------------------------------------------------------------------------------
#> RIDRETH2 : Linked NH3 Race/Ethnicity - Recode 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>    31126    70190        5    0.901    2.087        2    1.168 
#>                                         
#> Value          1     2     3     4     5
#> Frequency  12262  7765  8688   964  1447
#> Proportion 0.394 0.249 0.279 0.031 0.046
#> --------------------------------------------------------------------------------
#> DMQMILIT : Veteran/Military Status 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>    36914    64402        4    0.327     1.88        2   0.2243 
#>                                   
#> Value          1     2     7     9
#> Frequency   4571 32319    17     7
#> Proportion 0.124 0.876 0.000 0.000
#> --------------------------------------------------------------------------------
#> DMDBORN : Country of Birth - Recode 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>    41458    59858        5      0.4    1.222        1   0.3857 
#>                                         
#> Value          1     2     3     7     9
#> Frequency  34941  3905  2599    12     1
#> Proportion 0.843 0.094 0.063 0.000 0.000
#> --------------------------------------------------------------------------------
#> DMDCITZN : Citizenship Status 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>   101282       34        4    0.285    1.116        1   0.2102 
#>                                   
#> Value          1     2     7     9
#> Frequency  90534 10562   131    55
#> Proportion 0.894 0.104 0.001 0.001
#> --------------------------------------------------------------------------------
#> DMDYRSUS : Length of time in US 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>    18366    82950       12    0.984    7.654        5    8.116        2 
#>      .10      .25      .50      .75      .90      .95 
#>        2        3        5        7        8        9 
#>                                                                             
#> Value          1     2     3     4     5     6     7     8     9    77    88
#> Frequency    869  2737  2826  2494  1888  2910  1953  1186   844   321     6
#> Proportion 0.047 0.149 0.154 0.136 0.103 0.158 0.106 0.065 0.046 0.017 0.000
#>                 
#> Value         99
#> Frequency    332
#> Proportion 0.018
#> --------------------------------------------------------------------------------
#> DMDEDUC3 : Education Level - Children/Youth 6-19 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>    29475    71841       20    0.995    6.983      6.5    5.876        0 
#>      .10      .25      .50      .75      .90      .95 
#>        1        3        6       10       12       13 
#>                                                                             
#> Value          0     1     2     3     4     5     6     7     8     9    10
#> Frequency   2369  2134  2107  2043  2054  2129  2238  2197  2315  2228  2197
#> Proportion 0.080 0.072 0.071 0.069 0.070 0.072 0.076 0.075 0.079 0.076 0.075
#>                                                                 
#> Value         11    12    13    14    15    55    66    77    99
#> Frequency   2166   440  1438   115   989    26   279     2     9
#> Proportion 0.073 0.015 0.049 0.004 0.034 0.001 0.009 0.000 0.000
#> --------------------------------------------------------------------------------
#> DMDEDUC2 : Education Level - Adults 20+ 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>    55075    46241        7    0.951    3.317      3.5    1.467 
#>                                                     
#> Value          1     2     3     4     5     7     9
#> Frequency   6838  8302 12733 15366 11722    37    77
#> Proportion 0.124 0.151 0.231 0.279 0.213 0.001 0.001
#> --------------------------------------------------------------------------------
#> DMDEDUC : Education - Recode (old version) 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>    25920    75396        5    0.794    1.716      1.5   0.9102 
#>                                         
#> Value          1     2     3     7     9
#> Frequency  14690  4224  6946    20    40
#> Proportion 0.567 0.163 0.268 0.001 0.002
#> --------------------------------------------------------------------------------
#> DMDSCHOL : Now attending school? 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>    17708    83608        4    0.614    1.369        1   0.5682 
#>                                   
#> Value          1     2     3     9
#> Frequency  12810  3274  1622     2
#> Proportion 0.723 0.185 0.092 0.000
#> --------------------------------------------------------------------------------
#> DMDMARTL : Marital Status 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>    61563    39753        8     0.88    2.813        3    2.146 
#>                                                           
#> Value          1     2     3     4     5     6    77    99
#> Frequency  28578  5046  5599  1833 16272  4186    42     7
#> Proportion 0.464 0.082 0.091 0.030 0.264 0.068 0.001 0.000
#> --------------------------------------------------------------------------------
#> DMDHHSIZ : Total number of people in the Household 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>   101316        0        7    0.972    3.829        4    1.964 
#>                                                     
#> Value          1     2     3     4     5     6     7
#> Frequency   8215 19129 17791 21219 16336  8830  9796
#> Proportion 0.081 0.189 0.176 0.209 0.161 0.087 0.097
#> --------------------------------------------------------------------------------
#> INDHHINC : Annual Household Income 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>    38169    63147       15    0.986    7.721        7    5.223        2 
#>      .10      .25      .50      .75      .90      .95 
#>        3        4        7       10       11       11 
#>                                                                             
#> Value          1     2     3     4     5     6     7     8     9    10    11
#> Frequency   1069  2223  3459  3286  3267  5046  3882  3262  2387  1837  7338
#> Proportion 0.028 0.058 0.091 0.086 0.086 0.132 0.102 0.085 0.063 0.048 0.192
#>                                   
#> Value         12    13    77    99
#> Frequency    537   177   137   262
#> Proportion 0.014 0.005 0.004 0.007
#> --------------------------------------------------------------------------------
#> INDFMINC : Annual Family Income 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>    40831    60485       15     0.99    8.739      6.5    7.934        1 
#>      .10      .25      .50      .75      .90      .95 
#>        2        4        6       10       11       12 
#>                                                                             
#> Value          1     2     3     4     5     6     7     8     9    10    11
#> Frequency   2107  2896  4167  3574  3577  4824  3627  3092  2105  1714  6393
#> Proportion 0.052 0.071 0.102 0.088 0.088 0.118 0.089 0.076 0.052 0.042 0.157
#>                                   
#> Value         12    13    77    99
#> Frequency    899   739   556   561
#> Proportion 0.022 0.018 0.014 0.014
#> --------------------------------------------------------------------------------
#> INDFMPIR : Family PIR 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>    92120     9196      501    0.997    2.272    2.215      1.8     0.29 
#>      .10      .25      .50      .75      .90      .95 
#>     0.51     0.94     1.79     3.57     5.00     5.00 
#> 
#> lowest : 0    0.01 0.02 0.03 0.04, highest: 4.96 4.97 4.98 4.99 5   
#> --------------------------------------------------------------------------------
#> RIDEXPRG : Pregnancy Status at Exam - Recode 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>    19540    81776        3    0.433    1.997        2   0.3157 
#>                             
#> Value          1     2     3
#> Frequency   1722 16164  1654
#> Proportion 0.088 0.827 0.085
#> --------------------------------------------------------------------------------
#> RIDPREG : Pregnancy Status - Recode (old version) 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>     5030    96286        3    0.424    2.106        2   0.6986 
#>                             
#> Value          1     2     9
#> Frequency    679  4178   173
#> Proportion 0.135 0.831 0.034
#> --------------------------------------------------------------------------------
#> DMDHRGND : HH Ref Person Gender 
#>        n  missing distinct     Info     Mean 
#>   101301       15        2    0.749    1.479 
#>                       
#> Value          1     2
#> Frequency  52739 48562
#> Proportion 0.521 0.479
#> --------------------------------------------------------------------------------
#> DMDHRAGE : HH Ref Person Age 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>    92047     9269       71        1    45.18       44    18.26       23 
#>      .10      .25      .50      .75      .90      .95 
#>       26       33       42       55       70       78 
#> 
#> lowest : 15 16 17 18 19, highest: 81 82 83 84 85
#> --------------------------------------------------------------------------------
#> DMDHRBRN : HH Ref Person Country of Birth 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>    40057    61259        5      0.6    1.367        1   0.5723 
#>                                         
#> Value          1     2     3     7     9
#> Frequency  29376  6756  3904    19     2
#> Proportion 0.733 0.169 0.097 0.000 0.000
#> --------------------------------------------------------------------------------
#> DMDHREDU : HH Ref Person Education Level 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>    89049    12267        7    0.953    3.274      3.5    1.492 
#>                                                     
#> Value          1     2     3     4     5     7     9
#> Frequency  11069 15178 20841 23868 17656    65   372
#> Proportion 0.124 0.170 0.234 0.268 0.198 0.001 0.004
#> --------------------------------------------------------------------------------
#> DMDHRMAR : HH Ref Person Marital Status 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>    88303    13013        8    0.796    2.682        2    2.538 
#>                                                           
#> Value          1     2     3     4     5     6    77    99
#> Frequency  51583  5552  8745  3856 12180  5940   377    70
#> Proportion 0.584 0.063 0.099 0.044 0.138 0.067 0.004 0.001
#> --------------------------------------------------------------------------------
#> DMDHSEDU : HH Ref Person's Spouse Education Level 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>    46276    55040        7    0.951    3.391      3.5    1.527 
#>                                                     
#> Value          1     2     3     4     5     7     9
#> Frequency   5990  6227 10271 12138 11417    39   194
#> Proportion 0.129 0.135 0.222 0.262 0.247 0.001 0.004
#> --------------------------------------------------------------------------------
#> WTINT2YR : Full Sample 2 Year Interview Weight 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>   101316        0    50859        1    29454    23108    28277     4695 
#>      .10      .25      .50      .75      .90      .95 
#>     6126    10007    19137    36552    71685    91233 
#> 
#> lowest : 974.665 1169.3  1188.62 1196.5  1207.53
#> highest: 385797  387879  407301  424183  433085 
#> --------------------------------------------------------------------------------
#> WTINT4YR : Full Sample 4 Year Interview Weight 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>    21004    80312     7228        1    13267    10884    13674     1419 
#>      .10      .25      .50      .75      .90      .95 
#>     1852     3339     7795    18642    34750    43103 
#> 
#> lowest : 620.682 683.456 707.023 708.993 713.359
#> highest: 90510.5 91912.1 94900.9 95264.1 100652 
#> --------------------------------------------------------------------------------
#> WTMEC2YR : Full Sample 2 Year MEC Exam Weight 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>   101316        0    66780        1    29454    22948    29694     2093 
#>      .10      .25      .50      .75      .90      .95 
#>     5168     9469    18915    37058    73388    94065 
#> 
#> lowest : 0       980.337 1163.47 1182.69 1190.53
#> highest: 394721  407801  416874  419057  419763 
#> --------------------------------------------------------------------------------
#> WTMEC4YR : Full Sample 4 Year MEC Exam Weight 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>    21004    80312    13632        1    13267    10647    14526        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1429     3060     7046    18859    36311    44884 
#> 
#> lowest : 0       632.543 698.389 712.042 717.224
#> highest: 95269.4 102134  102690  103459  103831 
#> --------------------------------------------------------------------------------
#> SDMVPSU : Masked Variance Pseudo-PSU 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>   101316        0        3    0.761    1.523      1.5    0.529 
#>                             
#> Value          1     2     3
#> Frequency  49831 49986  1499
#> Proportion 0.492 0.493 0.015
#> --------------------------------------------------------------------------------
#> SDMVSTRA : Masked Variance Pseudo-Stratum 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>   101316        0      148        1    72.42     72.5    49.56        7 
#>      .10      .25      .50      .75      .90      .95 
#>       14       35       72      109      132      140 
#> 
#> lowest :   1   2   3   4   5, highest: 144 145 146 147 148
#> --------------------------------------------------------------------------------
#> SDJ1REPN : Jack Knife Replicate Number 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351       52        1     26.6     26.5    17.18        3 
#>      .10      .25      .50      .75      .90      .95 
#>        6       14       27       39       48       50 
#> 
#> lowest :  1  2  3  4  5, highest: 48 49 50 51 52
#> --------------------------------------------------------------------------------
#> DMAETHN : Logical Imputation Flag for Ethnicity 
#>        n  missing distinct     Info     Mean 
#>        2   101314        1        0        1 
#>             
#> Value      1
#> Frequency  2
#> Proportion 1
#> --------------------------------------------------------------------------------
#> DMARACE : Logical Imputation Flag for Race Recode 
#>        n  missing distinct     Info     Mean 
#>        2   101314        1        0        1 
#>             
#> Value      1
#> Frequency  2
#> Proportion 1
#> --------------------------------------------------------------------------------
#> WTMREP01 : MEC Exam Weight Jack Knife Replicate 01 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6361    0.999    27311    21160    32671        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1903     4730    11453    40718    79415   101402 
#> 
#> lowest : 0       1017.74 1191.34 1210.35 1222.92
#> highest: 199149  216043  216409  230935  258537 
#> --------------------------------------------------------------------------------
#> WTMREP02 : MEC Exam Weight Jack Knife Replicate 02 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6337    0.999    27311    21421    32758        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1648     4324    11612    41152    78906   100795 
#> 
#> lowest : 0       983.361 1166.2  1184.88 1192.73
#> highest: 221204  226518  227685  227705  260735 
#> --------------------------------------------------------------------------------
#> WTMREP03 : MEC Exam Weight Jack Knife Replicate 03 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6417    0.999    27311    21370    32347        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1935     5119    11725    40695    78313    99770 
#> 
#> lowest : 0       1032.38 1214.48 1237.31 1243.92
#> highest: 217080  223424  224575  225497  261390 
#> --------------------------------------------------------------------------------
#> WTMREP04 : MEC Exam Weight Jack Knife Replicate 04 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6361    0.999    27311    21329    32430        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1887     4955    11673    40572    78584    99848 
#> 
#> lowest : 0       1020.82 1212.12 1224.85 1229.41
#> highest: 218569  225246  226407  227344  261672 
#> --------------------------------------------------------------------------------
#> WTMREP05 : MEC Exam Weight Jack Knife Replicate 05 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6419    0.999    27311    21269    32632        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1922     4712    11617    40810    79005   100964 
#> 
#> lowest : 0       980.291 1165.31 1184.56 1192.42
#> highest: 221373  228100  229349  229756  261039 
#> --------------------------------------------------------------------------------
#> WTMREP06 : MEC Exam Weight Jack Knife Replicate 06 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6409    0.999    27311    21225    32685        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1910     4703    11574    40721    78875   101286 
#> 
#> lowest : 0       986.154 1177.24 1197.56 1204.62
#> highest: 222618  231009  231501  232748  262491 
#> --------------------------------------------------------------------------------
#> WTMREP07 : MEC Exam Weight Jack Knife Replicate 07 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6406    0.999    27311    21223    32567        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1996     4833    11457    40614    79056   100864 
#> 
#> lowest : 0       999.31  1189.92 1208.82 1217.69
#> highest: 222298  227843  228326  229762  258632 
#> --------------------------------------------------------------------------------
#> WTMREP08 : MEC Exam Weight Jack Knife Replicate 08 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6381    0.999    27311    21287    32661        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1858     4645    11715    40768    78788   100906 
#> 
#> lowest : 0       980.786 1168.71 1188.02 1195.9 
#> highest: 220281  228448  229364  230108  261428 
#> --------------------------------------------------------------------------------
#> WTMREP09 : MEC Exam Weight Jack Knife Replicate 09 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6357    0.999    27311    21217    32645        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1873     4795    11480    40679    79150   100855 
#> 
#> lowest : 0       992.597 1204.78 1222.3  1230.2 
#> highest: 220788  226377  227568  228480  263135 
#> --------------------------------------------------------------------------------
#> WTMREP10 : MEC Exam Weight Jack Knife Replicate 10 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6390    0.999    27311    21135    32781        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1878     4675    11435    40906    79550   101213 
#> 
#> lowest : 0       984.364 1170.83 1189.7  1198.05
#> highest: 229379  230630  231672  262179  264326 
#> --------------------------------------------------------------------------------
#> WTMREP11 : MEC Exam Weight Jack Knife Replicate 11 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6385    0.999    27311    20963    32953        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1881     4609    11162    40738    79675   102589 
#> 
#> lowest : 0       990.517 1172.23 1191.57 1199.89
#> highest: 228354  232428  233772  235208  265083 
#> --------------------------------------------------------------------------------
#> WTMREP12 : MEC Exam Weight Jack Knife Replicate 12 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6383    0.999    27311    21222    32755        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1812     4591    11583    40710    79176   101308 
#> 
#> lowest : 0       986.957 1165.17 1184.79 1192.27
#> highest: 224367  231478  232106  233947  261045 
#> --------------------------------------------------------------------------------
#> WTMREP13 : MEC Exam Weight Jack Knife Replicate 13 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6380    0.999    27311    21430    32640        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1855     4614    11684    41110    78852   100416 
#> 
#> lowest : 0       980.404 1163.49 1182.71 1190.55
#> highest: 219554  225844  226599  227702  259966 
#> --------------------------------------------------------------------------------
#> WTMREP14 : MEC Exam Weight Jack Knife Replicate 14 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6421    0.999    27311    20964    32859        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1947     4727    11201    40496    79709   102460 
#> 
#> lowest : 0       980.171 1163.36 1182.57 1190.41
#> highest: 222844  230377  232187  233611  267824 
#> --------------------------------------------------------------------------------
#> WTMREP15 : MEC Exam Weight Jack Knife Replicate 15 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6383    0.999    27311    20540    33341        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1737     4390    10868    40319    80429   104699 
#> 
#> lowest : 0       980.338 1163.47 1182.69 1190.53
#> highest: 231416  236926  239965  241546  264049 
#> --------------------------------------------------------------------------------
#> WTMREP16 : MEC Exam Weight Jack Knife Replicate 16 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6406    0.999    27311    20858    33050        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1866     4594    11033    40754    80196   102715 
#> 
#> lowest : 0       988.547 1163.35 1182.57 1190.41
#> highest: 228957  237153  238019  238432  265141 
#> --------------------------------------------------------------------------------
#> WTMREP17 : MEC Exam Weight Jack Knife Replicate 17 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6368    0.999    27311    21272    32769        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1742     4497    11693    41010    79108   101170 
#> 
#> lowest : 0       985.768 1163.3  1182.51 1190.35
#> highest: 219961  230909  230997  231795  260426 
#> --------------------------------------------------------------------------------
#> WTMREP18 : MEC Exam Weight Jack Knife Replicate 18 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6299    0.999    27311    21319    32543        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1745     4835    11544    40748    78935   100338 
#> 
#> lowest : 0       1039.69 1249.49 1272.19 1279.84
#> highest: 218682  225375  226171  227093  261367 
#> --------------------------------------------------------------------------------
#> WTMREP19 : MEC Exam Weight Jack Knife Replicate 19 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6372    0.999    27311    21201    32652        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1923     4747    11517    40663    79166   100936 
#> 
#> lowest : 0       995.604 1170.8  1190.54 1197.87
#> highest: 221783  226824  227231  228370  265394 
#> --------------------------------------------------------------------------------
#> WTMREP20 : MEC Exam Weight Jack Knife Replicate 20 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6360    0.999    27311    21361    32368        0 
#>      .10      .25      .50      .75      .90      .95 
#>     2005     5072    11692    40686    78346    99674 
#> 
#> lowest : 0       1019.49 1213.39 1234.9  1242.92
#> highest: 217638  223942  225120  226025  261810 
#> --------------------------------------------------------------------------------
#> WTMREP21 : MEC Exam Weight Jack Knife Replicate 21 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6391    0.999    27311    21285    32724        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1875     4642    11506    40833    79470   101128 
#> 
#> lowest : 0       980.341 1165.29 1184.94 1192.4 
#> highest: 224317  228878  230122  231010  261041 
#> --------------------------------------------------------------------------------
#> WTMREP22 : MEC Exam Weight Jack Knife Replicate 22 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6373    0.999    27311    21367    32341        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1987     5014    11688    40690    78409    99706 
#> 
#> lowest : 0       1029.99 1246    1271.18 1276.05
#> highest: 217163  223524  224676  225596  261411 
#> --------------------------------------------------------------------------------
#> WTMREP23 : MEC Exam Weight Jack Knife Replicate 23 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6372    0.999    27311    21219    32548        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1977     4865    11506    40418    79115   100415 
#> 
#> lowest : 0       1020.29 1218.5  1240.77 1249.55
#> highest: 219852  227904  229735  230523  261819 
#> --------------------------------------------------------------------------------
#> WTMREP24 : MEC Exam Weight Jack Knife Replicate 24 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6347    0.999    27311    21125    32671        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1762     4826    11446    40431    79209   101262 
#> 
#> lowest : 0       1031.29 1210.49 1233.03 1240.68
#> highest: 222514  229185  230600  231373  262433 
#> --------------------------------------------------------------------------------
#> WTMREP25 : MEC Exam Weight Jack Knife Replicate 25 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6341    0.999    27311    21385    32401        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1438     4877    11693    40713    78217    99716 
#> 
#> lowest : 0       1098.61 1286.3  1312.35 1318.12
#> highest: 217301  223315  224466  225390  261362 
#> --------------------------------------------------------------------------------
#> WTMREP26 : MEC Exam Weight Jack Knife Replicate 26 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6388    0.999    27311    21218    32628        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1913     4716    11570    40713    79228   100584 
#> 
#> lowest : 0       980.583 1164.53 1183.76 1191.61
#> highest: 222820  226125  228246  228444  259974 
#> --------------------------------------------------------------------------------
#> WTMREP27 : MEC Exam Weight Jack Knife Replicate 27 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6382    0.999    27311    20753    33176        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1798     4493    10976    40710    80265   103259 
#> 
#> lowest : 0       980.334 1159.76 1178.92 1186.73
#> highest: 236358  242548  244527  245137  260116 
#> --------------------------------------------------------------------------------
#> WTMREP28 : MEC Exam Weight Jack Knife Replicate 28 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6329    0.999    27311    21003    32900        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1796     4603    11281    40628    79998   101835 
#> 
#> lowest : 0       1014.76 1200.46 1211.1  1230.48
#> highest: 224865  229291  231825  232744  265884 
#> --------------------------------------------------------------------------------
#> WTMREP29 : MEC Exam Weight Jack Knife Replicate 29 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6334    0.999    27311    21283    32485        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1943     4870    11634    40383    78983   100139 
#> 
#> lowest : 0       1011.87 1238.81 1251.67 1259.76
#> highest: 221451  224463  225845  228530  263108 
#> --------------------------------------------------------------------------------
#> WTMREP30 : MEC Exam Weight Jack Knife Replicate 30 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6358    0.999    27311    21059    32915        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1807     4545    11306    40656    79724   102084 
#> 
#> lowest : 0       982.127 1175.34 1195.15 1202.73
#> highest: 224905  230831  232022  232848  261762 
#> --------------------------------------------------------------------------------
#> WTMREP31 : MEC Exam Weight Jack Knife Replicate 31 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6361    0.999    27311    21320    32410        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1908     4980    11711    40616    78606   100056 
#> 
#> lowest : 0       1038.41 1197.2  1245.44 1254.68
#> highest: 218080  225408  225911  226838  262964 
#> --------------------------------------------------------------------------------
#> WTMREP32 : MEC Exam Weight Jack Knife Replicate 32 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6367    0.999    27311    20998    32992        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1815     4545    11101    40960    80275   102782 
#> 
#> lowest : 0       992.645 1175.75 1195.17 1203.1 
#> highest: 225363  230038  234278  236123  254091 
#> --------------------------------------------------------------------------------
#> WTMREP33 : MEC Exam Weight Jack Knife Replicate 33 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6395    0.999    27311    21156    32736        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1934     4688    11463    40744    79499   101780 
#> 
#> lowest : 0       981.1   1167.8  1187.09 1194.96
#> highest: 222185  229587  230379  232208  259603 
#> --------------------------------------------------------------------------------
#> WTMREP34 : MEC Exam Weight Jack Knife Replicate 34 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6303    0.999    27311    21337    32518        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1661     4817    11596    40719    78635   100346 
#> 
#> lowest : 0       1049.31 1248.76 1294.73 1341.46
#> highest: 219557  224038  225712  227861  261548 
#> --------------------------------------------------------------------------------
#> WTMREP35 : MEC Exam Weight Jack Knife Replicate 35 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6374    0.999    27311    21316    32620        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1891     4702    11711    40768    78694   100917 
#> 
#> lowest : 0       985.003 1166.82 1186.1  1193.96
#> highest: 225919  233415  235429  236197  253437 
#> --------------------------------------------------------------------------------
#> WTMREP36 : MEC Exam Weight Jack Knife Replicate 36 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6426    0.999    27311    21030    32823        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1940     4723    11251    40528    79548   102121 
#> 
#> lowest : 0       980.34  1163.43 1182.65 1190.49
#> highest: 224217  228970  232182  234039  261427 
#> --------------------------------------------------------------------------------
#> WTMREP37 : MEC Exam Weight Jack Knife Replicate 37 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6384    0.999    27311    21352    32402        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1882     5021    11631    40690    78532    99807 
#> 
#> lowest : 0       1041.38 1211.78 1231.31 1242.62
#> highest: 217978  224760  225463  226644  262556 
#> --------------------------------------------------------------------------------
#> WTMREP38 : MEC Exam Weight Jack Knife Replicate 38 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6386    0.999    27311    21216    32703        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1890     4670    11572    40662    79141   101106 
#> 
#> lowest : 0       980.019 1165.5  1185.18 1192.61
#> highest: 221222  230256  230868  231985  265965 
#> --------------------------------------------------------------------------------
#> WTMREP39 : MEC Exam Weight Jack Knife Replicate 39 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6378    0.999    27311    21172    32626        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1961     4850    11464    40468    78813   100856 
#> 
#> lowest : 0       1007.06 1185.75 1204.47 1212.66
#> highest: 220100  227475  228328  228938  263382 
#> --------------------------------------------------------------------------------
#> WTMREP40 : MEC Exam Weight Jack Knife Replicate 40 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6353    0.999    27311    21343    32396        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1968     4990    11643    40585    78636    99826 
#> 
#> lowest : 0       1018.75 1229.43 1235.43 1254.49
#> highest: 216524  225128  226317  227222  262655 
#> --------------------------------------------------------------------------------
#> WTMREP41 : MEC Exam Weight Jack Knife Replicate 41 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6362    0.999    27311    21065    32914        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1770     4516    11327    40610    79544   102315 
#> 
#> lowest : 0       990.438 1172.51 1192.31 1201.32
#> highest: 224689  232278  232908  232987  263442 
#> --------------------------------------------------------------------------------
#> WTMREP42 : MEC Exam Weight Jack Knife Replicate 42 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6406    0.999    27311    20863    33013        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1884     4631    11062    40633    80236   102570 
#> 
#> lowest : 0       980.183 1163.34 1182.55 1190.4 
#> highest: 225142  233837  238250  238365  263488 
#> --------------------------------------------------------------------------------
#> WTMREP43 : MEC Exam Weight Jack Knife Replicate 43 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6368    0.999    27311    21167    32748        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1845     4682    11509    40584    79184   101501 
#> 
#> lowest : 0       988.024 1184.01 1205.12 1211.55
#> highest: 221420  222276  230783  231511  263992 
#> --------------------------------------------------------------------------------
#> WTMREP44 : MEC Exam Weight Jack Knife Replicate 44 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6394    0.999    27311    21167    32730        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1912     4684    11472    40644    79529   101674 
#> 
#> lowest : 0       980.332 1162.7  1181.9  1189.74
#> highest: 223925  226760  227395  227592  262044 
#> --------------------------------------------------------------------------------
#> WTMREP45 : MEC Exam Weight Jack Knife Replicate 45 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6390    0.999    27311    20930    33032        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1874     4592    11042    40974    80421   102927 
#> 
#> lowest : 0       980.319 1163.41 1182.63 1190.47
#> highest: 223938  236434  236625  237549  257749 
#> --------------------------------------------------------------------------------
#> WTMREP46 : MEC Exam Weight Jack Knife Replicate 46 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6371    0.999    27311    21018    32892        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1844     4586    11317    40549    79881   102218 
#> 
#> lowest : 0       991.079 1183.69 1203.81 1211.22
#> highest: 227846  231270  233132  236145  266060 
#> --------------------------------------------------------------------------------
#> WTMREP47 : MEC Exam Weight Jack Knife Replicate 47 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6355    0.999    27311    21178    32780        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1848     4625    11517    40704    79190   101565 
#> 
#> lowest : 0       990.053 1185.61 1205.16 1212.48
#> highest: 229754  236041  236940  238711  252840 
#> --------------------------------------------------------------------------------
#> WTMREP48 : MEC Exam Weight Jack Knife Replicate 48 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6285    0.999    27311    21406    32479        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1677     4819    11752    40769    78584    99721 
#> 
#> lowest : 0       1232    1262.84 1296.32 1371.16
#> highest: 216302  223954  225108  226193  261675 
#> --------------------------------------------------------------------------------
#> WTMREP49 : MEC Exam Weight Jack Knife Replicate 49 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6383    0.999    27311    21416    32604        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1918     4687    11635    41013    78725   100298 
#> 
#> lowest : 0       980.744 1164.21 1183.83 1191.29
#> highest: 219440  225683  226846  227783  261134 
#> --------------------------------------------------------------------------------
#> WTMREP50 : MEC Exam Weight Jack Knife Replicate 50 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6393    0.999    27311    21246    32589        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1946     4761    11684    40482    78794   100536 
#> 
#> lowest : 0       986.949 1170.53 1189.86 1197.75
#> highest: 221208  227946  229444  230349  261981 
#> --------------------------------------------------------------------------------
#> WTMREP51 : MEC Exam Weight Jack Knife Replicate 51 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6393    0.999    27311    21060    32844        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1887     4651    11390    40552    79527   102036 
#> 
#> lowest : 0       980.265 1165.66 1184.91 1192.77
#> highest: 227383  233917  235257  238829  259613 
#> --------------------------------------------------------------------------------
#> WTMREP52 : MEC Exam Weight Jack Knife Replicate 52 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     6393    0.999    27311    21353    32746        0 
#>      .10      .25      .50      .75      .90      .95 
#>     1684     4336    11743    40965    79062   100839 
#> 
#> lowest : 0       980.269 1163.41 1182.63 1190.47
#> highest: 221068  228321  229069  230455  260463 
#> --------------------------------------------------------------------------------
#> WTIREP01 : Interview Weight Jack Knife Replicate 01 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3359        1    27311    21871    30681     2022 
#>      .10      .25      .50      .75      .90      .95 
#>     2470     5879    13214    39410    75511    95439 
#> 
#> lowest : 0       1013.07 1198.13 1217.25 1229.89
#> highest: 186019  200425  209930  225116  238421 
#> --------------------------------------------------------------------------------
#> WTIREP02 : Interview Weight Jack Knife Replicate 02 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3388        1    27311    22079    30720     1875 
#>      .10      .25      .50      .75      .90      .95 
#>     2317     5838    13265    40105    75611    94485 
#> 
#> lowest : 0       977.221 1172.57 1191.35 1199.25
#> highest: 192835  199747  208953  218162  237014 
#> --------------------------------------------------------------------------------
#> WTIREP03 : Interview Weight Jack Knife Replicate 03 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3410        1    27311    22015    30289     2071 
#>      .10      .25      .50      .75      .90      .95 
#>     2564     6016    13355    39480    75026    93918 
#> 
#> lowest : 0       1025.18 1220.21 1243.15 1249.8 
#> highest: 190309  197131  206172  214218  236865 
#> --------------------------------------------------------------------------------
#> WTIREP04 : Interview Weight Jack Knife Replicate 04 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3377        1    27311    21981    30377     2055 
#>      .10      .25      .50      .75      .90      .95 
#>     2619     5993    13386    39220    74523    94314 
#> 
#> lowest : 0       1014.62 1218.11 1230.9  1235.49
#> highest: 191796  198671  206772  215613  237416 
#> --------------------------------------------------------------------------------
#> WTIREP05 : Interview Weight Jack Knife Replicate 05 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3410        1    27311    21943    30626     1986 
#>      .10      .25      .50      .75      .90      .95 
#>     2464     5849    13403    39302    75134    95179 
#> 
#> lowest : 0       974.666 1171.24 1190.59 1198.49
#> highest: 193828  200776  208952  217958  237748 
#> --------------------------------------------------------------------------------
#> WTIREP06 : Interview Weight Jack Knife Replicate 06 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3404        1    27311    21928    30648     1994 
#>      .10      .25      .50      .75      .90      .95 
#>     2476     5857    13313    39536    75013    95406 
#> 
#> lowest : 0       980.326 1183.15 1203.57 1210.67
#> highest: 195288  202288  208695  219256  238188 
#> --------------------------------------------------------------------------------
#> WTIREP07 : Interview Weight Jack Knife Replicate 07 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3381        1    27311    21928    30532     2073 
#>      .10      .25      .50      .75      .90      .95 
#>     2535     5873    13223    39207    74753    95497 
#> 
#> lowest : 0       993.164 1195.98 1214.97 1223.89
#> highest: 193171  200096  211966  219005  235375 
#> --------------------------------------------------------------------------------
#> WTIREP08 : Interview Weight Jack Knife Replicate 08 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3379        1    27311    21980    30638     1966 
#>      .10      .25      .50      .75      .90      .95 
#>     2419     5911    13443    39463    74504    95317 
#> 
#> lowest : 0       976.195 1171.98 1191.33 1199.23
#> highest: 193502  200439  211279  217032  237536 
#> --------------------------------------------------------------------------------
#> WTIREP09 : Interview Weight Jack Knife Replicate 09 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3349        1    27311    21951    30605     2002 
#>      .10      .25      .50      .75      .90      .95 
#>     2512     5870    13267    39419    74803    95053 
#> 
#> lowest : 0       987.5   1210.83 1213.9  1224.41
#> highest: 192882  199797  209485  217942  238836 
#> --------------------------------------------------------------------------------
#> WTIREP10 : Interview Weight Jack Knife Replicate 10 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3385        1    27311    21864    30766     1979 
#>      .10      .25      .50      .75      .90      .95 
#>     2461     5823    13135    39554    75279    95185 
#> 
#> lowest : 0       978.738 1176.81 1195.77 1204.17
#> highest: 195300  202301  207097  220924  240732 
#> --------------------------------------------------------------------------------
#> WTIREP11 : Interview Weight Jack Knife Replicate 11 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3400        1    27311    21720    30979     1968 
#>      .10      .25      .50      .75      .90      .95 
#>     2418     5774    12786    39613    75996    96858 
#> 
#> lowest : 0       984.718 1179.92 1199.38 1207.76
#> highest: 197238  204309  214244  224976  240440 
#> --------------------------------------------------------------------------------
#> WTIREP12 : Interview Weight Jack Knife Replicate 12 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3390        1    27311    21949    30723     1949 
#>      .10      .25      .50      .75      .90      .95 
#>     2395     5836    13399    39596    75017    95840 
#> 
#> lowest : 0       981.269 1171.12 1190.84 1198.35
#> highest: 183271  202795  209276  220654  237834 
#> --------------------------------------------------------------------------------
#> WTIREP13 : Interview Weight Jack Knife Replicate 13 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3391        1    27311    22090    30612     1964 
#>      .10      .25      .50      .75      .90      .95 
#>     2420     5876    13332    40071    75172    94509 
#> 
#> lowest : 0       974.665 1169.3  1188.62 1196.5 
#> highest: 191998  198880  207887  216481  236237 
#> --------------------------------------------------------------------------------
#> WTIREP14 : Interview Weight Jack Knife Replicate 14 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3398        1    27311    21748    30887     1988 
#>      .10      .25      .50      .75      .90      .95 
#>     2464     5782    12820    39500    75563    96244 
#> 
#> lowest : 0       974.665 1169.3  1188.62 1196.5 
#> highest: 196136  203167  211471  219985  242715 
#> --------------------------------------------------------------------------------
#> WTIREP15 : Interview Weight Jack Knife Replicate 15 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3403        1    27311    21447    31339     1916 
#>      .10      .25      .50      .75      .90      .95 
#>     2363     5684    12382    39914    76897    97982 
#> 
#> lowest : 0       974.665 1169.3  1188.62 1196.5 
#> highest: 202613  209876  219039  227735  241151 
#> --------------------------------------------------------------------------------
#> WTIREP16 : Interview Weight Jack Knife Replicate 16 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3406        1    27311    21698    31036     1970 
#>      .10      .25      .50      .75      .90      .95 
#>     2428     5744    12619    39832    76074    96206 
#> 
#> lowest : 0       982.671 1169.3  1188.62 1196.5 
#> highest: 200488  207675  214130  225636  241052 
#> --------------------------------------------------------------------------------
#> WTIREP17 : Interview Weight Jack Knife Replicate 17 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3394        1    27311    21963    30732     1933 
#>      .10      .25      .50      .75      .90      .95 
#>     2373     5843    13479    39525    74757    95588 
#> 
#> lowest : 0       979.944 1169.3  1188.62 1196.5 
#> highest: 194990  201979  207471  216762  237292 
#> --------------------------------------------------------------------------------
#> WTIREP18 : Interview Weight Jack Knife Replicate 18 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3330        1    27311    22001    30494     2010 
#>      .10      .25      .50      .75      .90      .95 
#>     2499     5980    13360    39163    74472    94789 
#> 
#> lowest : 0       1033.61 1255.84 1278.65 1284.74
#> highest: 191702  198574  208369  215844  237122 
#> --------------------------------------------------------------------------------
#> WTIREP19 : Interview Weight Jack Knife Replicate 19 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3389        1    27311    21917    30650     1996 
#>      .10      .25      .50      .75      .90      .95 
#>     2492     5895    13214    39426    75240    95117 
#> 
#> lowest : 0       990.147 1176.66 1196.51 1203.88
#> highest: 193359  200291  211490  219034  240663 
#> --------------------------------------------------------------------------------
#> WTIREP20 : Interview Weight Jack Knife Replicate 20 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3391        1    27311    22016    30324     2072 
#>      .10      .25      .50      .75      .90      .95 
#>     2627     5994    13391    39437    74920    93973 
#> 
#> lowest : 0       1012.42 1218.78 1240.39 1248.45
#> highest: 190796  197635  206225  214820  237367 
#> --------------------------------------------------------------------------------
#> WTIREP21 : Interview Weight Jack Knife Replicate 21 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3400        1    27311    21928    30758     1964 
#>      .10      .25      .50      .75      .90      .95 
#>     2419     5825    13049    39541    75464    95275 
#> 
#> lowest : 0       974.665 1171.22 1190.96 1198.46
#> highest: 195168  202164  210015  220806  238551 
#> --------------------------------------------------------------------------------
#> WTIREP22 : Interview Weight Jack Knife Replicate 22 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3369        1    27311    22012    30286     2090 
#>      .10      .25      .50      .75      .90      .95 
#>     2611     6052    13392    39425    74976    94043 
#> 
#> lowest : 0       1023.58 1251.44 1270.8  1276.5 
#> highest: 180932  190403  197228  214309  236979 
#> --------------------------------------------------------------------------------
#> WTIREP23 : Interview Weight Jack Knife Replicate 23 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3356        1    27311    21910    30519     2050 
#>      .10      .25      .50      .75      .90      .95 
#>     2554     5944    13364    39302    75101    94712 
#> 
#> lowest : 0       1015.55 1222.05 1244.38 1253.18
#> highest: 193707  200651  207113  216484  237791 
#> --------------------------------------------------------------------------------
#> WTIREP24 : Interview Weight Jack Knife Replicate 24 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3363        1    27311    21842    30623     1999 
#>      .10      .25      .50      .75      .90      .95 
#>     2535     5932    13208    39260    75417    95162 
#> 
#> lowest : 0       1024.1  1215.99 1238.64 1246.33
#> highest: 194593  201569  208883  219189  238519 
#> --------------------------------------------------------------------------------
#> WTIREP25 : Interview Weight Jack Knife Replicate 25 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3381        1    27311    22030    30343     1999 
#>      .10      .25      .50      .75      .90      .95 
#>     2561     6075    13384    39425    74911    93812 
#> 
#> lowest : 0       1090.63 1290.72 1316.86 1322.65
#> highest: 190269  197089  206249  214495  236876 
#> --------------------------------------------------------------------------------
#> WTIREP26 : Interview Weight Jack Knife Replicate 26 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3403        1    27311    21933    30641     1980 
#>      .10      .25      .50      .75      .90      .95 
#>     2458     5871    13304    39374    74887    95082 
#> 
#> lowest : 0       974.665 1169.3  1188.62 1196.5 
#> highest: 194358  201326  209667  220182  237925 
#> --------------------------------------------------------------------------------
#> WTIREP27 : Interview Weight Jack Knife Replicate 27 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3403        1    27311    21660    31158     1940 
#>      .10      .25      .50      .75      .90      .95 
#>     2376     5705    12462    39984    76498    96681 
#> 
#> lowest : 0       974.665 1169.3  1188.62 1196.5 
#> highest: 203838  211145  213345  231079  238878 
#> --------------------------------------------------------------------------------
#> WTIREP28 : Interview Weight Jack Knife Replicate 28 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3348        1    27311    21769    30887     1964 
#>      .10      .25      .50      .75      .90      .95 
#>     2411     5828    12948    39441    75426    95642 
#> 
#> lowest : 0       1008.97 1205.59 1216.29 1235.75
#> highest: 197490  204569  211490  222573  241459 
#> --------------------------------------------------------------------------------
#> WTIREP29 : Interview Weight Jack Knife Replicate 29 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3357        1    27311    21944    30485     2028 
#>      .10      .25      .50      .75      .90      .95 
#>     2526     5946    13381    39241    74876    94785 
#> 
#> lowest : 0       1006.32 1244.16 1244.8  1246.6 
#> highest: 192932  199848  207888  219168  237716 
#> --------------------------------------------------------------------------------
#> WTIREP30 : Interview Weight Jack Knife Replicate 30 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3384        1    27311    21831    30891     1953 
#>      .10      .25      .50      .75      .90      .95 
#>     2384     5786    13060    39512    75596    95999 
#> 
#> lowest : 0       976.576 1179.08 1198.94 1206.55
#> highest: 195896  202918  210545  221414  238268 
#> --------------------------------------------------------------------------------
#> WTIREP31 : Interview Weight Jack Knife Replicate 31 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3378        1    27311    21974    30364     2059 
#>      .10      .25      .50      .75      .90      .95 
#>     2601     5996    13406    39287    74439    94405 
#> 
#> lowest : 0       1033.38 1204.51 1253.05 1262.35
#> highest: 191317  198175  206963  215066  238065 
#> --------------------------------------------------------------------------------
#> WTIREP32 : Interview Weight Jack Knife Replicate 32 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3384        1    27311    21774    30976     1964 
#>      .10      .25      .50      .75      .90      .95 
#>     2409     5763    12740    39855    76121    95842 
#> 
#> lowest : 0       986.975 1182.42 1201.95 1209.92
#> highest: 199225  206367  217422  224020  232851 
#> --------------------------------------------------------------------------------
#> WTIREP33 : Interview Weight Jack Knife Replicate 33 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3373        1    27311    21843    30791     1968 
#>      .10      .25      .50      .75      .90      .95 
#>     2427     5811    13186    39413    74998    96412 
#> 
#> lowest : 0       974.665 1170.98 1190.32 1198.22
#> highest: 196506  203550  212453  218990  237123 
#> --------------------------------------------------------------------------------
#> WTIREP34 : Interview Weight Jack Knife Replicate 34 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3338        1    27311    21996    30479     2009 
#>      .10      .25      .50      .75      .90      .95 
#>     2546     5984    13437    39531    75177    94295 
#> 
#> lowest : 0       1045.44 1258.46 1281.36 1283.83
#> highest: 191718  198591  207290  216369  237637 
#> --------------------------------------------------------------------------------
#> WTIREP35 : Interview Weight Jack Knife Replicate 35 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3359        1    27311    22021    30581     1978 
#>      .10      .25      .50      .75      .90      .95 
#>     2467     5957    13360    39545    74751    95106 
#> 
#> lowest : 0       979.73  1172.83 1192.2  1200.11
#> highest: 197630  204715  211525  221998  232642 
#> --------------------------------------------------------------------------------
#> WTIREP36 : Interview Weight Jack Knife Replicate 36 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3410        1    27311    21758    30836     1992 
#>      .10      .25      .50      .75      .90      .95 
#>     2473     5763    12934    39265    75601    96353 
#> 
#> lowest : 0       974.665 1169.3  1188.62 1196.5 
#> highest: 196460  203503  214494  220996  238208 
#> --------------------------------------------------------------------------------
#> WTIREP37 : Interview Weight Jack Knife Replicate 37 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3384        1    27311    22005    30347     2057 
#>      .10      .25      .50      .75      .90      .95 
#>     2559     6021    13409    39425    74625    94197 
#> 
#> lowest : 0       1034.49 1217.72 1237.35 1248.71
#> highest: 191050  197899  206822  215092  237795 
#> --------------------------------------------------------------------------------
#> WTIREP38 : Interview Weight Jack Knife Replicate 38 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3385        1    27311    21919    30687     1966 
#>      .10      .25      .50      .75      .90      .95 
#>     2453     5852    13207    39439    75310    94822 
#> 
#> lowest : 0       974.667 1171.37 1191.15 1198.62
#> highest: 195293  202294  207231  218051  241174 
#> --------------------------------------------------------------------------------
#> WTIREP39 : Interview Weight Jack Knife Replicate 39 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3375        1    27311    21885    30591     2025 
#>      .10      .25      .50      .75      .90      .95 
#>     2506     5861    13211    39302    74724    94923 
#> 
#> lowest : 0       1000.14 1192.48 1211.31 1219.55
#> highest: 193347  200277  208115  217037  239060 
#> --------------------------------------------------------------------------------
#> WTIREP40 : Interview Weight Jack Knife Replicate 40 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3382        1    27311    21993    30336     2067 
#>      .10      .25      .50      .75      .90      .95 
#>     2581     5992    13417    39163    74527    94384 
#> 
#> lowest : 0       1013.42 1235.39 1241.42 1255.61
#> highest: 191652  198522  204858  213548  237986 
#> --------------------------------------------------------------------------------
#> WTIREP41 : Interview Weight Jack Knife Replicate 41 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3386        1    27311    21829    30866     1951 
#>      .10      .25      .50      .75      .90      .95 
#>     2391     5810    13130    39496    75450    96337 
#> 
#> lowest : 0       984.649 1178.49 1198.39 1207.45
#> highest: 196565  203612  212985  221568  239760 
#> --------------------------------------------------------------------------------
#> WTIREP42 : Interview Weight Jack Knife Replicate 42 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3407        1    27311    21677    30997     1966 
#>      .10      .25      .50      .75      .90      .95 
#>     2453     5745    12650    39648    75862    96192 
#> 
#> lowest : 0       974.665 1169.3  1188.62 1196.5 
#> highest: 200315  207496  211625  221522  239611 
#> --------------------------------------------------------------------------------
#> WTIREP43 : Interview Weight Jack Knife Replicate 43 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3380        1    27311    21870    30728     1960 
#>      .10      .25      .50      .75      .90      .95 
#>     2422     5872    13330    39366    74995    96023 
#> 
#> lowest : 0       982.298 1190.08 1211.3  1217.71
#> highest: 194698  201677  209755  218100  239321 
#> --------------------------------------------------------------------------------
#> WTIREP44 : Interview Weight Jack Knife Replicate 44 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3402        1    27311    21889    30701     1986 
#>      .10      .25      .50      .75      .90      .95 
#>     2462     5825    13144    39524    75980    95145 
#> 
#> lowest : 0       974.665 1169.3  1188.62 1196.5 
#> highest: 192838  199751  212193  221139  237572 
#> --------------------------------------------------------------------------------
#> WTIREP45 : Interview Weight Jack Knife Replicate 45 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3408        1    27311    21718    31039     1964 
#>      .10      .25      .50      .75      .90      .95 
#>     2422     5737    12603    40103    76510    97109 
#> 
#> lowest : 0       974.665 1169.3  1188.62 1196.5 
#> highest: 194817  200786  207984  217323  235750 
#> --------------------------------------------------------------------------------
#> WTIREP46 : Interview Weight Jack Knife Replicate 46 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3378        1    27311    21791    30855     1985 
#>      .10      .25      .50      .75      .90      .95 
#>     2408     5806    13029    39787    75568    95736 
#> 
#> lowest : 0       985.996 1190.74 1210.98 1218.43
#> highest: 197469  204547  216084  224284  241834 
#> --------------------------------------------------------------------------------
#> WTIREP47 : Interview Weight Jack Knife Replicate 47 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3382        1    27311    21882    30787     1966 
#>      .10      .25      .50      .75      .90      .95 
#>     2409     5824    13137    39840    75908    95752 
#> 
#> lowest : 0       984.405 1192.58 1212.24 1219.6 
#> highest: 202432  209689  213783  226232  232739 
#> --------------------------------------------------------------------------------
#> WTIREP48 : Interview Weight Jack Knife Replicate 48 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3351        1    27311    22056    30431     1992 
#>      .10      .25      .50      .75      .90      .95 
#>     2539     5989    13384    39496    75003    94127 
#> 
#> lowest : 0       1238.55 1244.96 1269.55 1282.3 
#> highest: 190732  197570  205353  213418  237148 
#> --------------------------------------------------------------------------------
#> WTIREP49 : Interview Weight Jack Knife Replicate 49 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3392        1    27311    22093    30576     1984 
#>      .10      .25      .50      .75      .90      .95 
#>     2462     5888    13242    39949    74565    94452 
#> 
#> lowest : 0       975.834 1172.66 1192.42 1199.94
#> highest: 192037  198921  207301  216324  237076 
#> --------------------------------------------------------------------------------
#> WTIREP50 : Interview Weight Jack Knife Replicate 50 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3380        1    27311    21920    30551     2001 
#>      .10      .25      .50      .75      .90      .95 
#>     2486     5909    13320    39118    74675    94570 
#> 
#> lowest : 0       978.609 1176.47 1195.9  1203.83
#> highest: 193863  200813  209981  217956  238360 
#> --------------------------------------------------------------------------------
#> WTIREP51 : Interview Weight Jack Knife Replicate 51 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3404        1    27311    21781    30861     1966 
#>      .10      .25      .50      .75      .90      .95 
#>     2424     5812    12999    39387    75668    95988 
#> 
#> lowest : 0       974.665 1169.3  1188.62 1196.5 
#> highest: 200460  207646  212284  223851  236649 
#> --------------------------------------------------------------------------------
#> WTIREP52 : Interview Weight Jack Knife Replicate 52 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     9965    91351     3409        1    27311    22043    30715     1888 
#>      .10      .25      .50      .75      .90      .95 
#>     2317     5803    13484    40037    75073    94815 
#> 
#> lowest : 0       974.665 1169.3  1188.62 1196.5 
#> highest: 193841  200790  207804  217840  236964 
#> --------------------------------------------------------------------------------
#> cycle 
#>        n  missing distinct 
#>   101316        0       10 
#>                                                                       
#> Value      1999-2000 2001-2002 2003-2004 2005-2006 2007-2008 2009-2010
#> Frequency       9965     11039     10122     10348     10149     10537
#> Proportion     0.098     0.109     0.100     0.102     0.100     0.104
#>                                                   
#> Value      2011-2012 2013-2014 2015-2016 2017-2018
#> Frequency       9756     10175      9971      9254
#> Proportion     0.096     0.100     0.098     0.091
#> --------------------------------------------------------------------------------
#> SIALANG 
#>        n  missing distinct     Info     Mean 
#>    80309    21007        2    0.342    1.131 
#>                       
#> Value          1     2
#> Frequency  69777 10532
#> Proportion 0.869 0.131
#> --------------------------------------------------------------------------------
#> SIAPROXY 
#>        n  missing distinct     Info     Mean 
#>    80298    21018        2    0.701    1.628 
#>                       
#> Value          1     2
#> Frequency  29873 50425
#> Proportion 0.372 0.628
#> --------------------------------------------------------------------------------
#> SIAINTRP 
#>        n  missing distinct     Info     Mean 
#>    80309    21007        2    0.077    1.974 
#>                       
#> Value          1     2
#> Frequency   2124 78185
#> Proportion 0.026 0.974
#> --------------------------------------------------------------------------------
#> FIALANG 
#>        n  missing distinct     Info     Mean 
#>    78835    22481        2    0.259    1.095 
#>                       
#> Value          1     2
#> Frequency  71314  7521
#> Proportion 0.905 0.095
#> --------------------------------------------------------------------------------
#> FIAPROXY 
#>        n  missing distinct     Info     Mean 
#>    78835    22481        2    0.005    1.998 
#>                       
#> Value          1     2
#> Frequency    128 78707
#> Proportion 0.002 0.998
#> --------------------------------------------------------------------------------
#> FIAINTRP 
#>        n  missing distinct     Info     Mean 
#>    78835    22481        2    0.068    1.977 
#>                       
#> Value          1     2
#> Frequency   1842 76993
#> Proportion 0.023 0.977
#> --------------------------------------------------------------------------------
#> MIALANG 
#>        n  missing distinct     Info     Mean 
#>    55759    45557        2    0.221     1.08 
#>                       
#> Value          1     2
#> Frequency  51283  4476
#> Proportion  0.92  0.08
#> --------------------------------------------------------------------------------
#> MIAPROXY 
#>        n  missing distinct     Info     Mean 
#>    55761    45555        2    0.019    1.994 
#>                       
#> Value          1     2
#> Frequency    350 55411
#> Proportion 0.006 0.994
#> --------------------------------------------------------------------------------
#> MIAINTRP 
#>        n  missing distinct     Info     Mean 
#>    55761    45555        2    0.058     1.98 
#>                       
#> Value          1     2
#> Frequency   1099 54662
#> Proportion  0.02  0.98
#> --------------------------------------------------------------------------------
#> AIALANG 
#>        n  missing distinct     Info     Mean 
#>    25256    76060        2    0.279    1.104 
#>                       
#> Value          1     2
#> Frequency  22636  2620
#> Proportion 0.896 0.104
#> --------------------------------------------------------------------------------
#> DMDFMSIZ 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>    70190    31126        7    0.974     3.67      3.5    2.019 
#>                                                     
#> Value          1     2     3     4     5     6     7
#> Frequency   9299 11879 11895 14359 10949  6019  5790
#> Proportion 0.132 0.169 0.169 0.205 0.156 0.086 0.082
#> --------------------------------------------------------------------------------
#> DMDBORN2 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>    20686    80630        6     0.45    1.447        1   0.7783 
#>                                               
#> Value          1     2     4     5     7     9
#> Frequency  16938  1550  1120  1065    11     2
#> Proportion 0.819 0.075 0.054 0.051 0.001 0.000
#> --------------------------------------------------------------------------------
#> INDHHIN2 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>    58628    42688       16    0.991    11.36      8.5    10.36        2 
#>      .10      .25      .50      .75      .90      .95 
#>        3        5        8       14       15       15 
#>                                                                             
#> Value          1     2     3     4     5     6     7     8     9    10    12
#> Frequency   1563  2430  3857  4056  4596  6919  5498  4310  3337  2683  2094
#> Proportion 0.027 0.041 0.066 0.069 0.078 0.118 0.094 0.074 0.057 0.046 0.036
#>                                         
#> Value         13    14    15    77    99
#> Frequency    757  5171  9126  1244   987
#> Proportion 0.013 0.088 0.156 0.021 0.017
#> --------------------------------------------------------------------------------
#> INDFMIN2 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>    58699    42617       16    0.992    11.08      8.5    10.36        2 
#>      .10      .25      .50      .75      .90      .95 
#>        3        5        7       14       15       15 
#>                                                                             
#> Value          1     2     3     4     5     6     7     8     9    10    12
#> Frequency   2147  2755  4178  4205  4711  6940  5434  4235  3231  2582  1647
#> Proportion 0.037 0.047 0.071 0.072 0.080 0.118 0.093 0.072 0.055 0.044 0.028
#>                                         
#> Value         13    14    15    77    99
#> Frequency    790  4930  8696  1270   948
#> Proportion 0.013 0.084 0.148 0.022 0.016
#> --------------------------------------------------------------------------------
#> DMDHRBR2 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>    20141    81175        6    0.629    1.646        1    1.037 
#>                                               
#> Value          1     2     4     5     7     9
#> Frequency  14435  2735  1646  1310     6     9
#> Proportion 0.717 0.136 0.082 0.065 0.000 0.000
#> --------------------------------------------------------------------------------
#> RIDRETH3 : Recode of reported race and Hispanic origin information 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>    39156    62160        6    0.944    3.357      3.5    1.802 
#>                                               
#> Value          1     2     3     4     6     7
#> Frequency   6373  4164 12863  9194  4566  1996
#> Proportion 0.163 0.106 0.329 0.235 0.117 0.051
#> --------------------------------------------------------------------------------
#> RIDEXAGY 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     3418    97898       19    0.997    9.641      9.5    5.954        2 
#>      .10      .25      .50      .75      .90      .95 
#>        3        5        9       14       17       19 
#>                                                                             
#> Value          2     3     4     5     6     7     8     9    10    11    12
#> Frequency    276   233   220   175   225   217   215   217   191   207   148
#> Proportion 0.081 0.068 0.064 0.051 0.066 0.063 0.063 0.063 0.056 0.061 0.043
#>                                                           
#> Value         13    14    15    16    17    18    19    20
#> Frequency    178   161   141   168   144   124   168    10
#> Proportion 0.052 0.047 0.041 0.049 0.042 0.036 0.049 0.003
#> --------------------------------------------------------------------------------
#> RIDEXAGM 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>    15715    85601      240        1    105.9    105.5    80.18      6.0 
#>      .10      .25      .50      .75      .90      .95 
#>     14.0     43.0    102.0    163.0    207.0    222.3 
#> 
#> lowest :   0   1   2   3   4, highest: 235 236 237 238 239
#> --------------------------------------------------------------------------------
#> DMQMILIZ 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>    24421    76895        4    0.245    1.912        2   0.1645 
#>                                   
#> Value          1     2     7     9
#> Frequency   2182 22235     3     1
#> Proportion 0.089 0.910 0.000 0.000
#> --------------------------------------------------------------------------------
#> DMQADFC 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>     2182    99134        4    0.751    1.502      1.5   0.5265 
#>                                   
#> Value          1     2     7     9
#> Frequency   1116  1061     3     2
#> Proportion 0.511 0.486 0.001 0.001
#> --------------------------------------------------------------------------------
#> DMDBORN4 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>    39156    62160        4    0.496    1.242        1   0.3961 
#>                                   
#> Value          1     2    77    99
#> Frequency  30966  8175     8     7
#> Proportion 0.791 0.209 0.000 0.000
#> --------------------------------------------------------------------------------
#> AIALANGA 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>    23010    78306        3    0.281     1.12        1   0.2176 
#>                             
#> Value          1     2     3
#> Frequency  20603  2053   354
#> Proportion 0.895 0.089 0.015
#> --------------------------------------------------------------------------------
#> DMDHHSZA 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>    39156    62160        4    0.725   0.5322      0.5   0.7643 
#>                                   
#> Value          0     1     2     3
#> Frequency  25082  8550  4282  1242
#> Proportion 0.641 0.218 0.109 0.032
#> --------------------------------------------------------------------------------
#> DMDHHSZB 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>    39156    62160        5    0.867   0.9717        1    1.209 
#>                                         
#> Value          0     1     2     3     4
#> Frequency  19213  8161  6860  3521  1401
#> Proportion 0.491 0.208 0.175 0.090 0.036
#> --------------------------------------------------------------------------------
#> DMDHHSZE 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>    39156    62160        4    0.639   0.4205        0   0.6405 
#>                                   
#> Value          0     1     2     3
#> Frequency  27720  6657  4529   250
#> Proportion 0.708 0.170 0.116 0.006
#> --------------------------------------------------------------------------------
#> DMDHRBR4 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>    28844    72472        4    0.655    1.413      1.5    0.618 
#>                                   
#> Value          1     2    77    99
#> Frequency  19561  9251    22    10
#> Proportion 0.678 0.321 0.001 0.000
#> --------------------------------------------------------------------------------
#> DMDHRAGZ 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>     9254    92062        4    0.885     2.86        3   0.8777 
#>                                   
#> Value          1     2     3     4
#> Frequency    121  3411  3364  2358
#> Proportion 0.013 0.369 0.364 0.255
#> --------------------------------------------------------------------------------
#> DMDHREDZ 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>     8764    92552        3    0.793    2.051        2   0.6711 
#>                             
#> Value          1     2     3
#> Frequency   1656  5007  2101
#> Proportion 0.189 0.571 0.240
#> --------------------------------------------------------------------------------
#> DMDHRMAZ 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>     9063    92253        3    0.698    1.473      1.5   0.6812 
#>                             
#> Value          1     2     3
#> Frequency   6006  1830  1227
#> Proportion 0.663 0.202 0.135
#> --------------------------------------------------------------------------------
#> DMDHSEDZ 
#>        n  missing distinct     Info     Mean  pMedian      Gmd 
#>     4751    96565        3    0.831    2.111        2   0.7239 
#>                             
#> Value          1     2     3
#> Frequency    892  2441  1418
#> Proportion 0.188 0.514 0.298
#> --------------------------------------------------------------------------------

# Supply descriptions from a prior nhanes_search_variables() call
vars <- nhanes_search_variables("cholesterol")
#> Fetching variable catalog for Demographics from CDC...
#> Fetching variable catalog for Dietary from CDC...
#> Fetching variable catalog for Examination from CDC...
#> Fetching variable catalog for Questionnaire from CDC...
#> Found 74 unique variables matching "cholesterol".
NH_describe(tc, descriptions = vars)
#> NH_label(x, descriptions = descriptions) 
#> 
#>  4  Variables      8021  Observations
#> --------------------------------------------------------------------------------
#> SEQN 
#>        n  missing distinct 
#>     8021        0     8021 
#> 
#> lowest : 83732 83733 83734 83735 83736, highest: 93697 93699 93700 93701 93702
#> --------------------------------------------------------------------------------
#> LBXTC : Total cholesterol (mg/dL) 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     7256      765      257        1    180.3      178    45.47      122 
#>      .10      .25      .50      .75      .90      .95 
#>      132      150      176      204      234      254 
#> 
#> lowest :  77  80  81  84  85, highest: 393 415 433 540 545
#> --------------------------------------------------------------------------------
#> LBDTCSI : Total cholesterol (mmol/L) 
#>        n  missing distinct     Info     Mean  pMedian      Gmd      .05 
#>     7256      765      257        1    4.661      4.6    1.176     3.15 
#>      .10      .25      .50      .75      .90      .95 
#>     3.41     3.88     4.55     5.28     6.05     6.57 
#> 
#> lowest : 1.99  2.07  2.09  2.17  2.2  , highest: 10.16 10.73 11.2  13.96 14.09
#> --------------------------------------------------------------------------------
#> cycle 
#>         n   missing  distinct     value 
#>      8021         0         1 2015-2016 
#>                     
#> Value      2015-2016
#> Frequency       8021
#> Proportion         1
#> --------------------------------------------------------------------------------
# }
```
