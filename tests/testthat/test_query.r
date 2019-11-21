context("Queries")
library(ieugwasr)


test_that("gwasinfo", 
{
	expect_true(
		nrow(api_query('gwasinfo/ieu-a-2',access_token=NULL) %>% get_query_content()) == 1
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

test_that("associations",
{
	expect_true(
		nrow(associations(c("rs9662760", "rs12759473"), "ieu-a-2")) == 2
	)
	
	expect_true(
		nrow(associations(c("rs9662760", "rs12759473"), "ieu-a-2", proxies=0)) == 1
	)

})


test_that("phewas",
{
	a <- phewas("rs234", 1)
	expect_true(nrow(a)>100)
})


test_that("tophits",
{
	expect_equal(nrow(tophits("ieu-a-2")), 79)
	expect_true(nrow(tophits("ieu-a-2", preclumped=0, clump=0))>79)
})





