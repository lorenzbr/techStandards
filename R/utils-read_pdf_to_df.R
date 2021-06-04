#' Read PDFs as data.frame. The read_pdf function from the R package textreadr' produced an error in my case.
#' @noRd
read_pdf_to_df <- function (file, skip = 0, remove.empty = TRUE, trim = TRUE, ocr = FALSE, ...) {
  
  text <- callr::r(function(file, ...) {pdftools::pdf_text(file, ...)}, args = list(file))
  
  if (all(text %in% "") & isTRUE(ocr)) {
    
    if (requireNamespace("tesseract", quietly = TRUE)) {
      
      temp <- tempdir()
      fls <- file.path(temp, paste0(gsub("\\.pdf$", "", 
                                         basename(file)), "_", PKPDmisc::pad_left(seq_along(text)), 
                                    ".png"))
      png_files <- pdftools::pdf_convert(file, dpi = 600, 
                                         filenames = fls)
      text <- tesseract::ocr(png_files)
      split <- "\\r\\n|\\n"
      unlink(png_files, TRUE, TRUE)
    }
    
    else {
      
      warning("'tesseract' not available.  `ocr = TRUE` ignored.", 
              call. = FALSE)
      
    }
    
  }
  
  else {
    
    split <- "\\r\\n"
    
  }
  Encoding(text) <- "UTF-8"
  text <- strsplit(text, split)
  
  if (isTRUE(remove.empty)) 
    text <- lapply(text, function(x) x[!grepl("^\\s*$", x)])
  
  out <- data.frame(page_id = rep(seq_along(text), sapply(text, length)), 
                    element_id = unlist(sapply(text, function(x) seq_len(length(x)))), 
                    text = unlist(text), stringsAsFactors = FALSE)
  
  if (skip > 0) 
    out <- utils::tail(out, -c(skip))
  
  if (isTRUE(trim)) 
    out[["text"]] <- trimws(out[["text"]])
  
  class(out) <- c("textreadr", "data.frame")
  out
  
}