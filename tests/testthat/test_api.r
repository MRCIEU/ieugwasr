context("API")

test_that("status", 
{
	stat <- api_status()
	expect_true(is.list(stat))
	expect_gte(length(stat), 2)
})


