library(tidyverse)
library(progress)

## Final function
hent_og_parse_moeder <- function(samling_id,
                                 year = NULL,
                                 meet_id = NULL,
                                 full_name = NULL,
                                 max_retry = 5,
                                 retry_delay = 5,
                                 pause = 0.5,
                                 output_filename = "data.csv",
                                 output_dir = "meeting_data",
                                 save_as_csv = FALSE) {
  
  if (!dir.exists(output_dir)) {
    dir.create(output_dir)
  }
  
  start <- Sys.time()
  message(start)
  
  if (!is.null(year)) {
    all_samlinger <- list_samlinger()
    
    if (length(all_samlinger) == 0) {
      stop("Kunne ikke hente samlingsliste fra FTP.")
    }
    
    # Filtrér samlinger der matcher de ønskede år
    year <- as.character(year)
    samling_id <- all_samlinger[stringr::str_sub(all_samlinger, 1, 4) %in% year]
    
    if (length(samling_id) == 0) {
      stop("Ingen samlinger fundet for år: ", paste(year, collapse = ", "))
    }
  }
  
  
  if (!is.null(samling_id)) {
    if (is.data.frame(samling_id) && "samling_id" %in% names(samling_id)) {
      samling_ids <- unique(samling_id$samling_id)
    } else {
      samling_ids <- unique(samling_id)
    }
    message("Collecting samlinger: ", paste(samling_ids, collapse = ", "))
  }
  
  if (is.null(samling_id)) {
    warning("Missing samling_id")
    return(NULL)
  }
  
  if (!is.null(meet_id)) {
    meet_id <- paste0("M", gsub("^M", "", meet_id))
  }
  
  if (is.data.frame(samling_id) &&
      "samling_id" %in% names(samling_id)) {
    combinations <- samling_id
  } else {
    combinations <- tibble(samling_id = samling_id)
  }
  
  if(!"meet_id" %in% colnames(combinations)) {
    combinations$meet_id <- NA_character_
  }
  
  combined_list <- list()
  
  for (i in seq_len(nrow(combinations))) {
    sid <- combinations$samling_id[i]
    mid <- combinations$meet_id[i]
    message(sprintf("Now collecting samling %s%s.",
                    sid, if (!is.na(mid)) paste0(", møde ", mid) else ""))
    
    base_url <- paste0("ftp://oda.ft.dk/ODAXML/Referat/samling/", sid, "/")
    file_info <- NULL
    
    for (retry_count in 1:max_retry) {
      tryCatch({
        file_info <- hent_moeder(sid, if (is.na(mid)) NULL else mid)
        break
      }, error = function(e) {
        message(sprintf("Failed %d/%d because %s", retry_count, max_retry, e$message))
        if (retry_count == max_retry) {
          warning(sprintf("Could not collect %s%s.",
                          sid, if (!is.na(mid)) paste0(", ", mid) else ""))
        } else {
          Sys.sleep(retry_delay)
        }
      })
    }
    
    if (is.null(file_info) || nrow(file_info) == 0) {
      message(sprintf("No files found for samling %s.", sid))
      next
    }
    
    df_list <- list()
    pb <- progress::progress_bar$new(format = " [:bar] :current/:total",
                                     total = nrow(file_info),
                                     clear = FALSE)
    
    for (j in seq_len(nrow(file_info))) {
      filename <- file_info$filename[j]
      full_url <- paste0(base_url, filename)
      last_updated <- file_info$last_updated[j]
      
      tryCatch({
        pb$tick()
        df <- parse_meeting_xml(full_url)
        
        # --- Ny del: ----
        
        if (!is.null(full_name)) {
          match_found <- any(stringr::str_detect(df$full_name, 
                                                 stringr::regex(paste0("^", full_name, "$"), ignore_case = TRUE)))
          if (!match_found) {
            next  # Skip mødet
          }
        }
        # ----------------
        df$last_updated <- last_updated
        df$samling_id <- sid
        if (!is.na(mid)) df$meet_id <- mid
        df_list[[j]] <- df
      }, error = function(e) {
        message(sprintf("Skipping %s because of error: %s", filename, e$message))
      })
      Sys.sleep(pause)
    }
    
    df_list <- Filter(Negate(is.null), df_list)
    if (length(df_list) == 0) {
      message(sprintf("No valid data for samling %s.", sid))
      next
    }
    
    combined_df <- dplyr::bind_rows(df_list)
    
    if(!is.null(full_name)) {
      meet_indices <- combined_df %>% 
        dplyr::filter(stringr::str_detect(full_name, 
                                          stringr::regex(paste0("^", full_name, "$"), ignore_case =  TRUE))) %>% 
        dplyr::pull(meetingnr) %>% 
        unique()
      
      combined_df <- combined_df %>% 
        dplyr::filter(meetingnr %in% meet_indices)
    }
    
    combined_list[[i]] <- combined_df
  }
  
  combined <- dplyr::bind_rows(combined_list)
  
  combined <- combined %>%
    group_by(samling_id) %>%
    arrange(meetingnr, .by_group = TRUE)
  
  if (save_as_csv) {
    output_file_csv <- file.path(output_dir, output_filename)
    readr::write_csv(combined, output_file_csv)
    message(sprintf("Data has been saved in a CSV", output_file_csv))
  }
  
  return(combined)
  
}

#base_url <- "ftp://oda.ft.dk/ODAXML/Referat/samling/"


hent_opdateret_moedefiler <- function(since = Sys.Date() - 1) {
  since <- as.POSIXct(since, tz = "CET")
  
  list_url = "ftp://oda.ft.dk/ODAXML/Referat/samling/"
  list_raw <- tryCatch({
    getURL(list_url, ftp.use.epsv = FALSE, dirlistonly = FALSE)
  }, error = function(e) {
    stop("Could not retrieve list", e$message)
  })
  
  lines <- strsplit(list_raw, "\n")[[1]]
  print(head(lines))
  folders <- str_match(lines, "\\s+(\\d{5})$")[,2]
  print(folders)
  folders <- na.omit(folders)
  
  result <- list()
  
  for (sid in folders) {
    message("Checking samling", sid)
    files <- hent_moeder(sid, only_files = TRUE)
    
    if (nrow(files) == 0) next
    
    newer_files <- files %>% 
      filter(last_updated > since)
    if (nrow(newer_files) == 0) next
    
    message(sprintf(" - %d updated files found since %s", nrow(newer_files), since))
    
    base_url <- paste0(list_url, sid, "/")
    
    pb <- progress_bar$new(
      format = sprintf(" Samling %s [:bar] :current/:total (:percent)", sid),
      total = nrow(newer_files), clear = FALSE, width = 60
    )
    
    df_list <- lapply(seq_len(nrow(newer_files)), function(j) {
      pb$tick()
      filename <- newer_files$filename[j]
      last_updated <- newer_files$last_updated[j]
      full_url <- paste0(base_url, filename)
      
      tryCatch({
        df <- parse_meeting_xml(full_url)
        df$last_updated <- last_updated
        df$samling_id <- sid
        return(df)
      }, error = function(e) {
        message(sprintf("Skipping file '%s': %s", filename, e$message))
        return(NULL)
      })
    })
    
    df_list <- Filter(Negate(is.null), df_list)
    if (length(df_list) > 0) {
      result[[sid]] <- bind_rows(df_list)
    }
  }
  
  if (length(result) == 0) {
    message("No updated files found since")
    return(NULL)
  }
  final_result <- bind_rows(result)
  final_result <- final_result %>% 
    # mutate(meetingnr = as.numeric(meetingnr)) %>% 
    group_by(samling_id) %>%
    arrange(meetingnr, .by_group = TRUE)
  return(final_result)
}