context("LD functions")
library(ieugwasr)

a <- tophits("IEU-a-2")
b <- dplyr::tibble(SNP=a$name, pval.exposure=a$p, id.exposure=a$id)

test_that("ld ref", {
	expect_equal(
		nrow(a), nrow(ld_clump(b, clump_r2=0.1))
	)
})


test_that("ld matrix", {
	expect_equal(
		length(unique(b$SNP)), nrow(ld_matrix(b$SNP))
	)
})

