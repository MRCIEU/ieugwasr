# ieugwasr 0.2.2
* Reinstating https://api.opengwas.org/api/ as the API server address
* Fixing issues with tests failing when server load is an issue

# ieugwasr 0.2.1
* Updating API server address temporarily
* Modifying tests to manage API server load
* Fixes to load/attach behaviour

# ieugwasr 0.2.0
* Moving API address to https://api.opengwas.org/api/
* Fixing issues for CRAN release

# ieugwasr 0.1.7
* Added functions to write LD scores files into compressed `.gz` files for each super-population and divided by chromosomes.
* Added argument to output [gwasglue2](https://mrcieu.github.io/gwasglue2/) objects in `ieugwasr::tophits()` and `ieugwasr::associations()`.

# ieugwasr 0.1.6
* Adding messaging about package version
* Adding messaging about OpenGWAS
# ieugwasr 0.1.5

* Added options to perform LD functions on different super-populations
* Catching 503 error codes and retrying up to 5 times. This should help avoid fails when the server is busy.

# ieugwasr 0.1.4

* Bug fixes in clumping. Thanks to [bethleegy](https://github.com/bethleegy) for pointing this out

# ieugwasr 0.1.3

* Bug fixes in clumping

# ieugwasr 0.1.2

* Updated API address

# ieugwasr 0.1.1

* Fixed bug in ld_clump - wasn't doing all traits

# ieugwasr 0.1.0

* First release in conjunction with API

# ieugwasr 0.0.0.9000

* Added a `NEWS.md` file to track changes to the package.
