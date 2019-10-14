

#' Toggle API address between development and release
#'
#' @param where Which API to use. Choice between "local", "release", "test". Default = "local"
#'
#' @export
#' @return NULL
toggle_api <- function(where="test")
{
	url <- switch(where,
		test = "http://ieu-db-interface.epi.bris.ac.uk:8084/",
		dev = "http://localhost:8019/"
	)
	if(is.null(url))
	{
		url <- options()$mrbaseapi
		warning("A valid API was not selected. No change")
	}

	options(mrbaseapi=url)
	message("API: ", where, ": ", url)
}


#' Get access token for OAuth2 access to MR Base
#'
#'
#' @export
#' @return access token string
get_access_token <- function()
{
	tf <- basename(tempfile())
	check <- suppressWarnings(file.create(tf))
	if(!check)
	{
		stop("You are currently in a directory which doesn't have write access.\n",
			"  In order to authenticate we need to store the credentials in a file called '.httr-oauth'.\n",
			"  Please setwd() to a different directory where you have write access.")
	} else {
		unlink(tf)
	}
	a <- googleAuthR::gar_auth("mrbase.oauth")
	if(! a$validate())
	{
		a$refresh()
	}
	return(a$credentials$access_token)
}


#' Check if authentication has been made
#'
#' If a call to get_access_token() has been made then it will have generated mrbase.oauth. Pass the token if it is present, if not, return NULL and do not authenticate.
#'
#' @export
#' @return NULL or access_token depending on current authentication state
check_access_token <- function()
{
	if(file.exists("mrbase.oauth"))
	{
		return(get_access_token())
	} else {
		return(NULL)
	}
}


#' Revoke access token for MR Base
#'
#' @export
#' @return NULL
revoke_mrbase_access_token <- function()
{
	a <- googleAuthR::gar_auth("mrbase.oauth")
	a$revoke()
}


#' Wrapper for sending queries and payloads to API
#'
#' There are a number of different GET and POST endpoints in the GWAS database API. This is a generic way to access them
#'
#' @param path Either a full query path (e.g. for get) or an endpoint (e.g. for post) queries
#' @param query If post query, provide a list of arguments as the payload. NULL by default
#' @param access_token=check_access_token()
#'
#' @export
#' @return Parsed json output from query, often in form of data frame
api_query <- function(path, query=NULL, access_token=check_access_token())
{
	ntry <- 0
	ntries <- 3
	headers <- httr::add_headers(
		# 'Content-Type'='application/json; charset=UTF-8',
		'X-Api-Token'=access_token,
		'X-Api-Source'=ifelse(is.null(options()$mrbase.environment), 'R/TwoSampleMR', 'mr-base-shiny')
	)

	while(ntry <= ntries)
	{
		if(!is.null(query))
		{
			r <- try(
				httr::POST(
					paste0(options()$mrbaseapi, path),
					body = query, 
					headers,
					encode="json",
					httr::timeout(300)
				),
				silent=TRUE
			)
		} else {
			r <- try(
				httr::GET(
					paste0(options()$mrbaseapi, path),
					headers,
					httr::timeout(300)
				),
				silent=TRUE
			)			
		}
		if(class(r) == 'try-error')
		{
			if(grepl("Timeout", as.character(attributes(r)$condition)))
			{
				stop("The query to MR-Base exceeded 300 seconds and timed out. Please simplify the query")
			}
		}
		if(class(r) != 'try-error')
		{
			break
		}
		ntry <- ntry + 1
	}
	if(class(r) == 'try-error')
	{
		if(grepl("Could not resolve host", as.character(attributes(r)$condition)))
		{
			stop("The MR-Base server appears to be down, the following error was received:\n", as.character(attributes(r)$condition))
		} else {
			stop("The following error was encountered in trying to query the MR-Base server:\n",
				as.character(attributes(r)$condition)
			)
		}
	}

	if(httr::status_code(r) >= 200 & httr::status_code(r) < 300)
	# if(httr::status_code(r) >= 200)
	{
		return(jsonlite::fromJSON(httr::content(r, "text", encoding='UTF-8')))
	} else {
		return(r)
		stop("error code: ", httr::status_code(r), "\n  message: ", jsonlite::fromJSON(httr::content(r, "text", encoding='UTF-8')))
	}
}

# error_codes <- function(code)
# {
# 	codes <- list(
# 		data_frame(code=400, message = "Incorrect"),
# 		data_frame(code=400, message = ""),
# 	)
# }


#' MR-Base server status
#'
#' @export
#' @return list of values regarding status
api_status <- function()
{
	o <- api_query('status')
	class(o) <- "ApiStatus"
	return(o)
}

print.ApiStatus <- function(x)
{
	lapply(names(x), function(y) cat(format(paste0(y, ":"), width=30, justify="right"), x[[y]], "\n"))
}


#' Get list of studies with available GWAS summary statistics through API
#'
#' @param id List of MR-Base IDs to retrieve. If NULL (default) retrieves all available datasets
#' @param access_token Google OAuth2 access token. Used to authenticate level of access to data
#'
#' @export
#' @return Dataframe of details for all available studies
gwas_info <- function(id=NULL, access_token = get_access_token())
{
	if(!is.null(id))
	{
		stopifnot(is.vector(id))
		out <- api_query('gwasinfo', query = list(id=id), access_token=access_token)
	} else {
		out <- api_query('gwasinfo', access_token=access_token)
	}
	out <- dplyr::bind_rows(out) %>%
		dplyr::select(id, trait, sample_size, nsnp, year, consortium, author, dplyr::everything())
	class(out) <- c("GwasInfo", class(out))
	return(out)
}

print.GwasInfo <- function(x)
{
	dplyr::glimpse(x)
}


#' Query specific variants from specific GWAS
#'
#' Every rsid is searched for against each requested GWAS id. To get a list of available GWAS ids, or to find their meta data, use \code{gwasinfo}. Can request LD proxies for instances when the requested rsid is not present in a particular GWAS dataset. This currently only uses an LD reference panel composed of Europeans in 1000 genomes version 3. It is also restricted to biallelic single nucleotide polymorphisms (no indels), with European MAF > 0.01.
#'
#' @param variants Array of variants e.g. c("rs234", "7:105561135-105563135")
#' @param id Array of GWAS studies to query. See \code{gwasinfo} for available studies
#' @param proxies 0 or (default) 1 - indicating whether to look for proxies
#' @param r2 Minimum proxy LD rsq value. Default=0.8
#' @param align_alleles = 1 Try to align tag alleles to target alleles (if proxies = 1). 1 = yes, 0 = no
#' @param palindromes = 1 Allow palindromic SNPs (if proxies = 1). 1 = yes, 0 = no
#' @param maf_threshold = 0.3 MAF threshold to try to infer palindromic SNPs
#' @param access_token Google OAuth2 access token. Used to authenticate level of access to data. By default, checks if already authenticated through \code{get_access_token} and if not then does not perform authentication
#'
#' @export
#' @return Dataframe
associations <- function(variants, id, proxies=1, r2=0.8, align_alleles=1, palindromes=1, maf_threshold = 0.3, access_token=check_access_token())
{
	rsid <- variants_to_rsid(variants)
	api_query("associations", query=list(
		rsid=rsid,
		id=id,
		proxies=proxies,
		r2=r2,
		align_alleles=align_alleles,
		palindromes=palindromes,
		maf_threshold=maf_threshold
	), access_token=access_token)
}


#' Perform fast phewas of a specific variants against all available GWAS datasets
#'
#' This is faster than doing it manually through \code{associations}
#'
#' @param variants Array of variants e.g. c("rs234", "7:105561135-105563135")
#' @param pval p-value threshold. Default = 0.00001
#' @param access_token Google OAuth2 access token. Used to authenticate level of access to data. By default, checks if already authenticated through \code{get_access_token} and if not then does not perform authentication
#'
#' @export
#' @return Dataframe
phewas <- function(variants, pval = 0.00001, access_token=check_access_token())
{
	rsid <- variants_to_rsid(variants)
	api_query("phewas", query=list(
		rsid=rsid,
		pval=pval
	), access_token=access_token)
}


#' Obtain top hits from a GWAS dataset
#'
#' By default performs clumping on the server side. 
#'
#' @param id Array of GWAS studies to query. See \code{gwasinfo} for available studies
#' @param pval P-value threshold. Default = 5e-8
#' @param clump Whether to clump (1) or not (0). Default = 1
#' @param r2 Clumping r2 threshold. Default is very strict, 0.001
#' @param kb Clumping kb window. Default is very strict, 5000
#' @param access_token=check_access_token() <what param does>
#'
#' @export
#' @return Dataframe
tophits <- function(id, pval=5e-8, clump = 1, r2 = 0.001, kb = 5000, access_token=check_access_token())
{
	api_query("tophits", query=list(
		id=id,
		pval=pval,
		clump=clump,
		r2=r2,
		kb=kb
	), access_token=access_token)
}

