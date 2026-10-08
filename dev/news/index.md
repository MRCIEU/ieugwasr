# Changelog

## ieugwasr (development version)

- [`ld_matrix_local()`](https://mrcieu.github.io/ieugwasr/dev/reference/ld_matrix_local.md)
  now reads the alleles in the `.bim` file as character. Previously a
  column of all `T` alleles was read as logical, so the row and column
  names contained `TRUE` instead of `T`
  ([\#38](https://github.com/MRCIEU/ieugwasr/issues/38)).
- [`ld_clump_local()`](https://mrcieu.github.io/ieugwasr/dev/reference/ld_clump_local.md),
  and so
  [`ld_clump()`](https://mrcieu.github.io/ieugwasr/dev/reference/ld_clump.md)
  with a local `bfile`, no longer errors with “cannot open the
  connection” when plink writes no `.clumped` file. If no variants pass
  clumping it now returns no rows with a message, and if plink fails it
  gives an informative error including the end of the plink log
  ([\#30](https://github.com/MRCIEU/ieugwasr/issues/30),
  [\#34](https://github.com/MRCIEU/ieugwasr/issues/34),
  [\#44](https://github.com/MRCIEU/ieugwasr/issues/44)).
- [`ld_clump()`](https://mrcieu.github.io/ieugwasr/dev/reference/ld_clump.md),
  [`ld_clump_local()`](https://mrcieu.github.io/ieugwasr/dev/reference/ld_clump_local.md),
  [`ld_matrix()`](https://mrcieu.github.io/ieugwasr/dev/reference/ld_matrix.md)
  and
  [`ld_matrix_local()`](https://mrcieu.github.io/ieugwasr/dev/reference/ld_matrix_local.md)
  gain a `tmpdir` argument, the directory in which the temporary files
  used by plink are written. The default,
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html), keeps the
  previous behaviour
  ([\#37](https://github.com/MRCIEU/ieugwasr/issues/37)).
- [`ld_matrix_local()`](https://mrcieu.github.io/ieugwasr/dev/reference/ld_matrix_local.md)
  now removes its temporary plink files when it exits.
- [`ld_clump()`](https://mrcieu.github.io/ieugwasr/dev/reference/ld_clump.md)
  now warns if several variants share the smallest p-value, e.g. because
  p-values smaller than R can represent underflow to 0, or because other
  software has capped them. Plink then chooses the lead variant among
  them arbitrarily. The warning suggests lowering any cap, e.g. setting
  `min_pval = 1e-300` in `TwoSampleMR::format_data()`
  ([\#39](https://github.com/MRCIEU/ieugwasr/issues/39)).

## ieugwasr 1.2.0

CRAN release: 2026-10-07

- [`associations()`](https://mrcieu.github.io/ieugwasr/dev/reference/associations.md)
  now returns the processed tibble. Previously its `... %>% return()`
  inside a pipe did not return from the function (since magrittr 2.0),
  so the raw server data frame was returned instead, with `n` as
  character.
- Remove the flipping of `beta` for `ukb-e` datasets in
  [`associations()`](https://mrcieu.github.io/ieugwasr/dev/reference/associations.md),
  [`tophits()`](https://mrcieu.github.io/ieugwasr/dev/reference/tophits.md)
  and
  [`phewas()`](https://mrcieu.github.io/ieugwasr/dev/reference/phewas.md).
  The flip was never applied in
  [`associations()`](https://mrcieu.github.io/ieugwasr/dev/reference/associations.md)
  (see above), and the OpenGWAS server is the right place to correct
  these datasets.
- Replace `%>% return()` with explicit
  [`return()`](https://rdrr.io/r/base/function.html) calls throughout.
- Update some GitHub Actions workflows, including no longer testing on R
  before R 4.1 due to the new testthat requirements
- Tweak an API test
- Bump version of roxygen2
- Fix a typo in the documentation for
  [`ld_clump()`](https://mrcieu.github.io/ieugwasr/dev/reference/ld_clump.md)
- Bump minimum required version of R to 4.1
- Update some URLs in the package
- Fix some typos in the docs
- Forward `...` to
  [`api_query()`](https://mrcieu.github.io/ieugwasr/dev/reference/api_query.md)
  in
  [`variants_chrpos()`](https://mrcieu.github.io/ieugwasr/dev/reference/variants_chrpos.md)
- Prevent divide-by-zero chunking in
  [`associations()`](https://mrcieu.github.io/ieugwasr/dev/reference/associations.md)
- Handle `NULL` `opengwas_jwt` in
  [`api_query()`](https://mrcieu.github.io/ieugwasr/dev/reference/api_query.md)
- Close connection in
  [`afl2_list()`](https://mrcieu.github.io/ieugwasr/dev/reference/afl2_list.md)
  hapmap3 branch
- Harden
  [`fill_n()`](https://mrcieu.github.io/ieugwasr/dev/reference/fill_n.md)
  against empty or multi-row
  [`gwasinfo()`](https://mrcieu.github.io/ieugwasr/dev/reference/gwasinfo.md)
  results
- Use [`getOption()`](https://rdrr.io/r/base/options.html) instead of
  copying the full options list
- Remove dead shadowing assignment in
  [`associations()`](https://mrcieu.github.io/ieugwasr/dev/reference/associations.md)
- Use
  [`seq_along()`](https://rdrr.io/r/base/seq.html)/[`seq_len()`](https://rdrr.io/r/base/seq.html)
  instead of `1:length()` loop bounds
- Align
  [`ld_clump_api()`](https://mrcieu.github.io/ieugwasr/dev/reference/ld_clump_api.md)
  defaults with its documentation
- Make
  [`get_query_content()`](https://mrcieu.github.io/ieugwasr/dev/reference/get_query_content.md)
  error path robust to non-JSON bodies
- Fix empty-result check in
  [`tophits()`](https://mrcieu.github.io/ieugwasr/dev/reference/tophits.md)
  (closes [\#76](https://github.com/MRCIEU/ieugwasr/issues/76))
- Supply `origin` to
  [`as.POSIXct()`](https://rdrr.io/r/base/as.POSIXlt.html) in allowance
  reset handling (closes
  [\#103](https://github.com/MRCIEU/ieugwasr/issues/103))
- Remove **utils** from Suggests, since it’s a Base package

## ieugwasr 1.1.0

CRAN release: 2025-07-31

- Improved error handling
- Managing new API limits on associations endpoint
- Updated header info passed to API

## ieugwasr 1.0.4

CRAN release: 2025-06-18

- Improved warning messages in
  [`ld_clump()`](https://mrcieu.github.io/ieugwasr/dev/reference/ld_clump.md)
  (thanks [@DarwinAwardWinner](https://github.com/DarwinAwardWinner)).
- [`ld_clump()`](https://mrcieu.github.io/ieugwasr/dev/reference/ld_clump.md)
  and
  [`ld_matrix()`](https://mrcieu.github.io/ieugwasr/dev/reference/ld_matrix.md)
  now search for the plink binary as documented (thanks
  [@DarwinAwardWinner](https://github.com/DarwinAwardWinner)).
- Made some minor amends in the helpfiles and vignettes including:
  fixing typos, replacing all references to MR-Base with OpenGWAS, and
  improving the
  [`gwasinfo_files()`](https://mrcieu.github.io/ieugwasr/dev/reference/gwasinfo_files.md)
  helpfile.
- Fixed bug in headers code in
  [`api_query()`](https://mrcieu.github.io/ieugwasr/dev/reference/api_query.md)
  (thanks [@Gaoyan152](https://github.com/Gaoyan152)).

## ieugwasr 1.0.3

CRAN release: 2025-03-20

- Add gwasinfo_files() function to return for each dataset specified the
  download URL for each file (.vcf.gz, .vcf.gz.tbi, \_report.html)
  associated with the dataset. The URLs will expire in 2 hours.

## ieugwasr 1.0.2

- Bump roxygen2 version
- Update OpenGWAS API URL

## ieugwasr 1.0.1

CRAN release: 2024-07-01

- Checking for allowance depletion, and erroring until the allowance is
  reset
- Import the magrittr pipe (thanks
  [@Bhashitha2014](https://github.com/Bhashitha2014))

## ieugwasr 1.0.0

CRAN release: 2024-04-22

- Introducing JWT authorisation for the API
- Phasing out Google Oauth2 authorisation
- Added user() function to get user information
- Fixing issue with anonymous functions and backwards compatibility
- Bug in tophits when result is empty
- Removing version check at startup
- Bug in querying when errors returned
- Removing unnecessary dependencies and vignettes

## ieugwasr 0.2.2

CRAN release: 2024-03-28

- Reinstating <https://api.opengwas.org/api/> as the API server address
- Fixing issues with tests failing when server load is an issue

## ieugwasr 0.2.1

- Updating API server address temporarily
- Modifying tests to manage API server load
- Fixes to load/attach behaviour

## ieugwasr 0.2.0

CRAN release: 2024-03-25

- Moving API address to <https://api.opengwas.org/api/>
- Fixing issues for CRAN release

## ieugwasr 0.1.7

- Added functions to write LD scores files into compressed `.gz` files
  for each super-population and divided by chromosomes.
- Added argument to output
  [gwasglue2](https://mrcieu.github.io/gwasglue2/) objects in
  [`ieugwasr::tophits()`](https://mrcieu.github.io/ieugwasr/dev/reference/tophits.md)
  and
  [`ieugwasr::associations()`](https://mrcieu.github.io/ieugwasr/dev/reference/associations.md).

## ieugwasr 0.1.6

- Adding messaging about package version

- Adding messaging about OpenGWAS \# ieugwasr 0.1.5

- Added options to perform LD functions on different super-populations

- Catching 503 error codes and retrying up to 5 times. This should help
  avoid fails when the server is busy.

## ieugwasr 0.1.4

- Bug fixes in clumping. Thanks to
  [bethleegy](https://github.com/bethleegy) for pointing this out

## ieugwasr 0.1.3

- Bug fixes in clumping

## ieugwasr 0.1.2

- Updated API address

## ieugwasr 0.1.1

- Fixed bug in ld_clump - wasn’t doing all traits

## ieugwasr 0.1.0

- First release in conjunction with API

## ieugwasr 0.0.0.9000

- Added a `NEWS.md` file to track changes to the package.
