# Query specific variants from specific GWAS

Every rsid is searched for against each requested GWAS id. To get a list
of available GWAS ids, or to find their meta data, use
[`gwasinfo`](https://mrcieu.github.io/ieugwasr/dev/reference/gwasinfo.md).
Can request LD proxies for instances when the requested rsid is not
present in a particular GWAS dataset. This currently only uses an LD
reference panel composed of Europeans in 1000 genomes version 3. It is
also restricted to biallelic single nucleotide polymorphisms (no
indels), with European MAF \> 0.01.

## Usage

``` r
associations(
  variants,
  id,
  proxies = 1,
  r2 = 0.8,
  align_alleles = 1,
  palindromes = 1,
  maf_threshold = 0.3,
  opengwas_jwt = get_opengwas_jwt(),
  assocs_per_request = 64,
  max_ids_per_request = 10,
  ...
)
```

## Arguments

- variants:

  Array of variants e.g. `c("rs234", "7:105561135-105563135")`

- id:

  Array of GWAS studies to query. See
  [`gwasinfo`](https://mrcieu.github.io/ieugwasr/dev/reference/gwasinfo.md)
  for available studies

- proxies:

  `0` or (default) `1` - indicating whether to look for proxies

- r2:

  Minimum proxy LD rsq value. Default=`0.8`

- align_alleles:

  Try to align tag alleles to target alleles (if `proxies = 1`). `1` =
  yes (default), `0` = no

- palindromes:

  Allow palindromic SNPs (if `proxies = 1`). `1` = yes (default), `0` =
  no

- maf_threshold:

  MAF threshold to try to infer palindromic SNPs. Default = `0.3`.

- opengwas_jwt:

  Used to authenticate protected endpoints. Login to
  <https://api.opengwas.io> to obtain a jwt. Provide the jwt string
  here, or store in .Renviron under the keyname OPENGWAS_JWT.

- assocs_per_request:

  Number of associations to request per API call. Default=64 to avoid
  query being rejected by the API.

- max_ids_per_request:

  Maximum number of IDs to query per API call. Default=10 to avoid
  timeouts.

- ...:

  Unused, for extensibility

## Value

Dataframe
