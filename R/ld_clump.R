#' Perform LD clumping on SNP data
#'
#' Uses PLINK clumping method, where SNPs in LD within a particular window will be pruned. The SNP with the lowest p-value is retained.
#'
#' @param dat Output from \code{format_data}. Must have a SNP name column (SNP) and pval column called either "P", "pval.exposure", or "pval". If id or id.exposure is present then it will  or pval.exposure not present they will be generated
#' @param clump_kb=10000 Clumping window 
#' @param clump_r2=0.001 Clumping r2 cutoff. Note that this default value has recently changed from 0.01.
#' @param clump_p=1 Clumping sig level for index SNPs
#' @param access_token Google OAuth2 access token. Used to authenticate level of access to data
#' @param bfile=NULL If this is provided then will use the API
#' @param plink_bin=NULL If null and bfile is not null then will detect packaged plink binary for specific OS. Otherwise specify path to plink binary
#'
#' @export
#' @return Data frame
ld_clump <- function(dat=NULL, clump_kb=10000, clump_r2=0.001, clump_p=1, access_token=NULL, bfile=NULL, plink_bin=NULL)
{
	if(!is.data.frame(dat))
	{
		stop("Expecting data frame returned from format_data")
	}

	if(! "pval.exposure" %in% names(dat))
	{
		dat$pval.exposure <- 0.99
	}

	if(! "id.exposure" %in% names(dat))
	{
		dat$id.exposure <- random_string(1)
	}
	if(is.null(bfile))
	{
		access_token = check_access_token()
	}
	res <- plyr::ddply(dat, c("id.exposure"), function(x)
	{
		x <- plyr::mutate(x)
		if(nrow(x) == 1)
		{
			message("Only one SNP for ", x$id.exposure[1])
			return(x)
		} else {
			message("Clumping ", x$id.exposure[1], ", ", nrow(x), " SNPs")
			if(is.null(bfile))
			{
				return(ld_clump_api(x, clump_kb=clump_kb, clump_r2=clump_r2, clump_p=clump_p, access_token=access_token))
			} else {
				return(ld_clump_local(x, clump_kb=clump_kb, clump_r2=clump_r2, clump_p=clump_p, bfile=bfile, plink_bin=plink_bin))
			}
		}
	})
	return(res)
}


#' Perform clumping on the chosen SNPs using through API
#'
#' @param dat Output from \code{read_exposure_data}. Must have a SNP name column (SNP), SNP chromosome column (chr_name), SNP position column (chrom_start) and p-value column (pval.exposure)
#' @param clump_kb=10000 Clumping window 
#' @param clump_r2=0.1 Clumping r2 cutoff
#' @param clump_p=1 Clumping sig level for index SNPs
#' @param access_token Google OAuth2 access token. Used to authenticate level of access to data#' @return Data frame of only independent SNPs
ld_clump_api <- function(dat, clump_kb=10000, clump_r2=0.1, clump_p, access_token=check_access_token())
{
	res <- api_query('ld/clump',
			query = list(
				rsid = dat$SNP,
				pval = dat$pval.exposure,
				pthresh = clump_p,
				r2 = clump_r2,
				kb = clump_kb
			),
			access_token=access_token
		)
	y <- subset(dat, !SNP %in% res)
	if(nrow(y) > 0)
	{
		message("Removing the following SNPs due to LD with other SNPs:\n", paste(y$SNP, collapse="\n"), sep="\n")
	}
	return(subset(dat, SNP %in% res))
}


#' Detect plink exe for operating system
#'
#' Returns error if not found
#'
#' @export
#' @return path to plink binary
get_plink_exe <- function()
{
    os <- Sys.info()['sysname']
    a <- paste0("bin/plink_", os)
    if(os == "Windows") a <- paste0(a, ".exe")
    plink_bin <- system.file(a, package="ieugwasr")
	if(!file.exists(plink_bin))
	{
		stop("No plink2 executable available for OS '", os, "'. Please provide your own plink2 executable file using the plink_bin argument.")
	}
	return(plink_bin)
}


#' Wrapper for clump function using local plink binary and ld reference dataset
#'
#' @param dat Output from \code{read_exposure_data}. Must have a SNP name column (SNP), SNP chromosome column (chr_name), SNP position column (chrom_start) and p-value column (pval.exposure)
#' @param clump_kb=10000 Clumping window 
#' @param clump_r2=0.1 Clumping r2 cutoff
#' @param clump_p=1 Clumping sig level for index SNPs
#' @param bfile=NULL Reference plink bed/bim/fam file set to be used for clumping
#' @param plink_bin=NULL If null then will detect packaged plink binary for specific OS. Otherwise specify path to plink binary
#' @importFrom utils read.table
#' @importFrom utils write.table

#'
#' @export
#' @return data frame of clumped SNPs
ld_clump_local <- function(dat, clump_kb, clump_r2, clump_p, bfile, plink_bin)
{
	if(is.null(plink_bin))
	{
		plink_bin <- get_plink_exe()
	}

	# Make textfile
	shell <- ifelse(Sys.info()['sysname'] == "Windows", "cmd", "sh")
	fn <- tempfile()
	write.table(data.frame(SNP=dat$SNP, P=dat$pval.exposure), file=fn, row=F, col=T, qu=F)

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
	res <- read.table(paste(fn, ".clumped", sep=""), he=T)
	unlink(paste(fn, "*", sep=""))
	y <- subset(dat, !SNP %in% res$SNP)
	if(nrow(y) > 0)
	{
		message("Removing the following SNPs due to LD with other SNPs:\n", paste(y$SNP, collapse="\n"), sep="\n")
	}
	return(subset(dat, SNP %in% res$SNP))
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
