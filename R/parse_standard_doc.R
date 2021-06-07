#' Standard document parser
#' 
#' Parse a standard document and get the full text for each section. The parsed table of contents is stored as a csv file.
#' 
#' @usage parse_standard_doc(file, path, sso = "", doc.type = "pdf", 
#'                    overwrite = FALSE, encoding = "UTF-8", print = TRUE)
#' @param file A string containing the file name of the standard document.
#' @param path A string containing the path of the parsed standard document.
#' @param sso A string containing the acronym of a standard-setting organization (\emph{IEEE}, \emph{ETSI} or \emph{ITU-T}).
#' @param doc.type A string containing the document type. Should be \emph{pdf}.
#' @param overwrite A logical indicating whether to overwrite existing data.
#' @param encoding Encoding of the input document. Default is \emph{UTF-8}. The encoding is converted to \emph{UTF-8}.
#' @param print A logical. If \code{TRUE} messages are printed.
#' 
#' @seealso \code{\link{parse_standard_docs}}
#' 
#' @export
parse_standard_doc <- function(file, path, sso = "", doc.type = "pdf", overwrite = FALSE, encoding = "UTF-8", print = TRUE) {

  ## initialize parsing (creates files and folders)
  if ( !file.exists(file.path(dirname(path), "log.txt")) ) init_standard_doc_parser(path, create.new.files = TRUE)
  
  ## output paths
  path.ch.txt <- paste0(gsub("/$", "", path), "_ch_txt/")
  path.toc <- paste0(gsub("/$", "", path), "_toc/")
  
  ## create windows path (because without it, R aborts after running for quite a while when parse_standard_docs is used)
  file <- gsub("/", "\\\\", file)
  
  standard <- basename(file)

  ## pattern to split the title into numbering and actual title
  ## this is somewhat based on trial and error, i.e. by checking particular problematic documents
  if (sso == "IEEE") {
    text.title.splitter <- "^[0-9a-z][0-9a-z]?[ \\.]([0-9]{1,2})?\\.?([0-9]{1,2})?\\.?([0-9]{1,2})?\\.?([0-9]{1,2})?|^annex [a-z]"
  } else if(sso == "ETSI") {
    text.title.splitter <- "^[0-9][0-9a-z]?[ \\.]([0-9]{1,2})? ?\\.?([0-9a-z]{1,2})? ?[_\\.]?([0-9a-z]{1,3})? ?-?[a-z]?[_\\.]?([0-9a-z]{1,3})? ?\\.?([0-9a-z]{1,2})? ?\\.?([0-9a-z]{1,2})? |^annex [a-z]|^[a-z][ \\.]([0-9]{1,2})? ?\\.?([0-9]{1,2})? ?\\.?([0-9]{1,2})? ?\\.?([0-9]{1,2})? ?\\.?([0-9]{1,2})? ?"
  } else if(sso == "ITU-T") {
    text.title.splitter <- "^[0-9a-z][0-9a-z]?[ \\.]([0-9]{1,2})?\\.?([0-9]{1,2})?\\.?([0-9]{1,2})?\\.?([0-9]{1,2})?|^annex [a-z]|^[0-9]{1,2}\\)"
  } else {
    ## same as ETSI
    text.title.splitter <- "^[0-9][0-9a-z]?[ \\.]([0-9]{1,2})? ?\\.?([0-9a-z]{1,2})? ?[_\\.]?([0-9a-z]{1,3})? ?-?[a-z]?[_\\.]?([0-9a-z]{1,3})? ?\\.?([0-9a-z]{1,2})? ?\\.?([0-9a-z]{1,2})? |^annex [a-z]|^[a-z][ \\.]([0-9]{1,2})? ?\\.?([0-9]{1,2})? ?\\.?([0-9]{1,2})? ?\\.?([0-9]{1,2})? ?\\.?([0-9]{1,2})? ?"
  }
  
  
  tryCatch({
    
    ## get document name (without file type)
    if (grepl(".pdf$|.csv$|.txt$", standard)) doc.name <- substring(standard, 1, nchar(standard) - 4)
    
    ## check whether document was already parsed successfully, if yes skip this one
    parsed.documents <- data.table::fread(file.path(dirname(path), "parsed_documents.txt"), sep = ";")
    document.parsed <- sum(grepl(standard, parsed.documents$Parsed_documents, fixed = TRUE)) > 0

    if ( document.parsed == FALSE || (document.parsed == TRUE && overwrite == TRUE) ) {
    
      ## read standard document into a data.frame
      if (doc.type == "pdf") {
        
          pdf <- read_pdf_to_df(file)
          
      } else if (doc.type == "csv") {
        
          pdf <- data.table::fread(paste0(dirname(file), "/", doc.name, ".csv"))
          
      }
      
      ## number of pages which have actual content
      nb.pages.with.content <- length(unique(pdf$page_id))
      
      ## get actual number of pages (sometimes pages are missing)
      if (doc.type == "pdf") {
        
        text <- callr::r(function(file) { pdftools::pdf_text(file)}, args = list(file))
        nb.pages <- length(text)
        rm(text)
        
      } else if (doc.type == "csv" || doc.type == "txt") {
        
        nb.pages <- max(pdf$page_id)
        
      }
      
      ## convert encoding to UTF-8
      pdf$text <- iconv(pdf$text, from = encoding, to = "UTF-8", sub = "")
      
      ## some cleaning
      pdf$text <- gsub("\\;", "\\. ", pdf$text)
      pdf$text <- gsub('\\"', "\\'", pdf$text)
      pdf <- pdf[!(pdf$text == sso), ]
      pdf <- pdf[!(grepl("all rights reserved", pdf$text)), ]

      ## create id for each line
      pdf$line_id <- 1:nrow(pdf)
      
      ## text to lower case
      pdf$text <- tolower(pdf$text)
      
      ## text without spaces (used to match strings)
      pdf$text_no_spaces <- gsub(" ", "", pdf$text)
      
      ## some manual cleaning
      pdf$text_no_spaces[pdf$text_no_spaces == "contentspage"] <- "contents"
      pdf$text_no_spaces <- gsub("\003|\002|\001|\004", "", pdf$text_no_spaces)
      
      
      
      
      ## identify first and last line of table of contents
      list.start.end <- identify_table_of_contents(pdf, standard, nb.pages, nb.pages.with.content, path)
      startline <- list.start.end$startline
      endline <- list.start.end$endline
      
      
      
      if ( exists("startline") && exists("endline") ) {
        
        ## get table of contents
        contents <- pdf[pdf$line_id >= (startline + 1) & pdf$line_id <= endline, ]
        
        ## remove table of contents in actual pdf
        pdf <- pdf[pdf$line_id > max(contents$line_id), ]
        
        ## clean table of contents
        contents <- clean_table_of_contents(contents, text.title.splitter, standard, sso, nb.pages, nb.pages.with.content, path)
        
        pdf$text_no_spaces <- gsub("\\(|\\)", "", pdf$text_no_spaces)
        
        list.output <- search_section_titles_in_text(contents, pdf, standard, nb.pages, nb.pages.with.content, path)
        
        contents <- list.output$contents
        pdf <- list.output$pdf
        
        contents <- get_section_text(contents, pdf, standard, nb.pages, nb.pages.with.content, path)
        
        if (nrow(contents) > 0) {
          
          contents$section_no <- gsub("annex", "", contents$section_no)
          
          contents$chapter_no <- stringr::str_extract(contents$section_no, "^[0-9a-z]{1,2}\\.?|^annex[a-z]|^[0-9]")
          contents$chapter_no <- gsub("\\.", "", contents$chapter_no)
          contents$chapter_no <- gsub(" ", "", contents$chapter_no)
          
          ## store parsed table of contents as csv
          utils::write.csv2(contents, paste0(path.toc, doc.name, "_toc.csv"), row.names = FALSE)
          
          
          
          ## remove those rows which have no chapter number
          contents <- contents[!(is.na(contents$chapter_no)), ]
          
          if (nrow(contents) > 0) { 
            
            write_chapters_to_txt(contents, standard, doc.name, nb.pages, nb.pages.with.content, path, path.ch.txt)
            
          } else if (nrow(contents) == 0) {
            
            df.err <- data.frame(timestamp = Sys.time(), file = standard, nb_pages = nb.pages, nb_pages_with_content = nb.pages.with.content, 
                                 msg = "contents is empty", error_orig = "")
            utils::write.table(df.err, file.path(dirname(path), "log.txt"), sep = ";", append = TRUE, row.names = FALSE, col.names = FALSE)      
            
          }
          
        }
        
        
        
      } ## end of if condition exists("startline") && exists("endline")
      
      
      
      utils::write.table(paste(Sys.time(), " *** Doc. Name: ", standard), file.path(dirname(path), "parsed_documents.txt"), 
                  col.names = FALSE, row.names = FALSE, append = TRUE)
      
      if (print) message(Sys.time(), " *** Doc. Name: ", doc.name)
      
    } else if (document.parsed) {
      
      message(standard, " was already parsed!")
      
    }
  
  }, error = function(e) {
    
    if ("page_id" %in% colnames(pdf)) nb.pages.with.content <- length(unique(pdf$page_id))
    
    if ( !("page_id" %in% colnames(pdf)) ) nb.pages.with.content <- NA
    
    if ( !exists("nb.pages") ) nb.pages <- NA
    
    df.err <- data.frame(timestamp = Sys.time(), standard, nb_pages = nb.pages, nb_pages_with_content = nb.pages.with.content,
                         msg = "Standard document not used", error_orig = gsub("\n", "", e))
    
    utils::write.table(df.err, file.path(dirname(path), "log.txt"), sep = ";", append = TRUE, row.names = FALSE, col.names = FALSE) 
    
  }
  
  ) ## end of try catch

}
