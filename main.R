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


overblik <- overblik_samlinger() # Overblik over samlingerne



# --- Brug af funktionerne ---



