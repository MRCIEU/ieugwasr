# Get list of data batches in IEU OpenGWAS database

Get list of data batches in IEU OpenGWAS database

## Usage

``` r
batches(opengwas_jwt = get_opengwas_jwt(), ...)
```

## Arguments

- opengwas_jwt:

  Used to authenticate protected endpoints. Login to
  <https://api.opengwas.io> to obtain a jwt. Provide the jwt string
  here, or store in .Renviron under the keyname OPENGWAS_JWT.

- ...:

  Unused, for extensibility

## Value

data frame
