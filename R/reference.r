# Get list of 20k SNPs 


# select_api()
# b <- associations(snpinfo$rsid, "ieu-a-7", proxies=FALSE)

# ab <- dplyr::inner_join(b, snpinfo)
# dplyr::select(ab, eaf, starts_with("AF.")) %>% cor

# ab$z <- ab$beta / ab$se
# summary(lm(z ~ L2.EUR, ab))






#' Infer ancestry of GWAS dataset by matching against 1000 genomes allele frequencies
#'
#' Uses ~20k SNPs selected for common frequency across 5 major super populations
#'
#' @param d Data frame containing at least rsid and eaf columns. e.g. output from associations
#'
#' @export
#' @return vector ordered by most likely ancestry
infer_ancestry <- function(d)
{
	select_api("dev1")
	snpinfo <- api_query("variants/afl2/snplist") %>% 
		get_query_content() %>%
		dplyr::as_tibble() %>%
		dplyr::inner_join(., d, by="rsid")

	nom <- grep("^AF\\.", names(snpinfo), value=TRUE)
	out <- sapply(nom, function(x)
	{
		cor(snpinfo$eaf, snpinfo[[x]], use="pair")
	}) %>% sort(decreasing=TRUE)
	names(out) <- gsub("AF\\.", "", names(out))
	return(out)
}

bv_ldsc <- function(id1, id2, ancestry)
{
	snpinfo <- api_query("variants/afl2/snplist") %>% 
		get_query_content() %>%
		dplyr::as_tibble() %>%
		dplyr::select(rsid, l2=paste0("L2.", ancestry))

	d1 <- associations(snpinfo$rsid, id1, proxies=FALSE) %>%
		d1 <- d1 %>% fill_n() %>%
		dplyr::mutate(z = beta / se) %>%
		dplyr::select(rsid, z1 = z, n1 = n)

	d2 <- associations(snpinfo$rsid, id2, proxies=FALSE) %>%
		d2 <- d2 %>% fill_n() %>%
		dplyr::mutate(z = beta / se) %>%
		dplyr::select(rsid, z2 = z, n2 = n)

	mod <- dplyr::inner_join(snpinfo, d1, by="rsid") %>%
		dplyr::inner_join(., d2, by="rsid") %>%
		dplyr::mutate(
			zz = z1 * z2, 
			n1 = as.numeric(n1),
			n2 = as.numeric(n2),
			rhs = l2 * sqrt(n1 * n2)
		) %>%
		{summary(lm(zz ~ rhs, .))}

	dat$zz <- dat$z1

}



fill_n <- function(d)
{
	id <- d$id[1]
	if(! "n" %in% names(d1))
	{
		d$n <- NA
	}
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
