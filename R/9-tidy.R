###########################################################
### For a tidy application of exprso

#' Extract Training Set
#'
#' This function extracts the training set from the result of a
#'  \code{split} method call such as \code{splitSample} or \code{splitStratify}.
#'
#' @param splitSets A two-item list. The result of a \code{split} method call.
#' @return An \code{ExprsArray} object.
#'
#' @export
trainingSet <- function(splitSets){

  if(class(splitSets) == "list" & length(splitSets) == 2){

    return(splitSets[["array.train"]])

  }else{

    stop("Uh oh! Cannot extract the training set from this object.")
  }
}

#' Extract Validation Set
#'
#' This function extracts the validation set from the result of a
#'  \code{split} method call such as \code{splitSample} or \code{splitStratify}.
#'
#' @inheritParams trainingSet
#' @return An \code{ExprsArray} object.
#'
#' @export
validationSet <- function(splitSets){

  if(class(splitSets) == "list" & length(splitSets) == 2){

    return(splitSets[["array.valid"]])

  }else{

    stop("Uh oh! Cannot extract the validation set from this object.")
  }
}

#' @describeIn trainingSet Identical to the \code{validationSet} function.
#' @export
testSet <- function(splitSets){

  validationSet(splitSets)
}

#' ExprsArray Subset Wrapper
#'
#' This function provides a tidy wrapper for the \code{ExprsArray}
#'  \code{subset} method.
#'
#' @inheritParams arrayExprs
#' @param object An \code{ExprsArray} object to subset.
#' @param include A character vector. Specifies which annotations in \code{colBy}
#'  to include in the subset.
#' @return An \code{ExprsArray} object.
#'
#' @export
modSubset <- function(object, colBy, include){

  if(!inherits(object, "ExprsArray")){

    stop("Uh oh! You can only use modSubset to subset an ExprsArray object!")
  }

  subset(object, subset = object@annot[, colBy] %in% include)
}

###########################################################
### For a tidy source code

#' Build an args List
#' @param ... Arguments passed down from a calling function.
getArgs <- function(...){

  args <- as.list(substitute(list(...)))[-1]
  return(args)
}

#' Set an args List Element to Default Value
#' @param what The name of the argument.
#' @param as The value to set it as.
#' @param args An args list. The result of \code{\link{getArgs}}.
defaultArg <- function(what, as, args){

  if(!what %in% names(args)){

    cat("Setting", what, "to", as.character(as), "(default behavior, override explicitly)...\n")
    names(as) <- what
    args <- append(args, as.list(as))
  }

  return(args)
}

#' Force an args List Element to Value
#' @inheritParams defaultArg
forceArg <- function(what, as, args){

  if(!what %in% names(args)){

    cat("Setting", what, "to", as.character(as), "(default behavior, override explicitly)...\n")
    names(as) <- what
    args <- append(args, as.list(as))

  }else{

    if(args[[what]] == as){

      cat(paste0("Uh oh! This function requires ", what, " = ", as,
                 ". Setting ", what, " to ", as, "...\n"))
      args[[what]] <- as
    }
  }

  return(args)
}