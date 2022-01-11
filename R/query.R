#' Wrapper for sending queries and payloads to API
#'
#' There are a number of different GET and POST endpoints in the GWAS database API. 
#' This is a generic way to access them.
#'
#' @param path Either a full query path (e.g. for get) or an endpoint (e.g. for post) queries
#' @param query If post query, provide a list of arguments as the payload. `NULL` by default
#' @param access_token Google OAuth2 access token. 
#' Used to authenticate level of access to data. By default, checks if already 
#' authenticated through [`get_access_token`] and if not then does not perform authentication
#' @param method `"GET"` (default) or `"POST"`, `"DELETE"` etc
#' @param silent `TRUE`/`FALSE` to be passed to httr call. `TRUE` by default
#' @param encode Default = `"json"`, see [`httr::POST`] for options
#' @param timeout Default = `300`, avoid increasing this, preferentially 
#' simplify the query first.
#'
#' @export
#' @return httr response object
api_query <- function(path, query=NULL, access_token=check_access_token(), 
                      method="GET", silent=TRUE, encode="json", timeout=300)
{
	ntry <- 0
	ntries <- 5
	headers <- httr::add_headers(
		# 'Content-Type'='application/json; charset=UTF-8',
		'X-Api-Token'=access_token,
		'X-Api-Source'=ifelse(is.null(options()$mrbase.environment), 'R/TwoSampleMR', 'mr-base-shiny')
	)

	retry_flag <- FALSE

	while(ntry <= ntries)
	{
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
		if('try-error' %in% class(r))
		{
			if(grepl("Timeout", as.character(attributes(r)$condition)))
			{
				stop("The query to MR-Base exceeded ", timeout, " seconds and timed out. Please simplify the query")
			}
		}
		if(! 'try-error' %in% class(r))
		{
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

	if(r$status_code >= 500 & r$status_code < 600)
	{
		message("Server error: ", r$status_code)
		message("Failed to retrieve results from server. See error status message in the returned object and contact the developers if the problem persists.")
		return(r)
	}
	if('try-error' %in% class(r))
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

	return(r)
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
}


#' MR-Base server status
#'
#' @export
#' @return list of values regarding status
api_status <- function()
{
	o <- api_query('status') %>% get_query_content
	class(o) <- "ApiStatus"
	return(o)
}

print.ApiStatus <- function(x)
{
	lapply(names(x), function(y) cat(format(paste0(y, ":"), width=30, justify="right"), x[[y]], "\n"))
}


#' Get list of studies with available GWAS summary statistics through API
#'
#' @param id List of MR-Base IDs to retrieve. If `NULL` (default) retrieves all 
#' available datasets
#' @param access_token Google OAuth2 access token. Used to authenticate level of access to data
#'
#' @importFrom magrittr %>%
#' @export
#' @return Dataframe of details for all available studies
gwasinfo <- function(id=NULL, access_token = check_access_token())
{
	id <- legacy_ids(id)
	if(!is.null(id))
	{
		stopifnot(is.vector(id))
		out <- api_query('gwasinfo', query = list(id=id), access_token=access_token) %>% get_query_content()
	} else {
		out <- api_query('gwasinfo', access_token=access_token) %>% get_query_content()
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

print.GwasInfo <- function(x)
{
	dplyr::glimpse(x)
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

#' Get list of data batches in IEU GWAS database
#'
#'
#' @param access_token Google OAuth2 access token. Used to authenticate level of access to data
#'
#' @export
#' @return data frame
batches <- function(access_token = check_access_token())
{
	api_query('batches', access_token=access_token) %>% get_query_content()
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
#' @param access_token Google OAuth2 access token. 
#' Used to authenticate level of access to data. 
#' By default, checks if already authenticated through [`get_access_token`] and 
#' if not then does not perform authentication
#'
#' @export
#' @return Dataframe
associations <- function(variants, id, proxies=1, r2=0.8, align_alleles=1, palindromes=1, maf_threshold = 0.3, access_token=check_access_token())
{
	id <- legacy_ids(id)
	out <- api_query("associations", query=list(
		variant=variants,
		id=id,
		proxies=proxies,
		r2=r2,
		align_alleles=align_alleles,
		palindromes=palindromes,
		maf_threshold=maf_threshold
	), access_token=access_token) %>% get_query_content()

	if(class(out) == "response")
	{
		return(out)
	} else if(is.data.frame(out)) {
		out %>% dplyr::as_tibble() %>% fix_n() %>% return()
	} else {
		return(dplyr::tibble())
	}
}

#' Look up sample sizes when meta data is missing from associations
#'
#' @param d Output from [`associations`]
#'
#' @export
#' @return Updated version of d
fill_n <- function(d)
{
	id <- d$id[1]
	if(! "n" %in% names(d))
	{
		d$n <- NA
	}
	d$n <- as.numeric(d$n)
	if(any(is.na(d$n)))
	{
		info <- gwasinfo(id)
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
#' @param access_token Google OAuth2 access token. 
#' Used to authenticate level of access to data. 
#' By default, checks if already authenticated through [`get_access_token`] and 
#' if not then does not perform authentication
#'
#' @export
#' @return Dataframe
phewas <- function(variants, pval = 0.00001, batch=c(), access_token=check_access_token())
{
	out <- api_query("phewas", query=list(
		variant=variants,
		pval=pval,
		index_list=batch
	), access_token=access_token) %>% get_query_content()
	if(class(out) != "response")
	{
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
#' @param access_token Google OAuth2 access token. 
#' Used to authenticate level of access to data. 
#' By default, checks if already authenticated through [`get_access_token`] 
#' and if not then does not perform authentication
#'
#' @export
#' @return Dataframe
tophits <- function(id, pval=5e-8, clump = 1, r2 = 0.001, kb = 10000, pop="EUR", 
                    force_server = FALSE, access_token=check_access_token())
{
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
	), access_token=access_token) %>% get_query_content()
	if(class(out) == "response")
	{
		return(out)
	} else if(is.data.frame(out)) {
		out %>% dplyr::as_tibble() %>% fix_n() %>% return()
	} else {
		return(dplyr::tibble())
	}
}


#' Check datasets that are in process of being uploaded
#'
#' @param id ID
#' @param access_token Google OAuth2 access token. 
#' Used to authenticate level of access to data. 
#' By default, checks if already authenticated through [`get_access_token`] 
#' and if not then does not perform authentication
#'
#' @export
#' @return Dataframe
editcheck <- function(id, access_token=check_access_token())
{
	api <- options()[["ieugwasr_api"]]
	select_api("private")
	out <- api_query(paste0("edit/check/", id), access_token=access_token) %>%
		get_query_content()
	options(ieugwasr_api=api)
	return(out)
}
