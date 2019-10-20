context("LD functions")
library(ieugwas)

a <- tophits("IEU-a-2")
au <- tophits("IEU-a-2", clump=0)
b <- dplyr::tibble(variant=au$name, pval=au$p, id=au$id)
bc <- ld_clump(b)
# bcl <- ld_clump(b, bfile="/Users/gh13047/data/ld_files/data_maf0.01_rs", plink_bin="plink")

test_that("ld clumping", {

	expect_true(nrow(a) == nrow(bc))
	# expect_true(nrow(bcl) == nrow(bc))

})


test_that("ld matrix", {
	expect_equal(
		length(unique(bc$variant)), nrow(ld_matrix(bc$variant))
	)
})

