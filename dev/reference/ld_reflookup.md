# Check which rsids are present in a remote LD reference panel

Provide a list of rsids that you may want to perform LD operations on to
check if they are present in the LD reference panel. If they are not
then some functions e.g.
[`ld_clump`](https://mrcieu.github.io/ieugwasr/dev/reference/ld_clump.md)
will exclude them from the analysis, so you may want to consider how to
handle those variants in your data.

## Usage

``` r
ld_reflookup(rsid, pop = "EUR", opengwas_jwt = get_opengwas_jwt(), ...)
```

## Arguments

- rsid:

  Array of rsids to check

- pop:

  Super-population to use as reference panel. Default = `"EUR"`. Options
  are `"EUR"`, `"SAS"`, `"EAS"`, `"AFR"`, `"AMR"`

- opengwas_jwt:

  Used to authenticate protected endpoints. Login to
  <https://api.opengwas.io> to obtain a jwt. Provide the jwt string
  here, or store in .Renviron under the keyname OPENGWAS_JWT.

- ...:

  Additional arguments passed to
  [`api_query()`](https://mrcieu.github.io/ieugwasr/dev/reference/api_query.md).

## Value

Array of rsids that are present in the LD reference panel
