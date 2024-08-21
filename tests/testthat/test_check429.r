skip_on_cran()
if(Sys.getenv("OPENGWAS_X_TEST_MODE_KEY") == "") {
    test_that("no allowance", {
        a <- try(api_query("tophits", query=list(id="ieu-a-2"), override_429=TRUE))
        if (inherits(a, c("try-error", "response"))) skip("Server issues")

        expect_warning(set_reset(a))
        expect_error(check_reset())
        expect_warning(check_reset(override_429=TRUE))
        expect_error(tophits("ieu-a-2"))
        expect_warning(expect_no_error(api_status()))
        expect_warning(expect_no_error(user()))
        expect_warning(expect_no_error(batches()))

        options(ieugwasr_reset=as.numeric(Sys.time())-1)

        expect_no_error(check_reset())

    })
}
