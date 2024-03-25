skip()
skip_on_cran()
skip_on_ci()

test_that("status", 
{
	stat <- api_status()
	expect_true(is.list(stat))
	expect_gte(length(stat), 2)
})


