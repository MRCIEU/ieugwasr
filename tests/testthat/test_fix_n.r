test_that("fix_n() converts n to numeric and does not change beta",
{
	d <- data.frame(id=c("ukb-e-23104_CSA", "ukb-b-19953"), beta=c(0.1, 0.2), n=c("", "461460"))
	out <- fix_n(d)
	expect_type(out$n, "double")
	expect_equal(out$beta, c(0.1, 0.2))
})

test_that("associations() returns the processed tibble",
{
	local_mocked_bindings(
		api_query = function(...) NULL,
		get_query_content = function(...) data.frame(id="ukb-e-23104_CSA", rsid="rs6567160", beta=0.06, n="")
	)
	out <- associations("rs6567160", "ukb-e-23104_CSA")
	expect_s3_class(out, "tbl_df")
	expect_type(out$n, "double")
	expect_equal(out$beta, 0.06)
})
