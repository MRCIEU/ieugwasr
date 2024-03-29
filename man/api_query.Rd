% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/query.R
\name{api_query}
\alias{api_query}
\title{Wrapper for sending queries and payloads to API}
\usage{
api_query(
  path,
  query = NULL,
  access_token = check_access_token(),
  method = "GET",
  silent = TRUE,
  encode = "json",
  timeout = 300
)
}
\arguments{
\item{path}{Either a full query path (e.g. for get) or an endpoint (e.g. for post) queries}

\item{query}{If post query, provide a list of arguments as the payload. \code{NULL} by default}

\item{access_token}{Google OAuth2 access token.
Used to authenticate level of access to data. By default, checks if already
authenticated through \code{\link{get_access_token}} and if not then does not perform authentication}

\item{method}{\code{"GET"} (default) or \code{"POST"}, \code{"DELETE"} etc}

\item{silent}{\code{TRUE}/\code{FALSE} to be passed to httr call. \code{TRUE} by default}

\item{encode}{Default = \code{"json"}, see \code{\link[httr:POST]{httr::POST}} for options}

\item{timeout}{Default = \code{300}, avoid increasing this, preferentially
simplify the query first.}
}
\value{
httr response object
}
\description{
There are a number of different GET and POST endpoints in the GWAS database API.
This is a generic way to access them.
}
