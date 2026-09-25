# Wrapper for clump function using local plink binary and ld reference dataset

Wrapper for clump function using local plink binary and ld reference
dataset

## Usage

``` r
ld_clump_local(dat, clump_kb, clump_r2, clump_p, bfile, plink_bin)
```

## Arguments

- dat:

  Dataframe. Must have a variant name column (`variant`) and pval column
  called `pval`. If `id` is present then clumping will be done per
  unique id.

- clump_kb:

  Clumping kb window. Default is very strict, `10000`

- clump_r2:

  Clumping r2 threshold. Default is very strict, `0.001`

- clump_p:

  Clumping sig level for index variants. Default = `1` (i.e. no
  threshold)

- bfile:

  If this is provided then will use the API. Default = `NULL`

- plink_bin:

  Specify path to plink binary. Default = `NULL`. See
  <https://github.com/MRCIEU/genetics.binaRies> for convenient access to
  plink binaries

## Value

data frame of clumped variants
