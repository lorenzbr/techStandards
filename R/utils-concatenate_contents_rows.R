#' Helper function to concatenate text and title in table of contents
#' @noRd
concatenate_contents_rows <- function(df, i, endrow) {
  
  df$text[i] <- paste(df$text[i:(i + endrow)], collapse = " ")
  df$section_title[i] <- paste(df$section_title[i:(i + endrow)], collapse = " ")
  df$text_no_spaces[i] <- paste(df$text_no_spaces[i:(i + endrow)], collapse = "")
  df$section_title_nospace[i] <- paste(df$section_title_nospace[i:(i + endrow)], collapse = "")
  
  return(df)
  
}