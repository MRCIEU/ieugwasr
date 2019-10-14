#' Get LD matrix for list of variants
#'
#' This function takes a list of variants and searches for them in 502 European samples from 1000 Genomes phase 3 data
#' It then creates an LD matrix of r values (signed, and not squared)
#' All LD values are with respect to the major alleles in the 1000G dataset. You can specify whether the allele names are displayed
#'
#' @param variants List of variants (rsids)
#' @param with_alleles Whether to append the allele names to the SNP names. Default: TRUE
#' @param bfile If this is provided then will use the API. Default = NULL
#' @param plink_bin If null and bfile is not null then will detect packaged plink binary for specific OS. Otherwise specify path to plink binary. Default = NULL
#'
#' @export
#' @return Matrix of LD r values
ld_matrix <- function(variants, with_alleles=TRUE, bfile=NULL, plink_bin=NULL)
{
	if(length(variants) > 500 & is.null(bfile))
	{
		stop("SNP list must be smaller than 500. Try running locally by providing local ld reference with bfile argument")
	}

	if(!is.null(bfile))
	{
		return(ld_matrix(variants, bfile=bfile, plink_bin=plink_bin, with_alleles=with_alleles))
	}

	res <- api_query('ld/matrix', query = list(rsid=variants), access_token=NULL)

	if(all(is.na(res))) stop("None of the requested variants were found")
	variants2 <- res$snplist
	res <- res$matrix
	res <- matrix(as.numeric(res), nrow(res), ncol(res))
	variants3 <- do.call(rbind, strsplit(variants2, split="_"))
	if(with_alleles)
	{
		rownames(res) <- variants2
		colnames(res) <- variants2
	} else {
		rownames(res) <- variants3[,1]
		colnames(res) <- variants3[,1]
	}
	missing <- variants[!variants %in% variants3[,1]]
	if(length(missing) > 0)
	{
		warning("The following variants are not present in the LD reference panel\n", paste(missing, collapse="\n"))
	}
	ord <- match(variants3[,1], variants)
	res <- res[order(ord), order(ord)]
	return(res)
}




#' Get LD matrix using local plink binary and reference dataset
#'
#' @param variants List of variants (rsids)
#' @param bfile Path to bed/bim/fam ld reference panel
#' @param plink_bin Specify path to plink binary. Default = NULL. See https://github.com/explodecomputer/plinkbinr for convenient access to plink binaries
#' @param with_alleles Whether to append the allele names to the SNP names. Default: TRUE
#'
#' @export
#' @return data frame
ld_matrix_local <- function(variants, bfile, plink_bin, with_alleles=TRUE)
{
	message("Warning: this is not doing the same behaviour as the API. Still need to implement missing SNP handling.")
	# Make textfile
	shell <- ifelse(Sys.info()['sysname'] == "Windows", "cmd", "sh")
	fn <- tempfile()
	write.table(data.frame(variants), file=fn, row.names=F, col.names=F, quote=F)

	fun2 <- paste0(
		shQuote(plink_bin, type=shell),
		" --bfile ", shQuote(bfile, type=shell),
		" --extract ", shQuote(fn, type=shell), 
		" --r square ", 
		" --out ", shQuote(fn, type=shell)
	)
	res <- read.table(paste0(fn, ".ld"), header=TRUE)
	return(res)
}