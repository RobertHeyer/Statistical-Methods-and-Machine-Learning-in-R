####################
## Normalization ##
###################

# Please make sure your csv file contains only numeric variables for the code to run.

# If your csv file has non numeric variables, make sure to remove them or alternatively you can choose a subset of 
# your data at " # Normalizing " 


# Cleaning the workplace

cat("\f")       # Clear old outputs
rm(list=ls())   # Clear all variables


# Loading Data Set

print(paste("Please select Input CSV"), quote = FALSE)

data <- file.choose()
data_csv <- read.csv(data, header = TRUE, sep = ',')
data_csv

# Creating a data matrix

data_matrix <- as.numeric(unlist(data_csv))
data_matrix <- as.data.frame(data_csv)

# Normalizing

data_matrix_out <- as.matrix(scale(data_matrix, center = TRUE, scale = TRUE))
print(data_matrix_out)

###############################################