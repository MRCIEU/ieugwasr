# Perform LD clumping on SNP data

Uses PLINK clumping method, where SNPs in LD within a particular window
will be pruned. The SNP with the lowest p-value is retained.

## Usage

``` r
ld_clump(
  dat = NULL,
  clump_kb = 10000,
  clump_r2 = 0.001,
  clump_p = 0.99,
  pop = "EUR",
  opengwas_jwt = get_opengwas_jwt(),
  bfile = NULL,
  plink_bin = NULL,
  ...
)
```

## Arguments

- dat:

  Dataframe. Must have a variant name column (`rsid`) and pval column
  called `pval`. If `id` is present then clumping will be done per
  unique id.

- clump_kb:

  Clumping kb window. Default is very strict, `10000`

- clump_r2:

  Clumping r2 threshold. Default is very strict, `0.001`

- clump_p:

  Clumping sig level for index variants. Default = `1` (i.e. no
  threshold)

- pop:

  Super-population to use as reference panel. Default = `"EUR"`. Options
  are `"EUR"`, `"SAS"`, `"EAS"`, `"AFR"`, `"AMR"`. `'legacy'` also
  available - which is a previously used version of the EUR panel with a
  slightly different set of markers

- opengwas_jwt:

  Used to authenticate protected endpoints. Login to
  <https://api.opengwas.io> to obtain a jwt. Provide the jwt string
  here, or store in .Renviron under the keyname OPENGWAS_JWT.

- bfile:

  If this is provided then will use the API. Default = `NULL`

- plink_bin:

  If `NULL` and `bfile` is not `NULL` then will detect packaged plink
  binary for specific OS. Otherwise specify path to plink binary.
  Default = `NULL`,

- ...:

  Additional arguments passed to
  [`ld_clump_local()`](https://mrcieu.github.io/ieugwasr/dev/reference/ld_clump_local.md).

## Value

Data frame

## Details

This function interacts with the OpenGWAS API, which houses LD reference
panels for the 5 super-populations in the 1000 genomes reference panel.
It includes only bi-allelic SNPs with MAF \> 0.01, so it's quite
possible that a variant you want to include in the clumping process will
be absent. If it is absent, it will be automatically excluded from the
results.

You can check if your variants are present in the LD reference panel
using
[`ld_reflookup()`](https://mrcieu.github.io/ieugwasr/dev/reference/ld_reflookup.md).

This function does put load on the OpenGWAS servers, which makes life
more difficult for other users. We have implemented a method and made
available the LD reference panels to perform clumping locally, see
`ld_clump()` and related vignettes for details.
