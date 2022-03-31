# Rscript to pre-process DNAm data in LBC1936
# Read accompanying .RMarkdown file (dnam_preproc.Rmd) for information on the steps carried out below
# Create flags for input of the script (read in datasets)
# Source functions from another file if relevant 
# Document output with sink
### How to run script on eddie:
# Rscript dnam_preproc.R --dnam --probes_to_exclude --covdata --covname --datasetname

# Rscript version: 3.6.3

##### R packages
library(optparse) # For option parsing
library(dplyr) # For data management
library(tibble) # For data management
# BiocManager::install("lumi")
library(lumi) # For beta2m
library(limma) # For lmFit
library(FactoMineR) # For PCA


##### Set up command line arguments
args <- commandArgs(trailingOnly=TRUE) # Reads variables stored in the bash environment in R
parse <- OptionParser()

# Option flags contain information about each file that is used in the script

option_list <- list(
  make_option('--dnam', type='character', help='DNAm data file', action='store'),
  make_option('--probes_to_exclude', type='character', default=NULL, help='Probes to exclude (450K array)', action='store'),
  make_option('--covdata', type='character', default=NULL, help='Covariate file for DNAm regression', action='store'),
  make_option('--covname', type='character', default=NULL, help='To be used for selecting covariates; MUST BE: for_methpc / mdd_ms_resids', action='store'),
  make_option('--datasetname', type='character',default=NULL, help='Name of DNAm dataset and wave',action='store'))

opt <- parse_args(OptionParser(option_list=option_list), args=args)

# Assign names to the files in command line arguments
dnam_data=opt$dnam
exclprob=opt$probes_to_exclude
covariates=opt$covdata
covname=opt$covname
name=opt$datasetname

# Output to a log file
sink(file=paste0("./logs/",name,"_",covname,"_logfile.log"), append=TRUE)
cat("DNAm pre-processing script in ",name, "\n")

# Read in datasets
dnam_data=readRDS(dnam_data)
probes=read.table(exclprob, header=T)
covs=readRDS(covariates)

cat("Log-transform beta to m-values: " ,"\n")
Sys.time()

# 1. Log-transform beta to m-values
mval=beta2m(dnam_data)

# Report that everything looks fine with data
cat("DNAm has been transformed from beta to m-values:", "\n")
cat("Minimum m-value: ", min(mval, na.rm=T),"\n")
cat("Maximum m-value: ", max(mval, na.rm=T),"\n")

# Check "Inf" or "-Inf" values in new dataset
if(min(mval, na.rm=T) == -Inf | max(mval, na.rm=T) == Inf){
    stop("Inf values in DNAm data.","\n")
    quit(save="no")
} else {
  cat("No Inf values in DNAm data.","\n")
}

# Quit if "Inf" or "-Inf" values identified in new dataset
if(min(mval, na.rm=T) == -Inf | max(mval, na.rm=T) == Inf){
    quit(save="no")
}


# Create histograms for beta- and m-values: to better visualise the distributions for each data type
tiff(paste0("../output/",name,"_",covname,"_beta_mvalue_comparison.tiff"),width=2400,height=1200,res=300)
par(mfrow=c(1,2))
hist(dnam_data, main="Beta values", 
     xlab="Beta values", 
     border="lightblue")
hist(mval, main="M-values", 
     xlab="M-values", 
     border="lightblue")
dev.off()

# Remove dnam_data
rm(dnam_data)


# 2. Exclude polymorphic, ch- and cross-hybridising CpGs
cat("Exclude polymorphic and cross-hybridising CpGs: " ,"\n")
Sys.time()

mval_proberem = subset(mval, !(rownames(mval) %in% probes$cpg))

# Report N CpGs that were removed
cat("Polymorphic and cross-hybridising CpGs now removed", "\n")
cat("N CpGs before probe removal:", nrow(mval),"\n")
cat("N CpGs after probe removal:", nrow(mval_proberem),"\n")
cat("NA values after probe removal: ", sum(is.na(mval)),"\n")

# Remove mval
rm(mval)

# 3. Regress DNAm m-values on relevant covariates:
if (covname=="for_methpc") {
  cat("Regressing DNAm on technical covariates, cell counts, age, and sex (for methylation PC calculation)", "\n")
} else {
  cat("Regressing DNAm on technical covariates and cell counts (for MDD methylation score residuals)", "\n")

}


# Use lmFit and extract residuals; this is set to include the following standard covariates (following procedure from Marioni et al., https://genomebiology.biomedcentral.com/articles/10.1186/s13059-015-0584-6#Sec9):
# age, sex, plate, array, position on the chip, white blood cell counts (for methylation PC calculation)
# plate, array, position on the chip, white blood cell counts (for using residuals in downstream MDD MS calculation)

if (covname=="for_methpc") {
  covs_select=c("Basename","sex","age","array","plate","pos","NK","Bcell","Gran","CD4T","CD8T")
} else {
  covs_select=c("Basename","array","plate","pos","NK","Bcell","Gran","CD4T","CD8T")
}

covs_resid=select(covs,contains(covs_select))
colnames(covs_resid)[1]<-"ID"

# Check which covariates were selected:
cat("Covariates selected:" , paste(names(covs_resid)[-1], collapse=','),"\n")

# Remove covs_list as we now have a refined covariate list for inclusion in regression models
rm(covs)

# Remove NAs
row.is.na = covs_resid[rowSums(is.na(covs_resid)) >0, ] # extract rows where at least one column has NAs

# Report covariate NAs
if(nrow(row.is.na) > 0){
  cat(nrow(row.is.na), "NAs in" ,colnames(row.is.na)[colSums(is.na(row.is.na)) > 0],"\n")
} else {
  cat(nrow(row.is.na), "NAs in covariate file","\n")
}

# Remove NAs in covariates
covs_resid=covs_resid[complete.cases(covs_resid),]
# Remove participant NAs in meth file
mval_forresid=mval_proberem[,!colnames(mval_proberem) %in% row.is.na$ID]
# Remove probes with NA from meth file
mval_forresid=mval_forresid[complete.cases(mval_forresid),]

# Remove mval_proberem
rm(mval_proberem)

# Report number of CpG and participants after NA removal
cat("N CpGs after NA removal:", nrow(mval_forresid),"\n")

# Check that the number of individuals in covs_resid is the same as number of individuals in DNAm columns
covs_resid=subset(covs_resid, ID %in% colnames(mval_forresid))

cat("N participants in covariate file:", nrow(covs_resid),"\n")
cat("N participants in DNAm file:", ncol(mval_forresid),"\n")

# Drop levels to not have any NA warnings when running lmFit
covs_resid$ID=droplevels(covs_resid$ID)
covs_resid$plate=droplevels(covs_resid$plate)
covs_resid$pos=droplevels(covs_resid$pos)

# Run lmFit
cat("Running lmFit","\n")
Sys.time()

# Put formula together for covariates
model_formula <- as.formula(paste('~', paste(names(covs_resid)[-1], collapse=' + ')))
design <- model.matrix(model_formula, data=covs_resid)

# Run regression model
fitlm <- lmFit(mval_forresid, design)

# Extract residuals from lmFit (no need to run eBayes to extract residuals)
# Source: https://bioconductor.org/packages/devel/bioc/manuals/limma/man/limma.pdf; http://web.mit.edu/~r/current/arch/i386_linux26/lib/R/library/limma/html/residuals.MArrayLM.html
meth_resids=residuals.MArrayLM(fitlm, mval_forresid)

# Create histogram for residuals
tiff(paste0("../output/",name,"_",covname,"_residual_histogram.tiff"),width=2400,height=1200,res=300)
hist(meth_resids, main="M-values (residuals)", 
     xlab="M-values", 
     border="lightblue")
dev.off()

# Save residuals for MDD ms score calculation only; these will be used in downstream analyses; those for calculating methylation PCs should not be saved
if (covname=="mdd_ms_resids") {
  saveRDS(meth_resids, paste0("../output/",name,"_",covname,".rds"))#
  
  cat("Residuals extracted and saved.","\n")
}

# 4. Create methylation PCs - this is only if the flag for "covname" is "for_methpc"

if (covname=="for_methpc") {

  cat("Calculating methylation PCs.","\n")
  Sys.time()

  # Transpose meth_resids to CpGs as cols, methIDs as rows
  transp_meth_resids = t(meth_resids)
  
  # Run PCA
  pca_results = PCA(transp_meth_resids, scale.unit = TRUE, ncp = 20, graph = F)
  pca_methyl = pca_results$ind$coord
  
  # Reformat to fit downstream analyses
  colnames(pca_methyl)=paste0('PC',1:20)
  pca_methyl = pca_methyl %>% data.frame %>%
    rownames_to_column(var='ID') %>% data.frame
    
  # Save methylation PCs
  saveRDS(pca_methyl, paste0("../output/",name,"_",covname,"_20pcs.rds"))
   
  # Produce eigenvalue plot to visualise % of variance explained by each PC
  tiff(paste0("../output/",name,"_",covname,"_pc_variances.tiff"),width=2400,height=1000,res=300)
  eig.val <- pca_results$eig
  barplot(eig.val[, 2], 
          names.arg = 1:nrow(eig.val), 
          main = "Variances Explained by PCs (%)",
          xlab = "Principal Components",
          ylab = "Percentage of variances",
          ylim=c(0,c(max(eig.val[,2])+1)), # ensure that y-axis is extended 1% past the maximum percentage explained
          col ="lightblue")
  dev.off()
  
  cat("Methylation PCs saved.","\n")
  
}

if (covname=="for_methpc") {
  cat("Analysis pipeline finished for methylation PC script version.","\n")
  Sys.time()
} else {
  cat("Analysis pipeline finished for MDD methylation score script version.","\n")
  Sys.time()
}

# Print sessionInfo to indicate packages used
cat("Session info: ","\n")
sessionInfo()

