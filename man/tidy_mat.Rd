% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tidy_mat.R
\name{tidy_mat}
\alias{tidy_mat}
\title{Removes duplicated rows in the matrices and rows with "NA" inside.}
\usage{
tidy_mat(ugmat = NULL)
}
\arguments{
\item{ugmat}{A list with matrices and additional information about the selected region. mat generated by "get_matrix"-function, passed by "plot_hm"-function. Default value is NULL.}
}
\value{
list with cleaned matrices and additional information about the region entered in "get_matrix"-function. Will be used of "plot_hm"-function
}
\description{
Takes list with matrices passed by "plot_hm"-function and removes duplicated rows and rows with "NA" inside. Called by "plot_hm"-function.
}
