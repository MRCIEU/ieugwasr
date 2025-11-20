# Changelog

## ieugwasr 1.1.0.9000

- Update some GitHub Actions workflows, including no longer testing on R
  before R 4.1 due to the new testthat requirements
- Tweak an API test
- Bump version of roxygen2

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
