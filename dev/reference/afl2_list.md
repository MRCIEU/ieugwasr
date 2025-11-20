# Retrieve a allele frequency and LD scores for pre-defined lists of variants

Data frame includes 1000 genomes metadata including sample sizes, allele
frequency and LD score, separated by 5 super populations (EUR =
European, AFR = African, EAS = East Asian, AMR = Admixed American, SAS =
South Asian)

## Usage

``` r
afl2_list(variantlist = "reduced", opengwas_jwt = get_opengwas_jwt(), ...)
```

## Arguments

- variantlist:

  Choose pre-defined list. `"reduced"` = ~20k SNPs that are common in
  all super populations (default). `"hapmap3"` = ~1.3 million hm3 SNPs

- opengwas_jwt:

  Used to authenticate protected endpoints. Login to
  <https://api.opengwas.io> to obtain a jwt. Provide the jwt string
  here, or store in .Renviron under the keyname OPENGWAS_JWT.

- ...:

  Additional arguments passed to
  [`api_query()`](https://mrcieu.github.io/ieugwasr/dev/reference/api_query.md).

## Value

Data frame containing ancestry specific LD scores and allele frequencies
for each variant
