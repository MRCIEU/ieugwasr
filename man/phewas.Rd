% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/query.R
\name{phewas}
\alias{phewas}
\title{Perform fast phewas of a specific variants against all available GWAS datasets}
\usage{
phewas(
  variants,
  pval = 1e-05,
  batch = c(),
  access_token = check_access_token()
)
}
\arguments{
\item{variants}{Array of variants e.g. \code{c("rs234", "7:105561135-105563135")}}

\item{pval}{p-value threshold. Default = \code{0.00001}}

\item{batch}{Vector of batch IDs to search across. If \code{c()} (default) then returns all batches}

\item{access_token}{Google OAuth2 access token.
Used to authenticate level of access to data.
By default, checks if already authenticated through \code{\link{get_access_token}} and
if not then does not perform authentication}
}
\value{
Dataframe
}
\description{
This is faster than doing it manually through \code{\link{associations}}
}
