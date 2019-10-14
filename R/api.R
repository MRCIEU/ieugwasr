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
	a <- googleAuthR::gar_auth(cache="ieugwasr_oauth", email=TRUE)
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
#' @return NULL
revoke_access_token <- function()
{
	a <- googleAuthR::gar_auth("mrbase.oauth")
	a$revoke()
}


