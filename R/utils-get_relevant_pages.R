#' Get relevant pages of the full text where to search for the section title
#' @noRd
get_relevant_pages <- function(contents, pdf, startpage = 10, endpage = 20, reset.page.number = 0) {
  
  ## function which selects the most relevant pages where to search for the full text
  
  ## only if page of section is not NA
  if ( !is.na(contents$page_of_section) ) {
    
    ## take range of pages
    pagenumbers <- (contents$page_of_section - startpage):(contents$page_of_section + endpage)
    
    pagenumbers <- pagenumbers + reset.page.number
    
    ##  keep only the relevant pages from the full text  in order to speed up the matching process
    pdfpage <- pdf[pdf$page_id %in% pagenumbers, ]
    
    return(pdfpage)
    
  }
  
}
