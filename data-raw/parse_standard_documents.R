files <- list.files(system.file("extdata/etsi_examples", package = "techStandards"), pattern = "pdf", full.names = TRUE)
documents <- basename(files)

input.path <- "inst/extdata/etsi_examples"
output.path <- input.path

# file <- files[1]
# parse_standard_doc(file, output.path, sso = "ETSI", overwrite = TRUE)

parse_standard_docs(input.path, output.path, sso = "ETSI", overwrite = TRUE)
