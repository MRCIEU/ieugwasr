library(ieugwasr)
context("afl2")

snpinfo <- common_snpinfo()

test_that("snplist", {
	expect_true(nrow(snpinfo) > 10000)
})

test_that("ancestry", {
	a <- associations(snpinfo$rsid, "bbj-a-10", prox=FALSE)
	res <- infer_ancestry(a, snpinfo)
	expect_true(res$pop[1] == "EAS")
})

