# Perform fast phewas of a specific variants against all available GWAS datasets

This is faster than doing it manually through
[`associations`](https://mrcieu.github.io/ieugwasr/dev/reference/associations.md)

## Usage

``` r
phewas(
  variants,
  pval = 1e-05,
  batch = c(),
  opengwas_jwt = get_opengwas_jwt(),
  ...
)
```

## Arguments

- variants:

  Array of variants e.g. `c("rs234", "7:105561135-105563135")`

- pval:

  p-value threshold. Default = `0.00001`

- batch:

  Vector of batch IDs to search across. If
  [`c()`](https://rdrr.io/r/base/c.html) (default) then returns all
  batches

- opengwas_jwt:

  Used to authenticate protected endpoints. Login to
  <https://api.opengwas.io> to obtain a jwt. Provide the jwt string
  here, or store in .Renviron under the keyname OPENGWAS_JWT.

- ...:

  Unused, for extensibility

## Value

Dataframe
