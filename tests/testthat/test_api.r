# skip()
# skip_on_cran()
# skip_on_ci()

stat <- try(api_status())
if (inherits(stat, "try-error")) skip("Server issues")

test_that("status", 
{
	expect_true(is.list(stat))
	expect_gte(length(stat), 2)
})


