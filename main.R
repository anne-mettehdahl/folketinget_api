# main.R

library(tidyverse)
library(xml2)
library(RCurl)
library(purrr)
library(lubridate)
library(progress)
library(stringr)

# Kilde dine moduler (R scripts)
r_scripts <- list.files("R", pattern = "\\.R$", full.names = TRUE)
invisible(lapply(r_scripts, source))



# --- Brug af funktionerne ---

## overblik <- overblik_samlinger() # Overblik over samlingerne

## alle_moeder <- hent_og_parse_moeder(year = c(2009:2024)) - henter alle møder

## 20181_bertel <- hent_og_parse_moeder(samling_id = "20181", full_name = "Bertel Haarder) - henter alle møder fra samling 20181 hvor Bertel Haarder snakker

## hent_opdateret_moedefiler(Sys.Date() - 7) - Henter de samlinger som er blevet opdateret den sidste uge 


