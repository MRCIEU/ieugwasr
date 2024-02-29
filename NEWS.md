# ieugwasr 0.1.6
* Added functions to write LD scores files into compressed `.gz` files for each super-population and divided by chromosomes.
* Added argument to output [gwasglue2](https://mrcieu.github.io/gwasglue2/) objects in `ieugwasr::tophits()` and `ieugwasr::associations()`.

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
