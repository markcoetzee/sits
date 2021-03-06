#' @title Classify a sits tibble using machine learning models
#' @name sits_classify
#' @author Gilberto Camara, \email{gilberto.camara@@inpe.br}
#'
#' @description This function classifies a set of time series, given
#' a set of training samples, an inference model, and an interval.
#' To perform the classification, users should provide a set of
#' labelled samples. Each samples should be associated to one spatial location
#' (latitude/longitude), one time interval and a label.
#'
#' After defining the training samples, the users need to provide a machine learning model.
#' Currenly, sits supports the following models:
#' 'svm' (see \code{\link[sits]{sits_svm}}), 'random forest' (see \code{\link[sits]{sits_rfor}}),
#' 'boosting' (see \code{\link[sits]{sits_gbm}}), 'lda' (see \code{\link[sits]{sits_lda}}),
#' 'qda' (see \code{\link[sits]{sits_qda}}), multinomial logit' (see \code{\link[sits]{sits_mlr}}),
#' 'lasso' (see \code{\link[sits]{sits_mlr}}), and 'ridge' (see \code{\link[sits]{sits_mlr}}).
#'
#' The model should be precomputed by the user. This model should be
#' passed to the function using the parameter "ml_model".
#'
#'
#' @param  data.tb           tibble with time series metadata and data
#' @param  ml_model          pre-built machine learning model (see \code{\link[sits]{sits_train}})
#' @param  interval          interval used for classification (in months)
#' @param  multicores        number of threads to process the time series.
#' @return data.tb           tibble with the predicted labels for each input segment
#' @examples
#' \donttest{
#' # Retrieve the set of samples for the Mato Grosso region (provided by EMBRAPA)
#' data(samples_MT_ndvi)
#' # select the bands "ndvi", "evi", "nir", and "mir"
#' samples.tb <- sits_select(samples_MT_9classes, bands = c("ndvi","evi","nir","mir"))
#' # build a classification model using SVM
#' model_svm <- sits_train(samples.tb, ml_method = sits_svm ())
#' # Retrieve a time series and select the bands "ndvi", "evi", "nir", and "mir"
#' point.tb <- sits_select(point_MT_6bands, bands = c("ndvi","evi","nir","mir"))
#' # classify the point
#' class.tb <-  sits_classify(point.tb, ml_model = model_svm)
#' # plot the classification
#' sits_plot(class.tb)
#' }
#'
#' @export
sits_classify <- function(data.tb    = NULL,
                          ml_model   = NULL,
                          interval   = "12 month",
                          multicores = 1) {

    .sits_test_tibble(data.tb)

    # ensure the machine learning model has been built
    ensurer::ensure_that(ml_model,  !purrr::is_null(.), err_desc = "sits-classify: please provide a machine learning model already trained")

    # has normalization been applied to the data?
    stats.tb   <- environment(ml_model)$stats.tb

    # obtain the distances after normalizing data by band
    if (!purrr::is_null(stats.tb))
        distances_DT <- sits_distances(sits_normalize_data(data.tb, stats.tb, multicores))
    else
        distances_DT <- sits_distances(data.tb)

    # define the parameters for breaking up a long time series
    samples.tb <- environment(ml_model)$data.tb
    class_info.tb <- .sits_class_info(data.tb, samples.tb, interval)

    # create a vector to store the predicted results
    predict.vec <- .sits_classify_distances(distances_DT, class_info.tb,  ml_model,  multicores)

    # Store the result in the input data
    data.tb <- .sits_tibble_prediction(data.tb, class_info.tb, predict.vec, interval)

    return(data.tb)
}
#' @title Classify a distances tibble using machine learning models
#' @name .sits_classify_distances
#' @author Gilberto Camara, \email{gilberto.camara@@inpe.br}
#'
#' @description Returns a sits table with the results of the ML classifier.
#'
#' @param  distances_DT    data.table with distances
#' @param  class_info.tb   classification information
#' @param  ml_model        model trained by \code{\link[sits]{sits_train}}
#' @param  multicores      number of threads to process the time series
#' @return pred.vec        vector with the predicted labels
.sits_classify_distances <- function(distances_DT, class_info.tb, ml_model, multicores) {

    # get the labels of the data
    labels <- class_info.tb$labels[[1]]

    # create a named vector with integers match the class labels
    int_labels <- c(1:length(labels))
    names(int_labels) <- labels

    # define the column names
    attr_names <- names(environment(ml_model)$train_data_DT)

    # create a data table to store the distances
    dist_DT <- data.table::data.table(nrow = 0, ncol = length(attr_names))

    # select the data table indexes for each time index
    select.lst <- .sits_select_indexes(class_info.tb, ncol(distances_DT))

    # classify a block of data
    classify_block <- function(block_DT) {
        # create a list to store the data tables to be used for prediction
        row.lst <- list()
        for (i in 1:length(select.lst)) {
                rows_DT <- block_DT[, select.lst[[i]], with = FALSE]
                row.lst[[length(row.lst) + 1]] <- rows_DT
        }
        # create a set of distances to be classified
        dist_DT <- data.table::rbindlist(row.lst)
        # set the attribute names of the columns
        colnames(dist_DT) <- attr_names

        # classify the subset data
        prediction_DT <- ml_model(dist_DT)

        # extract the values
        values <-  names(int_labels[max.col(prediction_DT)])

        return(values)
    }

    join_blocks <- function(blocks.lst) {

        pred.vec <- vector()
        blocks.lst %>%
            purrr::map(function(block){
                pred.vec <<- c(pred.vec, block )
            })
        return(pred.vec)
    }

    if (multicores > 1) {
        blocks.lst <- split.data.frame(distances_DT, cut(1:nrow(distances_DT), multicores, labels = FALSE))
        # apply parallel processing to the split dat
        results.lst <- parallel::mclapply(blocks.lst, classify_block, mc.cores = multicores)

        pred.vec <- join_blocks(results.lst)
    }
    else
        pred.vec <- classify_block(distances_DT)

    return(pred.vec)
}







