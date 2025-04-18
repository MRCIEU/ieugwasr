% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/query.R
\name{check_reset}
\alias{check_reset}
\title{Check if OpenGWAS allowance needs to be reset}
\usage{
check_reset(override_429 = FALSE)
}
\arguments{
\item{override_429}{Logical value indicating whether to override the allowance reset check (default: \code{FALSE})}
}
\description{
This function checks if a recent query indicated that the OpenGWAS allowance has been used up. To prevent the IP being blocked, it will error if the new query is being submitted before the reset time.
If the allowance has been used up, it displays a message indicating the time when the allowance will be reset.
By default, the function will throw an error if the allowance has been used up, but this behavior can be overridden by setting \code{override_429} to \code{TRUE}.
}
