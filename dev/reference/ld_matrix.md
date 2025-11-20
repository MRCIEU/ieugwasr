# Get LD matrix for list of SNPs

This function takes a list of SNPs and searches for them in a specified
super-population in the 1000 Genomes phase 3 reference panel. It then
creates an LD matrix of r values (signed, and not squared). All LD
values are with respect to the major alleles in the 1000G dataset. You
can specify whether the allele names are displayed.

## Usage

``` r
ld_matrix(
  variants,
  with_alleles = TRUE,
  pop = "EUR",
  opengwas_jwt = get_opengwas_jwt(),
  bfile = NULL,
  plink_bin = NULL,
  ...
)
```

## Arguments

- variants:

  List of variants (rsids)

- with_alleles:

  Whether to append the allele names to the SNP names. Default: `TRUE`

- pop:

  Super-population to use as reference panel. Default = `"EUR"`. Options
  are `"EUR"`, `"SAS"`, `"EAS"`, `"AFR"`, `"AMR"`. `'legacy'` also
  available - which is a previously used version of the EUR panel with a
  slightly different set of markers

- opengwas_jwt:

  Used to authenticate protected endpoints. Login to
  <https://api.opengwas.io> to obtain a jwt. Provide the jwt string
  here, or store in .Renviron under the keyname OPENGWAS_JWT.

- bfile:

  If this is provided then will use the API. Default = `NULL`

- plink_bin:

  If `NULL` and bfile is not `NULL` then will detect packaged plink
  binary for specific OS. Otherwise specify path to plink binary.
  Default = `NULL`

- ...:

  Additional arguments passed to `ld_matrix_api()`.

## Value

Matrix of LD r values

## Details

The data used for generating the LD matrix includes only bi-allelic SNPs
with MAF \> 0.01, so it's quite possible that a variant you want to
include will be absent. If it is absent, it will be automatically
excluded from the results.

You can check if your variants are present in the LD reference panel
using
[`ld_reflookup()`](https://mrcieu.github.io/ieugwasr/dev/reference/ld_reflookup.md)

This function does put load on the OpenGWAS servers, which makes life
more difficult for other users, and has been limited to analyse only up
to 500 variants at a time. We have implemented a method and made
available the LD reference panels to perform the operation locally, see
`ld_matrix()` and related vignettes for details.
