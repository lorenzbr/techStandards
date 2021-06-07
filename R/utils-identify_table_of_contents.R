#' Identify start and end of table of contents
#' @noRd
identify_table_of_contents <- function(pdf, standard, nb.pages, nb.pages.with.content, path) {
  
  ## this gives the maximum element id: in all rows lower than this try to find the start of the table of contents
  ## because one would expect the table of contents to start at the beginning of a page
  max.element.id <- 10
  
  ## all keywords to try in order to identify the start line of the table of contents
  keywords <- c("tableofcontents", "contents", "content")
  
  startline.final <- c()
  
  for (keyword in keywords) {
    
    startline <- pdf$line_id[pdf$text_no_spaces == keyword & pdf$element_id < max.element.id]
    if ( Hmisc::all.is.numeric(startline) ) startline <- min(startline)
    if ( length(startline) == 0 ) rm(startline)
    if ( exists("startline") ) { if(startline == "Inf") { rm(startline) } }
    if ( exists("startline") ) startline.final <- c(startline.final, startline)
    if ( Hmisc::all.is.numeric(startline.final) ) startline.final <- min(startline.final)
    
  }
  
  startline <- startline.final
  if ( length(startline) == 0 ) rm(startline)
  if ( exists("startline") ) { if (startline == "Inf") { rm(startline)} }
  
  ## take only those startlines which appear at the very top of the page (i.e. among the first 10 lines)
  pdf.top.page <- pdf[pdf$element_id < max.element.id, ]
  
  ## if startline still not exists: identify startline if any row with dots exist
  if ( (nrow(pdf[grepl("\\.{4}([0-9]{1,2})$", pdf$text_no_spaces, perl = TRUE), ]) > 0) && !exists("startline") ) {
    
    ## get all rows which have dots in the line
    startline <- pdf.top.page$line_id[grepl("\\.{4}([0-9]{1,2})$", pdf.top.page$text_no_spaces, perl = TRUE)] - 1
    
    ## choose the minimum line_id as this is the beginning of the table of contents
    if ( Hmisc::all.is.numeric(startline) ) startline <- min(startline)
    if ( length(startline) == 0 ) rm(startline)
    if ( exists("startline") ) { if (startline == "Inf") { rm(startline) } }
    
  }
  
  
  ## identify endline if any row with dots exist where a number with 1 to 4 figures follows at the end
  if (nrow(pdf[grepl("\\.{4}([0-9]{1,4})$", pdf$text_no_spaces, perl = TRUE), ]) > 0) {
    
    ## get all rows which have dots and some number at the end of the line (HOW ROBUST IS THIS???)
    endline <- pdf$line_id[grepl("\\.{4}([0-9]{1,4})$", pdf$text_no_spaces, perl = TRUE)]
    
    ## remove all endlines which are smaller than startline
    if(exists("startline")) endline <- endline[endline > startline]
    
    ## vector to data.frame
    df.endline <- data.frame(endline)
    
    ## if startline exists but endline does not exist produce an error message
    if (nrow(df.endline) == 0) {
      df.err <- data.frame(timestamp = Sys.time(), standard, nb.pages, nb.pages.with.content, msg = "df.endline is empty.", error_orig = "")
      utils::write.table(df.err, file.path(dirname(path), "log.txt"), sep = ";", append = TRUE, row.names = FALSE, col.names = FALSE)
    }
    
    ## compute difference to the previous line
    df.endline$diff <- c(diff(df.endline$endline), 1)
    
    ## remove all entries where for the first time the difference to the previous line is larger than 30 lines
    if (any(df.endline$diff > 30)) {
      df.endline <- df.endline[df.endline$endline <= min(df.endline$endline[df.endline$diff > 30]), ]
    }
    
    endline <- df.endline$endline
    
    ## choose the maximum line_id because this is the end of the table of contents
    if (Hmisc::all.is.numeric(endline)) { endline <- max(endline) }
    if (length(endline) == 0) {rm(endline)}
    if (exists("endline")) { if(endline == "Inf") {rm(endline)} }
    
  }
  
  
  ## remove endline if startline is greater than endline because this would not make sense
  if ( exists("startline") & exists("endline") ) { if (startline > endline) { rm(endline) } }
  
  ## if endline exists but startline does not exist produce an error message 
  if ( !exists("startline") && exists("endline") ) {
    df.err <- data.frame(timestamp = Sys.time(), standard, nb.pages, nb.pages.with.content, 
                         msg = "Startline for table of contents not identified", error_orig = "")
    utils::write.table(df.err, file.path(dirname(path), "log.txt"), sep = ";", append = TRUE, row.names = FALSE, col.names = FALSE)
  }
  
  ## if startline exists but endline does not exist produce an error message
  if ( !exists("endline") && exists("startline") ) {
    df.err <- data.frame(timestamp = Sys.time(), standard, nb.pages, nb.pages.with.content, 
                         msg = "Endline for table of contents not identified", error_orig = "")
    utils::write.table(df.err, file.path(dirname(path), "log.txt"), sep = ";", append = TRUE, row.names = FALSE, col.names = FALSE)
  }
  
  ## if both startline and endline do not exist produce an error message
  if ( !exists("endline") && !exists("startline") ) {
    df.err <- data.frame(timestamp = Sys.time(), standard, nb.pages, nb.pages.with.content, 
                         msg = "Startline and endline for table of contents not identified", error_orig = "")
    utils::write.table(df.err, file.path(dirname(path), "log.txt"), sep = ";", append = TRUE, row.names = FALSE, col.names = FALSE)      
  }
  
  list.start.end <- list(startline = startline, endline = endline)
  
  return(list.start.end)

}
