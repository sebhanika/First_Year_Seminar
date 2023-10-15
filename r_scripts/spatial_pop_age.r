# Title: spatial_pop_age
# Date: 2023-10-15
# Purpose: Script Purpose


library(tidyverse)
library(geojsonsf)
library(sf)
library(eurostat)
library(ggthemes)

source("r_scripts/0_settings.R")

# Download data -----------------------------------------------------------

# nut2 geodata
nuts3 <- eurostat_geodata_60_2016 %>%
    janitor::clean_names() %>%
    filter(levl_code == 3) %>%
    subset(!grepl("^FRY|^FR$", nuts_id)) %>% # Exclude Oversee territories
    select(c(cntr_code, name_latn, geo, geometry)) %>%
    mutate(area = as.numeric(st_area(geometry) / 1000000)) # calc area


age_dat <- get_eurostat("demo_r_pjanind3", time_format = "num") %>%
    filter(indic_de == "MEDAGEPOP", time == 2021)


dat_map <- nuts3 %>%
    left_join(age_dat, by = c("geo"))


plot(density(dat_map$values, na.rm = TRUE))


dat_map %>%
    ggplot() +
    geom_sf(aes(fill = values)) +
    coord_sf(xlim = c(-13, 45), ylim = c(33, 72), expand = FALSE)
