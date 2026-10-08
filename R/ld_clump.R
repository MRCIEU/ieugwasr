#' Perform LD clumping on SNP data
#'
#' Uses PLINK clumping method, where SNPs in LD within a particular window will be pruned. 
#' The SNP with the lowest p-value is retained.
#' 
#' @details
#' This function interacts with the OpenGWAS API, which houses LD reference panels 
#' for the 5 super-populations in the 1000 genomes reference panel. 
#' It includes only bi-allelic SNPs with MAF > 0.01, so it's quite possible that 
#' a variant you want to include in the clumping process will be absent. 
#' If it is absent, it will be automatically excluded from the results.
#' 
#' You can check if your variants are present in the LD reference panel using 
#' [`ld_reflookup()`].
#'
#' This function does put load on the OpenGWAS servers, which makes life more 
#' difficult for other users. We have implemented a method and made available 
#' the LD reference panels to perform clumping locally, see 
#' [`ld_clump()`] and related vignettes for details.
#'
#' @param dat Dataframe. Must have a variant name column (`rsid`) and pval column called `pval`. 
#' If `id` is present then clumping will be done per unique id.
#' @param clump_kb Clumping kb window. Default is very strict, `10000`
#' @param clump_r2 Clumping r2 threshold. Default is very strict, `0.001`
#' @param clump_p Clumping sig level for index variants. Default = `1` (i.e. no threshold)
#' @param pop Super-population to use as reference panel. Default = `"EUR"`. 
#' Options are `"EUR"`, `"SAS"`, `"EAS"`, `"AFR"`, `"AMR"`. 
#' `'legacy'` also available - which is a previously used version of the EUR 
#' panel with a slightly different set of markers
#' @param opengwas_jwt Used to authenticate protected endpoints. Login to <https://api.opengwas.io> to obtain a jwt. Provide the jwt string here, or store in .Renviron under the keyname OPENGWAS_JWT.
#' @param bfile If this is provided then will use the API. Default = `NULL`
#' @param plink_bin If `NULL` and `bfile` is not `NULL` then will detect 
#' packaged plink binary for specific OS. Otherwise specify path to plink binary. 
#' Default = `NULL`,
#' @param tmpdir Directory in which to write the temporary files used by plink when `bfile` is provided. Default = [`tempdir()`]
#' @param ... Additional arguments passed to [`ld_clump_api()`].
#'
#' @export
#' @return Data frame
ld_clump <- function(dat=NULL, clump_kb=10000, clump_r2=0.001, clump_p=0.99, 
                     pop = "EUR", opengwas_jwt=get_opengwas_jwt(), bfile=NULL, plink_bin=NULL, tmpdir=tempdir(), ...)
{

	stopifnot("rsid" %in% names(dat))
	stopifnot(is.data.frame(dat))

	if(is.null(bfile))
	{
		message("Please look at vignettes for options on running this locally if you need to run many instances of this command.")
	}

	if (!is.null(bfile) && is.null(plink_bin)) {
	  plink_bin <- Sys.which("plink")
	  if (plink_bin == "" || is.na(plink_bin)) {
	    stop("Could not find PLINK executable. Please set plink_bin to the path of the PLINK executable.")
	  }
	}
	
	if(! "pval" %in% names(dat))
	{
		if( "p" %in% names(dat))
		{
			warning("No 'pval' column found in dat object. Using 'p' column.")
			dat[["pval"]] <- dat[["p"]]
		} else {
			warning("No 'pval' column found in dat object. Setting p-values for all SNPs to clump_p parameter.")
			dat[["pval"]] <- clump_p
		}
	}

	if(! "id" %in% names(dat))
	{
		dat$id <- random_string(1)
	}

	ids <- unique(dat[["id"]])
	res <- list()
	for(i in seq_along(ids))
	{
		x <- subset(dat, dat[["id"]] == ids[i])
		if(nrow(x) == 1)
		{
			message("Only one SNP for ", ids[i])
			res[[i]] <- x
		} else {
			warn_tied_pval(x[["pval"]], clump_p, ids[i])
			if(is.null(bfile))
			{
			  message("Clumping ", ids[i], ", ", nrow(x), " variants, using ", pop, " population reference")
			  res[[i]] <- ld_clump_api(x, clump_kb=clump_kb, clump_r2=clump_r2, clump_p=clump_p, pop=pop, opengwas_jwt=opengwas_jwt, ...)
			} else {
			  message("Clumping ", ids[i], ", ", nrow(x), " variants, using: ", bfile)
				res[[i]] <- ld_clump_local(x, clump_kb=clump_kb, clump_r2=clump_r2, clump_p=clump_p, bfile=bfile, plink_bin=plink_bin, tmpdir=tmpdir)
			}
		}
	}
	res <- dplyr::bind_rows(res)
	return(res)
}


#' Perform clumping on the chosen variants using the API
#'
#' @param dat Dataframe. Must have a variant name column (`variant`) and pval column called `pval`. 
#' If `id` is present then clumping will be done per unique id.
#' @param clump_kb Clumping kb window. Default is very strict, `10000`
#' @param clump_r2 Clumping r2 threshold. Default is very strict, `0.001`
#' @param clump_p Clumping sig level for index variants. Default = `1` (i.e. no threshold)
#' @param pop Super-population to use as reference panel. Default = `"EUR"`. 
#' Options are `"EUR"`, `"SAS"`, `"EAS"`, `"AFR"`, `"AMR"`
#' @param opengwas_jwt Used to authenticate protected endpoints. Login to <https://api.opengwas.io> to obtain a jwt. Provide the jwt string here, or store in .Renviron under the keyname OPENGWAS_JWT.
#' @param ... Additional arguments passed to `api_query()`.
#' @return Data frame of only independent variants
ld_clump_api <- function(dat, clump_kb=10000, clump_r2=0.001, clump_p=1, pop="EUR", opengwas_jwt=get_opengwas_jwt(), ...)
{
	res <- api_query('ld/clump',
			query = list(
				rsid = dat[["rsid"]],
				pval = dat[["pval"]],
				pthresh = clump_p,
				r2 = clump_r2,
				kb = clump_kb,
				pop = pop
			),
			opengwas_jwt=opengwas_jwt, ...
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
#' @param dat Dataframe. Must have a variant name column (`variant`) and pval column called `pval`. 
#' If `id` is present then clumping will be done per unique id.
#' @param clump_kb Clumping kb window. Default is very strict, `10000`
#' @param clump_r2 Clumping r2 threshold. Default is very strict, `0.001`
#' @param clump_p Clumping sig level for index variants. Default = `1` (i.e. no threshold)
#' @param bfile If this is provided then will use the API. Default = `NULL`
#' @param plink_bin Specify path to plink binary. Default = `NULL`. 
#' See \url{https://github.com/MRCIEU/genetics.binaRies} for convenient access to plink binaries
#' @param tmpdir Directory in which to write the temporary files used by plink. Default = [`tempdir()`]
#' @importFrom utils read.table
#' @importFrom utils write.table
#' @export
#' @return data frame of clumped variants
ld_clump_local <- function(dat, clump_kb, clump_r2, clump_p, bfile, plink_bin, tmpdir=tempdir())
{
	if(!dir.exists(tmpdir)) stop("tmpdir does not exist: ", tmpdir)

	# Make textfile
	shell <- ifelse(Sys.info()['sysname'] == "Windows", "cmd", "sh")
	fn <- tempfile(tmpdir=tmpdir)
	write.table(data.frame(SNP=dat[["rsid"]], P=dat[["pval"]]), file=fn, row.names=FALSE, col.names=TRUE, quote=FALSE)

	fun2 <- paste0(
		shQuote(plink_bin, type=shell),
		" --bfile ", shQuote(bfile, type=shell),
		" --clump ", shQuote(fn, type=shell), 
		" --clump-p1 ", clump_p, 
		" --clump-r2 ", clump_r2, 
		" --clump-kb ", clump_kb, 
		" --out ", shQuote(fn, type=shell)
	)
	status <- system(fun2)
	# plink writes no .clumped file if no variants pass clumping, or if it fails
	if(!file.exists(paste(fn, ".clumped", sep="")))
	{
		log <- paste(fn, ".log", sep="")
		log <- if(file.exists(log)) readLines(log) else character(0)
		unlink(paste(fn, "*", sep=""))
		if(any(grepl("No significant --clump results", log)))
		{
			message("Removing all ", nrow(dat), " variants: none had a p-value below clump_p and were present in the LD reference panel")
			return(dat[0, ])
		}
		stop(
			"plink clumping failed (exit status ", status, "). ",
			"Check that bfile is the path to the .bed/.bim/.fam files without the extension, and that plink_bin is a working plink 1.9 binary.",
			if(length(log) > 0) paste0("\nEnd of plink log:\n", paste(utils::tail(log, 10), collapse="\n"))
		)
	}
	res <- read.table(paste(fn, ".clumped", sep=""), header=TRUE)
	unlink(paste(fn, "*", sep=""))
	y <- subset(dat, !dat[["rsid"]] %in% res[["SNP"]])
	if(nrow(y) > 0)
	{
		message("Removing ", length(y[["rsid"]]), " of ", nrow(dat), " variants due to LD with other variants or absence from LD reference panel")
	}
	return(subset(dat, dat[["rsid"]] %in% res[["SNP"]]))
}

# Warn if the smallest p-value is shared by several variants, e.g. because of
# numerical underflow or p-values capped by other software, since plink then
# chooses the lead variant among them arbitrarily (#39)
warn_tied_pval <- function(pval, clump_p, id)
{
	if(all(is.na(pval))) return(invisible())
	p <- min(pval, na.rm=TRUE)
	n <- sum(pval == p, na.rm=TRUE)
	if(n > 1 && p <= clump_p)
	{
		warning(
			n, " variants for ", id, " share the smallest p-value (", format(p), "), ",
			"e.g. because of numerical underflow or p-values capped by other software. ",
			"The lead variant among them will be chosen arbitrarily, not by strength of association. ",
			"If the p-values were capped, e.g. by TwoSampleMR::format_data() (min_pval = 1e-200 by default), consider lowering the cap, e.g. to 1e-300."
		)
	}
	invisible()
}

random_string <- function(n=1, len=6)
{
	randomString <- character(n)
	for (i in seq_len(n))
	{
		randomString[i] <- paste(sample(c(0:9, letters, LETTERS),
		len, replace=TRUE),
		collapse="")
	}
	return(randomString)
}


#' Check which rsids are present in a remote LD reference panel
#'
#' Provide a list of rsids that you may want to perform LD operations on to 
#' check if they are present in the LD reference panel. If they are not then 
#' some functions e.g. [`ld_clump`] will exclude them from the analysis, 
#' so you may want to consider how to handle those variants in your data.
#'
#' @param rsid Array of rsids to check
#' @param pop Super-population to use as reference panel. Default = `"EUR"`. 
#' Options are `"EUR"`, `"SAS"`, `"EAS"`, `"AFR"`, `"AMR"`
#' @param opengwas_jwt Used to authenticate protected endpoints. Login to <https://api.opengwas.io> to obtain a jwt. Provide the jwt string here, or store in .Renviron under the keyname OPENGWAS_JWT.
#' @param ... Additional arguments passed to `api_query()`.
#'
#' @export
#' @return Array of rsids that are present in the LD reference panel
ld_reflookup <- function(rsid, pop='EUR', opengwas_jwt=get_opengwas_jwt(), ...)
{
	res <- api_query('ld/reflookup',
			query = list(
				rsid = rsid,
				pop = pop
			),
			opengwas_jwt=opengwas_jwt, ...
		) %>% get_query_content()
	if(length(res) == 0)
	{
		res <- character(0)
	}
	return(res)
}
