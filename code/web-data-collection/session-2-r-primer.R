# ---------------------------------------------------------------------------------------
# WEB DATA COLLECTION WITH R
# Sascha Goebel
# SESSION 2: R Primer
# Winter Semester 2020/21
# ---------------------------------------------------------------------------------------

# change working directory --------------------------------------------------------------
setwd("web-data-collection-r")

# Arithmetic operations -----------------------------------------------------------------

5 + 3 # addition
5 - 3 # subtraction
5 ^ 3 # exponentiation
5 ** 3 # exponentiation
5 * 3 # multiplication
5 / 3 # division
5 * (10 - 3) # use of brackets
10 %% 3 # modulo, remainder of division
10 %/% 3 # integer divide

# Relational operations -----------------------------------------------------------------

5 > 3 # greater than
5 < 3 # less than
5 <= 3 # weakly less than
5 >= 3 # weakly greater than
5 == 3 # equals
5 != 3 # unequal

# Assignment ----------------------------------------------------------------------------
result <- 5 + 3 # assign
result # call object, note that calling 'Result' will throw an error as R is case sensitive
result <- 5 ^ 3 # overwrite object
result
results <- c(5 + 3, 5 - 3, result) # assigning multiple values using 'c()' - concatenate
results

# Logical operations --------------------------------------------------------------------
5 & 3 %in% results # logical conjunction (and)
5 == 2 | 3 == 2# same but evaluates left to right until the result is determined
!3 %in% results # logical negation

# Function calls ------------------------------------------------------------------------
mean(x = results) # arithmetic mean
base::mean(x = results) # to avoid conflict with other packages, specify the function source as 'source::', usually not necessary
sqrt(x = result) # square root
sum(x = results) # sum of elements
seq(from = 1, to = 10) # sequence
values <- seq(from = 1, to = 10, by = 2)
rep(x = result, times = 3) # replication of elements
rep(x = results, each = 3)
print(values) # print values
print(c(values, result))
cat(values, result)
print(mean(results)) # nested function calls

# Chaining commands ---------------------------------------------------------------------
#install.packages("magrittr")
library(magrittr)
5 %>% 
  cat(2)
6 %>%
  add(4) %>%
  seq(from = 1) %>%
  rep(times = 3) %>%
  sum()
results %>%
  mean() %>%
  print()

# Subsetting operations -----------------------------------------------------------------
results[3] # access the thrid element in results
results # 125 is the third element in results

# Control structures --------------------------------------------------------------------
# Conditional execution with `if` - `if (condition) {do}`
if (result %in% results) {
  cat(result, "is in results")
} 
# Conditional execution with `if` and `else` - `if (condition) {do} else {do}`
if (sample(x = 1:20, size = 1) <= 10) {
  print("x is less than 10")
} else {
  print("x is greater than 10")
}
# Conditional execution with vectorized `ifelse` - `ifelse(condition, if met do, else do)`
values <- sample(x = 1:20)
ifelse(values >= 10, TRUE, FALSE)
# `for` loop for iterative tasks - `for (element in sequence of elements) {do}`
for (i in 1:length(values)) {
  print(values[i])
}
# `for` loop with conditional execution
for (i in 1:length(values)) {
  if (values[i] >= 10) {
    print(TRUE)
  } else {
    print(FALSE)
  }
}
# `while` loop - `while (condition is met) {do}`
while (result < 200) {
  print(result)
  result <- result + 5
}
# Conditional jump with `next` - skips processing element further and begins with next iteration, not required in this example but useful for nested loops or exception handling
for(i in 1:length(values)) { 
  if(values[i] %% 2 == 0) {
    next
  }
  values[i] <- 0
}
# Conditional jump with `break` - stops execution of loop upon condition
values
for(i in 1:length(values)) {
  print(i)
  values[i] <- values[i] + 1
  if(all(values != 0)) {
    break
  }
}
values

## Data types and transformations, i.e., how R stores data ******************************

# Boolean -------------------------------------------------------------------------------
boolean <- TRUE
boolean
typeof(boolean)
boolean <- F
boolean
typeof(boolean)
typeof(1 == 2) # comparison operation
results %in% values # matching operation

# Integer -------------------------------------------------------------------------------
whole <- c(2L, 14L, 36L)
whole
typeof(whole)

# Numeric -------------------------------------------------------------------------------
decimal <- c(2.14, 3, 1836.819120)
decimal
typeof(decimal)
class(decimal)

# Character -----------------------------------------------------------------------------
string <- ("multilevel")
typeof(string)
string <- paste(string, "modeling", sep = " ") # concatenates two strings to form one string separated by a single space
nchar(string) # number of characters in string
string <- toupper(string) # convert string to all capital letters
string
tolower(string) # convert string to all lower case letters

# Type transformation -------------------------------------------------------------------
typeof(as.numeric("5"))
result + as.numeric("5")
as.character(result)
typeof(as.integer("2"))

## Structured data abstraction, i.e., how R serves data to you **************************

# Vectors -------------------------------------------------------------------------------
result # a scalar, or a vector of length 1
values # a vector, a collection of elements
log_vect <- c(TRUE, FALSE, T, F) # a logical vector
length(log_vect) # length of vector
str(log_vect) # structure of vector
int_vect <- c(1L, 2L, 3L) # an integer vector
str(int_vect) 
num_vect <- c(1, 1.3, 1.7, 2, 2.3, 2.7) # a numeric vector
str(num_vect) 
cha_vect <- c("multilevel", "modeling", "course") # a character vector
str(cha_vect) 
c(1, 2, "3", TRUE, 5) # coercion to most flexible type - character
c(1, 2, FALSE, 5) # coercion to most flexible type - numeric
c(1, 2, NA, 3, NaN, 5, Inf) # special values in a vector, NA - missing data, NaN - not a number, Inf - infinity
results[3] # access third element
results[c(2,3)] # access second and third element
results[c(FALSE, TRUE, TRUE)] # same
results[3] <- 4 # replace
results[3] # now the third element is 4
results <- results[-3] # remove
results # now there is no third element anymore
results[results > 3] # access by using conditions
results <- setNames(object = results, nm = c("a", "b")) # give names to elements
results
results["b"] # access element by its name

# Matrices ------------------------------------------------------------------------------
matrix_1 <- matrix(data = 1:6, nrow = 2, ncol = 3) # create a matrix with 'matrix()'
matrix_1
matrix_2 <- array(data = 1:6, dim = c(2, 3)) # or use 'array()' which is also used to construct multidimensional arrays (not covered here)
matrix_2
dim(matrix_1) # dimensions of a matrix
str(matrix_1) # structure of a matrix
nrow(matrix_1) # number of rows, same as dim(matrix_1)[1]
ncol(matrix_1) # number of columns, same as dim(matrix_1)[2]
length(matrix_1) # number of rows times number of columns
# to combine matrices 'c()' won't yield the desired result
c(matrix_1, matrix_2)
# use 'cbind()' and 'rbind()'
cbind(matrix_1, matrix_2) # combine matrices by columns
rbind(matrix_1, matrix_2) # combine matrices by columns
matrix_2[2, 3] # access using index with two positions [rows, columns], otherwise works same as for vectors
matrix_2[c(1, 2), 3] # full third column
matrix_2[, 3] # same
matrix_2[,-3] # remove third column
matrix_2[2, 3] <- NA # replace value with missing
matrix_2
rownames(matrix_1) <- c("a", "b") # modify row names
matrix_1
colnames(matrix_1) <- c("A", "B", "C") # modify column names
matrix_1
dimnames(matrix_1) <- list(c("c", "d"), c("C", "D", "E"))
matrix_1
matrix_1["c","E"] # access by row and colum names
# for matrix algebra use:
matrix_1 * matrix_2 # for elementwise multiplication
matrix_1 <- t(matrix_1) # to transpose a matrix
matrix_1 %*% matrix_2 # for matrix multiplication
colMeans(matrix_1) # columns means
colSums(matrix_1) # column sums
rowMeans(matrix_1) # row sums
rowSums(matrix_1) # row sums

# Lists ---------------------------------------------------------------------------------
list_1 <- list(1:5, c("this", "is", "the second", "vector"), matrix_1)
list_1
str(list_1) # structure of a list
length(list_1) # number of list elements
# to combine lists use c()
list_2 <- list(6:10, rep("a", times = 5))
list_3 <- c(list_2, list_1) # combine lists in order
list_3
# lists can be nested
nested_list <- list(list(1, 2), c(3, 4))
str(nested_list)
# you can provide names to list elements as to vector elements
list_1 <- setNames(object = list_1, nm = c("a", "b", "c"))
list_1
# access works same as described above and below but use `[[` to select list elements
list_3[[3]] # third element in list
list_3[[5]][,"d"] # fifth element in list (a matrix) and column "d" from the matrix
list_3[1:3] # first three list elements

# Data frames ---------------------------------------------------------------------------
data_1 <- data.frame("A" = c(1:6), 
                     "B" = rep("a", times = 6), 
                     "C" = c(seq(from = 0, to = 1, by = 0.2))) # create data frame
str(data_1)
View(data_1)
data_2 <- data.frame("D" = c(7:12), 
                     "E" = rep("b", times = 6), 
                     "F" = c(seq(from = 1, to = 2, by = 0.2)))
# to combine data frames use cbind() and rbind()
cbind(data_1, data_2) # combine column-wise, number of rows must match
rbind(data_1, data_1) # combine row_wise, column names and number of columns must match
# access via `[`
data_1[,"B"] # access column B
data_1[2,3] # access second row third column
# access via `$`
data_1$B # access column B
data_1$C[3] # access third value of column C
data_1[data_1$C < 0.5,] # all rows for which the values in column C are below 0.5
# access via `[[`
data_1[[2]] # access second column
data_1[["A"]] # access column A
# access via subset() function
subset(data_1, select = c("A", "C"), 
       subset = (C < "0.5" & A > 1)) # access rows of columns A and C where values in A 
# are larger than 1 and values in C are smaller than 0.5

# Attributes ----------------------------------------------------------------------------
attributes(results) # a named vector
attributes(matrix_1) # a matrix
attributes(list_1) # a named list
attributes(data_1) # data frame
# or use dim(), names(), class()
fac_vec_1 <- factor(c("a", "b", "b", "a", "c")) # create a factor vector
fac_vec_1
fac_vec_2 <- factor(c("a", "b", "b", "a", "c"), 
                    levels = c("a", "b", "c", "d"), 
                    labels = c("Dem", "Rep", "Ind", "None")) # provide levels and label them
levels(fac_vec_1) <- c("a", "b", "c", "d") # add level
levels(fac_vec_2)[levels(fac_vec_2) == "Dem"] <- "D" # relabel by name
levels(fac_vec_2)[2] <- "R" # relabel by position
nlevels(fac_vec_1) # number of levels
table(fac_vec_2) # tabluar representation of categorical (factor) variables


#### WORKING WITH DATA ==================================================================

# Import data sets ----------------------------------------------------------------------
nominate_data <- read.csv(file = "./code/congress.txt") # import csv file
# data source https://github.com/kosukeimai/qss/blob/master/MEASUREMENT/congress.csv
str(nominate_data)
# Note how all string variables are automatically transformed to factor variables. This is a nuisance in R and often makes no sense, to avoid this use the `stringsAsFactors` argument.
nominate_data <- read.csv(file = "./code/congress.txt", stringsAsFactors = FALSE)
str(nominate_data)
# dwnom1 = economic liberalism/conservatism
# dwnom2 = racial liberalism/conservatism

# Apply functions to lists or vectors ---------------------------------------------------
apply(state.x77, MARGIN = 2, FUN = mean) # state.x77 data is part of base R
# same as the following but apply is less code, clearer, and often faster
avgs <- rep(NA, 8)
for (i in 1:8) {
  avgs[i] <- mean(state.x77[,i])
}
# Now we use an anonymous function. If you choose not to give the function a name, you get an anonymous function. You use an anonymous function when it’s not worth the effort to give it a name and store it in the global environment.
apply(state.x77, MARGIN = 2, function(x) c(min(x), median(x), max(x)))
# To apply functions on lists or vectors, returning a list, the structure of the function call is `lapply(data, function to apply)`.
lapply(list_3, FUN = `[`, 2) # second element of each list element
lapply(state.x77, is.numeric) # applied to a matrix, taken as a vector
lapply(as.data.frame(state.x77), is.numeric) # applied to a data.frame, taken as lists
# To apply functions on lists or vectors, returning an atomic vector, the structure of the function call is `sapply(data, function to apply)`.
sapply(list_3, FUN = `[`, 2)
sapply(state.x77, is.numeric) # applied to a matrix, taken as a vector
sapply(as.data.frame(state.x77), is.numeric) # applied to a data.frame, taken as lists
# For a multivariate version of lapply, which applies a function for each value according to each value specified in the arguments, the structure of the function call is `mapply(function to apply, data on which function shall be applied, arguments to function)`. For example, you do not want to pick every 2nd element but varying elements the position of which are stored in an object passed as an argument.
mapply(FUN = rep, 1:4, 4:1)
list_4 <- list(c(1,2,3,4,5,6), c(6,5,4,3,2,1), c(3,2,1,4,5,6))
list_5 <- list(c(1,2,1,2,1,2), c(3,4,3,4,3,4), c(5,6,5,6,5,6))
mapply(FUN = `+`, list_4, list_5)
# To apply functions to categories (factors) the structure of the function call is `tapply(data, factor variable, function)`.
nominate_data$party <- as.factor(nominate_data$party)
tapply(nominate_data$dwnom1, INDEX = nominate_data$party, FUN = mean)

# Data management -----------------------------------------------------------------------
library(dplyr)
library(stringr)
# To select rows conditional on specific criteria, use `filter()`. The following selects rows that pertain to the states Florida and New Jersey, the Republican party, and the 112th Congress.
nominate_subset <- filter(nominate_data, state %in% c("FLORIDA", "NEW JER") & party == "Republican" & congress == 112)
# To select or reorder columns conditional on specific criteria, use `select()`.
colnames(nominate_subset) # show column names of nominate_subset data 
nominate_subset2 <- select(nominate_subset, congress, district, state, party, name) # select variables and reorder by name
nominate_subset3 <- select(nominate_subset, c(5, 4, 1:3)) # select variables and reorder by position
nominate_subset4 <- select(nominate_data, 1:3, starts_with("dw")) # select variables and reorder by pattern
# To add new or alter existing variables, use `mutate()`.
nominate_data <- mutate(nominate_data, president = ifelse(state == "USA", TRUE, FALSE)) # variable identifying presidents
nominate_data <- mutate(nominate_data, name = tolower(name)) # make name variable lower case
# To order rows by variables, use `arrange()`.
nominate_data <- arrange(nominate_data, president, congress, dwnom1) # order data by president indicator, congress session and dwnom1
# To group data by one or more variables in order to perform group-specific operations, use groub_by.
nominate_states <- group_by(nominate_data, state) # group by states
groups(nominate_states) # to check groups
# use ungroup() to remove grouping
# In order to reduce multiple values down to single values, i.e., perform group operations, use `summarise` after group_by.
nominate_states <- summarise(nominate_states, n = n(), average_dw = mean(dwnom1))
# For data integration tasks use members of the join family.
# Here, a left join seems appropriate to match the dwnom and president variables to nominate_subset2. The left join returns all rows from x, and all columns from x and y. Rows in x with no match in y will have NA values in the new columns. If there are multiple matches between x and y, all combinations of the matches are returned.
nominate_joined <- left_join(x = nominate_subset2, y = nominate_data, by = c("congress", "district", "state"))
# Further options are:
?join

# Inspecting data -----------------------------------------------------------------------
head(nominate_data[nominate_data$congress == 110 & nominate_data$president == FALSE, "dwnom1"], n = 10) # first 10 values
tail(nominate_data[nominate_data$congress == 110 & nominate_data$president == FALSE, "dwnom1"], n = 10) # last 10 values
# Or use `summary`, a generic function which depending on the class of an object outputs different summaries. For a numeric column vector, for instance, summary returns the quantiles of vector's distribution. In this case, same can be achieved with `quantile()`.
summary(nominate_data$dwnom1)
quantile(nominate_data$dwnom1)
# Use `table()` and `prop.table()` to inspect the distribution of data across factors.
table(nominate_data[nominate_data$president == FALSE, "party"])
prop.table(table(nominate_data[nominate_data$president == FALSE, "party"]))
# To visualize the distribution of a factor variable, use `barplot()`.
barplot(prop.table(table(nominate_data$party)), 
        names.arg = as.character(unique(nominate_data$party)), 
        cex.names = 0.7, 
        cex.axis = 0.7, 
        ylim = c(0, 1)) # depict party shares
nominate_states <- group_by(nominate_data, state) # group data by state
nominate_states <- summarise(nominate_states, n = n(), average_dw = mean(dwnom1)) # compute average dwnom score
nominate_states <- arrange(nominate_states, average_dw) # sort state grouped nominate data by average dwnom score
barplot(nominate_states$average_dw, 
        names.arg = as.character(nominate_states$state),
        las=2, 
        cex.names = 0.7, 
        cex.axis = 0.7, 
        ylim = c(-1, 1)) # depict average dwnom score by state (factor variable)
# To visualize the distribution of a numeric variable, use `hist()` or `boxlplot()`.
hist(nominate_data$dwnom1, 
     cex.axis = 0.7, 
     xlim = c(-1.5, 1.5), 
     ylim = c(0,3500), 
     main = NULL, 
     ylab = NULL, 
     xlab = "economic liberalism/conservatism")
hist(nominate_data$dwnom2, 
     cex.axis = 0.7, 
     xlim = c(-1.5, 1.5), 
     ylim = c(0,3500), 
     main = NULL, 
     ylab = NULL, 
     xlab = "racial liberalism/conservatism")
boxplot(nominate_data$dwnom1, 
        nominate_data$dwnom2, 
        cex.axis = 0.7, 
        names = c("economic", "racial"))
boxplot(nominate_data$dwnom1 ~ nominate_data$party, 
        cex.axis = 0.7)
# To summarize bivariate relationships, use `plot`. Note that plot is a generic function, depending on the data input, the plot will look different and can do more than just scatterplots.
plot(nominate_data[nominate_data$congress == 112, "dwnom1"],
     nominate_data[nominate_data$congress == 112, "dwnom2"], 
     cex.axis = 0.7, 
     xlim = c(-1.5, 1.5), 
     ylim = c(-1.5, 1.5), 
     xlab = "economic liberalism/conservatism", 
     ylab = "racial liberalism/conservatism", 
     pch = 16)
plot(nominate_data[nominate_data$congress == 112, "dwnom1"],
     nominate_data[nominate_data$congress == 112, "dwnom2"], 
     cex.axis = 0.7, 
     xlim = c(-1.5, 1.5), 
     ylim = c(-1.5, 1.5), 
     xlab = "economic liberalism/conservatism", 
     ylab = "racial liberalism/conservatism", 
     pch = 16)
points(nominate_data[nominate_data$congress == 112 & nominate_data$party == "Republican", "dwnom1"], 
       nominate_data[nominate_data$congress == 112 & nominate_data$party == "Republican", "dwnom2"],  
       pch = 16, 
       col = "red")
points(nominate_data[nominate_data$congress == 112 & nominate_data$party == "Democrat", "dwnom1"], 
       nominate_data[nominate_data$congress == 112 & nominate_data$party == "Democrat", "dwnom2"],  
       pch = 16, 
       col = "blue")

# Fitting regression models (frequentist style) -----------------------------------------
nominate_data <- mutate(nominate_data, president = ifelse(state == "USA", TRUE, FALSE)) # variable identifying presidents
nominate_reg <- filter(nominate_data, congress == 112, party != "Other", president == FALSE)
levels(nominate_reg$party) <- c("Democrat", NA, "Republican")
linear_model <- lm(formula = dwnom1 ~ party, data = nominate_reg) # simple linear model with one covariate
summary(linear_model) # gives the difference in means of dwnom1 over subgroups (democrats and republicans)