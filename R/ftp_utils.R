library(RCurl)
library(purrr)
library(lubridate)
library(tibble)
library(stringr)
library(dplyr)

hent_ftp_listing <- function(base_url = "ftp://oda.ft.dk/ODAXML/Referat/samling/") {
  tryCatch(
    getURL(base_url, ftp.use.epsv = FALSE) %>%
      strsplit("\n") %>%
      unlist() %>%
      trimws(), 
    error = function(e) {
      message("Error with getting FTP listing: ", e$message)
      character(0)
    }
  )
}

parse_ftp_listing <- function(lines) {
  parsed <- strsplit(lines, "\\s+")
  
  purrr::map_df(parsed, function(parts) {
    if (length(parts) < 4) return(NULL)
    datetime <- lubridate::mdy_hm(paste(parts[1], parts[2]))
    
    tibble::tibble(
      name = parts[4],
      datetime = datetime
    )
  })
}


list_samlinger <- function() {
  url <- "ftp://oda.ft.dk/ODAXML/Referat/samling/"
  res <- tryCatch(
    system2("curl", args = c("-s", "-l", url), stdout = TRUE),
    error = function(e) character(0)
  )
  
  samlinger <- res[stringr::str_detect(res, "^\\d{5}$")]
  return(samlinger)
}


# Tæl antal mødefiler i en samling
count_of_meetings <- function(samling_id, base_url = "ftp://oda.ft.dk/ODAXML/Referat/samling/") {
  samling_url <- paste0(base_url, samling_id, "/")
  
  tryCatch(
    getURL(samling_url, ftp.use.epsv = FALSE, dirlistonly = TRUE) %>%
      strsplit("\n") %>%
      unlist() %>%
      trimws() %>%
      stringr::str_detect("\\.xml$") %>%
      sum(), 
    error = function(e) {
      message("Error while retrieving files for samling ", samling_id, ": ", e$message)
      0
    }
  )
}

overblik_samlinger <- function(base_url = "ftp://oda.ft.dk/ODAXML/Referat/samling/") {
  
  raw <- hent_ftp_listing(base_url)
  
  parsed <- parse_ftp_listing(raw)
  
  samlinger <- parsed %>% 
    dplyr::filter(stringr::str_detect(name, "^\\d{5}$")) %>%
    dplyr::mutate(year = substr(name, 1, 4),
                  meet_count = purrr::map_int(name, count_of_meetings, base_url = base_url))
  
  if (nrow(samlinger) == 0) {
    warning("No samlinger found.")
    return(NULL)
  }
  
  year_overview <- samlinger %>%
    dplyr::group_by(year) %>%
    dplyr::summarise(
      samling_count = dplyr::n(), 
      count_of_meetings = sum(meet_count), 
      latest_update = max(datetime, na.rm = TRUE)
    )
  
  list(samlinger = samlinger, year_overview = year_overview)
}

