# Get meta information on ETSI standard documents from: https://www.etsi.org/standards
# Select subsample of 10 standard documents
etsi_standards_meta <- etsi_standards_meta[sample.int(nrow(etsi_standards_meta), 10), ]
save(etsi_standards_meta, file = "data/etsi_standards_meta.rda")
