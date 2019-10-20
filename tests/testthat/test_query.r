context("Queries")
library(ieugwas)


test_that("gwasinfo", 
{
	expect_true(
		nrow(api_query('gwasinfo/IEU-a-2',access_token=NULL) %>% get_query_content()) == 1
	)
	expect_equal(
		nrow(api_query('gwasinfo', query=list(id=c("IEU-a-2","IEU-a-1001"))) %>% get_query_content()), 
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
		nrow(associations(c("rs9662760", "rs12759473"), "IEU-a-2")) == 2
	)
	
	expect_true(
		nrow(associations(c("rs9662760", "rs12759473"), "IEU-a-2", proxies=0)) == 1
	)

})


test_that("phewas",
{
	a <- phewas("rs234", 1)
	expect_true(nrow(a)>100)
})


test_that("tophits",
{
	expect_equal(nrow(tophits("IEU-a-2")), 79)
	expect_true(nrow(tophits("IEU-a-2", clump=0))>79)
})





