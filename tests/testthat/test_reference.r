library(ieugwasr)
context("reference")

snpinfo <- common_snpinfo()

test_that("snplist", {

	expect_true(nrow(snpinfo) > 10000)

})

test_that("ancestry", {

	a <- associations(snpinfo$rsid, "bbj-a-10", prox=FALSE)
	res <- infer_ancestry(a, snpinfo)
	expect_true(res$pop[1] == "EAS")
})


test_that("ldsc", {

	id1 <- "ukb-a-248"
	id2 <- "ukb-b-19953"
	ancestry <- "EUR"
	res <- bv_ldsc(id1, id2, ancestry, snpinfo=snpinfo)
	expect_true(is.list(res))
})

