#' Retrieve a allele frequency and LD scores for pre-defined lists of variants
#'
#' Data frame includes 1000 genomes metadata including sample sizes, 
#' allele frequency and LD score, separated by 5 super populations 
#' (EUR = European, AFR = African, EAS = East Asian, AMR = Admixed American, 
#' SAS = South Asian)
#'
#' @param variantlist Choose pre-defined list. reduced = ~20k SNPs that are 
#' common in all super populations (default). hapmap3 = ~1.3 million hm3 SNPs
#' @param opengwas_jwt Used to authenticate protected endpoints. Login to <https://api.opengwas.io> to obtain a jwt. Provide the jwt string here, or store in .Renviron under the keyname OPENGWAS_JWT.
#'
#' @export
#' @return Data frame containing ancestry specific LD scores and allele frequencies for each variant
afl2_list <- function(variantlist=c("reduced", "hapmap3")[1], opengwas_jwt=get_opengwas_jwt())
{
	if(variantlist == "reduced")
	{
		api_query("variants/afl2/snplist", opengwas_jwt=opengwas_jwt) %>% 
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
#' @param opengwas_jwt Used to authenticate protected endpoints. Login to <https://api.opengwas.io> to obtain a jwt. Provide the jwt string here, or store in .Renviron under the keyname OPENGWAS_JWT.
#'
#' @export
#' @return Data frame containing ancestry specific LD scores and allele frequencies for each variant
afl2_rsid <- function(rsid, reference="1000g", opengwas_jwt=get_opengwas_jwt())
{
	out <- api_query("variants/afl2", list(rsid=rsid), opengwas_jwt=opengwas_jwt) %>% get_query_content()
	if(inherits(out, "response"))
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
#' @param opengwas_jwt Used to authenticate protected endpoints. Login to <https://api.opengwas.io> to obtain a jwt. Provide the jwt string here, or store in .Renviron under the keyname OPENGWAS_JWT.
#'
#' @export
#' @return Data frame containing ancestry specific LD scores and allele frequencies for each variant
afl2_chrpos <- function(chrpos, reference="1000g", opengwas_jwt=get_opengwas_jwt())
{
	out <- api_query("variants/afl2", list(chrpos=chrpos), opengwas_jwt=opengwas_jwt) %>% get_query_content()
	if(inherits(out, "response"))
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
#' @param opengwas_jwt Used to authenticate protected endpoints. Login to <https://api.opengwas.io> to obtain a jwt. Provide the jwt string here, or store in .Renviron under the keyname OPENGWAS_JWT.
#'
#' @export
#' @return data frame ordered by most likely ancestry, each row represents a super population and cor column represents the correlation between the GWAS dataset and the 1000 genomes super population allele frequencies
infer_ancestry <- function(d, snpinfo=NULL, opengwas_jwt=get_opengwas_jwt())
{
	if(is.null(snpinfo))
	{
		snpinfo <- afl2_list(opengwas_jwt=opengwas_jwt)
	}
	snpinfo <- snpinfo %>%
		dplyr::inner_join(., d, by="rsid")

	nom <- grep("^AF\\.", names(snpinfo), value=TRUE)
	out <- sapply(nom, function(x)
	{
		stats::cor(snpinfo$eaf, snpinfo[[x]], use="pair")
	}) %>% sort(decreasing=TRUE)
	out <- dplyr::tibble(pop=gsub("AF\\.", "", names(out)), cor=out)
	return(out)
}

