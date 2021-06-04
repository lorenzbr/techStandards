#' Initialize standard document parser, create files and folders
#' @noRd
init_standard_doc_parser <- function (path, create.new.files = FALSE) {
  
  ## output paths
  output.path.ch.txt <- paste0(gsub("/$", "", path), "_ch_txt/")
  output.path.toc <- paste0(gsub("/$", "", path), "_toc/")
  
  ## create folders if not exists
  dir.create(output.path.ch.txt, recursive = TRUE)
  dir.create(output.path.toc, recursive = TRUE)
  
  ## create new files (files will be overwritten)
  if (create.new.files) {
    
    ## empty log.txt
    err.msg.colnam <- c("timestamp", "a_filename", "nb_pages", "nb_pages_with_content", "error_message", "original_error_message")
    df <- data.frame(matrix(ncol = 6, nrow = 0))
    names(df) <- err.msg.colnam
    utils::write.table(df, file.path(dirname(path), "log.txt"), append = FALSE, row.names = FALSE, col.names = TRUE, sep = ";")
    rm(df)
    
    ## empty parsed_documents.txt
    utils::write.table("Parsed_documents", file.path(dirname(path), "parsed_documents.txt"), append = FALSE, col.names = FALSE, row.names = FALSE)
    
  }
  
}
