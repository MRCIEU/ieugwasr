# skip()
# skip_on_cran()
# skip_on_ci()

snpinfo1 <- afl2_list()
if(inherits(snpinfo1, "response")) skip("Server issues")
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

test_that("chrpos", {
	a <- afl2_chrpos("1:100000-900000")
	expect_true(nrow(a) > 100)
})

test_that("rsid", {
	a <- afl2_rsid(c("rs234", "rs123"))
	expect_true(nrow(a) == 2)
})



