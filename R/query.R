#' Wrapper for sending queries and payloads to API
#'
#' There are a number of different GET and POST endpoints in the GWAS database API. 
#' This is a generic way to access them.
#'
#' @param path Either a full query path (e.g. for get) or an endpoint (e.g. for post) queries
#' @param query If post query, provide a list of arguments as the payload. `NULL` by default
#' @param opengwas_jwt Used to authenticate protected endpoints. Login to https://api.opengwas.io to obtain a jwt. Provide the jwt string here, or store in .Renviron under the keyname OPENGWAS_JWT.
#' @param method `"GET"` (default) or `"POST"`, `"DELETE"` etc
#' @param silent `TRUE`/`FALSE` to be passed to httr call. `TRUE` by default
#' @param encode Default = `"json"`, see [`httr::POST`] for options
#' @param timeout Default = `300`, avoid increasing this, preferentially 
#' simplify the query first.
#' @param override_429 Default=`FALSE`. If allowance is exceeded then the query will error before submitting a request to avoid getting blocked. If you are sure you want to submit the request then set this to TRUE.
#'
#' @export
#' @return httr response object
api_query <- function(path, query=NULL, opengwas_jwt=get_opengwas_jwt(), 
                      method="GET", silent=TRUE, encode="json", timeout=300, override_429=FALSE)
{
	# check if previous query gave 429 error, and allowance was maxed out
	check_reset(override_429)

	ntry <- 0
	ntries <- 5
	if(opengwas_jwt == "") {
		headers <- httr::add_headers(
			# 'Content-Type'='application/json; charset=UTF-8',
			'X-Api-Source'=ifelse(is.null(options()$mrbase.environment), 'R/TwoSampleMR', 'mr-base-shiny'),
			'X-TEST-MODE-KEY'=Sys.getenv("OPENGWAS_X_TEST_MODE_KEY")
		)
	} else {
		headers <- httr::add_headers(
			# 'Content-Type'='application/json; charset=UTF-8',
			'X-Api-Source'=ifelse(is.null(options()$mrbase.environment), 'R/TwoSampleMR', 'mr-base-shiny'),
			'X-TEST-MODE-KEY'=Sys.getenv("OPENGWAS_X_TEST_MODE_KEY"),
			'Authorization'=paste("Bearer", opengwas_jwt=opengwas_jwt)
		)
	}
	retry_flag <- FALSE
	while(ntry <= ntries)
	{
		Sys.sleep(2^ntry-1)
		if(method == "DELETE")
		{
			r <- try(
				httr::DELETE(
					paste0(options()$ieugwasr_api, path),
					headers,
					httr::timeout(timeout)
				),
				silent=TRUE
			)
		} else if(!is.null(query)) {
			r <- try(
				httr::POST(
					paste0(options()$ieugwasr_api, path),
					body = query, 
					headers,
					encode=encode,
					httr::timeout(timeout)
				),
				silent=TRUE
			)
		} else {
			r <- try(
				httr::GET(
					paste0(options()$ieugwasr_api, path),
					headers,
					httr::timeout(timeout)
				),
				silent=TRUE
			)			
		}
		if(inherits(r, 'try-error'))
		{
			if(grepl("Timeout", as.character(attributes(r)$condition)))
			{
				stop("The query to OpenGWAS exceeded ", timeout, " seconds and timed out. Potential reasons:
				- You have a bad internet connection
				- The query was very large and it timed out
				- You have maxed out your allowance, and kept submitting requests, which led to your IP address being temporarily blocked. See here for details: https://api.opengwas.io/api/#allowance")
			}
		}

		if(! inherits(r, 'try-error'))
		{
			if(r$status_code == 429) {
				set_reset(r)
				return(r)
			}
			if(r$status_code >= 500 & r$status_code < 600)
			{
				message("Server code: ", r$status_code, "; Server is possibly experiencing traffic, trying again...")
				retry_flag <- TRUE
				Sys.sleep(1)
			} else {
				if(retry_flag)
				{
					message("Retry succeeded!")
				}
				break
			}
		}
		ntry <- ntry + 1
	}

	if(inherits(r, 'try-error'))
	{
		if(grepl("Could not resolve host", as.character(attributes(r)$condition)))
		{
			stop("The OpenGWAS server appears to be down, the following error was received:\n", as.character(attributes(r)$condition))
		} else {
			stop("The following error was encountered in trying to query the OpenGWAS server:\n",
				as.character(attributes(r)$condition)
			)
		}
	}

	if(r$status_code >= 500 & r$status_code < 600)
	{
		message("Server error: ", r$status_code)
		message("Failed to retrieve results from server. See error status message in the returned object and contact the developers if the problem persists.")
		return(r)
	}

	return(r)
}

#' Set the reset time for OpenGWAS allowance
#'
#' This function sets the reset time for the OpenGWAS allowance based on the retry-after header
#' returned by the API response. It also displays a warning message indicating the time at which
#' the allowance will reset.
#' 
#'
#' @param r The API response object
#' @return None
set_reset <- function(r) {
	ret <- as.numeric(Sys.time()) + as.numeric(r$headers$`retry-after`)
	options(ieugwasr_reset=ret)
	warning("You have used up your OpenGWAS allowance. Your allowance will reset at ", as.POSIXct(ret), ". See https://api.opengwas.io/api/#allowance for more details.")
}


#' Check if OpenGWAS allowance needs to be reset
#'
#' This function checks if a recent query indicated that the OpenGWAS allowance has been used up. To prevent the IP being blocked, it will error if the new query is being submitted before the reset time.
#' If the allowance has been used up, it displays a message indicating the time when the allowance will be reset.
#' By default, the function will throw an error if the allowance has been used up, but this behavior can be overridden by setting `override_429` to `TRUE`.
#'
#' @param override_429 Logical value indicating whether to override the allowance reset check (default: `FALSE`)
#'
#' @return NULL
check_reset <- function(override_429=FALSE) {
	if(! is.null(options()$ieugwasr_reset)) {
		if(as.numeric(Sys.time()) < options()$ieugwasr_reset) {
			rt <- as.POSIXct(options()$ieugwasr_reset)
			msg <- paste0("You have used up your OpenGWAS allowance. Please wait until ", rt, "to submit another query. See https://api.opengwas.io/api/#allowance for more details. This check is in place to prevent your IP address from being temporarily blocked, but you can override it at your own risk by setting override_429=TRUE.")
			if(!override_429) {
				stop(msg)
			} else {
				warning(msg)
			}
		} else {
			options(ieugwasr_reset=NULL)
		}
	} else {
		options(ieugwasr_reset=NULL)
	}
	return(NULL)
}


#' Parse out json response from httr object
#'
#' @param response Output from httr
#'
#' @export
#' @return Parsed json output from query, often in form of data frame. 
#' If status code is not successful then return the actual response
get_query_content <- function(response)
{
	if(httr::status_code(response) >= 200 & httr::status_code(response) < 300)
	{
		o <- jsonlite::fromJSON(httr::content(response, "text", encoding='UTF-8'))
		if('eaf' %in% names(o)) 
		{
			o[["eaf"]] <- as.numeric(o[["eaf"]])
		}
		return(o)
	} else {
		return(response)
		# stop("error code: ", httr::status_code(response), "\n  message: ", jsonlite::fromJSON(httr::content(response, "text", encoding='UTF-8')))
	}
	return(NULL)
}


#' OpenGWAS server status
#'
#' @export
#' @return List of values regarding status
api_status <- function()
{
	o <- api_query('status', override_429=TRUE) %>% get_query_content
	class(o) <- "ApiStatus"
	return(o)
}

#' Print API status
#' @param x Output from [`api_status`]
#' @param ... Unused, for extensibility
#' @export 
#' @return Print out of API status
print.ApiStatus <- function(x, ...)
{
	lapply(names(x), function(y) cat(format(paste0(y, ":"), width=30, justify="right"), x[[y]], "\n"))
}


#' Get list of studies with available GWAS summary statistics through API
#'
#' @param id List of OpenGWAS IDs to retrieve. If `NULL` (default) retrieves all 
#' available datasets
#' @param opengwas_jwt Used to authenticate protected endpoints. Login to https://api.opengwas.io to obtain a jwt. Provide the jwt string here, or store in .Renviron under the keyname OPENGWAS_JWT.
#'
#' @export
#' @return Dataframe of details for all available studies
gwasinfo <- function(id=NULL, opengwas_jwt=get_opengwas_jwt())
{
	id <- legacy_ids(id)
	if(!is.null(id))
	{
		stopifnot(is.vector(id))
		out <- api_query('gwasinfo', query = list(id=id), opengwas_jwt=opengwas_jwt) %>% get_query_content()
	} else {
		out <- api_query('gwasinfo', opengwas_jwt=opengwas_jwt) %>% get_query_content()
	}
	if(length(out) == 0)
	{
		return(dplyr::tibble())
	}
	out <- dplyr::bind_rows(out) %>%
		dplyr::select("id", "trait", dplyr::everything())
	class(out) <- c("GwasInfo", class(out))
	return(out)
}

#' Print GWAS information
#' @param x Output from [`gwasinfo`]
#' @param ... Unused, for extensibility
#' @export
#' @return Print out of GWAS information 
print.GwasInfo <- function(x, ...)
{
	dplyr::glimpse(x)
}


#' Get list of download URLs for each file associated with a dataset through API
#' 
#' `gwasinfo_files()` returns a list of download URLs for each file (.vcf.gz, .vcf.gz.tbi, _report.html) associated with a dataset. 
#' The URLs will expire in 2 hours. 
#' If a dataset is missing from the results, 
#' that means either the dataset doesn't exist or you don't have access to it.
#' If a dataset is in the results but some/all links are missing, that means the files are unavailable.
#'
#' @param id List of OpenGWAS IDs to retrieve.
#' @param opengwas_jwt Used to authenticate protected endpoints. Login to https://api.opengwas.io to obtain a JWT. Provide the JWT string here, or store in .Renviron under the keyname OPENGWAS_JWT.
#'
#' @export
#' @return Dataframe of details for requested studies
gwasinfo_files <- function(id, opengwas_jwt=get_opengwas_jwt()) {
  if (is.null(id)) stop("List of study ids must be provided.")
  id <- legacy_ids(id)
  stopifnot(is.vector(id))
  out <- api_query('gwasinfo/files', query = list(id=id), opengwas_jwt=opengwas_jwt) %>% get_query_content()
  if(length(out) == 0) {
    return(dplyr::tibble())
  }
  else {
    return(dplyr::bind_rows(out))
  }
}


#' Extract batch name from study ID
#'
#' @param id Array of study IDs
#'
#' @export
#' @return Array of batch names
batch_from_id <- function(id)
{
	sapply(strsplit(id, "-"), function(x) paste(x[1], x[2], sep="-"))
}

#' Get list of data batches in IEU OpenGWAS database
#'
#' @param opengwas_jwt Used to authenticate protected endpoints. Login to https://api.opengwas.io to obtain a jwt. Provide the jwt string here, or store in .Renviron under the keyname OPENGWAS_JWT.
#'
#' @export
#' @return data frame
batches <- function(opengwas_jwt=get_opengwas_jwt())
{
	api_query('batches', opengwas_jwt=opengwas_jwt, override_429=TRUE) %>% get_query_content()
}

#' Query specific variants from specific GWAS
#'
#' Every rsid is searched for against each requested GWAS id. To get a list of 
#' available GWAS ids, or to find their meta data, use [`gwasinfo`]. 
#' Can request LD proxies for instances when the requested rsid is not present 
#' in a particular GWAS dataset. This currently only uses an LD reference panel 
#' composed of Europeans in 1000 genomes version 3. 
#' It is also restricted to biallelic single nucleotide polymorphisms (no indels), 
#' with European MAF > 0.01.
#'
#' @param variants Array of variants e.g. `c("rs234", "7:105561135-105563135")`
#' @param id Array of GWAS studies to query. See [`gwasinfo`] for available studies
#' @param proxies `0` or (default) `1` - indicating whether to look for proxies
#' @param r2 Minimum proxy LD rsq value. Default=`0.8`
#' @param align_alleles Try to align tag alleles to target alleles (if `proxies = 1`). 
#' `1` = yes (default), `0` = no
#' @param palindromes Allow palindromic SNPs (if `proxies = 1`). `1` = yes (default), `0` = no
#' @param maf_threshold MAF threshold to try to infer palindromic SNPs. Default = `0.3`.
#' @param opengwas_jwt Used to authenticate protected endpoints. Login to https://api.opengwas.io to obtain a jwt. Provide the jwt string here, or store in .Renviron under the keyname OPENGWAS_JWT.
#'
#' @export
#' @return Dataframe
associations <- function(variants, id, proxies=1, r2=0.8, align_alleles=1, palindromes=1, maf_threshold = 0.3, opengwas_jwt=get_opengwas_jwt()) {
	id <- legacy_ids(id)
	out <- api_query("associations", query=list(
		variant=variants,
		id=id,
		proxies=proxies,
		r2=r2,
		align_alleles=align_alleles,
		palindromes=palindromes,
		maf_threshold=maf_threshold
	), opengwas_jwt=opengwas_jwt) %>% get_query_content()

	if(inherits(out, "response"))
	{
		return(out)
	} else if(is.data.frame(out)) {
		out %>% dplyr::as_tibble() %>% fix_n() %>% return()
	} else {
		return(dplyr::tibble())
	}
	
	return(out)
}

#' Look up sample sizes when meta data is missing from associations
#'
#' @param d Output from [`associations`]
#' @param opengwas_jwt Used to authenticate protected endpoints. Login to https://api.opengwas.io to obtain a jwt. Provide the jwt string here, or store in .Renviron under the keyname OPENGWAS_JWT.
#'
#' @export
#' @return Updated version of d
fill_n <- function(d, opengwas_jwt=get_opengwas_jwt())
{
	id <- d$id[1]
	if(! "n" %in% names(d))
	{
		d$n <- NA
	}
	d$n <- as.numeric(d$n)
	if(any(is.na(d$n)))
	{
		info <- gwasinfo(id, opengwas_jwt=opengwas_jwt)
		if(!is.na(info$sample_size))
		{
			d$n <- info$sample_size
		} else {
			d$n <- info$ncase + info$ncontrol
		}
	}
	return(d)	
}

fix_n <- function(d)
{
	if("n" %in% names(d))
	{
		d[["n"]] <- as.numeric(d[["n"]])
	}
	# Issue with the ukb-e batch - need to flip alleles until it is fixed
	index <- grepl("ukb-e", d[["id"]])
	d[["beta"]][index] <- d[["beta"]][index] * -1
	return(d)
}

#' Perform fast phewas of a specific variants against all available GWAS datasets
#'
#' This is faster than doing it manually through [`associations`]
#'
#' @param variants Array of variants e.g. `c("rs234", "7:105561135-105563135")`
#' @param pval p-value threshold. Default = `0.00001`
#' @param batch Vector of batch IDs to search across. If `c()` (default) then returns all batches
#' @param opengwas_jwt Used to authenticate protected endpoints. Login to https://api.opengwas.io to obtain a jwt. Provide the jwt string here, or store in .Renviron under the keyname OPENGWAS_JWT.
#'
#' @export
#' @return Dataframe
phewas <- function(variants, pval = 0.00001, batch=c(), opengwas_jwt=get_opengwas_jwt())
{
	out <- api_query("phewas", query=list(
		variant=variants,
		pval=pval,
		index_list=batch
	), opengwas_jwt=opengwas_jwt) %>% get_query_content()
	
	if(!inherits(out, "response")) {
		out <- out %>% dplyr::as_tibble() %>% fix_n()
		if(nrow(out) > 0)
		{
			out <- dplyr::arrange(out, .data$p)
		}
		if(nrow(out) >= 100000)
		{
			warning("Reached output limit of 100000 rows. Please reduce your query size.")
		}
	}
	return(out)
}


#' Obtain top hits from a GWAS dataset
#'
#' By default performs clumping on the server side. 
#'
#' @param id Array of GWAS studies to query. See [`gwasinfo`] for available studies
#' @param pval use this p-value threshold. Default = `5e-8`
#' @param clump whether to clump (`1`) or not (`0`). Default = `1`
#' @param r2 use this clumping r2 threshold. Default is very strict, `0.001`
#' @param kb use this clumping kb window. Default is very strict, `10000`
#' @param force_server Logical. By default will return preclumped hits. 
#' p-value threshold 5e-8, with r2 threshold 0.001 and kb threshold 10000, 
#' using only SNPs with MAF > 0.01 in the European samples in 1000 genomes. 
#' If force_server = `TRUE` then will recompute using server side LD reference panel.
#' @param pop Super-population to use as reference panel. Default = `"EUR"`. 
#' Options are `"EUR"`, `"SAS"`, `"EAS"`, `"AFR"`, `"AMR"`
#' @param opengwas_jwt Used to authenticate protected endpoints. Login to https://api.opengwas.io to obtain a jwt. Provide the jwt string here, or store in .Renviron under the keyname OPENGWAS_JWT.
#'
#' @export
#' @return Dataframe
tophits <- function(id, pval=5e-8, clump = 1, r2 = 0.001, kb = 10000, pop="EUR", 
                    force_server = FALSE, opengwas_jwt=get_opengwas_jwt()) {
	id <- legacy_ids(id)
	if(clump == 1 & r2 == 0.001 & kb == 10000 & pval == 5e-8)
	{
		preclumped <- 1
	} else {
		preclumped <- 0
	}
	if(preclumped == 1 & force_server)
	{
		preclumped <- 0
	}
	out <- api_query("tophits", query=list(
		id=id,
		pval=pval,
		preclumped=preclumped,
		clump=clump,
		r2=r2,
		kb=kb,
		pop=pop
	), opengwas_jwt=opengwas_jwt) %>% get_query_content()
	if(inherits(out, "response"))
	{
		return(out)
	} else if(is.data.frame(out)) {
		out %>% dplyr::as_tibble() %>% fix_n() %>% return()
	} else if(out == "[]") {
		return(dplyr::tibble())
	} else {
		stop("There was an error, please contact the developers")
	}
}


#' Check datasets that are in process of being uploaded
#'
#' @param id ID
#' @param opengwas_jwt Used to authenticate protected endpoints. Login to https://api.opengwas.io to obtain a jwt. Provide the jwt string here, or store in .Renviron under the keyname OPENGWAS_JWT.
#'
#' @export
#' @return Dataframe
editcheck <- function(id, opengwas_jwt=get_opengwas_jwt())
{
	api <- options()[["ieugwasr_api"]]
	select_api("private")
	out <- api_query(paste0("edit/check/", id), opengwas_jwt=opengwas_jwt) %>%
		get_query_content()
	options(ieugwasr_api=api)
	return(out)
}
