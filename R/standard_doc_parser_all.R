#' Parse all standard documents
#' 
#' Parses all standard documents and gets the full text for each section. The parsed tables of contents are stored as csv's.
#' 
#' @usage standard_doc_parser_all(path, sso = NULL, doc.type = "pdf", print = TRUE)
#' @param path A string containing the path of the standard document.
#' @param sso A string containing the acronym of a standard-setting organization (\emph{IEEE}, \emph{ETSI} or \emph{ITU-T}).
#' @param doc.type A string containing the document type. Should be \emph{pdf}.
#' @param print A logical. If \code{TRUE} messages are printed.
#' 
#' @export
standard_doc_parser_all <- function(path, sso = NULL, doc.type = "pdf", print = TRUE) {
  
  ## Parse all standard documents in path
  
  files <- list.files(path, pattern = paste0(".", doc.type, "$"), full.names = TRUE)
  
  mapply(standard_doc_parser, files, MoreArgs = list(path, sso, doc.type, print))
  
  if (print) return(message("Parsing completed!"))
  
}