context("Variants")
library(ieugwas)

o1 <- variants_gene("ENSG00000123374")
o2 <- variants_gene("ENSG00000123374", 100000)

test_that("genes",
{
	expect_gt(nrow(o1), 0)
	expect_gt(nrow(o2), nrow(o1))
})


test_that("chrpos",
{
	o <- variants_chrpos("7:105561135-105563135")
	expect_true(nrow(o) > 1)

	o <- variants_chrpos("7:105561135")
	expect_true(nrow(o) == 1)

	o <- variants_chrpos("nonsense")
	expect_true(class(o) == "response")
})



test_that("conversion",
{
	o <- variants_to_rsid(c("rs234", "7:105561135"))
	expect_true(length(o) == 1)

	o <- variants_to_rsid(c("rs234"))
	expect_true(length(o) == 1)
})


