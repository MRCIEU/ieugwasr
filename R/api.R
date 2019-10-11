

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
get_mrbase_access_token <- function()
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
#' @param access_token=get_mrbase_access_token()
#'
#' @export
#' @return Parsed json output from query, often in form of data frame
api_query <- function(path, query=NULL, access_token=get_mrbase_access_token())
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
gwas_info <- function(id=NULL, access_token = get_mrbase_access_token())
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


#' <brief desc>
#'
#' <full description>
#'
#' @param rsid <what param does>
#' @param id <what param does>
#' @param proxies <what param does>
#' @param r2 <what param does>
#' @param align_alleles <what param does>
#' @param palindromes <what param does>
#' @param maf_threshold <what param does>
#'
#' @export
#' @return
associations <- function(rsid, id, proxies, r2, align_alleles, palindromes, maf_threshold)
{

}


phewas <- function(rsid, pval)
{

}


tophits <- function(id, pval, clump, r2, kb)
{

}