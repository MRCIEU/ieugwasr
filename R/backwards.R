#' Convert current IDs to legacy IDs
#'
#' @param x Vector of ids
#'
#' @export
#' @return vector of back compatible ids
legacy_ids <- function(x)
{
	if(is.null(x)) return(NULL)
	changes <- dplyr::tibble(
		old = c("UKB-a:", "UKB-b:", "UKB-c:", "IEU-a:", "\\D"),
		new = c("ukb-a-", "ukb-b-", "ukb-c-", "ieu-a-", "ieu-a-")
	)

	y <- x
	for(i in 1:nrow(changes))
	{
		index <- grepl(changes$old[i], x)
		if(changes$old[i] == "\\D")
		{
			index <- !grepl(changes$old[i], x)
		}
		if(any(index))
		{
			if(changes$old[i] == "\\D")
			{
				x[index] <- paste0(changes$new[i], x[index])
			} else {
				x[index] <- gsub(changes$old[i], changes$new[i], x[index])
			}
		}
	}

	# met datasets
	index <- x %in% paste0("ieu-a-", 303:754)
	x[index] <- gsub("ieu-a-", "met-a-", x[index])
	index <- x %in% paste0("ieu-a-", 119:269)
	x[index] <- gsub("ieu-a-", "met-b-", x[index])
	index <- x %in% paste0("ieu-a-", 838:960)
	x[index] <- gsub("ieu-a-", "met-c-", x[index])

	overallindex <- y != x
	if(any(overallindex))
	{
		message("Deprecated IDs being used? Detected numeric IDs. Trying to fix, but please note the changes below for future.")
		message(paste(y[overallindex], " -> ", x[overallindex], collapse="\n"))
	}
	return(x)
}
