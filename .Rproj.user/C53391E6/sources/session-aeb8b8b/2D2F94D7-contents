library(RCurl)
library(stringr)
library(purrr)
library(tibble)

hent_moeder <- function(samling_id = NULL, meet_id = NULL, only_files = TRUE) {
  
  if (is.null(samling_id)) {
    stop("Please enter a samling_id.")
  }
  
  base_url <- paste0("ftp://oda.ft.dk/ODAXML/Referat/samling/", samling_id, "/")
  
  file_listing <- tryCatch({
    getURL(base_url, ftp.use.epsv = FALSE, dirlistonly = FALSE)
  }, error = function(e) {
    message("Could not collect the file list: ", e$message)
    return(tibble(filename = character(0), last_updated = as.POSIXct(character(0))))
  })
  
  file_lines <- strsplit(file_listing, "\\n")[[1]]
  
  file_df <- purrr::map_dfr(file_lines, function(line) {
    if (str_detect(line, "\\.xml$")) {
      parts <- str_match(line, "^\\s*(\\d{2}-\\d{2}-\\d{2})\\s+(\\d{2}:\\d{2}[APM]{2})\\s+\\d+\\s+(\\S+\\.xml)$")
      if (!is.na(parts[1,1])) {
        last_updated <- as.POSIXct(paste(parts[1,2], parts[1,3]), format = "%m-%d-%y %I:%M%p", tz = "CET")
        tibble(filename = parts[1,4], last_updated = last_updated)
      }
    } else {
      NULL
    }
  })
  
  if (!is.null(meet_id)) {
    file_df <- file_df %>% 
      filter(str_detect(filename, paste0("_", meet_id, "_")))
  }
  return(file_df)
}


