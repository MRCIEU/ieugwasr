# Parse out json response from httr object

Parse out json response from httr object

## Usage

``` r
get_query_content(response)
```

## Arguments

- response:

  Output from
  [`api_query()`](https://mrcieu.github.io/ieugwasr/dev/reference/api_query.md)

## Value

Parsed json output from query, often in form of data frame. If status
code is not successful then return the actual response
