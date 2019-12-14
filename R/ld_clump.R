#' Perform LD clumping on SNP data
#'
#' Uses PLINK clumping method, where variants in LD within a particular window will be pruned. The SNP with the lowest p-value is retained.
#'
#' @param dat Dataframe. Must have a variant name column ("rsid") and pval column called "pval". If id is present then clumping will be done per unique id.
#' @param clump_kb Clumping kb window. Default is very strict, 10000
#' @param clump_r2 Clumping r2 threshold. Default is very strict, 0.001
#' @param clump_p Clumping sig level for index variants. Default = 1 (i.e. no threshold)
#' @param access_token Google OAuth2 access token. Used to authenticate level of access to data
#' @param bfile If this is provided then will use the API. Default = NULL
#' @param plink_bin If null and bfile is not null then will detect packaged plink binary for specific OS. Otherwise specify path to plink binary. Default = NULL
#'
#' @export
#' @return Data frame
ld_clump <- function(dat=NULL, clump_kb=10000, clump_r2=0.001, clump_p=1, access_token=NULL, bfile=NULL, plink_bin=NULL)
{

	stopifnot("rsid" %in% names(dat))
	stopifnot(is.data.frame(dat))

	if(! "pval" %in% names(dat))
	{
		dat$pval <- 0.99
	}

	if(! "id" %in% names(dat))
	{
		dat$id <- random_string(1)
	}

	if(is.null(bfile))
	{
		access_token = check_access_token()
	}

	ids <- unique(dat[["id"]])
	res <- list()
	for(i in 1:length(ids))
	{
		x <- subset(dat, dat[["id"]] == ids[i])
		if(nrow(x) == 1)
		{
			message("Only one SNP for ", ids[i])
			return(x)
		} else {
			message("Clumping ", ids[i], ", ", nrow(x), " variants")
			if(is.null(bfile))
			{
				return(ld_clump_api(x, clump_kb=clump_kb, clump_r2=clump_r2, clump_p=clump_p, access_token=access_token))
			} else {
				return(ld_clump_local(x, clump_kb=clump_kb, clump_r2=clump_r2, clump_p=clump_p, bfile=bfile, plink_bin=plink_bin))
			}
		}
	}
	res <- dplyr::bind_rows(res)
	return(res)
}


#' Perform clumping on the chosen variants using through API
#'
#' @param dat Dataframe. Must have a variant name column ("variant") and pval column called "pval". If id is present then clumping will be done per unique id.
#' @param clump_kb Clumping kb window. Default is very strict, 10000
#' @param clump_r2 Clumping r2 threshold. Default is very strict, 0.001
#' @param clump_p Clumping sig level for index variants. Default = 1 (i.e. no threshold)
#' @param access_token Google OAuth2 access token. Used to authenticate level of access to data#' @return Data frame of only independent variants
ld_clump_api <- function(dat, clump_kb=10000, clump_r2=0.1, clump_p, access_token=check_access_token())
{
	res <- api_query('ld/clump',
			query = list(
				rsid = dat[["rsid"]],
				pval = dat[["pval"]],
				pthresh = clump_p,
				r2 = clump_r2,
				kb = clump_kb
			),
			access_token=access_token
		) %>% get_query_content()
	y <- subset(dat, !dat[["rsid"]] %in% res)
	if(nrow(y) > 0)
	{
		message("Removing ", length(y[["rsid"]]), " of ", nrow(dat), " variants due to LD with other variants or absence from LD reference panel")
	}
	return(subset(dat, dat[["rsid"]] %in% res))
}


#' Wrapper for clump function using local plink binary and ld reference dataset
#'
#' @param dat Dataframe. Must have a variant name column ("variant") and pval column called "pval". If id is present then clumping will be done per unique id.
#' @param clump_kb Clumping kb window. Default is very strict, 10000
#' @param clump_r2 Clumping r2 threshold. Default is very strict, 0.001
#' @param clump_p Clumping sig level for index variants. Default = 1 (i.e. no threshold)
#' @param bfile If this is provided then will use the API. Default = NULL
#' @param plink_bin Specify path to plink binary. Default = NULL. See https://github.com/explodecomputer/plinkbinr for convenient access to plink binaries
#' @importFrom utils read.table
#' @importFrom utils write.table

#'
#' @export
#' @return data frame of clumped variants
ld_clump_local <- function(dat, clump_kb, clump_r2, clump_p, bfile, plink_bin)
{

	# Make textfile
	shell <- ifelse(Sys.info()['sysname'] == "Windows", "cmd", "sh")
	fn <- tempfile()
	write.table(data.frame(SNP=dat[["rsid"]], P=dat[["pval"]]), file=fn, row.names=F, col.names=T, quote=F)

	fun2 <- paste0(
		shQuote(plink_bin, type=shell),
		" --bfile ", shQuote(bfile, type=shell),
		" --clump ", shQuote(fn, type=shell), 
		" --clump-p1 ", clump_p, 
		" --clump-r2 ", clump_r2, 
		" --clump-kb ", clump_kb, 
		" --out ", shQuote(fn, type=shell)
	)
	system(fun2)
	res <- read.table(paste(fn, ".clumped", sep=""), header=T)
	unlink(paste(fn, "*", sep=""))
	y <- subset(dat, !dat[["rsid"]] %in% res[["SNP"]])
	if(nrow(y) > 0)
	{
		message("Removing ", length(y[["rsid"]]), " of ", nrow(dat), " variants due to LD with other variants or absence from LD reference panel")
	}
	return(subset(dat, dat[["rsid"]] %in% res[["SNP"]]))
}

random_string <- function(n=1, len=6)
{
	randomString <- c(1:n)
	for (i in 1:n)
	{
		randomString[i] <- paste(sample(c(0:9, letters, LETTERS),
		len, replace=TRUE),
		collapse="")
	}
	return(randomString)
}
