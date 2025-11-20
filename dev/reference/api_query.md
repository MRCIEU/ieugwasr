# Wrapper for sending queries and payloads to API

There are a number of different GET and POST endpoints in the GWAS
database API. This is a generic way to access them.

## Usage

``` r
api_query(
  path,
  query = NULL,
  opengwas_jwt = get_opengwas_jwt(),
  method = "GET",
  silent = TRUE,
  encode = "json",
  timeout = 300,
  override_429 = FALSE,
  x_api_source = paste0("ieugwasr/", utils::packageVersion("ieugwasr"))
)
```

## Arguments

- path:

  Either a full query path (e.g. for get) or an endpoint (e.g. for post)
  queries

- query:

  If post query, provide a list of arguments as the payload. `NULL` by
  default

- opengwas_jwt:

  Used to authenticate protected endpoints. Login to
  <https://api.opengwas.io> to obtain a jwt. Provide the jwt string
  here, or store in .Renviron under the keyname OPENGWAS_JWT.

- method:

  `"GET"` (default) or `"POST"`, `"DELETE"` etc

- silent:

  `TRUE`/`FALSE` to be passed to httr call. `TRUE` by default

- encode:

  Default = `"json"`, see
  [`httr::POST`](https://httr.r-lib.org/reference/POST.html) for options

- timeout:

  Default = `300`, avoid increasing this, preferentially simplify the
  query first.

- override_429:

  Default=`FALSE`. If allowance is exceeded then the query will error
  before submitting a request to avoid getting blocked. If you are sure
  you want to submit the request then set this to TRUE.

- x_api_source:

  Default = `paste0("ieugwasr/", utils::packageVersion("ieugwasr"))`.

## Value

httr response object
