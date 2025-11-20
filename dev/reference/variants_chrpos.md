# Obtain information about chr pos and surrounding region

For a list of chromosome and positions, finds all variants within a
given radius

## Usage

``` r
variants_chrpos(chrpos, radius = 0, opengwas_jwt = get_opengwas_jwt(), ...)
```

## Arguments

- chrpos:

  list of `<chr>:<pos>` in build 37, e.g.
  `c("3:46414943", "3:122991235")`. Also allows ranges e.g.
  `"7:105561135-105563135"`

- radius:

  Radius around each chrpos, default = `0`

- opengwas_jwt:

  Used to authenticate protected endpoints. Login to
  <https://api.opengwas.io> to obtain a jwt. Provide the jwt string
  here, or store in .Renviron under the keyname OPENGWAS_JWT.

- ...:

  Additional arguments passed to
  [`api_query()`](https://mrcieu.github.io/ieugwasr/dev/reference/api_query.md).

## Value

Data frame
