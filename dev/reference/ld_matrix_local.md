# Get LD matrix using local plink binary and reference dataset

Get LD matrix using local plink binary and reference dataset

## Usage

``` r
ld_matrix_local(variants, bfile, plink_bin, with_alleles = TRUE)
```

## Arguments

- variants:

  List of variants (rsids)

- bfile:

  Path to bed/bim/fam ld reference panel

- plink_bin:

  Specify path to plink binary. Default = `NULL`. See
  <https://github.com/MRCIEU/genetics.binaRies> for convenient access to
  plink binaries

- with_alleles:

  Whether to append the allele names to the SNP names. Default: `TRUE`

## Value

data frame
