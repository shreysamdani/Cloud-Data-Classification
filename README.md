# Cloud-Data-Classification
Exploration and modeling of cloud detection in the polar regions based on radiance recorded automatically by the MISR sensor abroad the NASA satellite Terra

## To reproduce:
	1. Make sure the data is labeled as image{}.txt and under the folder image_data
	2. Open up project2.Rnw in RStudio.
	3. Click compile PDF at the top
	4. If there are LaTeX dependencies or R packages that are missing, install them and retry
	5. Wait for ~30 minutes until the PDF is created.

## CVGeneric (the cross validation function)
 - this function performs K-fold cross validation on a classifier. 
 - Function parameters:
 	- classifier: string to identify the classifier. Options include:
 		- "QDA" - Quadratic Discriminant Analysis
 		- "LDA" - Linear Discriminant Analysis
 		- "logistic" - Logistic Regression
 		- "kernelSVM" - Kernel SVM (RBF kernel)
 		- "dtree" - Decision tree
 	- data: the data to train on
 	- K: the amount of folds
 	- loss: the loss function
 	- hyperparameters: hyperparameters for a model formatted as a list
 		- "C" and "sigma" are for kernel SVM
 		- "prior" is for QDA/LDA
 	- formula: string formula
 	- splitMethod: method of splitting (integer)
 		- 1: splitting by blocks
 		- 2: splitting by image

## Other Comments:
- All visuals were made using the ggplot and default libraries


## Packages Used:
- base
- knitr
- ggplot2
- corrplot
- dplyr
- Matrix
- foreach
- glmnet
- iterators
- doParallel
- lattice
- caret
- MASS
- rpart
- MLmetrics
- reshape2
- rpart.plot
- pROC
- magrittr
- ggpubr
