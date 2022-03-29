# Dataset example

# Refer to the .RMarkdown file for explanation of the script

# Load relevant R packages
library(tidyverse)
library(data.table)
library(rlist)

# Function to reshape wide imaging format into long imaging format

bilateral_imag <- function(imagnames,hemnames,idname,n,data,covariates){
  
  # Function arguments:
  # Imagnames: names to be assigned to new time-varying variables (i.e. for left and right anterior thalamic radiation, this will be "anterior thalamic radiation")
  # Hemnames: names of left and right hemisphere brain regions to loop through in order to reshape into long format
  # ID: participant ID name (this differs between cohorts)
  # N: number of bilateral regions (i.e. if 12 lh and 12 rh, N=12)
  # Data: dataset in which the variables are
  # Covariates: dataset with covariates to merge after reshaping the data
  
  long_format <- lapply(1:n, function(x)
    melt(setDT(data), id = idname, 
         measure = c(hemnames[[1]][x],hemnames[[2]][x]), 
         value.name = c(imagnames[x]),
         variable.name = "hemi"))
  
  # Reduce all lists to the first column (participant ID), last column (the 2 hemispheres put together), and "hemi"
  imag_only = lapply(long_format, function(x) x %>% select(c(1,2,3)))
  
  # Cbind all imag variables
  imag_cbind = list.cbind(imag_only)
  
  # Remove duplicated columns - this will leave "hemi" with level names that corresponded to the first imaging measure (this is a residual from the first list element - when you remove duplicates of a column, only the first obs remains); this should be turned into "1" and "2"
  imag_cbind_deduped=imag_cbind %>% subset(., select = which(!duplicated(names(.))))
  
  # Merge with the other covs
  imag_cbind_deduped=merge(imag_cbind_deduped,covariates,by=idname)
  
  # Turn "hemi" to factor with level "1" and "2"
  levels(imag_cbind_deduped$hemi) <- c(1,2)
  
  # return
  return(imag_cbind_deduped)
}

# Read in dummy covariates
dummy_whitematter=readRDS("./wide_to_long_dummy_dataset.rds")

# Read in dummy dataset
covars=readRDS("./wide_to_long_dummy_covfile.rds")

# Pre-process dataset

# Select those that have left and right hemispheres 
# This is useful if there are other variables that you do not wish to have in the dataset
# This also orders variables in order of selection (below is lh first, rh second)
whitematter_bl=select(dummy_whitematter, contains(c("ID","lh","rh")))
# Merging with covariates will be done in the function below

# FOR FUNCTION TERMS
# Turn from wide to long format
data_lh=paste0(colnames(whitematter_bl)[2:4])
data_rh=paste0(colnames(whitematter_bl)[5:7])

# Include both in a list
imag_list = list(data_lh,data_rh)
# ID name can be modified based on dataset used
part_id = "ID"

# Paste the column name of either left or right hemisphere (they will be in the same order) 
# This will be used to provide new names to variables in the long-format dataset
data_names = sub('lh.', '', colnames(whitematter_bl)[2:4])

# Run function
longformat_imag <- bilateral_imag(data_names,imag_list,part_id,3,whitematter_bl,covars)

# Save long-format dataset
# saveRDS(longformat_imag, "./whitematter_longformat.rds")

# Run function - no covariates selected
# Simply comment out the line that merges covariates with dataset variables)
# Also take out the covariates flag in the function (on first line)

bilateral_imag <- function(imagnames,hemnames,idname,n,data){
  
  # Function arguments:
  # Imagnames: names to be assigned to new time-varying variables (i.e. for left and right anterior thalamic radiation, this will be "anterior thalamic radiation")
  # Hemnames: names of left and right hemisphere brain regions to loop through in order to reshape into long format
  # ID: participant ID name (this differs between cohorts)
  # N: number of bilateral regions (i.e. if 12 lh and 12 rh, N=12)
  # Data: dataset in which the variables are
  # Covariates: dataset with covariates to merge after reshaping the data
  
  long_format <- lapply(1:n, function(x)
    melt(setDT(data), id = idname, 
         measure = c(hemnames[[1]][x],hemnames[[2]][x]), 
         value.name = c(imagnames[x]),
         variable.name = "hemi"))
  
  # Reduce all lists to the first column (participant ID), last column (the 2 hemispheres put together), and "hemi"
  imag_only = lapply(long_format, function(x) x %>% select(c(1,2,3)))
  
  # Cbind all imag variables
  imag_cbind = list.cbind(imag_only)
  
  # Remove duplicated columns - this will leave "hemi" with level names that corresponded to the first imaging measure (this is a residual from the first list element - when you remove duplicates of a column, only the first obs remains); this should be turned into "1" and "2"
  imag_cbind_deduped=imag_cbind %>% subset(., select = which(!duplicated(names(.))))
  
  # Merge with the other covs
  # imag_cbind_deduped=merge(imag_cbind_deduped,covariates,by=idname)
  
  # Turn "hemi" to factor with level "1" and "2"
  levels(imag_cbind_deduped$hemi) <- c(1,2)
  
  # return
  return(imag_cbind_deduped)
}

longformat_imag_nocovs <- bilateral_imag(data_names,imag_list,part_id,3,whitematter_bl)
