#' Get actual text of section from full text
#' @noRd
get_section_text <- function(contents, pdf, standard, nb.pages, nb.pages.with.content, path) {
  
  ## get one unique text_line_id / check that this is unique
  
  ## remove sections which were not identified
  contents <- contents[!(is.na(contents$text_line_id)), ]
  contents <- contents[contents$text_line_id != "", ]
  
  ## to numeric
  contents$text_line_id_start <- as.numeric(contents$text_line_id)
  

  if (nrow(contents) > 0) {
    
    ## get end line of each section
    contents$text_line_id_end <- NA
    for (i in 1:(nrow(contents) - 1)) contents$text_line_id_end[i] <- contents$text_line_id_start[i + 1] - 1
    
    ## last row in contents goes until end of pdf document
    contents$text_line_id_end[nrow(contents)] <- max(pdf$line_id)
    
    ## now all the text between two adjacent sections is combined and assign it to the section occurring earlier in the text
    ## for a focal section take the text_line_id from the subsequent section minus 1. then have to take all strings
    ## from pdf data frame and paste it and write this into the corresponding line in contents
    ## for loop over all rows specified in contents for each row in contents
    contents$section_text <- ""
    
    ## for loop takes the actual text of each section and writes it into contents
    for (k in 1:nrow(contents)) {
      contents$section_text[k] <- paste0(pdf$text[pdf$line_id >= contents$text_line_id_start[k] 
                                                   & pdf$line_id <= contents$text_line_id_end[k]], collapse = " ")
    }
   
  } else if (nrow(contents) == 0) {
    
    ## if contents is empty get error message
    df.err <- data.frame(timestamp = Sys.time(), standard, nb.pages, nb.pages.with.content, 
                         msg = "contents is empty due to no identified title in text", error_orig = "")
    utils::write.table(df.err, file.path(dirname(path), "log.txt"), sep = ";", append = TRUE, row.names = FALSE, col.names = FALSE)
    
  }
  
  return(contents)
  
}
