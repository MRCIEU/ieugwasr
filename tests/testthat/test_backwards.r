test_that("backwards compatibility", 
{
	a <- c("2", "UKB-a:3", "IEU-a:4", "ieu-a-5")
	b <- legacy_ids(a)
	expect_true(all(b == c("ieu-a-2", "ukb-a-3", "ieu-a-4", "ieu-a-5")))
})


test_that("met1",
{
	a <- c("ieu-a-303", "ieu-a-119", "ieu-a-838")
	b <- legacy_ids(a)
	expect_true(all(b == c("met-a-303", "met-b-119", "met-c-838")))
})

test_that("met2",
{
	a <- c("303", "119", "838")
	b <- legacy_ids(a)
	expect_true(all(b == c("met-a-303", "met-b-119", "met-c-838")))
})
