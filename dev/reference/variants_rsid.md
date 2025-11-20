# Obtain information about rsid

Obtain information about rsid

## Usage

``` r
variants_rsid(rsid, opengwas_jwt = get_opengwas_jwt(), ...)
```

## Arguments

- rsid:

  Vector of rsids

- opengwas_jwt:

  Used to authenticate protected endpoints. Login to
  <https://api.opengwas.io> to obtain a jwt. Provide the jwt string
  here, or store in .Renviron under the keyname OPENGWAS_JWT.

- ...:

  Additional arguments passed to
  [`api_query()`](https://mrcieu.github.io/ieugwasr/dev/reference/api_query.md).

## Value

data frame
