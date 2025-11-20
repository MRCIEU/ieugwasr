# Infer ancestry of GWAS dataset by matching against 1000 genomes allele frequencies

Uses ~20k SNPs selected for common frequency across 5 major super
populations

## Usage

``` r
infer_ancestry(d, snpinfo = NULL, opengwas_jwt = get_opengwas_jwt(), ...)
```

## Arguments

- d:

  Data frame containing at least `rsid` and `eaf` columns. e.g. output
  from associations

- snpinfo:

  Output from
  [`afl2_list`](https://mrcieu.github.io/ieugwasr/dev/reference/afl2_list.md),
  [`afl2_rsid`](https://mrcieu.github.io/ieugwasr/dev/reference/afl2_rsid.md)
  or
  [`afl2_chrpos`](https://mrcieu.github.io/ieugwasr/dev/reference/afl2_chrpos.md).
  If `NULL` then
  [`afl2_list()`](https://mrcieu.github.io/ieugwasr/dev/reference/afl2_list.md)
  is used by default

- opengwas_jwt:

  Used to authenticate protected endpoints. Login to
  <https://api.opengwas.io> to obtain a jwt. Provide the jwt string
  here, or store in .Renviron under the keyname OPENGWAS_JWT.

- ...:

  Additional arguments passed to
  [`afl2_list()`](https://mrcieu.github.io/ieugwasr/dev/reference/afl2_list.md)

## Value

data frame ordered by most likely ancestry, each row represents a super
population and cor column represents the correlation between the GWAS
dataset and the 1000 genomes super population allele frequencies
