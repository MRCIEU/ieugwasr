% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/afl2.r
\name{afl2_chrpos}
\alias{afl2_chrpos}
\title{Look up allele frequencies and LD scores for 1000 genomes populations by chrpos}
\usage{
afl2_chrpos(chrpos, reference = "1000g")
}
\arguments{
\item{chrpos}{list of <chr>:<pos> in build 37, e.g. c("3:46414943", "3:122991235"). Also allows ranges e.g "7:105561135-105563135"}

\item{reference}{Default="1000g"}
}
\value{
data frame
}
\description{
Look up allele frequencies and LD scores for 1000 genomes populations by chrpos
}