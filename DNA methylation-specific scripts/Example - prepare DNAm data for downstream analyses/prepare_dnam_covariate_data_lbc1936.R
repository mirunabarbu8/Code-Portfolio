# Define upper and lower SD bounds for cell count removal
library(dplyr)

# Read in covariate file as "lbc"
lbc=readRDS("./LBC36_w1_DNAm_target.rds")
estcellcounts=readRDS("./LBC36_w1_EstCellCounts.rds")

# Reduce both datasets to relevant variables to include (technical covariates, get rid of measured cell types in "lbc")
lbc=lbc[,c(1,2,4,5,6,14,15,16,17,18)]
estcellcounts=estcellcounts[,c(2,6:7,9:11)]

lbc36_covs=merge(lbc,estcellcounts,by="Basename")

# First check histograms for 5 cell type proportions to include as covariates:
# CD8+T, CD4+T, natural killer cells, B cells and granulocytes

# Histograms
par(mfrow=c(3,2))
hist(lbc36_covs$NK, main="Natural killer cells", 
     #xlab="Beta values", 
     border="lightblue")
hist(lbc36_covs$Gran, main="Granulocytes", 
    # xlab="Beta values", 
     border="lightblue")
hist(lbc36_covs$CD4T, main="CD4T", 
    # xlab="Beta values", 
     border="lightblue")
hist(lbc36_covs$CD8T, main="CD8T", 
    # xlab="Beta values", 
     border="lightblue")
hist(lbc36_covs$Bcell, main="B cells", 
    # xlab="Beta values", 
     border="lightblue")

# Define column numbers and SD number (5 SDs as read in: https://www.pure.ed.ac.uk/ws/portalfiles/portal/141993579/SeebothCE2020DnaMethylationOutlierBurden.pdf)
a=11
b=15
c=5

# Create new dataframe that will contain the NA values (to then compare to how many NAs were removed)
lbc_rem=lbc36_covs

for (i in a:b){
  lower_limit <- mean(lbc_rem[[i]],na.rm=T) - (c*sd(lbc_rem[[i]],na.rm=T))
  upper_limit <- mean(lbc_rem[[i]],na.rm=T) + (c*sd(lbc_rem[[i]],na.rm=T))  
  lbc_rem[[i]][lbc_rem[[i]] < lower_limit | lbc_rem[[i]] > upper_limit] <- NA}

# Print the number of outliers removed (i.e. this will be additional NAs, as all outliers in "lbc_rem" were turned to NA)
items=colnames(lbc36_covs[a:b])
nas_orig=sapply(a:b, function(x) sum(is.na(lbc36_covs[x])))
nas_outlier_rem=sapply(a:b, function(x) sum(is.na(lbc_rem[x])))

# Turn to dataframe
na_n=as.data.frame(cbind(items,nas_orig,nas_outlier_rem))

# Turn NA Ns to character, then numeric
na_n=na_n %>%   
  mutate_at(vars(starts_with("nas")),funs(as.character))

na_n=na_n %>%   
  mutate_at(vars(starts_with("nas")),funs(as.numeric))


# Subtract nas_orig from nas_outlier_rem to find outliers removed
na_n$outlier_n=na_n$nas_outlier_rem-na_n$nas_orig

print(na_n)

# Check histogram for new estimated cell counts
# Histograms
par(mfrow=c(3,2))
hist(lbc_rem$NK, main="Natural killer cells", 
     #xlab="Beta values", 
     border="lightblue")
hist(lbc_rem$Gran, main="Granulocytes", 
     # xlab="Beta values", 
     border="lightblue")
hist(lbc_rem$CD4T, main="CD4T", 
     # xlab="Beta values", 
     border="lightblue")
hist(lbc_rem$CD8T, main="CD8T", 
     # xlab="Beta values", 
     border="lightblue")
hist(lbc_rem$Bcell, main="B cells", 
     # xlab="Beta values", 
     border="lightblue")

# Save this dataset with outliers for estimated cell counts removed
saveRDS(lbc_rem, "V:/miruna/mdd mwas/LBC36_w1_prepared_covariates.rds",version=2)

