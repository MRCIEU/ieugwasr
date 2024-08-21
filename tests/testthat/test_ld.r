# skip()
skip_on_cran()
# skip_on_ci()

library(dplyr)

a <- try(tophits("ieu-a-2"))
if (inherits(a, c("try-error", "repsonse"))) skip("Server issues")
ap <- try(tophits("ieu-a-2", force_server=TRUE))
if (inherits(ap, c("try-error", "repsonse"))) skip("Server issues")
au <- try(tophits("ieu-a-2", clump=1))
if (inherits(au, c("try-error", "repsonse"))) skip("Server issues")
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

test_that("multiple", {
  ab <- try(tophits(c("ieu-a-2", "ieu-a-1001")))
  if (inherits(ab, c("try-error", "repsonse"))) skip("Server issues")
  ab2 <- try(ld_clump(ab))
  if (inherits(ab2, c("try-error", "repsonse"))) skip("Server issues")
	expect_equal(
		length(unique(ab2$id)), length(unique(ab$id))
	)
})


test_that("onesnp", {
  th <- try(tophits(c("ieu-a-2", "ieu-a-7")))
  if (inherits(th, c("try-error", "repsonse"))) skip("Server issues")
  a <- th %>% subset(., !duplicated(id))
  expect_warning(ab <- ld_clump(a))
	expect_equal(nrow(ab), 2)
})



test_that("ld_reflookup", {
	a <- try(ld_reflookup(c("rs234", "fakesnp"), pop="AFR"))
	if (inherits(a, c("try-error", "repsonse"))) skip("Server issues")
	expect_true(a == "rs234")
})

