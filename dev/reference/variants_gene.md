# Obtain variants around a gene

Provide a gene identified, either Ensembl or Entrez

## Usage

``` r
variants_gene(gene, radius = 0, opengwas_jwt = get_opengwas_jwt(), ...)
```

## Arguments

- gene:

  Vector of genes, either Ensembl or Entrez, e.g.
  `c("ENSG00000123374", "ENSG00000160791")` or `1017`

- radius:

  Radius around the gene region to include. Default = `0`

- opengwas_jwt:

  Used to authenticate protected endpoints. Login to
  <https://api.opengwas.io> to obtain a jwt. Provide the jwt string
  here, or store in .Renviron under the keyname OPENGWAS_JWT.

- ...:

  Additional arguments passed to
  [`api_query()`](https://mrcieu.github.io/ieugwasr/dev/reference/api_query.md).

## Value

data frame with the following columns
