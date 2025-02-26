# skip()
skip_on_cran()
# skip_on_ci()

library(dplyr)

a <- try(api_status())
if (inherits(a, c("try-error", "response"))) skip("Server issues")

test_that("get_query_content", {
	a <- try(api_query("FALSE_ENDPOINT"))
	if (inherits(a, c("try-error", "response"))) skip("Server issues")
	expect_true(inherits(a, "response"))
})


test_that("gwasinfo", 
{
  skip_on_ci()
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
  skip_on_ci()
	a1 <- gwasinfo("ieu-a-2", opengwas_jwt="")
	a2 <- gwasinfo("ieu-a-2")
	expect_true(all(a1 == a2, na.rm=TRUE))
})


test_that("associations",
{
  skip_on_ci()
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
  skip_on_ci()
	x <- associations(c("rs12759473"), "bbj-a-10") %>% fill_n
	expect_true(
		is.numeric(x$n) & !is.na(x$n)
	)
})

test_that("phewas",
{
	a <- try(phewas("rs977747", 0.01))
	if (inherits(a, c("try-error", "response"))) skip("Server issues")
	expect_true(nrow(a)>100)
	b <- try(phewas("rs977747", 0.01, batch=c("ieu-a")))
	if (inherits(b, c("try-error", "response"))) skip("Server issues")
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
	a <- try(phewas("1:1850428", 0.001))
	if (inherits(a, c("try-error", "response"))) skip("Server issues")
	expect_true(nrow(a)>10)
})


test_that("tophits",
{
  a <- try(tophits("ieu-a-2"))
  if (inherits(a, c("try-error", "response"))) skip("Server issues")
	expect_equal(nrow(a), 79)
	b <- try(tophits("ieu-a-2", clump=0))
	if (inherits(b, c("try-error", "response"))) skip("Server issues")
	expect_true(nrow(b)>79)
})


test_that("batch", {
	b <- try(batch_from_id(c("ieu-a-1", "ukb-b-100-10")))
	if (inherits(b, c("try-error", "response"))) skip("Server issues")
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

test_that("gwasinfo/files", {
  skip_on_cran()
  skip_on_ci()
  test <- try(api_query('gwasinfo/files', query = list(id='ieu-a-2'), opengwas_jwt = get_opengwas_jwt()) %>% get_query_content())
  if (inherits(test, c("try-error", "response"))) skip("Server issues")
  expect_equal(test %>% length(), 1)
  expect_equal(test$`ieu-a-2` %>% length(), 3)
})

test_that("Test gwasinfo_files()", {
  skip_on_cran()
  skip_on_ci()
  urls <- try(gwasinfo_files(id = 'ieu-a-2'))
  if (inherits(urls, c("try-error", "response"))) skip("Server issues")
  expect_equal(urls %>% ncol(), 1)
  expect_equal(urls %>% nrow(), 3)
  expect_is(urls, "data.frame")
  expect_equal(urls %>% colnames(), "ieu-a-2")
})

test_that("Test gwasinfo_files()", {
  skip_on_cran()
  skip_on_ci()
  urls2 <- try(gwasinfo_files(id = c('ieu-a-2', 'ieu-a-31')))
  if (inherits(urls2, c("try-error", "response"))) skip("Server issues")
  expect_equal(urls2 %>% ncol(), 2)
  expect_equal(urls2 %>% nrow(), 3)
  expect_is(urls2, "data.frame")
  expect_equal(urls2 %>% colnames(), c("ieu-a-2", "ieu-a-31"))
})
