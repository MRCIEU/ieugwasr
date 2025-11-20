# Perform fast queries against a massive database of complete GWAS summary data

The [OpenGWAS database](https://gwas.mrcieu.ac.uk/) comprises over
50,000 curated, QC’d and harmonised complete GWAS summary datasets and
can be queried using an API. See [here](https://api.opengwas.io/api/)
for documentation on the API itself. This R package is a wrapper to make
generic calls to the API, plus convenience functions for specific
queries.

## Authentication

From 1st May 2024, most queries to the OpenGWAS API will require user
authentication. For more information on why this is necessary, see this
[blog post](https://blog.opengwas.io/posts/user-auth-spring-2024/).

To authenticate, you need to generate a token from the OpenGWAS website.
The token behaves like a password, and it will be used to authorise the
requests you make to the OpenGWAS API. Here are the steps to generate
the token and then have `ieugwasr` automatically use it for your
queries:

1.  Login to <https://api.opengwas.io/profile/>
2.  Generate a new token
3.  Add `OPENGWAS_JWT=<token>` to your `.Renviron` file. This file could
    be either in your home directory or in the working directory of your
    R session. You can check the location of your `.Renviron` file by
    running `Sys.getenv("R_ENVIRON_USER")` in R.
4.  Restart your R session
5.  To check that your token is being recognised, run
    [`ieugwasr::get_opengwas_jwt()`](https://mrcieu.github.io/ieugwasr/dev/reference/get_opengwas_jwt.md).
    If it returns a long random string then you are authenticated.
6.  To check that your token is working, run
    [`user()`](https://mrcieu.github.io/ieugwasr/dev/reference/user.md).
    It will make a request to the API for your user information using
    your token. It should return a list with your user information. If
    it returns an error, then your token is not working.

Now any query to OpenGWAS will automatically include your token to
authorise the request.

**IMPORTANT NOTE**: Do not share this token with others as it is
equivalent to a password. If you think your token has been compromised,
you can generate a new one from the OpenGWAS website.

### Deprecated Google authentication

Note that previously we used Google OAuth2 for authentication, in order
for users to access private datasets to which they had specific access.
This authentication method is no longer supported, and all users should
now use the JWT token method described above. You can delete the
`ieugwasr_oauth2` directory as it will no longer be needed.

### Allowance

Due to very high usage, we have had to limit the number of queries that
can be made in a given time period. Every user has an allowance that is
reset periodically, and is used based on the queries that you submit. If
this is posing an issue do get in touch and we can discuss how to manage
this. See here for full details on the allowance system:
<https://api.opengwas.io/api/#allowance>.

## General API queries

The API has a number of endpoints documented
[here](https://api.opengwas.io/api/). A general way to access them in R
is using the `api_query` function. There are two types of endpoints -
`GET` and `POST`.

- `GET` - you provide a single URL which includes the endpoint and
  query. For example, for the `association` endpoint you can obtain some
  rsids in some studies, e.g.

  ``` r
  api_query("associations/ieu-a-2,ieu-a-7/rs234,rs123")
  ```

- `POST` - Here you send a “payload” to the endpoint. So, the path
  specifies the endpoint and you add a list of query specifications.
  This is useful for long lists of rsids being queried, for example

  ``` r
  api_query("associations", query = list(rsid = c("rs234", "rs123"), id = c("ieu-a-2", "ieu-a-7")))
  ```

The `api_query` function returns a `response` object from the `httr`
package. See below for a list of functions that make the input and
output to `api_query` more convenient.

## Get API status

``` r
library(ieugwasr)
api_status()
```

## Get list of all available studies

``` r
gwasinfo()
```

## Get list of a specific study

``` r
gwasinfo("ieu-a-2")
```

## Extract particular associations from particular studies

Provide a list of variants to be obtained from a list of studies:

``` r
associations(variants = c("rs123", "7:105561135"), id = c("ieu-a-2", "ieu-a-7"))
```

By default this will look for LD proxies using 1000 genomes reference
data (Europeans only, the reference panel has INDELs removed and only
retains SNPs with MAF \> 0.01). This behaviour can be turned off using
`proxies=0` as an argument.

Note that the queries are performed on rsids, but chromosome:position
values will be automatically converted. A range query can be done using
e.g.

``` r
associations(variants = "7:105561135-105563135", id = c("ieu-a-2"), proxies = 0)
```

## Get the tophits from a study

The tophits can be obtained using

``` r
tophits(id = "ieu-a-2")
```

Note that it will perform strict clumping by default (r2 = 0.001 and
radius = 10000kb). This can be turned off with `clump=0`.

## Perform PheWAS

Lookup association of specified variants across every study, returning
at a particular threshold. Note that no LD proxy lookups are made here.

``` r
phewas(variants = "rs1205", pval = 1e-5)
```

PheWAS can also be performed in only specific subsets of the data. The
datasets in the OpenGWAS database are organised by batch, you can see
info about it here: <https://gwas.mrcieu.ac.uk/datasets/> or get a list
of batches and their descriptions using:

``` r
batches()
```

You can perform PheWAS in only specified batches using:

``` r
phewas(variants = "rs1205", pval = 1e-5, batch = c('ieu-a', 'ukb-b'))
```

By default PheWAS is performed in all batches (which is of course
somewhat slower).

## LD clumping

The API has a wrapper around [plink version
1.90](https://www.cog-genomics.org/plink/1.9) and can use it to perform
clumping with an LD reference panel from 1000 genomes reference data.

``` r
a <- tophits(id = "ieu-a-2", clump = 0)
b <- ld_clump(
    dplyr::tibble(rsid = a$rsid, pval = a$p, id = a$id)
)
```

There are 5 super-populations that can be requested via the `pop`
argument. By default this will use the Europeans subset (EUR
super-population). The reference panel has INDELs removed and only
retains SNPs with MAF \> 0.01 in the selected population.

Note that you can perform the same operation locally if you provide a
path to plink and a bed/bim/fam LD reference dataset. e.g.

``` r
ld_clump(
    dplyr::tibble(rsid = a$rsid, pval = a$p, id = a$id),
    plink_bin = "/path/to/plink",
    bfile = "/path/to/reference_data"
)
```

See the following vignette for more information: [Running local LD
operations](https://mrcieu.github.io/ieugwasr/dev/articles/local_ld.md)

## LD matrix

Similarly, a matrix of LD r values can be generated using

``` r
ld_matrix(b$variant)
```

This uses the API by default but is limited to only 500 variants. You
can use, instead, local plink and LD reference data in the same manner
as in the `ld_clump` function, e.g.

``` r
ld_matrix(b$variant, plink_bin = "/path/to/plink", bfile = "/path/to/reference_data")
```

There are 5 super-populations that can be requested via the `pop`
argument. By default this will use the Europeans subset (EUR
super-population). The reference panel has INDELs removed and only
retains SNPs with MAF \> 0.01 in the selected population.

Super-populations:

- EUR = European
- EAS = East Asian
- AMR = Admixed American
- SAS = South Asian
- AFR = African

See the following vignette for more information: [Running local LD
operations](https://mrcieu.github.io/ieugwasr/dev/articles/local_ld.md)

## Variant information

Translating between rsids and chromosome:position, while also getting
other information, can be achieved.

The `chrpos` argument can accept the following

- `<chr>:<position>`
- `<chr>:<start>-<end>`

For example

``` r
a <- variants_chrpos(c("7:105561135-105563135", "10:44865737"))
```

This provides a table with dbSNP variant IDs, gene info, and various
other metadata. Similar data can be obtained from searching by rsid

``` r
b <- variants_rsid(c("rs234", "rs333"))
```

And a list of variants within a particular gene region can also be
found. Provide a ensembl or entrez gene ID (e.g. ENSG00000123374 or
1017) to the following:

``` r
c <- variants_gene("ENSG00000123374")
```

## Extracting GWAS summary data based on gene region

Here is an example of how to obtain summary data for some datasets for a
gene region. As an example, we’ll extract CDK2 (HGNC number 1017) from a
BMI dataset (ieu-a-2)

Use the
[mygene](https://bioconductor.org/packages/release/bioc/html/mygene.html)
bioconductor package to query the [mygene.info](https://mygene.info/)
API.

``` r
library(mygene)
a <- mygene::getGene("1017", fields = "genomic_pos_hg19")
r <- paste0(a[[1]]$genomic_pos_hg19$chr, ":", a[[1]]$genomic_pos_hg19$start, "-", a[[1]]$genomic_pos_hg19$end)
b <- ieugwasr::associations(r, "ieu-a-2")
```

## 1000 genomes annotations

The OpenGWAS database contains a database of population annotations from
the 1000 genomes project - the alternative allele frequencies and the LD
scores for each variant, calculated for each super population
separately. Only variants are present if they are MAF \> 1% in at least
one super population. You can access this info in different ways

1.  Look up a particular set of rsids

    ``` r
    afl2_rsid(c("rs234", "rs123"))
    ```

2.  Look up a set of positions or regions

    ``` r
    afl2_chrpos("1:100000-900000")
    ```

3.  Extract annotations for a list of 20k variants that are common in
    all super populations, and evenly spaced across the genome

    ``` r
    afl2_list()
    ```

4.  Extract annotations for a 1.3 million HapMap3 variants

    ``` r
    afl2_list("hapmap3")
    ```

5.  Infer the ancestry of a particular study by comparing the allele
    frequencies with different super population reference frequencies

    ``` r
    snplist <- afl2_list()
    eur_example <- associations(snplist$rsid, "ieu-a-2")
    infer_ancestry(eur_example, snplist)
    eas_example <- associations(snplist$rsid, "bbj-a-10")
    infer_ancestry(eur_example, snplist)
    ```
