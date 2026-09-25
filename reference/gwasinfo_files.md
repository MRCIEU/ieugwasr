# Get list of download URLs for each file associated with a dataset through API

`gwasinfo_files()` returns a list of download URLs for each file
(.vcf.gz, .vcf.gz.tbi, \_report.html) associated with a dataset. The
URLs will expire in 2 hours. If a dataset is missing from the results,
that means either the dataset doesn't exist or you don't have access to
it. If a dataset is in the results but some/all links are missing, that
means the files are unavailable.

## Usage

``` r
gwasinfo_files(id, opengwas_jwt = get_opengwas_jwt(), ...)
```

## Arguments

- id:

  List of OpenGWAS IDs to retrieve.

- opengwas_jwt:

  Used to authenticate protected endpoints. Login to
  <https://api.opengwas.io> to obtain a JWT. Provide the JWT string
  here, or store in .Renviron under the keyname OPENGWAS_JWT.

- ...:

  Unused, for extensibility

## Value

Dataframe of details for requested studies
