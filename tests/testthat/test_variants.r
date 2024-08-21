# skip()
skip_on_cran()
# skip_on_ci()


o1 <- try(variants_gene("ENSG00000123374"))
if (inherits(o1, c("try-error", "response"))) skip("Server issues")

o2 <- try(variants_gene("ENSG00000123374", 100000))
if (inherits(o2, c("try-error", "response"))) skip("Server issues")

test_that("genes",
{
  if (nrow(o1) == 0) skip("o1 has 0 rows")
  if (nrow(o2) == 0) skip("o2 has 0 rows")
	expect_gt(nrow(o1), 0)
	expect_gt(nrow(o2), nrow(o1))
})


test_that("chrpos",
{
	o <- try(variants_chrpos("7:105561135-105563135"))
	if (inherits(o, c("try-error", "response"))) skip("Server issues")
	expect_true(nrow(o) > 1)

	o <- try(variants_chrpos("7:105561135"))
	if (inherits(o, c("try-error", "response"))) skip("Server issues")
	expect_true(nrow(o) == 1)

	o <- try(variants_chrpos("nonsense"))
	if (inherits(o, "try-error")) skip("Server issues")
	expect_true(class(o) == "response")
})


test_that("rsid", 
{
	o <- try(variants_chrpos("7:105561135-105563135"))
	if (inherits(o, c("try-error", "response"))) skip("Server issues")
	p <- try(variants_rsid(o$name))
	if (inherits(p, c("try-error", "response"))) skip("Server issues")
	expect_true(all(nrow(o) == nrow(p)))
	expect_true(all(o$name == p$name))
})


test_that("conversion",
{
  skip_on_ci()
	o <- NULL
  o <- try(variants_to_rsid(c("rs1205", "7:105561135")))
	if (inherits(o, c("try-error", "response"))) skip("Server issues")
	if (!inherits(o, "character")) skip("o of wrong class")
  if (length(o) == 0) skip("o is of length 0")
	expect_true(length(o) == 2)

	o <- NULL
	o <- try(variants_to_rsid(c("rs234", "7:105561135")))
	if (inherits(o, c("try-error", "response"))) skip("Server issues")
	expect_true(length(o) == 1)

	o <- NULL
	o <- try(variants_to_rsid(c("rs234")))
	if (inherits(o, c("try-error", "response"))) skip("Server issues")
	expect_true(length(o) == 1)
})


