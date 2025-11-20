# Look up sample sizes when meta data is missing from associations

Look up sample sizes when meta data is missing from associations

## Usage

``` r
fill_n(d, opengwas_jwt = get_opengwas_jwt(), ...)
```

## Arguments

- d:

  Output from
  [`associations`](https://mrcieu.github.io/ieugwasr/dev/reference/associations.md)

- opengwas_jwt:

  Used to authenticate protected endpoints. Login to
  <https://api.opengwas.io> to obtain a jwt. Provide the jwt string
  here, or store in .Renviron under the keyname OPENGWAS_JWT.

- ...:

  Unused, for extensibility

## Value

Updated version of d
