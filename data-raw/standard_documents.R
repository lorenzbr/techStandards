files <- list.files(system.file("extdata/etsi_examples", package = "techStandards"), pattern = "pdf", full.names = TRUE)
documents <- basename(files)

# document <- documents[1]
# parse_standard_doc(document, path, sso, overwrite = TRUE)

parse_standard_docs(path = "inst/extdata/etsi_examples", sso = "ETSI", doc.type = "pdf", overwrite = TRUE, print = TRUE)
