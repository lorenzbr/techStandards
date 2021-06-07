#' Parse standard documents
#' 
#' Parses standard documents and gets the full text for each section. The parsed tables of contents are stored as csv's.
#' 
#' @usage parse_standard_docs(path, sso = NULL, doc.type = "pdf", 
#'                     overwrite = FALSE, encoding = "UTF-8", print = TRUE)
#' @param path A string containing the path of the parsed standard document.
#' @param sso A string containing the acronym of a standard-setting organization (\emph{IEEE}, \emph{ETSI} or \emph{ITU-T}).
#' @param doc.type A string containing the document type. Should be \emph{pdf}.
#' @param overwrite A logical indicating whether to overwrite existing data.
#' @param encoding Encoding of the input document. Default is \emph{UTF-8}. The encoding is converted to \emph{UTF-8}.
#' @param print A logical. If \code{TRUE} messages are printed.
#' 
#' @seealso \code{\link{parse_standard_doc}}
#' 
#' @export
parse_standard_docs <- function(path, sso = NULL, doc.type = "pdf", overwrite = FALSE, encoding = "UTF-8", print = TRUE) {
  
  files <- list.files(path, pattern = paste0(".", doc.type, "$"), full.names = TRUE)
  
  mapply(parse_standard_doc, files, MoreArgs = list(path, sso, doc.type, overwrite, encoding, print))
  
  if (print) return(message("Parsing completed!"))
  
}