# Rscript to calculate methylation scores
# Create flags for input of the script (read in datasets)
# Source functions from another file if relevant
# Document output with sink
### How to run script on eddie:
# Rscript calculate_ms.R --dnam --dnamid --pval --coef --name --out

# Rscript version: 3.6.3

##### R packages
library(data.table) # Data management
library(optparse) # For option parsing
library(tibble) # Data management

##### Set up command line arguments
args <- commandArgs(trailingOnly=TRUE) # Reads variables stored in the bash environment in R
parse <- OptionParser()

# Option flags contain information about each file that is used in the script

# Create options list
option_list <- list(
  make_option('--dnam', type='character', help="DNAm data file", action='store'),
  make_option('--dnamid', type='character', help="Participants to include in the analysis", action='store'),
  make_option("--pval", type="character", help="P-value thresholds to include in analysis; no threshold limit", action='store'),
  make_option('--coef', type='character', help="Base/training data coefficients; needs to have CpG sites, weights and p-value (in that order)", action='store'),
  make_option('--name', type='character', help="Name of dataset", action='store'),
  make_option('--out', type='character', help="Output file", action='store'))

opt <- parse_args(OptionParser(option_list=option_list), args=args)

dnam_data = opt$dnam
dnamid = opt$dnamid
pval = opt$pval
coeffile = opt$coef
name=opt$name
output = opt$out

# Output to a log file
sink(file=paste0("./logs/",name,"_logfile.log"), append=TRUE)
cat("Calculate methylation scores in ",name, "\n")

# Read in datasets
dnam_data = readRDS(dnam_data)
dnamid = readRDS(dnamid)
coeffile = readRDS(coeffile)
colnames(coeffile)=c("coef.name","coef.value","coef.pval")

cat("Start calculation: " ,"\n")
Sys.time()

# Prepare data for methylation score calculation
# Turn the string of p-values into numeric values
pval_num = strsplit(pval, ",")[[1]]
pval_num=as.numeric(pval_num)

# Intersect individuals in DNAm data that are in the participant ID file
a = which(colnames(dnam_data) %in% dnamid$ID)
meth = dnam_data[,a]
# Remove original DNAm data
rm(dnam_data)

cat("N participants in DNAm data after intersecting with individuals in participant ID file:", ncol(meth) ,"\n")

# Select p-value from coefficient file
# Create empty list to store data

coef_selected_pvals = list()
# Select p-value thresholds from coeffile
for(n in pval_num){
  
  # Select all p-value threshold provided and store in list
  coef_selected_pvals[[length(coef_selected_pvals) + 1]] = subset(coeffile, coef.pval < n)
  
}

# For coeffile, assign "coef.name" to rownames; this will be used in methylation score calculation below
for(i in 1:length(coef_selected_pvals)){
  rownames(coef_selected_pvals[[i]])<-coef_selected_pvals[[i]]$coef.name
}

# From "meth", subset all CpGs that are present in "coef.name" in "coeffile"
meth_pvals = lapply(1:length(coef_selected_pvals), function(x) subset(meth, rownames(meth) %in% coef_selected_pvals[[x]]$coef.name))

# Intersect probes in coeffile with probes in meth_pvals; each element number in coef_selected_pvals corresponds to the same element number in meth_pvals
probes = lapply(1:length(coef_selected_pvals), function(x) intersect(coef_selected_pvals[[x]]$coef.name, rownames(meth_pvals[[x]])))

cat("N CpG sites in DNAm data intersecting with those at each p-value threshold:","\n")
probes2=probes
names(probes2)<-pval_num
print(lengths(probes2))

# Calculate methylation scores

b = lapply(1:length(meth_pvals), function(x) meth_pvals[[x]][probes[[x]],])

p = lapply(1:length(coef_selected_pvals), function(x) coef_selected_pvals[[x]][probes[[x]],])

mval_product = lapply(1:length(meth_pvals), function(x) b[[x]]*p[[x]]$coef.value) 

predicted_score = lapply(1:length(mval_product), function(x) colSums(mval_product[[x]]))

# Turn to dataframe
pred_score = purrr:::reduce(predicted_score, data.frame)
# Change column names - these will be in the same order as the pval_num variable
colnames(pred_score)[1:length(predicted_score)]<-lapply(pval_num, function(x) paste0("methyl_score_",x))
# Assign rownames to an ID column
pred_score$ID = rownames(pred_score)

# Save file with all methylation scores incorporated
saveRDS(pred_score, file=output)

cat("Finished analysis. Score file is in", output, "\n")
