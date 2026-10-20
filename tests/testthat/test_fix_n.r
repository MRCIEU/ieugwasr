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

test_that("associations() combines chunks with integer and character n",
{
	chunks <- list(
		data.frame(id="ieu-a-1", rsid="rs1", beta=0.1, n=1000L),
		data.frame(id="ieu-a-2", rsid="rs1", beta=0.2, n="")
	)
	i <- 0
	local_mocked_bindings(
		api_query = function(...) NULL,
		get_query_content = function(...) {
			i <<- i + 1
			chunks[[i]]
		}
	)
	out <- suppressMessages(associations("rs1", c("ieu-a-1", "ieu-a-2"), max_ids_per_request=1))
	expect_equal(nrow(out), 2)
	expect_type(out$n, "double")
	expect_equal(out$n, c(1000, NA))
})
