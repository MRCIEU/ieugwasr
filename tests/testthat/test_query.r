# skip()
skip_on_cran()
# skip_on_ci()

library(dplyr)

a <- api_status()
if(inherits(a, "response")) skip("Server issues")

test_that("get_query_content", {
	a <- api_query("FALSE_ENDPOINT")
	expect_true(inherits(a, "response"))
})


test_that("gwasinfo", 
{
	expect_true(
		nrow(api_query('gwasinfo/ieu-a-2') %>% get_query_content()) == 1
	)
	expect_equal(
		nrow(api_query('gwasinfo', query=list(id=c("ieu-a-2","ieu-a-1001"))) %>% get_query_content()), 
		2
	)
	expect_gt(
		nrow(gwasinfo()),
		100
	)
})

test_that("gwasinfo without token", {
	a1 <- gwasinfo("ieu-a-2", opengwas_jwt="")
	a2 <- gwasinfo("ieu-a-2")
	expect_true(all(a1 == a2, na.rm=TRUE))
})


test_that("associations",
{
	expect_true(
		nrow(associations(c("rs9662760", "rs12759473"), "ieu-a-2")) == 2
	)
	
	expect_true(
		nrow(associations(c("rs9662760", "rs12759473"), "ieu-a-2", proxies=0)) == 1
	)

	expect_true(
		nrow(associations(c("1:1000000-10002000", "2:1000000-10002000"), "ieu-a-2")) > 10000
	)

})

test_that("fill_n", 
{
	x <- associations(c("rs12759473"), "bbj-a-10") %>% fill_n
	expect_true(
		is.numeric(x$n) & !is.na(x$n)
	)
})

test_that("phewas",
{
	a <- phewas("rs977747", 0.01)
	if(inherits(a, "response")) skip("Server issues")
	expect_true(nrow(a)>100)
	b <- phewas("rs977747", 0.01, batch=c("ieu-a"))
	if(inherits(b, "response")) skip("Server issues")
	expect_true(nrow(b) < nrow(a))
	expect_true(nrow(b) > 0)
})


# test_that("phewas",
# {
# 	a <- phewas("1:1000000-10000100", 0.1)
# 	expect_true(nrow(a)>100)
# })


test_that("phewas",
{
	a <- phewas("1:1850428", 0.001)
	expect_true(nrow(a)>10)
})


test_that("tophits",
{
	expect_equal(nrow(tophits("ieu-a-2")), 79)
	expect_true(nrow(tophits("ieu-a-2", clump=0))>79)
})


test_that("batch", {
	b <- batch_from_id(c("ieu-a-1", "ukb-b-100-10"))
	expect_true(all(b == c("ieu-a", "ukb-b")))
})

test_that("user", {

	# with no key
	# u1 <- user(opengwas_jwt="")
	# expect_true(inherits(u1, "response"))

	skip_on_cran()
	skip_on_ci()
	skip_if(Sys.getenv('OPENGWAS_X_TEST_MODE_KEY') != "")

	# make sure valid jwt is in .Renviron
	key <- get_opengwas_jwt()
	expect_true(nchar(key) > 0)
	
	u2 <- user()
	expect_false(inherits(u2, "response"))
})

