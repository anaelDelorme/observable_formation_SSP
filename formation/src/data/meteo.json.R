library(readr)
library(purrr)
library(dplyr)
library(stringr)
library(jsonlite)

setwd("/workspaces/observable_formation_SSP/formation/src/data/")

# Lister tous les fichiers CSV dans le répertoire
fichiers_csv <- list.files(pattern = "\\.csv$", full.names = TRUE)

# Lire et combiner tous les fichiers CSV
donnees_combinees <- fichiers_csv %>%
  map_dfr(~ {
    # Lire le fichier CSV
    df <- read_delim(.x, delim = ";")
    # Extraire le code départemental à partir du nom de fichier
    code_departement <- str_extract(basename(.x), "\\d{2}")
    # Ajouter la colonne code_departement au dataframe
    df <- df %>%
      select(NUM_POSTE, NOM_USUEL, LAT, LON, AAAAMMJJ, RR, TN, TX, TAMPLI, DG) %>%
      rename(id_poste = NUM_POSTE,
             nom_poste = NOM_USUEL,
             lat = LAT,
             lon = LON,
             date = AAAAMMJJ,
             precipitation = RR,
             temp_min = TN,
             temp_max = TX,
             ampli_thermique = TAMPLI,
             duree_gel_minute = DG) %>%
      mutate(code_departement = as.character(code_departement))

  })


# Exporter les données en JSON
write_json(donnees_combinees, path = "meteo.json")

