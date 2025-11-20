# Running local LD operations

We have tried to provide useful cloud-based functionality for many
operations, including relatively demanding LD operations. If you are
running a large number of LD operations, we request that you think about
performing those locally rather than through the API. We have tried to
write the software to enable this to work seamlessly. Some examples
below.

LD operations available on the OpenGWAS API

- LD clumping
- Generating LD matrices
- Looking for LD proxies

``` r
library(ieugwasr)
#> OpenGWAS updates:
#>   Date: 2024-05-17
#>   [>] OpenGWAS is growing!
#>   [>] Please take 2 minutes to give us feedback -
#>   [>] It will help directly shape our emerging roadmap
#>   [>] https://forms.office.com/e/eSr7EFAfCG
```

## LD clumping

The API has a wrapper around [plink version
1.90](https://www.cog-genomics.org/plink/1.9) and can use it to perform
clumping with an LD reference panel from 1000 genomes reference data.

``` r
a <- tophits(id="ieu-a-2", clump = 0)
b <- ld_clump(
    dplyr::tibble(rsid = a$rsid, pval = a$p, id = a$id)
)
```

There are 5 super-populations that can be requested via the `pop`
argument. By default this will use the Europeans subset (EUR
super-population). The reference panel has INDELs removed and only
retains SNPs with MAF \> 0.01 in the selected population.

Note that you can perform the same operation locally if you provide a
path to plink and a bed/bim/fam LD reference dataset.

To get a path to plink you can do the following:

``` r
remotes::install_github("MRCIEU/genetics.binaRies")
genetics.binaRies::get_plink_binary()
```

To get the same LD reference dataset that is used by the API, you can
download it directly from here:

<http://fileserve.mrcieu.ac.uk/ld/1kg.v3.tgz>

This contains an LD reference panel for each of the 5 super-populations
in the 1000 genomes reference dataset. e.g. for the European super
population it has the following files:

- `EUR.bed`
- `EUR.bim`
- `EUR.fam`

Now supposing in R you have a dataframe, `dat`, with the following
columns:

- `rsid`
- `pval`
- `trait_id`

to perform clumping, just do the following:

``` r
ld_clump(
    dplyr::tibble(rsid = dat$rsid, pval = dat$pval, id = dat$trait_id),
    plink_bin = genetics.binaRies::get_plink_binary(),
    bfile = "/path/to/reference/EUR"
)
```

## LD matrix

Similarly, a matrix of LD r values can be generated using

``` r
ld_matrix(b$variant)
```

This uses the API by default but is limited to only 500 variants. You
can use, instead, local plink and LD reference data in the same manner
as in the `ld_clump` function, e.g.

``` r
ieugwasr::ld_matrix(
    dat$rsid,
    plink_bin = genetics.binaRies::get_plink_binary(),
  bfile = "/path/to/reference/EUR"
)
```

## LD proxies

To automatically extract variants from a dataset, and search for LD
proxies when a requested variant is not present in the dataset, please
look at the options available in the
[gwasvcf](https://mrcieu.github.io/gwasvcf/) package:

<https://mrcieu.github.io/gwasvcf/articles/guide.html#ld-proxies-1>
