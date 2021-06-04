#' Clean table of contents
#' @noRd
clean_table_of_contents <- function(contents, text.title.splitter, standard, sso, nb.pages, nb.pages.with.content, path) {
  
  contents$text <- gsub("^section","", contents$text)
  contents$text_no_spaces <- gsub("^section", "", contents$text_no_spaces)
  contents$text <- gsub("^chapter","",contents$text)
  contents$text_no_spaces <- gsub("^chapter", "", contents$text_no_spaces)
  
  contents$text <- gsub(" $|^ ", "", contents$text)
  
  ## remove rows which are actually not part of the toc but are simply a header
  contents <- contents[contents$text_no_spaces != "annex", ]
  contents <- contents[contents$text_no_spaces != "annexes", ]
  contents <- contents[contents$text_no_spaces != "clausepage", ]
  contents <- contents[contents$text_no_spaces != "usepage", ]
  contents <- contents[contents$text_no_spaces != "page", ]
  contents <- contents[contents$text_no_spaces != "sectionpage", ]
  contents <- contents[contents$text_no_spaces != "figures", ]
  contents <- contents[contents$text_no_spaces != "figurespage", ]
  contents <- contents[contents$text_no_spaces != "figurepage", ]
  contents <- contents[contents$text_no_spaces != "tables", ]
  contents <- contents[contents$text_no_spaces != "tablespage", ]
  contents <- contents[contents$text_no_spaces != "tablepage", ]
  contents <- contents[contents$text_no_spaces != "appendix", ]
  contents <- contents[contents$text_no_spaces != "appendixfigures", ]
  contents <- contents[contents$text_no_spaces != "appendixtable", ]
  contents <- contents[contents$text_no_spaces != "annexfigures", ]
  contents <- contents[contents$text_no_spaces != "annextables", ]
  contents <- contents[contents$text_no_spaces != "parti", ]
  contents <- contents[contents$text_no_spaces != "parti1", ]
  contents <- contents[contents$text_no_spaces != "superseded", ]
  contents <- contents[contents$text_no_spaces != "", ]
  contents <- contents[contents$text_no_spaces != "-", ]
  contents <- contents[contents$text_no_spaces != "~", ]
  contents <- contents[contents$text_no_spaces != ".", ]
  contents <- contents[contents$text_no_spaces != "n", ]
  contents <- contents[contents$text_no_spaces != "a", ]
  contents <- contents[contents$text_no_spaces != "rec.no.page", ]
  contents <- contents[contents$text_no_spaces != "0age", ]
  contents <- contents[contents$text_no_spaces != "contents", ]
  
  ## sometimes there are page numbers with roman letters in the table of contents
  pagenumbers.which.need.to.be.removed <- seq(1 : 100)
  pagenumbers.which.need.to.be.removed <- tolower(as.character(utils::as.roman(pagenumbers.which.need.to.be.removed)))
  for (pagenumber in pagenumbers.which.need.to.be.removed) { contents <- contents[contents$text_no_spaces != pagenumber, ] }
  
  contents <- contents[!(grepl("\\.{4}[xvi]{1,4}$", contents$text_no_spaces)), ]
  
  if (sso == "ITU-T") {
    
    contents <- contents[!(grepl("persededbyamorerecentversion", contents$text_no_spaces)), ]
    contents$text <- gsub("q.[0-9]{3}", "", contents$text)
    contents$text_no_spaces <- gsub("q.[0-9]{3}", "", contents$text_no_spaces)
    
  } else if (sso == "IEEE") {
    
    contents$text <- gsub("\\(changes to\\)", "", contents$text)
    contents$text_no_spaces <- gsub("\\(changesto\\)", "", contents$text_no_spaces)
    
  }

  contents$text <- gsub("^\\s+", "", contents$text)
  
  
  ## identify section_title which is simply substring until many dots appear (e.g. ten dots in a row split the title from page number)
  ## section title is everything before many dots OR before the page number at the end
  ## arbitrary number of dots, but at least more than one dot, followed by optional spaces, 
  ## followed by number with something between 1 to 4 figures at the end of the string
  contents$section_title <- sapply(contents$text, function(x) { strsplit(x, split = "\\s*?\\.+\\s*?[0-9]{1,4}$")[[1]][1] })
  
  ## remove all spaces and dots at the end of section titles until there are non left WHY DO THIS LIKE THAT?
  while (sum(grepl(" $|\\.$",contents$section_title)) > 0) {
    contents$section_title <- gsub(" $|\\.$", "", contents$section_title)
  }
  
  ## section titles without spaces
  contents$section_title_nospace <- sapply(contents$text_no_spaces, 
                                            function(x) { strsplit(x, split = "\\s*?\\.+\\s*?[0-9]{1,4}$")[[1]][1] })
  
  ## identify section and chapter numbers and write them into new column; always "number dot number ..." format
  ## for Annexes different format A.1 or A.1.1 ...
  ## if it starts with a number or with character dot number, then the separator is the first space; put that into a new
  ## column
  ## optional space after each number, optional dot after each number; after first number or character either space
  ## or dot needs to exist
  
  #### sometimes there are section titles which go over more than one line. this is indicated with the variable morelines
  #### the code for this follows
  
  ## identify rows in the table of contents which do not have a page number at the end
  ## i.e. morelines is True if there is basically no page number at the end
  contents$morelines <- !(grepl("[.)0-9a-z] ?\\.\\.+ ?[0-9]{1,4}$|tables\\.\\.+", contents$text_no_spaces))
  
  ## need to correct some morelines
  ## e.g. sometimes there are just no dots because the section title is so long that immediately the page number follows
  contents$morelines[grepl("^[0-9]{1,2}\\.?[0-9]{1,2}\\.?[0-9a-z]+[0-9]{1,4}$", contents$text_no_spaces)] <- FALSE
  
  ## which.morelines indicates rows which follow those rows which are the first ones of several lines belonging to one section title
  which.morelines <- (which(contents$morelines == FALSE) + 1)
  
  which.morelines <- which.morelines[1:(length(which.morelines) - 1)]
  
  which.morelines <- c(1, which.morelines)
  
  ## initialize new column
  contents$section_no <- ""
  
  contents$section_no[which.morelines] <- stringr::str_extract(contents$text[which.morelines], text.title.splitter)
  
  if (sso == "ETSI") contents$section_no <- gsub(" 5g ?$", "", contents$section_no)
  
  contents$section_no <- gsub(" ", "", contents$section_no)
  contents$section_no <- gsub("\\.$", "", contents$section_no)
  contents$section_no <- gsub("\\)", "", contents$section_no)
  contents$section_no[contents$section_no == ""] <- NA
  
  if ( all(is.na(contents$section_no)) ) {
    df.err <- data.frame(timestamp = Sys.time(), standard, nb.pages, nb.pages.with.content, msg = "Section numbers not identified",
                         error_orig = "")
    utils::write.table(df.err, file.path(dirname(path), "log.txt"), sep = ";", append = TRUE, row.names = FALSE, col.names = FALSE)
  }
  
  ## identify the section titles which go over 2, 3, 4, 5, 6 or 7 lines and store the text into the first line
  ## the choice of considering seven lines is arbitrary chosen (there may be even longer section titles)
  for ( i in which(contents$morelines) ) {
    
    for ( j in 6:1) { 
      
      if ( all(is.na(contents$section_no[(i + 1):(i + j)])) & i + j <= nrow(contents) ) contents <- concatenate_contents_rows(contents, i, j)
      
    }
    
  }
    
  ## delete rows from sections which have more lines, i.e. when section_no == NA and the row before morelines == TRUE
  ## remove second lines of title which go over more lines
  contents$several_lines <- NA
  contents$several_lines[which(contents$morelines) + 1] <- TRUE
  contents$several_lines[is.na(contents$several_lines)] <- FALSE
  logicsecondlines <- (contents$several_lines & is.na(contents$section_no))
  
  ## all lines which are the next lines of the first section line are removed
  ## if condition: do this only if there are several lines at all, otherwise would get an error
  if (length(logicsecondlines) > 0) {
    contents$several_line_title <- logicsecondlines
    ## change last row to FALSE
    contents$several_line_title[nrow(contents)] <- FALSE
    contents <- contents[contents$several_line_title == FALSE, ]
  }
  
  ## identify the actual title which is the second part in the string split 
  contents$section_title_text <- sapply(contents$section_title, 
                                         function(x){ strsplit(x, split = "^[0-9a-z][0-9a-z]?[ \\.]([0-9a-z]{1,2})? ?\\.?([0-9]{1,2})? ?\\.?([0-9]{1,2})? ?\\.?([0-9]{1,2})? ?|annex ?[a-z]|^[0-9]{1,2}\\)|^annex ?[a-z]\\)")[[1]][2]})
  
  contents$section_title_text <- gsub("^\\s+", "", contents$section_title_text)
  
  ## identify page of section at the end of the string; always the last numbers in the string
  contents$page_of_section <- as.numeric(stringr::str_extract(contents$text_no_spaces, "[0-9]{1,4}$"))
  
  ## some section are void. indicate this (not required but interesting)
  contents$void_ident <- grepl(" void |^void ", contents$text)
  
  ## remove figures and tables because only interested in the actual text
  contents <- contents[!(grepl("^fig", contents$text_no_spaces)), ]
  contents <- contents[!(grepl("^table", contents$text_no_spaces)), ]
  
  contents$section_title_nospace <- gsub("\\(|\\)", "", contents$section_title_nospace)
  
  ## remove rows where page of the section is not identified
  contents <- contents[!(is.na(contents$page_of_section)), ]
  
  return(contents)
  
}
