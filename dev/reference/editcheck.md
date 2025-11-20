# Check datasets that are in process of being uploaded

Check datasets that are in process of being uploaded

## Usage

``` r
editcheck(id, opengwas_jwt = get_opengwas_jwt(), ...)
```

## Arguments

- id:

  ID

- opengwas_jwt:

  Used to authenticate protected endpoints. Login to
  <https://api.opengwas.io> to obtain a jwt. Provide the jwt string
  here, or store in .Renviron under the keyname OPENGWAS_JWT.

- ...:

  Unused, for extensibility

## Value

Dataframe
