#' Converter for gwasglue2 system variant IDs
#' 
#' @param afl2_list A `ieugwasr::afl2_list()` dataframe
#' @return The same dataframe with the gwasglue2 variant IDs added
#' @export 
convert_variantid <- function(afl2_list){
  chr <- afl2_list$chr
  pos <- afl2_list$pos
  a1 <- afl2_list$alt
  a2 <- afl2_list$ref
  # NOTE: It is indifferently if "alt" and "ref" are "a1" or "a2". The function will sort them alphabetically.
  
  # variantid <-  gwasglue2::create_variantid(chr,pos,a1,a2)
  variantid <-  create_variantid(chr,pos,a1,a2)

  afl2_list[,"variantid"] <- variantid 
  return(afl2_list)
}


#' LD scores writer
#' The LD scores are saved in compressed `.gz`files, split by chromosome name.
#' @param afl2_list A `ieugwasr::afl2_list()` dataframe.
#' @param pop A string with the population name. Default is "EUR".
#' @param path_to_save A string with the path to save the  LD scores. Default is 'ldsc/population_name'. 
#' @export
#' @return A directory with the compressed LD scores files. Each file is named as the chromosome number, and contains the positions, variant IDs and LD scores.
write_ldscores <- function(afl2_list, pop = "EUR", path_to_save = paste0("ldsc/",pop)){
  
  # Check if there is a valid population name
  pops <- c("AFR", "AMR", "EAS", "EUR", "SAS")
  if (!(pop %in% pops)){
    stop("The population name is not valid. Please use one of the following: AFR, AMR, EAS, EUR, SAS")
  }

  # check if variantid is present
  if (!"variantid" %in% colnames(afl2_list)){
    afl2_list <- convert_variantid(afl2_list)
  }
  
  # Create a directory to save the ldscores
  if (path_to_save == path_to_save){
    dir.create(pop, showWarnings = FALSE)
  } else{
    dir.create(path_to_save, showWarnings = FALSE)}
  

  # subset the ldscores to only include the columns we need
   split_ldscores <-   afl2_list[, c("chr", "variantid","pos", paste0("L2.",pop))] %>%
            # rename the columns to match the  GenomicSEM format
            dplyr::rename("BP" = "pos", "SNP" = "variantid", "L2" = paste0("L2.",pop)) %>%
            # Split the ldscores by chromosome
            split(., .$chr)
  # number of chromosomes
  chr <- length(split_ldscores)
  # Write the ldscores to the directory
  for (i in 1:chr){
    readr::write_delim(split_ldscores[[i]], paste0(path_to_save,"/", i, ".l2.ldscore.gz"))
  }
}


#  This function is a copy of the `gwasglue2::create_variantid()` function, because the gwasglue2 package is not exporting the function. When the gwasglue2 package is fixed, this function should be removed.
create_variantid <-function(chr,pos,a1,a2) {
  alleles_sorted <- t(apply(cbind(a1,a2),1,sort)) 
  #  create variantid
  variantid <- paste0(chr,":", pos,"_",alleles_sorted[,1],"_",alleles_sorted[,2])

  # create hashes when alleles nchar > 10
  # allele ea
   if (all(nchar(alleles_sorted[,1]) <= 10) == FALSE){
    index = which(nchar(alleles_sorted[,1]) > 10)
    variantid[index] <- lapply(index, function(i){
      v <- paste0(chr[i],":", pos[i],"_#",digest::digest(alleles_sorted[i,1],algo= "murmur32"),"_",alleles_sorted[i,2],) 
    }) %>% unlist()
  }

  # allele nea
  if (all(nchar(alleles_sorted[,2]) <= 10) == FALSE){
    index = which(nchar(alleles_sorted[,2]) > 10)
    variantid[index] <- lapply(index, function(i){
      v <- paste0(chr[i],":", pos[i],"_",alleles_sorted[i,1],"_#",digest::digest(alleles_sorted[i,2],algo= "murmur32")) 
    }) %>% unlist()
  }
  
  return(variantid)
  }