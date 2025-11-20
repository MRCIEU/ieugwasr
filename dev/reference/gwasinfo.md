# Get list of studies with available GWAS summary statistics through API

Get list of studies with available GWAS summary statistics through API

## Usage

``` r
gwasinfo(id = NULL, opengwas_jwt = get_opengwas_jwt(), ...)
```

## Arguments

- id:

  List of OpenGWAS IDs to retrieve. If `NULL` (default) retrieves all
  available datasets

- opengwas_jwt:

  Used to authenticate protected endpoints. Login to
  <https://api.opengwas.io> to obtain a jwt. Provide the jwt string
  here, or store in .Renviron under the keyname OPENGWAS_JWT.

- ...:

  Unused, for extensibility

## Value

Dataframe of details for all available studies
