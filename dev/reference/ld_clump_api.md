# Perform clumping on the chosen variants using through API

Perform clumping on the chosen variants using through API

## Usage

``` r
ld_clump_api(
  dat,
  clump_kb = 10000,
  clump_r2 = 0.1,
  clump_p,
  pop = "EUR",
  opengwas_jwt = get_opengwas_jwt(),
  ...
)
```

## Arguments

- dat:

  Dataframe. Must have a variant name column (`variant`) and pval column
  called `pval`. If `id` is present then clumping will be done per
  unique id.

- clump_kb:

  Clumping kb window. Default is very strict, `10000`

- clump_r2:

  Clumping r2 threshold. Default is very strict, `0.001`

- clump_p:

  Clumping sig level for index variants. Default = `1` (i.e. no
  threshold)

- pop:

  Super-population to use as reference panel. Default = `"EUR"`. Options
  are `"EUR"`, `"SAS"`, `"EAS"`, `"AFR"`, `"AMR"`

- opengwas_jwt:

  Used to authenticate protected endpoints. Login to
  <https://api.opengwas.io> to obtain a jwt. Provide the jwt string
  here, or store in .Renviron under the keyname OPENGWAS_JWT.

- ...:

  Additional arguments passed to
  [`api_query()`](https://mrcieu.github.io/ieugwasr/dev/reference/api_query.md).

## Value

Data frame of only independent variants
