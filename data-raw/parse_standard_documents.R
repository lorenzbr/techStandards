files <- list.files(system.file("extdata/etsi_examples", package = "techStandards"), pattern = "pdf", full.names = TRUE)
documents <- basename(files)

# file <- files[1]
# parse_standard_doc(file, path = "inst/extdata/etsi_examples", sso = "ETSI", overwrite = TRUE)

parse_standard_docs(path = "inst/extdata/etsi_examples", sso = "ETSI", overwrite = TRUE)
