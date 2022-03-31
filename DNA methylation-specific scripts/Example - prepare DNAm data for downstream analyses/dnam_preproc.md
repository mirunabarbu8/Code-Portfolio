LBC - DNAm pre-processing
================

### LBC1936 DNAm pre-processing

The script “dnam\_preproc.R” is used to pre-process DNAm data in LBC1936
prior to downstream analyses. Details of previous QC (based on raw
intensities) are presented
[here](https://www.medrxiv.org/content/10.1101/2020.07.20.20156935v1.full.pdf).

Steps include:

1.  Log-transform beta values to m-values; check any abnormalities in
    DNAm data (e.g. extreme values in beta value matrix; “Inf” values
    produced by outlying beta values); turn these to NA

2.  Exclude polymorphic and cross-hybridising CpG sites (450K
    array-specific; [DOI for
    source](https://dx.doi.org/10.4161%2Fepi.23470))

3.  Data pre-processing; this has 2 steps depending on downstream
    procedures:

( a ) regress on age, sex, technical covariates, and cell count
estimates to extract residuals (these will be input to create
methylation PCs in script below)

( b ) regress technical covariates and cell count estimates to extract
residuals (these will be saved and an MDD methylation score will be
calculated using these residuals)

4.  Create methylation PCs (extract 20; for option “a” only)
