#' Write chapter texts to txt file
#' @noRd
write_chapters_to_txt <- function(contents, standard, doc.name, nb.pages, nb.pages.with.content, path, path.ch.txt) {
  
  ## store all chapter numbers in string
  unique.chapters <- unique(contents$chapter_no)
  
  ## if unique.chapters contains NA, give error message
  if (sum(is.na(unique.chapters)) > 0) {
    df.err <- data.frame(timestamp = Sys.time(), file = standard, nb_pages = nb.pages, nb_pages_with_content = nb.pages.with.content, 
                         msg = "NA Error at unique.chapters", error_orig = "")
    utils::write.table(df.err, file.path(dirname(path), "log.txt"), sep = ";", append = TRUE, row.names = FALSE, col.names = FALSE)
  }
  
  ## paste all section_texts of one chapter (with same chapter_no) together
  ## new data frame with standard, chapter, combined titles, combined text, start line, end line, start page, end page
  
  ## get rid of NA
  unique.chapters <- unique.chapters[!is.na(unique.chapters)]
  
  ## store text for each chapter in txt files
  for (i in 1:length(unique.chapters)) {
    
    ## get full text for entire chapter
    text <- paste(contents$section_text[contents$chapter_no == unique.chapters[i]], collapse = " ")
    
    ## write actual text for each document for each chapter into separate txt file
    file <- file(paste0(path.ch.txt, doc.name, "_ch_", unique.chapters[i], ".txt"))
    writeLines(text, file)
    close(file)
    rm(file)
    
  }
  
}
