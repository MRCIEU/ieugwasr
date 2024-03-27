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
			paste0(sample(c(1:9, LETTERS, letters), 20, replace = TRUE), collapse=''),
		googleAuthR.tryAttempts = 5
	)
	# toset <- !(names(op.googleAuthR) %in% names(op))
	# if(any(toset)) options(op.googleAuthR[toset])
	options(op.googleAuthR)
	select_api("public", silent=TRUE)

	invisible()
}


.onAttach <- function(libname, pkgname) {

	a <- suppressWarnings(try(readLines("https://raw.githubusercontent.com/MRCIEU/ieugwasr/master/DESCRIPTION"), silent=TRUE))

	if(!inherits(a, 'try-error'))
	{
		latest <- gsub("Version: ", "", a[grep("Version", a)])
		current = utils::packageDescription('ieugwasr')

		test <- utils::compareVersion(latest, current$Version)
		if(test == 1)
		{
			packageStartupMessage("\nWarning:\nYou are running an old version of the ieugwasr package.\n",
				"This version:   ", current$Version, "\n",
				"Latest version: ", latest, "\n",
				"Please consider updating using remotes::install_github('MRCIEU/ieugwasr')")
		}
	}

	b <- suppressWarnings(try(jsonlite::read_json("https://raw.githubusercontent.com/MRCIEU/opengwas/main/messages.json"), silent=TRUE))
	if(!inherits(b, 'try-error'))
	{
		if(length(b) > 0) {
			packageStartupMessage("OpenGWAS updates:")
		}
		o <- lapply(b, function(x) {
			packageStartupMessage("  Date: ", x[["date"]])
			sapply(x[["message"]], function(j) packageStartupMessage(paste(" ", j)))
		})
	}


	invisible()
}