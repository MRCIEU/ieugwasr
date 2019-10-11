#' Get LD matrix for list of SNPs
#'
#' This function takes a list of SNPs and searches for them in 502 European samples from 1000 Genomes phase 3 data
#' It then creates an LD matrix of r values (signed, and not squared)
#' All LD values are with respect to the major alleles in the 1000G dataset. You can specify whether the allele names are displayed
#'
#' @param snps List of SNPs
#' @param with_alleles Whether to append the allele names to the SNP names. Default: TRUE
#'
#' @export
#' @return Matrix of LD r values
ld_matrix <- function(snps, with_alleles=TRUE, bfile=NULL, plink_bin=NULL)
{
	if(length(snps) > 500 & is.null(bfile))
	{
		stop("SNP list must be smaller than 500. Try running locally by providing local ld reference with bfile argument")
	}

	if(!is.null(bfile))
	{
		return(ld_matrix(snps, bfile=bfile, plink_bin=plink_bin, with_alleles=with_alleles))
	}

	res <- api_query('ld/matrix', query = list(rsid=snps), access_token=NULL)

	if(all(is.na(res))) stop("None of the requested SNPs were found")
	snps2 <- res$snplist
	res <- res$matrix
	res <- matrix(as.numeric(res), nrow(res), ncol(res))
	snps3 <- do.call(rbind, strsplit(snps2, split="_"))
	if(with_alleles)
	{
		rownames(res) <- snps2
		colnames(res) <- snps2
	} else {
		rownames(res) <- snps3[,1]
		colnames(res) <- snps3[,1]
	}
	missing <- snps[!snps %in% snps3[,1]]
	if(length(missing) > 0)
	{
		warning("The following SNPs are not present in the LD reference panel\n", paste(missing, collapse="\n"))
	}
	ord <- match(snps3[,1], snps)
	res <- res[order(ord), order(ord)]
	return(res)
}




#' Get LD matrix using local plink binary and reference dataset
#'
#' @param snps <what param does>
#' @param bfile <what param does>
#' @param plink_bin <what param does>
#' @param with_alleles=TRUE <what param does>
#'
#' @export
#' @return
ld_matrix_local <- function(snps, bfile, plink_bin, with_alleles=TRUE)
{
	message("Warning: this is not doing the same behaviour as the API. Still need to implement missing SNP handling.")
	if(is.null(plink_bin))
	{
		plink_bin <- get_plink_exe()
	}

	# Make textfile
	shell <- ifelse(Sys.info()['sysname'] == "Windows", "cmd", "sh")
	fn <- tempfile()
	write.table(data.frame(dat$SNP), file=fn, row=F, col=F, qu=F)

	fun2 <- paste0(
		shQuote(plink_bin, type=shell),
		" --bfile ", shQuote(bfile, type=shell),
		" --extract ", shQuote(fn, type=shell), 
		" --r square ", clump_r2, 
		" --out ", shQuote(fn, type=shell)
	)
	res <- read.table(paste0(fn, ".ld"), header=TRUE)
	return(res)
}