context("LD functions")
library(ieugwasr)

a <- tophits("ieu-a-2")
ap <- tophits("ieu-a-2", force_server=TRUE)
au <- tophits("ieu-a-2", clump=1)
b <- dplyr::tibble(variant=au$name, pval=au$p, id=au$id, clump=0)
bc <- ld_clump(b)
# bcl <- ld_clump(b, bfile="/Users/gh13047/data/ld_files/data_maf0.01_rs", plink_bin="plink")

test_that("preclumped", {
	expect_true(all(ap$name %in% a$name))
})


test_that("ld clumping", {

	expect_true(nrow(ap) == nrow(bc))
	expect_true(all(bc$variant %in% a$name))
	# expect_true(nrow(bcl) == nrow(bc))
})


test_that("ld matrix", {
	expect_equal(
		length(unique(bc$variant)), nrow(ld_matrix(bc$variant))
	)
})

