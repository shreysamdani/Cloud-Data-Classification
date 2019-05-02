library(foreach)
library(doParallel)
library(caret)
library(MASS)
library(rpart)
library(dplyr)

QDA = function(data, hyperparams, formula) {
  if (!is.null(hyperparams[['prior']])) {
    return(qda(formula, data, prior = hyperparams[['prior']]))
  }
  MASS::qda(formula, data)
}

LDA = function(data, hyperparams, formula) {
  if (!is.null(hyperparams[['prior']])) {
    return(lda(formula, data, prior = hyperparams[['prior']]))
  }
  MASS::lda(formula, data)
}

logistic = function(data, hyperparams, formula) {
  glm(formula,family = 'binomial', data = data)
}

kernelSVM = function(data, hyperparams, formula) {
  caret::train(formula, 
               data=data,
               method ='svmRadial',
               trControl=caret::trainControl(method = "none"),
               tuneGrid = expand.grid(C = hyperparams[['C']],sigma = hyperparams[['sigma']]))
}

dtree = function(data, hyperparams, formula) {
  rpart::rpart(formula, data=data, method = 'class')
}

split.1 = function(data, K) {
  set.seed(123)
  uniqueImages = sort(unique(data$image))
  images = list()
  for (image in uniqueImages) {
    images[[length(images)+1]] = data[data$image == image,]
  }
  
  # METHOD 1 (divide by blocks)
  BLOCK_SIZE = 10
  blocks = list()
  images = list(data1,data2,data3)
  for (i in 1:length(images)) {
    image = images[[i]]
    x = range(image$x)
    x.coordinates = seq(x[1],x[2],BLOCK_SIZE)
    y = range(image$y)
    y.coordinates = seq(y[1],y[2],BLOCK_SIZE)
    for (x_coord in x.coordinates) {
      for (y_coord in y.coordinates) {
        blocks[[length(blocks)+1]] = c(i,x_coord,y_coord)
      }
    }
  }
  
  n = length(blocks)
  
  random_blocks = createFolds(1:n,K)
  
  folds = list()
  for (fold in random_blocks) {
    rows = c()
    for (block in fold) {
      block.value = blocks[[block]]
      image = paste0('data',block.value[[1]])
      x = block.value[[2]]
      y = block.value[[3]]
      rows = c(which(data$image ==image & between(data$x,x,x+9) & between(data$y,y,y+9)),rows)
    }
    folds[[length(folds)+1]] = rows
  }
  folds
  
}

split.2 = function(data) {
  folds = list()
  for (image in unique(data$image)) {
    folds[[image]] = which(data$image == image)
  }
  folds
}

CVgeneric = function(classifier, data, K, loss, hyperparams, formula, splitMethod) {
  
  
  if (splitMethod == 1) {
    folds = split.1(data, K)
  } else {
    folds = split.2(data)
  }
  if (classifier == 'kernelSVM') {
    
    data = data[,]
    data$label = factor(data$label)
    cores=detectCores()
    cl <- makeCluster(cores[1]-1) 
    registerDoParallel(cl)
  }
  classifierModel = eval(as.symbol(classifier))
  error = c()
  accuracies = c()
  for (fold in folds) {
    trainData = data[-fold,-c(1,2,12)]
    testData = data[fold,-c(1,2,12)]
    model = classifierModel(trainData,hyperparams, formula)

    if (classifier == 'dtree') {
      p = predict(model, testData, type = "prob")[,2]
    } else if (classifier == 'kernelSVM') {
      predicted = predict(model, testData)
    } else {
      p = predict(model, testData, type = 'response')
    }
  
    if (classifier == 'QDA' || classifier == 'LDA') {
      p= p$posterior[,2]
    }
    if (classifier != "kernelSVM") {
      error = c(error,loss(p, as.numeric(testData$label)))
      predicted = round(p)
    } else{
      error = c(0,error)
    }
    accuracies = c(accuracies, mean(as.numeric(predicted) == as.numeric(testData$label)))
    
  }
  if (classifier == 'kernelSVM') {
    stopCluster(cl)
  }
  list("losses"=error / K,"accuracies"=accuracies)
}