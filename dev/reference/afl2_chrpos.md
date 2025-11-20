# Look up allele frequencies and LD scores for 1000 genomes populations by chrpos

Look up allele frequencies and LD scores for 1000 genomes populations by
chrpos

## Usage

``` r
afl2_chrpos(
  chrpos,
  reference = "1000g",
  opengwas_jwt = get_opengwas_jwt(),
  ...
)
```

## Arguments

- chrpos:

  list of `<chr>:<pos>` in build 37, e.g.
  `c("3:46414943", "3:122991235")`. Also allows ranges e.g
  `"7:105561135-105563135"`

- reference:

  Default=`"1000g"`

- opengwas_jwt:

  Used to authenticate protected endpoints. Login to
  <https://api.opengwas.io> to obtain a jwt. Provide the jwt string
  here, or store in .Renviron under the keyname OPENGWAS_JWT.

- ...:

  Additional arguments passed to
  [`api_query()`](https://mrcieu.github.io/ieugwasr/dev/reference/api_query.md).

## Value

Data frame containing ancestry specific LD scores and allele frequencies
for each variant
