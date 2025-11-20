# Package index

## All functions

- [`afl2_chrpos()`](https://mrcieu.github.io/ieugwasr/dev/reference/afl2_chrpos.md)
  : Look up allele frequencies and LD scores for 1000 genomes
  populations by chrpos
- [`afl2_list()`](https://mrcieu.github.io/ieugwasr/dev/reference/afl2_list.md)
  : Retrieve a allele frequency and LD scores for pre-defined lists of
  variants
- [`afl2_rsid()`](https://mrcieu.github.io/ieugwasr/dev/reference/afl2_rsid.md)
  : Look up allele frequencies and LD scores for 1000 genomes
  populations by rsid
- [`api_query()`](https://mrcieu.github.io/ieugwasr/dev/reference/api_query.md)
  : Wrapper for sending queries and payloads to API
- [`api_status()`](https://mrcieu.github.io/ieugwasr/dev/reference/api_status.md)
  : OpenGWAS server status
- [`associations()`](https://mrcieu.github.io/ieugwasr/dev/reference/associations.md)
  : Query specific variants from specific GWAS
- [`batch_from_id()`](https://mrcieu.github.io/ieugwasr/dev/reference/batch_from_id.md)
  : Extract batch name from study ID
- [`batches()`](https://mrcieu.github.io/ieugwasr/dev/reference/batches.md)
  : Get list of data batches in IEU OpenGWAS database
- [`check_access_token()`](https://mrcieu.github.io/ieugwasr/dev/reference/check_access_token.md)
  : Check if authentication has been made
- [`check_reset()`](https://mrcieu.github.io/ieugwasr/dev/reference/check_reset.md)
  : Check if OpenGWAS allowance needs to be reset
- [`editcheck()`](https://mrcieu.github.io/ieugwasr/dev/reference/editcheck.md)
  : Check datasets that are in process of being uploaded
- [`fill_n()`](https://mrcieu.github.io/ieugwasr/dev/reference/fill_n.md)
  : Look up sample sizes when meta data is missing from associations
- [`get_opengwas_jwt()`](https://mrcieu.github.io/ieugwasr/dev/reference/get_opengwas_jwt.md)
  : Retrieve OpenGWAS JSON Web Token from .Renviron file
- [`get_query_content()`](https://mrcieu.github.io/ieugwasr/dev/reference/get_query_content.md)
  : Parse out json response from httr object
- [`gwasinfo()`](https://mrcieu.github.io/ieugwasr/dev/reference/gwasinfo.md)
  : Get list of studies with available GWAS summary statistics through
  API
- [`gwasinfo_files()`](https://mrcieu.github.io/ieugwasr/dev/reference/gwasinfo_files.md)
  : Get list of download URLs for each file associated with a dataset
  through API
- [`infer_ancestry()`](https://mrcieu.github.io/ieugwasr/dev/reference/infer_ancestry.md)
  : Infer ancestry of GWAS dataset by matching against 1000 genomes
  allele frequencies
- [`ld_clump()`](https://mrcieu.github.io/ieugwasr/dev/reference/ld_clump.md)
  : Perform LD clumping on SNP data
- [`ld_clump_api()`](https://mrcieu.github.io/ieugwasr/dev/reference/ld_clump_api.md)
  : Perform clumping on the chosen variants using through API
- [`ld_clump_local()`](https://mrcieu.github.io/ieugwasr/dev/reference/ld_clump_local.md)
  : Wrapper for clump function using local plink binary and ld reference
  dataset
- [`ld_matrix()`](https://mrcieu.github.io/ieugwasr/dev/reference/ld_matrix.md)
  : Get LD matrix for list of SNPs
- [`ld_matrix_local()`](https://mrcieu.github.io/ieugwasr/dev/reference/ld_matrix_local.md)
  : Get LD matrix using local plink binary and reference dataset
- [`ld_reflookup()`](https://mrcieu.github.io/ieugwasr/dev/reference/ld_reflookup.md)
  : Check which rsids are present in a remote LD reference panel
- [`legacy_ids()`](https://mrcieu.github.io/ieugwasr/dev/reference/legacy_ids.md)
  : Convert current IDs to legacy IDs
- [`logging_info()`](https://mrcieu.github.io/ieugwasr/dev/reference/logging_info.md)
  : Details of how access token logs are used
- [`phewas()`](https://mrcieu.github.io/ieugwasr/dev/reference/phewas.md)
  : Perform fast phewas of a specific variants against all available
  GWAS datasets
- [`print(`*`<ApiStatus>`*`)`](https://mrcieu.github.io/ieugwasr/dev/reference/print.ApiStatus.md)
  : Print API status
- [`print(`*`<GwasInfo>`*`)`](https://mrcieu.github.io/ieugwasr/dev/reference/print.GwasInfo.md)
  : Print GWAS information
- [`select_api()`](https://mrcieu.github.io/ieugwasr/dev/reference/select_api.md)
  : Toggle API address between development and release
- [`set_reset()`](https://mrcieu.github.io/ieugwasr/dev/reference/set_reset.md)
  : Set the reset time for OpenGWAS allowance
- [`tophits()`](https://mrcieu.github.io/ieugwasr/dev/reference/tophits.md)
  : Obtain top hits from a GWAS dataset
- [`user()`](https://mrcieu.github.io/ieugwasr/dev/reference/user.md) :
  Get user details
- [`variants_chrpos()`](https://mrcieu.github.io/ieugwasr/dev/reference/variants_chrpos.md)
  : Obtain information about chr pos and surrounding region
- [`variants_gene()`](https://mrcieu.github.io/ieugwasr/dev/reference/variants_gene.md)
  : Obtain variants around a gene
- [`variants_rsid()`](https://mrcieu.github.io/ieugwasr/dev/reference/variants_rsid.md)
  : Obtain information about rsid
- [`variants_to_rsid()`](https://mrcieu.github.io/ieugwasr/dev/reference/variants_to_rsid.md)
  : Convert mixed array of rsid and chrpos to list of rsid
