# These tests use a fake plink shell script, so need neither plink nor the API
skip_on_os("windows")

fake_plink <- function(bim_lines) {
	bim <- tempfile(fileext=".bim")
	writeLines(bim_lines, bim)
	exe <- tempfile()
	writeLines(c(
		"#!/bin/sh",
		"while [ $# -gt 0 ]; do",
		"  case \"$1\" in",
		"    --out) out=\"$2\"; shift ;;",
		"    --make-just-bim) mode=bim ;;",
		"    --r) mode=ld ;;",
		"  esac",
		"  shift",
		"done",
		paste0("if [ \"$mode\" = bim ]; then cp '", bim, "' \"$out.bim\"; fi"),
		paste0("if [ \"$mode\" = ld ]; then printf '1\\t0.5\\t0.1\\n0.5\\t1\\t0.2\\n0.1\\t0.2\\t1\\n' > \"$out.ld\"; fi")
	), exe)
	Sys.chmod(exe, "755")
	exe
}

test_that("ld_matrix_local keeps T alleles as character (#38)", {
	plink <- fake_plink(c(
		"1\trs3811450\t0\t154551032\tT\tC",
		"1\trs11264222\t0\t154554357\tT\tC",
		"1\trs9616\t0\t154555733\tT\tA"
	))
	res <- ld_matrix_local(c("rs3811450", "rs11264222", "rs9616"), bfile="fake", plink_bin=plink)
	expect_equal(rownames(res), c("rs3811450_T_C", "rs11264222_T_C", "rs9616_T_A"))
	expect_equal(colnames(res), rownames(res))
})
