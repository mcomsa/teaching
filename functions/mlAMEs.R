mlAMEs <- function(data, levels, draws, posterior, linear_predictor, type) {
  # throw error if type is not one of linear or logit
  if (!(type %in% c("linear", "logit")))
    stop ("mlAMEs works with 'type' = 'linear' or 'logit' only. Specify the 'type' argument accordingly or adjust mlAMEs.")
  # create ID column denoting unique combinations of variables in the data
  data <- as.data.table(data)
  data[, predID := .GRP, by = names(data)]
  # record the number of times each unique combination of variables occurs in the data
  predID_count <- count(data, predID)$n
  # assign the unique combinatiions of variables in the data to a computation dataset
  data_comp <- distinct(data, .keep_all = TRUE)
  # predict matrix size in GB to determine whether to vectorize the prediction over all
  # draws or whether to loop over the draws, the former is fast but infeasible if
  # the number of unique combinations of variables in the data grows too big
  exceed_ram <- (nrow(data_comp)*draws*8)/1e+9 >
    (memory.size(NA)-memory.size(max = FALSE))/1000
  if (!isTRUE(exceed_ram)) {
    # all pieces of data in a list (similar to rstan) and assign into the environment
    data_list <- c(list(n_draws = draws),
                   levels,
                   as.list(data_comp),
                   posteriors)
    for (i in 1:length(data_list)) {
      assign(names(data_list)[i], data_list[[i]])
    }
    # modify the linear predictor such that is evaluates to elementwise addition for 
    # matrices and column-wise recycling of vectors added to or multiplied with vectors.
    # In the matrices that are arithmetically evaluated, rows are posterior draws and 
    # columns are data values for the specific unique combinations of variables in the data
    linear_predictor <- linear_predictor %>%
      str_replace_all("\\[n", str_c("\\[1\\:", n_draws))
    # parse the modified linear predictor so that in can be evaluated
    linear_predictor <- parse(text = linear_predictor)
    # iterate over the predetermined steps of x (parallelized)
    ames_full <- foreach(k = 1:length(x), .packages = c("arm", "purrr"), 
                         .verbose = FALSE, .export = c(names(data_list)[-1])) %dopar% {  
                           # evaluate the linear predictor and transform using the inverse of the link 
                           # function if type == "logit", else evaluate without transforming
                           if (type == "logit") {
                             prediction <- arm::invlogit(eval(linear_predictor))
                           } else {
                             prediction <- eval(linear_predictor)
                           }
                           # for each posterior draw expand the predictions for unique combinations
                           # of variables in the data according to their occurence in the data, i.e.,
                           # a prediction for each individual in the data. Then average over the predictions,
                           # producing a population averaged prediction for each draw and step of x
                           ames <- 1:n_draws %>%
                             purrr::map(~{
                               y <- mean(rep(prediction[.x,], times = predID_count))
                             }) %>%
                             unlist
                           return(ames)
                         }
    # tranform output to tidy format for easy visualization via ggplot2
    ames_full <- data.table::transpose(as.data.table(ames_full))
    ames_full <- melt(data = ames_full, measure.vars = 1:n_draws,
                      value.name = "y", variable.name = "draw")
    ames_full$x <- rep(x, n_draws)
    #ames_full$draw <- as.integer(str_replace(ames_full$draw, "V", ""))
  } else {
    
    # add mapped approach looping over n_draws when exceed_ram is TRUE
    
  }
  
  return(ames_full)
}