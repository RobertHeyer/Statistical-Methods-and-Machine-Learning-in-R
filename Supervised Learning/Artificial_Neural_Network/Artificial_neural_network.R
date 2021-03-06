"
NOTE: Please make sure your data is scaled before using this script, or you can use min-max
scaling implemented in the script
NOTE: First Column is treated as 1 in the Selection of Data:
1- Please select the dataset provided with the name 'German_state_results_New') or any numeric data available.
                   Column(Variable) 1       Column(Variable) 2     . . . .    Column(Classification) n
      
      Row(Instance) 1      (Value)                  (Value)           . . . .         (Value)
      
      Row(Instance) 2      (Value)                  (Value)           . . . .         (Value)
      
      .                       .                        .                                 .
      .                       .                        .                                 .
      .                       .                        .                                 .
      .                       .                        .                                 .
      
      Row(Instance) n       (Value)                  (Value)           . . . .         (Value)
      
                                        
2- To run the code, select the whole code and run as source (top right in this window) & enter parameters
   which will be asked on running the code in the CONSOLE screen. In this case select:
   a- Select Dataset to work on (after screen pops out)
   b- Select Separator 
   c- Assign the Classification column
   d- Select the size of the Training set
   e- Select the type of Activation function you want
   f- Select the scaling option if your data is not scaled
   
3- After providing all the parameters, the code will compute the following:
   * Computation and Visualization of Neural Network
   * Comparison of predicted output and corresponding actual test data
   * Confusion Matrix to check false positives etc.
"

# Cleaning the workspace to start over
cat("\f")       # Clear old outputs
rm(list=ls())   # Clear all variables


#------------------------------------------------
"REQUIRED PACKAGES FOR Amynn"
#------------------------------------------------

#Cleaning the workplace to start over
cat("\f")       #Clear old outputs
rm(list=ls())   #Clear all variables

#Installing  Packages
if(!require("neuralnet")) install.packages("neuralnet") #For using Neural network package
if(!require("caret")) install.packages("caret")         #For confusion matrix


library("neuralnet")
library("caret")
#------------------------------------------------
"SELECTION OF DATASET"
#------------------------------------------------

# choose file
print(paste("Please select Input CSV", " The different samples in columns and the measured variables in the rows."), quote = FALSE)

#Choose the Separator for file
fname <- file.choose()     #choose German_State_Results_New.csv

#type of separator used in input data
ask_sep <- as.character(readline(prompt = "ENTER the SEPARATOR for file(',' or ';') : "))

matrix<- read.csv(fname, sep= ask_sep)

#dummify the data
dmy <- dummyVars(" ~ .", data = matrix, sep = NULL)
dmy2 <- data.frame(predict(dmy, newdata = matrix))
matrix <- dmy2

View(matrix)

#extract classification column
#new data(matrix) will be shown in spreadsheet style in R console for you to choose column
#please move your cursor to column name, and R will give you column number
output_col <- as.integer(readline(prompt = "Enter the Column number of Classification Column: "))

#extract Size of Training set
training_size <- as.integer(readline(prompt = "Enter a Percentage of training dataset (e.g. 70) : "))

#taking user's input for activation function
actfct <- as.character(readline(prompt = "Enter either of the activation functions you like to use. 'tanh' or 'logistic': "))

#taking user's input for scaling function
ask_scaling <- as.character(readline(prompt = "Enter yes if you would like to scale your data (min-max scaling is used): "))

if (ask_scaling == 'yes'){
   #scaling our data
   scaling <- function(x) {
      return ((x - min(x)) / (max(x) - min(x)))
   }
   matrix <- as.data.frame(lapply(matrix, scaling))
   
}

cat("\f")       #Clear old outputs


#------------------------------------------------
"Train-Test Data Split"
#------------------------------------------------

training_size <- training_size/100   #extracting the Percentage
n = nrow(matrix)

smp_size <- floor(training_size * n) #training_size asked from the user
index<- sample(seq_len(n),size = smp_size)

#Breaking into Training and Testing Sets:
TrainingSet <- matrix[index,]
TestingSet  <- matrix[-index,]


#------------------------------------------------
"Neural Network Creation"
#------------------------------------------------
#getting formula variables:
classification <- colnames(TrainingSet[output_col])
rest_var <- colnames(TrainingSet[names(TrainingSet) != classification])

#Making Dynamic formula
rest_var  <- paste(rest_var, collapse = " + ")
nn_formula <- as.formula(paste(classification, rest_var, sep=" ~ "))

# Using neuralnet Function for Making the Tree
library(neuralnet)
nn <- neuralnet(formula = nn_formula, data=TrainingSet, 
                hidden=c(2,1),act.fct = actfct, linear.output=F, threshold=0.01)

#hidden:        the number of hidden neurons (vertices) in each layer
#act.fct:       the activation function
#linear.output: specifies the impact of the independent variables on the dependent variable('ResultPromoted', in this case) 
#threshold:     change in error percentage during an iteration 
#               after which no further optimization will be carried out


#nn$result.matrix #to see the computations, un comment this line 

#------------------------------------------------
"Plot Neural Net"
#------------------------------------------------
# Plotting the Neural Network
plot(nn)

#------------------------------------------------
"Predict the Output"
#------------------------------------------------

#taking the classification column which we asked the user initially
classification_col <- TestingSet[,output_col]

#taking the rest of columns other than the classification column
rest_col <- TestingSet[,-output_col]

#Predicting Output
nn.results<- predict(nn, rest_col)

#scaling the result back
nn.results<-sapply(nn.results,round,digits=0)

res <- data.frame(nn.results, classification_col)

cat("\f")       #Clear old outputs

print(res)

#making the confusion matrix
Conf_Matrix <- confusionMatrix(table(nn.results, res$classification_col))
print(Conf_Matrix)


print(paste("FINISHED"), quote = FALSE)
