#' Toggle API address between development and release
#'
#' @param where Which API to use. Choice between `"public"`, `"private"`, `"dev1"`, `"dev2"`. 
#' Default = `"public"`.
#'
#' @export
#' @return NULL
select_api <- function(where="public")
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
	message("API: ", where, ": ", url)
}

#' Retrieve OpenGWAS JSON Web Token from .Renviron file
#' 
#' @export
#' @return JWT string
get_opengwas_jwt <- function() {
	key <- Sys.getenv("OPENGWAS_JWT")
	if(key == "") {
		message("OPENGWAS_JWT=<token> needs to be set in your .Renviron file. You can obtain a token from https://api.opengwas.io")
	}
	return(key)
}


#' Details of how access token logs are used
#'
#' @export
#' @return NULL
logging_info <- function()
{
	message(
		"Please note that we log your email address to\n",
		"a) ensure that you obtain appropriate access to the GWAS database,\n", 
		"b) to compile usage statistics that help us keep this project funded, and\n", 
		"c) to monitor inappropriate or unfair usage.\n",
		"We do NOT log the queries that are being performed, and we do NOT share your email address with anybody else.")
}
