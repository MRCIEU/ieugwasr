# skip()
skip_on_cran()
# skip_on_ci()

snpinfo1 <- try(afl2_list())
if (inherits(snpinfo1, c("try-error", "response"))) skip("Server issues")
snpinfo2 <- try(afl2_list("hapmap3"))
if (inherits(snpinfo2, c("try-error", "response"))) skip("Server issues")

test_that("snplist", {
	expect_true(nrow(snpinfo2) > 1000000)
})

test_that("snplist", {
	expect_true(nrow(snpinfo1) > 10000 & nrow(snpinfo1) < 30000)
})

test_that("ancestry", {
	a <- try(associations(snpinfo1$rsid, "bbj-a-10", prox=FALSE))
	if (inherits(a, c("try-error", "response"))) skip("Server issues")
	res <- infer_ancestry(a, snpinfo1)
	expect_true(res$pop[1] == "EAS")
})

test_that("chrpos", {
	a <- try(afl2_chrpos("1:100000-900000"))
	if (inherits(a, c("try-error", "response"))) skip("Server issues")
	expect_true(nrow(a) > 100)
})

# test_that("rsid", {
# 	a <- afl2_rsid(c("rs234", "rs123"))
# 	expect_true(nrow(a) == 2)
# })



