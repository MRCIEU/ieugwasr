# Obtain top hits from a GWAS dataset

By default performs clumping on the server side.

## Usage

``` r
tophits(
  id,
  pval = 5e-08,
  clump = 1,
  r2 = 0.001,
  kb = 10000,
  pop = "EUR",
  force_server = FALSE,
  opengwas_jwt = get_opengwas_jwt(),
  ...
)
```

## Arguments

- id:

  Array of GWAS studies to query. See
  [`gwasinfo`](https://mrcieu.github.io/ieugwasr/dev/reference/gwasinfo.md)
  for available studies

- pval:

  use this p-value threshold. Default = `5e-8`

- clump:

  whether to clump (`1`) or not (`0`). Default = `1`

- r2:

  use this clumping r2 threshold. Default is very strict, `0.001`

- kb:

  use this clumping kb window. Default is very strict, `10000`

- pop:

  Super-population to use as reference panel. Default = `"EUR"`. Options
  are `"EUR"`, `"SAS"`, `"EAS"`, `"AFR"`, `"AMR"`

- force_server:

  Logical. By default will return preclumped hits. p-value threshold
  5e-8, with r2 threshold 0.001 and kb threshold 10000, using only SNPs
  with MAF \> 0.01 in the European samples in 1000 genomes. If
  force_server = `TRUE` then will recompute using server side LD
  reference panel.

- opengwas_jwt:

  Used to authenticate protected endpoints. Login to
  <https://api.opengwas.io> to obtain a jwt. Provide the jwt string
  here, or store in .Renviron under the keyname OPENGWAS_JWT.

- ...:

  Unused, for extensibility

## Value

Dataframe
