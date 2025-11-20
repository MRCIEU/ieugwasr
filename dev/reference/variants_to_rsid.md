# Convert mixed array of rsid and chrpos to list of rsid

Convert mixed array of rsid and chrpos to list of rsid

## Usage

``` r
variants_to_rsid(variants, opengwas_jwt = get_opengwas_jwt(), ...)
```

## Arguments

- variants:

  Array of variants e.g. `c("rs234", "7:105561135-105563135")`

- opengwas_jwt:

  Used to authenticate protected endpoints. Login to
  <https://api.opengwas.io> to obtain a jwt. Provide the jwt string
  here, or store in .Renviron under the keyname OPENGWAS_JWT.

- ...:

  Additional arguments passed to API.

## Value

list of rsids
