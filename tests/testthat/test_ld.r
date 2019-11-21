context("LD functions")
library(ieugwasr)

a <- tophits("ieu-a-2")
ap <- tophits("ieu-a-2", preclumped=0)
au <- tophits("ieu-a-2", preclumped=0, clump=0)
b <- dplyr::tibble(variant=au$name, pval=au$p, id=au$id)
bc <- ld_clump(b)
# bcl <- ld_clump(b, bfile="/Users/gh13047/data/ld_files/data_maf0.01_rs", plink_bin="plink")

test_that("preclumped", {
	all(a$name %in% ap$name)
})


test_that("ld clumping", {

	expect_true(nrow(a) == nrow(bc))
	expect_true(all(a$name %in% bc$variant))
	# expect_true(nrow(bcl) == nrow(bc))

})


test_that("ld matrix", {
	expect_equal(
		length(unique(bc$variant)), nrow(ld_matrix(bc$variant))
	)
})

