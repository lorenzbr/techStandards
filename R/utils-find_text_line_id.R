#' Find the line_id of the actual text for each section in table of contents
#' @noRd
find_text_line_id <- function(contents, pdf, startpage, endpage, remaining.rows = NULL, reset.page.number = 0, search.type = "exact",
                              stringsim.threshold = 0.85, several.lines = 1, preceding = FALSE) {
  
  ## new temp column which stores the line_id where the full text of a section can be found
  contents$text_line_id_temp <- ""
  
  if ( is.null(remaining.rows) ) remaining.rows <- 1:nrow(contents)
  
  ## PDF page numbering may sometimes be set to 1 after toc
  toc.reset.pages <- max(contents$page_id)
  
  ## for loop over all sections in contents (to get the actual text for each section)
  for (i in remaining.rows) {
    
    ## get relevant pdf pages to search in
    pdfpage <- get_relevant_pages(contents[i, ], pdf, startpage, endpage, reset.page.number)
    
    if (nrow(pdfpage) == 0) pdfpage <- get_relevant_pages(contents[i, ], pdf, startpage, endpage, reset.page.number = toc.reset.pages)
    
    
    ## this string match identifies the line_id of the section title in the full pdf
    if (nrow(pdfpage) > 0) {
      
      if (several.lines >= 2 && preceding == FALSE) {
        
        pdfpage$text_nospace_severallines <- ""
        
        for (j in 1:(nrow(pdfpage) - (several.lines - 1)) ) {
          
          if (several.lines == 2) {
            
            pdfpage$text_nospace_severallines[j] <- paste0(pdfpage$text_no_spaces[j], pdfpage$text_no_spaces[j + 1])
            
          } else if (several.lines == 3) {
            
            pdfpage$text_nospace_severallines[j] <- paste0(pdfpage$text_no_spaces[j], pdfpage$text_no_spaces[j + 1], 
                                                           pdfpage$text_no_spaces[j + 2])
            
          }
          
        }
        
        pdfpage$text_no_spaces <- pdfpage$text_nospace_severallines
        
      } else if (several.lines >= 2 && preceding) {
        
        ## create new column which comprise the focal text plus the preceding ones
        pdfpage$text_nospace_severallines_preceding <- ""
        
        for (j in several.lines:nrow(pdfpage) ) {
          
          if (several.lines == 2) {
            
            pdfpage$text_nospace_severallines_preceding[j] <- paste0(pdfpage$text_no_spaces[j - 1], pdfpage$text_no_spaces[j])
            
          } else if (several.lines == 3) {
            
            pdfpage$text_nospace_severallines_preceding[j] <- paste0(pdfpage$text_no_spaces[j - 2], pdfpage$text_no_spaces[j - 1], 
                                                                     pdfpage$text_no_spaces[j])
            
          }
          
        }
        
        pdfpage$text_no_spaces <- pdfpage$text_nospace_severallines_preceding
        
      }
      
      
      if (search.type == "exact") {
        
        text.no.spaces.substr <- substring(pdfpage$text_no_spaces, 1, nchar(contents$section_title_nospace[i]))
        match.section.title <- contents$section_title_nospace[i] == text.no.spaces.substr
        
      } else if (search.type == "stringsim") {
        
        ## use string similarity stringsim (restricted Damerau-Levenshtein distance). The default value 0.85 is an arbitrary value
        text.no.spaces.substr <- substr(pdfpage$text_no_spaces, 1, nchar(contents$section_title_nospace[i]))
        match.section.title <- stringdist::stringsim(contents$section_title_nospace[i], text.no.spaces.substr) > stringsim.threshold
        
      }
      
      section.title.is.not.contents <- pdfpage$line_id != contents$line_id[i]
      contents$text_line_id_temp[i] <- paste(as.character(pdfpage$line_id[match.section.title & section.title.is.not.contents]), collapse = ';')
    }
    
  }
  
  ## store those identified text line ids in the final complete column
  line.id.compl.is.empty <- contents$text_line_id == ""
  line.id.is.unique <- !grepl(";", contents$text_line_id_temp)
  contents$text_line_id[line.id.compl.is.empty & line.id.is.unique] <- contents$text_line_id_temp[line.id.compl.is.empty & line.id.is.unique]
  
  ## keep those rows in contents which do not yet have an identified full text
  remaining.rows <- which(contents$text_line_id == "")
  
  contents <- contents[, names(contents) != "text_line_id_temp"]
  contents <- contents[, names(contents) != "text_no_spaces"]
  
  return(list(contents = contents, remaining.rows = remaining.rows))
  
}