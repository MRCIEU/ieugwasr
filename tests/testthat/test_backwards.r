context("backwards compatibility")
library(ieugwasr)

test_that("backwards compatibility", 
{
	a <- c("2", "UKB-a:3", "IEU-a:4", "ieu-a-5")
	b <- legacy_ids(a)
	expect_true(all(b == c("ieu-a-2", "ukb-a-3", "ieu-a-4", "ieu-a-5")))
})