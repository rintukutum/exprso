###########################################################
### Define generic functions

#' @name split
#' @rdname split
#'
#' @title split \code{ExprsArray} objects
#'
#' @description A collection of functions to build the training and validation sets.
#'
#' @details
#'
#' \code{splitSample} builds training and validation sets through randomly sampling
#'  the subjects found within the \code{ExprsArray} object. Note that this method
#'  is not truly random. Instead, \code{splitSample} iterates through the random sampling
#'  process until it settles on a solution such that both the training and validation set
#'  contain at least one subject for each class label. If this method finds no solution
#'  within 10 iterations, the function will post an error. Set \code{percent.include = 100}
#'  to skip random sampling and return a \code{NULL} validation set. Additional arguments
#'  (e.g. \code{replace = TRUE}) passed along to \code{\link{sample}}. This method works well
#'  for all (i.e. binary and multi-class) \code{ExprsArray} objects.
#'
#' \code{splitStratify} builds training and validation sets through a stratified
#'  random sampling process. This function utilizes the \code{strata} function from the
#'  sampling package as well as the \code{cut} function from the base package. The latter
#'  function provides a means by which to bin continuous data prior to stratified random
#'  sampling. We refer the user to the parameter descriptions to learn the specifics for
#'  how to use this function. When applied to an \code{ExprsMulti} object, this function
#'  stratifies subjects across all classes found in that object.
#'
#' @seealso
#' \code{\link{ExprsArray-class}}
NULL

#' @rdname split
#' @export
setGeneric("splitSample",
           function(object, ...) standardGeneric("splitSample")
)

#' @rdname split
#' @export
setGeneric("splitStratify",
           function(object, ...) standardGeneric("splitStratify")
)

###########################################################
### Split data

#' @rdname split
#'
#' @param object Specifies the \code{ExprsArray} object to split.
#' @param percent.include Specifies the percent of the total number
#'  of subjects to include in the training set.
#' @param ... For \code{splitSample}: additional arguments passed
#'  along to \code{\link{sample}}.
#' @return Returns a list of two \code{ExprsArray} objects.
#'
#' @export
setMethod("splitSample", "ExprsArray",
          function(object, percent.include, ...){

            if(percent.include < 1 | percent.include > 100){

              stop("Uh oh! Use an inclusion percentage between 1-100!")
            }

            # Return NULL validation set if percent.include = 100
            size <- round((ncol(object@exprs) * percent.include)/100, digits = 0)
            if(size == ncol(object@exprs)){

              cat("Building a NULL validation set...\n\n")
              return(list(
                "array.train" = object,
                "array.valid" = NULL)
              )
            }

            warning(c("This method is not truly random; at least one of every class ",
                      "will appear in validation set!"))

            # Sample until training and validation sets have one of every class
            # Terminate after 10 iterations if no solution found
            all.in <- FALSE
            counter <- 1
            while(!all.in){

              counter <- counter + 1
              if(counter > 10) stop("splitSample could not find a solution. Check the supplied parameters.")
              random.train <- sample(1:ncol(object@exprs), size = size, ...)
              random.valid <- setdiff(1:ncol(object@exprs), random.train)
              if(all(unique(object$defineCase) %in% object$defineCase[random.train]) &
                 all(unique(object$defineCase) %in% object$defineCase[random.valid])) all.in <- TRUE
            }

            return(list(
              "array.train" = object[random.train, , drop = FALSE],
              "array.valid" = object[random.valid, , drop = FALSE])
            )
          }
)

#' @rdname split
#'
#' @inheritParams splitSample
#' @param colBy Specifies a vector of column names by which to stratify in
#'  addition to class labels annotation. If \code{colBy = NULL}, random
#'  sampling will occur across the class label annotation only.
#' @param bin A logical vector indicating whether to bin the respective
#'  \code{colBy} column using \code{cut} (e.g. \code{bin = c(FALSE, TRUE)}).
#' @param ... For \code{splitSample}: additional arguments passed
#'  along to \code{\link{cut}}.
#'
#' @export
setMethod("splitStratify", "ExprsArray",
          function(object, percent.include, colBy = NULL,
                   bin = rep(FALSE, length(colBy)),
                   breaks, ...){

            if(percent.include < 1 | percent.include > 100){

              stop("Uh oh! Use an inclusion percentage between 1-100!")
            }

            if(!is.null(colBy)){

              # Perform pre-stratification binning
              vals <- lapply(seq_along(bin),
                             function(i){

                               # For each colBy argument, bin when appropriate
                               if(bin[i]) return(cut(object@annot[, colBy[i]], breaks = breaks[[i]], ...))
                               if(!bin[i]) return(object@annot[, colBy[i]])
                             }
              )

              # Add "defineCase" values to the vals bin list
              vals <- c(list(object@annot[, "defineCase"]), vals)

              # Name vals according to source
              names(vals) <- c("defineCase", colBy)

              # Build a sampling data.frame
              df <- data.frame(vals,
                               row.names = rownames(object@annot),
                               stringsAsFactors = FALSE)

              # Order vals
              index <- do.call(order, vals)
              df <- df[index, ]

              # Remove any row with NAs
              index.NAs <- apply(df, 1, function(row) !NA %in% row)
              df <- df[index.NAs, ]

              cat("\nPre-stratification table:\n")
              print(table(df))

              # Manipulate order of apply(df) so that size vector matches strata expectations
              sizes <- apply(table(df[, c("defineCase", rev(colBy))]), MARGIN = -1, FUN = min)
              sizes <- round(sizes * percent.include/100)
              sizes <- rep(sizes, length(unique(object$defineCase)))

              # Provide error for anticipated stratum of size 0
              if(0 %in% sizes) stop("This function cannot create a stratum of size 0. Subset first!")

              # Perform stratification with remaining non-NA colBy values (e.g. those introduced by binning)
              s <- sampling::strata(df, stratanames = colnames(df), size = sizes, method = "srswor")
              if(!identical(rownames(s), rownames(df)[s$ID_unit])) stop("Uh-oh! DEBUG ERROR: 001")

              cat("\nWeighted stratification results:\n")
              print(table(s[, colnames(df)]))
            }

            if(is.null(colBy)){

              # Build a sampling data.frame
              df <- data.frame("defineCase" = object@annot$defineCase,
                               row.names = rownames(object@annot),
                               stringsAsFactors = FALSE)

              cat("\nPre-stratification table:\n")
              print(table(df))

              # Compute strata sizes
              sizes <- min(table(df))
              sizes <- round(sizes * percent.include/100)
              sizes <- rep(sizes, length(unique(object$defineCase)))

              # Provide error for anticipated stratum of size 0
              if(0 %in% sizes) stop("This function cannot create a stratum of size 0. Subset first!")

              # Stratify
              s <- sampling::strata(df, stratanames = colnames(df), size = sizes, method = "srswor")
              rownames(s) <- rownames(df)[s$ID_unit]

              cat("\nWeighted stratification results:\n")
              print(table(s[, colnames(df)]))
            }

            return(list(
              "array.train" = object[rownames(s), , drop = FALSE],
              "array.valid" = object[setdiff(rownames(object@annot), rownames(s)), , drop = FALSE])
            )
          }
)