# skip()
skip_on_cran()
# skip_on_ci()

library(dplyr)

a <- tophits("ieu-a-2")
if(inherits(a, "response")) skip("Server issues")
ap <- tophits("ieu-a-2", force_server=TRUE)
au <- tophits("ieu-a-2", clump=1)
b <- dplyr::tibble(rsid=au$rsid, pval=au$p, id=au$id, clump=0)
bc <- ld_clump(b)
# bcl <- ld_clump(b, bfile="/Users/gh13047/data/ld_files/data_maf0.01_rs", plink_bin="plink")

test_that("preclumped", {
	expect_true(nrow(ap) == nrow(bc))
})


test_that("ld clumping", {

	expect_true(nrow(ap) == nrow(bc))
	expect_true(all(bc$rsid %in% a$rsid))
	# expect_true(nrow(bcl) == nrow(bc))
})


test_that("ld matrix", {
	expect_equal(
		length(unique(bc$rsid)), nrow(ld_matrix(bc$rsid))
	)
})

ab <- tophits(c("ieu-a-2", "ieu-a-1001"))
expect_warning(ab2 <- ld_clump(ab))
test_that("multiple", {
	expect_equal(
		length(unique(ab2$id)), length(unique(ab$id))
	)
})


a <- tophits(c("ieu-a-2", "ieu-a-7")) %>% subset(., !duplicated(id))
expect_warning(ab <- ld_clump(a))
test_that("onesnp", {
	expect_equal(nrow(ab), 2)
})



test_that("ld_reflookup", {

	a <- ld_reflookup(c("rs234", "fakesnp"), pop="AFR")
	expect_true(a == "rs234")
})

