#' Retrieve a allele frequency and LD scores for pre-defined lists of variants
#'
#' Data frame includes 1000 genomes metadata including sample sizes, 
#' allele frequency and LD score, separated by 5 super populations 
#' (EUR = European, AFR = African, EAS = East Asian, AMR = Admixed American, 
#' SAS = South Asian)
#'
#' @param variantlist Choose pre-defined list. reduced = ~20k SNPs that are 
#' common in all super populations (default). hapmap3 = ~1.3 million hm3 SNPs
#'
#' @export
#' @return Data frame
afl2_list <- function(variantlist=c("reduced", "hapmap3")[1])
{
	if(variantlist == "reduced")
	{
		api_query("variants/afl2/snplist") %>% 
			get_query_content() %>%
			dplyr::as_tibble() %>%
			return()
	} else if (variantlist == "hapmap3") {
		url("http://fileserve.mrcieu.ac.uk/ld/hm3_afl2.rds", "rb") %>%
		readRDS() %>%
			return()
	} else {
		message("variantlist ", variantlist, " not recognised")
		return(NULL)
	}
}


#' Look up allele frequencies and LD scores for 1000 genomes populations by rsid
#'
#' @param rsid Vector of rsids
#' @param reference Default=`"1000g"`
#'
#' @export
#' @return data frame
afl2_rsid <- function(rsid, reference="1000g")
{
	out <- api_query("variants/afl2", list(rsid=rsid)) %>% get_query_content()
	if(class(out) == "response")
	{
		return(out)
	} else if(is.data.frame(out)) {
		out %>% dplyr::as_tibble() %>% return()
	} else {
		return(dplyr::tibble())
	}
}

#' Look up allele frequencies and LD scores for 1000 genomes populations by chrpos
#'
#' @param chrpos list of `<chr>:<pos>` in build 37, e.g. `c("3:46414943", "3:122991235")`. 
#' Also allows ranges e.g `"7:105561135-105563135"`
#' @param reference Default=`"1000g"`
#'
#' @export
#' @return data frame
afl2_chrpos <- function(chrpos, reference="1000g")
{
	out <- api_query("variants/afl2", list(chrpos=chrpos)) %>% get_query_content()
	if(class(out) == "response")
	{
		return(out)
	} else if(is.data.frame(out)) {
		out %>% dplyr::as_tibble() %>% return()
	} else {
		return(dplyr::tibble())
	}
}


#' Infer ancestry of GWAS dataset by matching against 1000 genomes allele frequencies
#'
#' Uses ~20k SNPs selected for common frequency across 5 major super populations
#'
#' @param d Data frame containing at least `rsid` and `eaf` columns. 
#' e.g. output from associations
#' @param snpinfo Output from [`afl2_list`], [`afl2_rsid`] or [`afl2_chrpos`]. 
#' If `NULL` then [`afl2_list()`] is used by default
#'
#' @export
#' @return data frame ordered by most likely ancestry
infer_ancestry <- function(d, snpinfo=NULL)
{
	if(is.null(snpinfo))
	{
		snpinfo <- afl2_list()
	}
	snpinfo <- snpinfo %>%
		dplyr::inner_join(., d, by="rsid")

	nom <- grep("^AF\\.", names(snpinfo), value=TRUE)
	out <- sapply(nom, function(x)
	{
		cor(snpinfo$eaf, snpinfo[[x]], use="pair")
	}) %>% sort(decreasing=TRUE)
	out <- dplyr::tibble(pop=gsub("AF\\.", "", names(out)), cor=out)
	return(out)
}

#' Look up sample sizes when meta data is missing from associations
#'
#' @param d Output from [`associations`]
#'
#' @export
#' @return Updated version of d
fill_n <- function(d)
{
	id <- d$id[1]
	if(! "n" %in% names(d))
	{
		d$n <- NA
	}
	d$n <- as.numeric(d$n)
	if(any(is.na(d$n)))
	{
		info <- gwasinfo(id)
		if(!is.na(info$sample_size))
		{
			d$n <- info$sample_size
		} else {
			d$n <- info$ncase + info$ncontrol
		}
	}
	return(d)	
}

