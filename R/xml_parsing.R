library(xml2)
library(purrr)
library(tibble)
library(stringr)

safe_xml_text <- function(node, xpath) {
  res <- xml_find_first(node, xpath)
  if (inherits(res, "xml_missing") || is.na(res)) return(NA_character_)
  xml_text(res)
}

parse_meeting_xml <- function(xml_input) {
  ft_xml <- if (is.character(xml_input)) read_xml(xml_input) else xml_input
  
  meetingnr <- safe_xml_text(ft_xml, ".//MeetingNumber")
  date_of_sitting <- safe_xml_text(ft_xml, ".//DateOfSitting")
  
  agenda_points <- xml_find_all(ft_xml, ".//DagsordenPunkt")
  
  agenda_df <- map_dfr(agenda_points, function(punkt) {
    itemNum <- safe_xml_text(punkt, ".//ItemNo")
    title   <- safe_xml_text(punkt, ".//ShortTitle")
    start   <- safe_xml_text(punkt, ".//StartDateTime")
    caseNumber <- safe_xml_text(punkt, ".//FTCaseNumber")
    caseType <- safe_xml_text(punkt, ".//FTCaseType")
    caseStage <- safe_xml_text(punkt, ".//FTCaseStage")
    speeches <- xml_find_all(punkt, ".//Tale")
    
    speech_df <- map_dfr(speeches, function(tale) {
      first_name <- safe_xml_text(tale, ".//OratorFirstName")
      last_name  <- safe_xml_text(tale, ".//OratorLastName")
      full_name  <- paste(trimws(first_name), trimws(last_name))
      
      tibble(
        meetingnr       = meetingnr,
        date_of_sitting = date_of_sitting,
        itemNum         = itemNum,
        caseNumber = caseNumber,
        caseType = caseType,
        caseStage = caseStage,
        title           = title,
        full_name       = full_name,
        group           = safe_xml_text(tale, ".//GroupNameShort"),
        tale_text       = xml_text(tale),
        start_time      = safe_xml_text(tale, ".//StartDateTime"),
        end_time        = safe_xml_text(tale, ".//EndDateTime"),
        rolle           = safe_xml_text(tale, ".//TalerTitel")
      )
    })
    
    speech_df
  })
  
  return(agenda_df)
}
