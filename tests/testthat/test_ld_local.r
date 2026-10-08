# These tests use a fake plink shell script, so need neither plink nor the API
skip_on_os("windows")

# clump: what the fake plink does for --clump
#   "ok": write a .clumped file containing the first variant
#   "none": log plink's no significant results warning and write no .clumped file
#   "fail": log an error and exit with status 1
fake_plink <- function(bim_lines=character(0), clump=c("ok", "none", "fail")) {
	clump <- match.arg(clump)
	bim <- tempfile(fileext=".bim")
	writeLines(bim_lines, bim)
	exe <- tempfile()
	writeLines(c(
		"#!/bin/sh",
		"while [ $# -gt 0 ]; do",
		"  case \"$1\" in",
		"    --out) out=\"$2\"; shift ;;",
		"    --clump) mode=clump; infile=\"$2\"; shift ;;",
		"    --make-just-bim) mode=bim ;;",
		"    --r) mode=ld ;;",
		"  esac",
		"  shift",
		"done",
		paste0("if [ \"$mode\" = bim ]; then cp '", bim, "' \"$out.bim\"; fi"),
		paste0("if [ \"$mode\" = ld ]; then printf '1\\t0.5\\t0.1\\n0.5\\t1\\t0.2\\n0.1\\t0.2\\t1\\n' > \"$out.ld\"; fi"),
		"if [ \"$mode\" = clump ]; then",
		switch(clump,
			ok = "  printf ' CHR F SNP BP P TOTAL NSIG S05 S01 S001 S0001 SP2\\n 1 1 %s 1 1e-10 0 0 0 0 0 0 NONE\\n' \"$(sed -n 2p \"$infile\" | cut -d' ' -f1)\" > \"$out.clumped\"",
			none = "  echo 'Warning: No significant --clump results.  Skipping.' > \"$out.log\"",
			fail = "  echo 'Error: Failed to open fake.bed.' > \"$out.log\"; exit 1"
		),
		"fi"
	), exe)
	Sys.chmod(exe, "755")
	exe
}

dat <- data.frame(rsid=c("rs1", "rs2", "rs3"), pval=c(1e-10, 1e-9, 1e-8))

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

test_that("ld_clump_local returns clumped variants", {
	plink <- fake_plink(clump="ok")
	expect_message(res <- ld_clump_local(dat, 10000, 0.001, 1, bfile="fake", plink_bin=plink), "Removing 2 of 3")
	expect_equal(res$rsid, "rs1")
})

test_that("ld_clump_local returns no rows when no variants pass clumping (#34)", {
	plink <- fake_plink(clump="none")
	expect_message(res <- ld_clump_local(dat, 10000, 0.001, 5e-8, bfile="fake", plink_bin=plink), "Removing all 3 variants")
	expect_equal(nrow(res), 0)
	expect_equal(names(res), names(dat))
})

test_that("ld_clump_local gives an informative error when plink fails (#34)", {
	plink <- fake_plink(clump="fail")
	expect_error(ld_clump_local(dat, 10000, 0.001, 1, bfile="fake", plink_bin=plink), "Failed to open fake.bed")
})

test_that("ld_clump with local plink returns no rows when no variants pass clumping (#34)", {
	plink <- fake_plink(clump="none")
	expect_message(res <- ld_clump(dat, clump_p=5e-8, bfile="fake", plink_bin=plink), "Removing all 3 variants")
	expect_equal(nrow(res), 0)
})
