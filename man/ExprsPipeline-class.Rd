% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/1.1-classes.R, R/1.2-methods.R
\docType{class}
\name{ExprsPipeline-class}
\alias{$,ExprsPipeline-method}
\alias{ExprsPipeline-class}
\alias{[,ExprsPipeline,ANY,ANY,ANY-method}
\alias{[,ExprsPipeline-method}
\alias{getFeatures,ExprsPipeline-method}
\alias{show,ExprsPipeline-method}
\alias{subset,ExprsPipeline-method}
\alias{summary,ExprsPipeline-method}
\title{An S4 class to store models built during high-throughput learning}
\usage{
\S4method{show}{ExprsPipeline}(object)

\S4method{[}{ExprsPipeline,ANY,ANY,ANY}(x, i, j)

\S4method{$}{ExprsPipeline}(x, name)

\S4method{subset}{ExprsPipeline}(x, subset, select)

\S4method{summary}{ExprsPipeline}(object)

\S4method{getFeatures}{ExprsPipeline}(object, index)
}
\arguments{
\item{object, x}{An object of class \code{ExprsPipeline}.}

\item{i, j}{Subsets entire \code{ExprsPipeline} object via
\code{object@summary[i, j]}. Returns \code{object@summary[, j]} if
argument \code{i} is missing.}

\item{name}{Returns \code{object@summary[, name]}.}

\item{subset}{Subsets entire \code{ExprsPipeline} object via
\code{object@summary[subset, ]}. Can be used to rearrange summary table.}

\item{select}{Subsets entire \code{ExprsPipeline} object via
\code{object@summary[, select]}. Can be used to rearrange summary table.}

\item{index}{A numeric scalar. The i-th model from which to retrieve features.
If missing, \code{getFeatures} will tabulate features across all models.}
}
\description{
An S4 class to store models built during high-throughput learning
}
\section{Methods (by generic)}{
\itemize{
\item \code{show}: Method to show \code{ExprsPipeline} object.

\item \code{[}: Method to subset \code{ExprsPipeline} object.

\item \code{$}: Method to subset \code{ExprsPipeline} object.

\item \code{subset}: Method to subset \code{ExprsPipeline} object.

\item \code{summary}: Method to summarize \code{ExprsPipeline} classification results.

\item \code{getFeatures}: Method to return features within an \code{ExprsPredict} model.
}}
\section{Slots}{

\describe{
\item{\code{summary}}{Typically a data.frame. Stores the parameters and
performances for classification models.}

\item{\code{machs}}{Typically a list. Stores the classification models
referenced in \code{summary} slot.}
}}
\seealso{
\code{\link{ExprsArray-class}}\cr
\code{\link{ExprsModel-class}}\cr
\code{\link{ExprsPipeline-class}}\cr
\code{\link{ExprsEnsemble-class}}\cr
\code{\link{ExprsPredict-class}}
}

