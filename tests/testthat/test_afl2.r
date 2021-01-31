library(ieugwasr)
context("afl2")

snpinfo1 <- afl2_list()
snpinfo2 <- afl2_list("hapmap3")

test_that("snplist", {
	expect_true(nrow(snpinfo2) > 1000000)
})

test_that("snplist", {
	expect_true(nrow(snpinfo1) > 10000 & nrow(snpinfo1) < 30000)
})

test_that("ancestry", {
	a <- associations(snpinfo1$rsid, "bbj-a-10", prox=FALSE)
	res <- infer_ancestry(a, snpinfo1)
	expect_true(res$pop[1] == "EAS")
})

