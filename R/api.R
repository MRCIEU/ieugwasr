#' Toggle API address between development and release
#'
#' @param where Which API to use. Choice between `"public"`, `"private"`, `"dev1"`, `"dev2"`. 
#' Default = `"public"`.
#' @param silent Silent? Default = FALSE
#'
#' @export
#' @return No return value, called for side effects
select_api <- function(where="public", silent=FALSE)
{
	url <- switch(where,
		public = "https://api.opengwas.io/api/",
		private = "http://ieu-db-interface.epi.bris.ac.uk:8082/",
		dev1 = "http://localhost:8019/",
		dev2 = "http://127.0.0.1:5000/"
	)
	if(is.null(url))
	{
		url <- options()$ieugwasr_api
		warning("A valid API was not selected. No change")
	}

	options(ieugwasr_api=url)
	if(!silent) {
		message("API: ", where, ": ", url)
	}
}


#' Get access token for OAuth2 access to MR Base
#'
#'
#' @export
#' @return access token string
get_access_token <- function()
{
	message("Using access token. For info on how this is used see logging_info()")
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
	a <- googleAuthR::gar_auth(email=TRUE)
	if(! a$validate())
	{
		a$refresh()
	}
	return(a$credentials$access_token)
}


#' Check if authentication has been made
#'
#' If a call to [`get_access_token()`] has been made then it will have generated `mrbase.oauth`. 
#' Pass the token if it is present, if not, return `NULL` and do not authenticate.
#'
#' @export
#' @return NULL or access_token depending on current authentication state
check_access_token <- function()
{
	if(file.exists("ieugwasr_oauth"))
	{
		return(get_access_token())
	} else {
		return(NULL)
	}
}


#' Revoke access token for MR Base
#'
#' @export
#' @return No return value, called for side effects
revoke_access_token <- function()
{
	a <- googleAuthR::gar_auth("mrbase.oauth")
	a$revoke()
}


#' Details of how access token logs are used
#'
#' @export
#' @return No return value, called for side effects
logging_info <- function()
{
	message(
		"Please note that we log your email address to\n",
		"a) ensure that you obtain appropriate access to the GWAS database,\n", 
		"b) to compile usage statistics that help us keep this project funded, and\n", 
		"c) to monitor inappropriate or unfair usage.\n",
		"We do NOT log the queries that are being performed, and we do NOT share your email address with anybody else.")
}
