.onLoad <- function(libname, pkgname) {

	op <- options()
	op.googleAuthR <- list(
		gargle_oauth_cache = "ieugwasr_oauth",
		googleAuthR.verbose = 3,
		googleAuthR.webapp.client_id = "906514199468-1jpkqgngur8emoqfg9j460s47fdo2euo.apps.googleusercontent.com",
		googleAuthR.webapp.client_secret = "I7Gqp83Ku4KJxL9zHWYxG_gD",

		googleAuthR.client_id = "906514199468-m9thhcept50gu26ng494376iipt125d6.apps.googleusercontent.com",
		googleAuthR.client_secret = "zkihPnJnNRlHTinpzI0NUs4R",


		googleAuthR.webapp.port = 4018,
		googleAuthR.jsonlite.simplifyVector = TRUE,
		googleAuthR.scopes.selected = c("https://www.googleapis.com/auth/userinfo.profile",
										"https://www.googleapis.com/auth/userinfo.email"),
		googleAuthR.ok_content_types=c("application/json; charset=UTF-8", ("text/html; charset=UTF-8")),
		googleAuthR.securitycode = 
			paste0(sample(c(1:9, LETTERS, letters), 20, replace = T), collapse=''),
		googleAuthR.tryAttempts = 5
	)
	# toset <- !(names(op.googleAuthR) %in% names(op))
	# if(any(toset)) options(op.googleAuthR[toset])
	options(op.googleAuthR)
	select_api("public")

	invisible()

}
