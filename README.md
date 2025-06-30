# Folketingets mødeutræk via FTP 

## Beskrivelse

Dette projekt indeholder en samling af R-scripts, der henter, parser og producerer rensede datasæt. Projektet er opdelt i moduler for at sikre god struktur, genbrug og nem vedligeholdelse.

Målet er at automatisere arbejdet med at hente og bearbejde referater fra Folketingets forhandlinger. 
Referaterne fra møderne findes som XML-filer via en FTP-server og kan findes på [Folketingets hjemmeside](https://www.ft.dk/da/dokumenter/dokumentlister/referater). 
Disse data parses og renses, så de er klar til videre analyse.


Mødefilerne er referater 
---

## Funktionalitet
Funktionalitet: Projektet indeholder funktioner til:

- Henting og parsing af mappe- og fillister fra en offentlig FTP
- Overblik over samlinger og antal møder pr. år
- Hentning af XML-filer for specifikke møder
- Parsing af mødeindhold (talere, dagsordenspunkter, talerens navn, gruppe, titel, tidspunkt mv.).
 Mulighed for filtrering på samling, mødenummer og taler.
- Automatisk retry ved fejl og progress-bar ved mange filer
- Gem data til .csv.

---

## Mappestruktur

```
/
├── R/                  # R scripts og moduler
│   ├── ftp_utils.R         # Funktioner til FTP-download og filhåndtering
│   ├── meeting_files.R     # Funktioner til håndtering og filtrering af mødefiler
│   ├── xml_parsing.R       # Funktioner til parsing af XML-filer
│   ├── rds_split.R         # Funktion til at splitte større datasæt op efter samling_id
│   └── main_processing.R   # Hovedfunktioner til at hente alle filer
├── meeting_data/       # Mappe til at gemme dataframes til .csv-filer
├── meeting_data_rds/   # Alle mødefiler delt op efter samlinger hentet den 26/06-2025
├── main.R              # Script der sourcer moduler og kører hovedprocessen
└── README.md           # README.md
```

---

## Hovedfunktionerne

**hent_og_parse_moeder()**: Inputparametre:

| Parameter         | Type               | Beskrivelse                                                                                     |
| ----------------- | ------------------ | ----------------------------------------------------------------------------------------------- |
| `samling_id`      | karakter / df      | ID eller liste af samlinger (fx "20221") eller en dataframe med `samling_id` og evt. `meet_id`. |
| `year`            | numerisk/karakter  | Alternativ til `samling_id`, fx `c(2009:2024)` – henter alle samlinger mellem 2009 og 2024.     |
| `meet_id`         | karakter (valgfri) | Filtrerer på specifikke møder (fx "M5").                                                        |
| `full_name`       | karakter (valgfri) | Navn på taler, bruges til at filtrere møder der indeholder vedkommende.                         |
| `max_retry`       | heltal             | Antal forsøg hvis FTP fejler.                                                                   |
| `retry_delay`     | heltal             | Sekunders pause mellem forsøg.                                                                  |
| `pause`           | numerisk           | Pause mellem hver download/parsing (i sekunder).                                                |
| `output_filename` | karakter           | Navn på evt. CSV-output.                                                                        |
| `output_dir`      | karakter           | Outputmappe til gemte filer.                                                                    |
| `save_as_csv`     | boolean            | Skal resultatet gemmes som CSV?                                                                 |




**hent_opdaterede_moedefiler()**: Inputparametre:

| Argument | Type               | Forklaring                                                                         |
| -------- | ------------------ | ---------------------------------------------------------------------------------- |
| `since`  | Date eller POSIXct | Dato hvorfra man vil tjekke for opdateringer. Default er i går (`Sys.Date() - 1`). |


**meeting_data_rds**: 
hent_og_parse_moedefiler() er kørt den 25/06-2025 og gemt i mappen "meeting_data_rds"





