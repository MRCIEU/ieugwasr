# Get LD matrix using local plink binary and reference dataset

Get LD matrix using local plink binary and reference dataset

## Usage

``` r
ld_matrix_local(
  variants,
  bfile,
  plink_bin,
  with_alleles = TRUE,
  tmpdir = tempdir(),
  threads = NULL,
  memory = NULL
)
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

- tmpdir:

  Directory in which to write the temporary files used by plink. Default
  = [`tempdir()`](https://rdrr.io/r/base/tempfile.html)

- threads:

  Number of threads plink may use, passed as `--threads`. Default =
  `NULL`, plink's own default (all available cores)

- memory:

  Memory in MiB plink may reserve, passed as `--memory`. Default =
  `NULL`, plink's own default (half the system's RAM)

## Value

data frame
