#' Search section titles in the full text
#' @noRd
search_section_titles_in_text <- function(contents, pdf, standard, nb.pages, nb.pages.with.content, path) {
  
  ## the title can be split up in several lines meaning that one needs to compare the title from the table of contents
  ## with mostly one line in the text but sometimes with several lines (this makes it a bit tricky)
  ## sometimes the page in the toc is not the right page within the document, i.e. one needs to search in other pages in the neighborhood
  
  ## new column which stores the line_id of the full text of a section
  contents$text_line_id <- ""
  
  pdf$text_no_spaces <- gsub("\\(|\\)", "", pdf$text_no_spaces)
  
  ## PDF page numbering may sometimes be set to 1 after toc
  toc.reset.pages <- max(contents$page_id)
  

  ## these settings are based on trial and error. the idea is to start with a rather narrow search and only if the section title cannot be found
  ## a broader search within the document is done
  all.settings <- data.frame(
    startpage = c(2,2,10,10, 10, 10, 2, 2, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10),
    endpage = c(2, 2, 20, 20, 20, 20, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 150, 150, 150, 150, 150, 150),
    search.type = c("exact", "exact", "exact", "exact", "stringsim", "stringsim", "stringsim", "stringsim", "stringsim", "stringsim", 
                    "stringsim", "stringsim", "stringsim", "stringsim", "stringsim", "stringsim", "exact", "stringsim", "stringsim", 
                    "stringsim", "stringsim", "stringsim"),
    preceding = c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE,
                  FALSE, FALSE, TRUE, TRUE),
    reset.page.number = c(0, toc.reset.pages, 0, toc.reset.pages, 0, toc.reset.pages, 0, toc.reset.pages, 0, toc.reset.pages, 
                          0, toc.reset.pages, 0, toc.reset.pages, 0, toc.reset.pages, 0, 0, 0, 0, 0, 0),
    several.lines = c(1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 2, 2, 3, 3, 1, 1, 2, 3, 2, 3),
    stringsim.threshold = c(0, 0, 0, 0, 0.85, 0.85, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0, 0.85, 0.9, 0.9, 0.9, 0.9)
  )
  
  ## initialize remaining rows
  remaining.rows <- 1:nrow(contents)
  
  for (i in 1:nrow(all.settings) ) {
    
    ## find the line_id which stores the actual full text corresponding to a title in the table of contents
    output <- find_text_line_id(contents = contents, pdf = pdf, remaining.rows = remaining.rows,
                                startpage = all.settings$startpage[i],
                                endpage = all.settings$endpage[i],
                                reset.page.number = all.settings$reset.page.number[i],
                                search.type = all.settings$search.type[i],
                                stringsim.threshold = all.settings$stringsim.threshold[i],
                                several.lines = all.settings$several.lines[i],
                                preceding = all.settings$preceding[i]
                                )
    contents <- output$contents
    remaining.rows <- output$remaining.rows
    
  }
  
  
  #### do the following only if not enough sections are identified (because this can take very long)
  
  ## contents which all section title where a section number exists
  contents.section.no.exist <- contents[!(is.na(contents$section_no)), ]
  
  ## share of section titles not identified
  share.of.not.identified <- nrow(contents.section.no.exist[contents.section.no.exist$text_line_id == "", ]) / nrow(contents.section.no.exist)
  
  if (share.of.not.identified > 0.3) {
    
    ## extremely broad exact search within 1500 pdf pages
    output <- find_text_line_id(contents, pdf, startpage = 10, endpage = 1500, remaining.rows = remaining.rows, reset.page.number = 0, 
                                search.type = "exact", several.lines = 1, preceding = FALSE)
    contents <- output$contents
    remaining.rows <- output$remaining.rows
    
    ## exact string match but for larger subsample of the pdf, starting 1500 pages later (negative startpage)
    output <- find_text_line_id(contents, pdf, startpage = -1500, endpage = 3000, remaining.rows = remaining.rows, reset.page.number = 0, 
                                search.type = "exact", several.lines = 1, preceding = FALSE)
    contents <- output$contents
    remaining.rows <- output$remaining.rows
    
    ## extremely broad stringsim search within 3000 pdf pages
    output <- find_text_line_id(contents, pdf, startpage = 10, endpage = 3000, remaining.rows = remaining.rows, reset.page.number = 0, 
                                search.type = "stringsim", several.lines = 1, preceding = FALSE)
    contents <- output$contents
    remaining.rows <- output$remaining.rows
    
  }
  
  
  #### produce error/warning message if contents has rows with section numbers but has no title identified in the text
  
  ## contents which all section title where a section number exists
  contents.section.no.exist <- contents[!(is.na(contents$section_no)), ]
  
  ## the share of section titles not identified
  share.of.not.identified <- nrow(contents.section.no.exist[contents.section.no.exist$text_line_id == "", ]) / nrow(contents.section.no.exist)
  
  ## if no section title was identified at all set to 1
  if (share.of.not.identified == "NaN") share.of.not.identified <- 1
  
  ## if the share of no section titles identified is larger than 30%, produce warning message
  if (share.of.not.identified > 0.3) {
    df.err <- data.frame(timestamp = Sys.time(), standard, nb.pages, nb.pages.with.content, 
                         msg = paste0(sprintf(share.of.not.identified, fmt = '%#.2f'), " of section titles not identified in the text"),
                         error_orig = "")
    utils::write.table(df.err, file.path(dirname(path), "log.txt"), sep = ";", append = TRUE, row.names = FALSE, col.names = FALSE)
  }
  
  contents <- contents[, names(contents) != "section_title_nospace"]
  
  return(list(contents = contents, pdf = pdf))
  
}
