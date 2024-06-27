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
		dev2 = "http://127.0.0.1:5000/",
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

#' Retrieve OpenGWAS JSON Web Token from .Renviron file
#' 
#' @export
#' @return JWT string
get_opengwas_jwt <- function() {
	key <- Sys.getenv("OPENGWAS_JWT")
	# if(key == "") {
	# 	message("OPENGWAS_JWT=<token> needs to be set in your .Renviron file. You can obtain a token from https://api.opengwas.io")
	# }
	return(key)
}

#' Get user details
#' 
#' @param opengwas_jwt Used to authenticate protected endpoints. Login to https://api.opengwas.io to obtain a jwt. Provide the jwt string here, or store in .Renviron under the keyname OPENGWAS_JWT.
#' 
#' @export
#' @return user information
user <- function(opengwas_jwt=get_opengwas_jwt()) {
	if(nchar(opengwas_jwt)>0) {
		message("Important note: do not share your token with others as it is equivalent to a password.")
	}
	api_query('user', opengwas_jwt=opengwas_jwt, override_429=TRUE) %>% get_query_content()
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


#' Check if authentication has been maded
#'
#' Deprectated. Use `get_opengwas_jwt()` instead. See https://mrcieu.github.io/ieugwasr/articles/guide.html#authentication for more information.
#'
#' @export
#' @return NULL or access_token depending on current authentication state
check_access_token <- function()
{
	message("Deprectated. Use `get_opengwas_jwt()` instead. See https://mrcieu.github.io/ieugwasr/articles/guide.html#authentication for more information.")
}

