#' Retrieve a list of ~20k variants that are common in all five human super populations
#'
#' Data frame includes 1000 genomes metadata including sample sizes, allele frequency and LD score
#'
#' @export
#' @return Data frame
common_snpinfo <- function()
{
	api_query("variants/afl2/snplist") %>% 
		get_query_content() %>%
		dplyr::as_tibble()
}


#' Look up allele frequencies and LD scores for 1000 genomes populations by rsid
#'
#' @param rsid Vector of rsids
#' @param reference Default="1000g"
#'
#' @export
#' @return data frame
afl2_rsid <- function(rsid, reference="1000g")
{
	out <- api_query("variants/afl2/rsid", list(rsid=rsid)) %>% get_query_content()
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
#' @param chrpos list of <chr>:<pos> in build 37, e.g. c("3:46414943", "3:122991235"). Also allows ranges e.g "7:105561135-105563135"
#' @param reference Default="1000g"
#'
#' @export
#' @return data frame
afl2_chrpos <- function(chrpos, reference="1000g")
{
	out <- api_query("variants/afl2/chrpos", list(chrpos=chrpos)) %>% get_query_content()
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
#' @param d Data frame containing at least rsid and eaf columns. e.g. output from associations
#'
#' @export
#' @return data frame ordered by most likely ancestry
infer_ancestry <- function(d, snpinfo=NULL)
{
	if(is.null(snpinfo))
	{
		snpinfo <- common_snpinfo()
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
#' @param d Output from \code{associations}
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


#' Perform basic version of bivariate LD score regression
#'
#' For best results please use the LDSC software. This version is a rough approximation that uses only 20k SNPs for the purposes of minimising server load. 
#'
#' @param id1 ID of trait 1
#' @param id2 ID of trait 2
#' @param ancestry ancestry of traits 1 and 2 (AFR, AMR, EAS, EUR, SAS) or 'infer' (default) in which case it will try to guess based on allele frequencies
#'
#' @export
#' @return List of results
bv_ldsc <- function(id1, id2, ancestry="infer", snpinfo=NULL)
{
	.Deprecated("TwoSampleMR::LDSC_rg")
	if(is.null(snpinfo))
	{
		snpinfo <- common_snpinfo()
	}

	d1 <- associations(snpinfo$rsid, id1, proxies=FALSE) %>%
		fill_n() %>%
		dplyr::mutate(z = beta / se) %>%
		dplyr::select(rsid, z1 = z, n1 = n)

	d2 <- associations(snpinfo$rsid, id2, proxies=FALSE) %>%
		fill_n() %>%
		dplyr::mutate(z = beta / se) %>%
		dplyr::select(rsid, z2 = z, n2 = n)

	if(ancestry == "infer")
	{
		ancestry1 <- infer_ancestry(d1, snpinfo)
		ancestry2 <- infer_ancestry(d2, snpinfo)
		if(ancestry1$pop[1] != ancestry2$pop[1])
		{
			stop("d1 ancestry is ", ancestry1$pop[1], " and d2 ancestry is ", ancestry2$pop[1])
		}
		ancestry <- ancestry1$pop[1]
	}

	dat1 <- snpinfo %>% 
		dplyr::select(rsid, l2=paste0("L2.", ancestry)) %>%
		dplyr::inner_join(., d1, by="rsid")

	mod1 <- summary(lm(z1 ~ l2, dat1))

	res <- list()
	res$id1 <- list()
	res$id1$intercept <- coefficients(mod1)[1,1]
	res$id1$intercept_se <- coefficients(mod1)[1,2]
	res$id1$intercept_pval <- coefficients(mod1)[1,4]
	res$id1$h2 <- coefficients(mod1)[2,1] * nrow(dat1)
	res$id1$h2_se <- coefficients(mod1)[2,2] * nrow(dat1)
	res$id1$h2_pval <- coefficients(mod1)[2,4]

	dat2 <- snpinfo %>% 
		dplyr::select(rsid, l2=paste0("L2.", ancestry)) %>%
		dplyr::inner_join(., d2, by="rsid")

	mod2 <- summary(lm(z2 ~ l2, dat2))

	res$id2 <- list()
	res$id2$intercept <- coefficients(mod2)[1,1]
	res$id2$intercept_se <- coefficients(mod2)[1,2]
	res$id2$intercept_pval <- coefficients(mod2)[1,4]
	res$id2$h2 <- coefficients(mod2)[2,1] * nrow(dat2)
	res$id2$h2_se <- coefficients(mod2)[2,2] * nrow(dat2)
	res$id2$h2_pval <- coefficients(mod2)[2,4]


	dat <- snpinfo %>% 
		dplyr::select(rsid, l2=paste0("L2.", ancestry)) %>%
		dplyr::inner_join(., d1, by="rsid") %>%
		dplyr::inner_join(., d2, by="rsid") %>%
		dplyr::mutate(
			zz = z1 * z2, 
			n1 = as.numeric(n1),
			n2 = as.numeric(n2),
			rhs = l2 * sqrt(n1 * n2)
		)

	mod <- summary(lm(zz ~ rhs, dat))


	res$gcov = coefficients(mod)[2,1] * nrow(dat)
	res$gcov_se = coefficients(mod)[2,2] * nrow(dat)
	res$gcor = res$gcov / sqrt(res$id1$h2 * res$id2$h2)
	res$intercept = coefficients(mod)[1,1]
	res$intercept_se = coefficients(mod)[1,2]
	res$intercept_pval = coefficients(mod)[1,4]
	res$n1 <- mean(dat$n1, na.rm=T)
	res$n2 <- mean(dat$n2, na.rm=T)
	res$intercept_numerator = res$intercept / sqrt(res$n1 * res$n2)

	return(res)
}
