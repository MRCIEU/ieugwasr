# skip()
# skip_on_cran()
# skip_on_ci()

stat <- api_status()
if(inherits(stat, "response")) skip("Server issues")

test_that("status", 
{
	expect_true(is.list(stat))
	expect_gte(length(stat), 2)
})


