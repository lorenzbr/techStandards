#' Download ETSI standard documents
#' 
#' Download ETSI standard documents from the ETSI standards database (\url{https://www.etsi.org/standards}) as PDFs
#' 
#' @usage download_etsi_standards(df, path = "")
#' @param df A data.frame containing at least two columns with the download link \emph{PDF.link} and the name of the standard \emph{ETSI.deliverable}. This data format can be downloaded from \url{https://www.etsi.org/standards}.
#' @param path A character string containing the path where to store the standard documents. Default is the current working directory.
#' 
#' @export
download_etsi_standards <- function(df, path = "") {
  
  mapply(df$PDF.link, FUN = utils::download.file,
         destfile = file.path(path, df$ETSI.deliverable, ".pdf", fsep = ""), 
         mode = 'wb')
  
}
