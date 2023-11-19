# Title: spatial_pop_age
# Date: 2023-10-15
# Purpose: Script Purpose

# /* cSpell:disable */

library(tidyverse)
library(geojsonsf)
library(sf)
library(ggspatial)
library(eurostat)
library(ggthemes)
library(leaflet)

source("r_scripts/0_settings.R")

# Download data -----------------------------------------------------------

# nut2 geodata
nuts3 <- eurostat_geodata_60_2016 %>%
    janitor::clean_names() %>%
    filter(levl_code == 3) %>%
    subset(!grepl("^FRY|^FR$", nuts_id)) %>% # Exclude Oversee territories
    subset(cntr_code != "TR") %>% # Exclude Turkey territories
    select(c(cntr_code, name_latn, geo, geometry)) %>%
    st_transform(3035)

age_dat <- get_eurostat("demo_r_pjanind3", time_format = "num") %>%
    filter(indic_de == "MEDAGEPOP", time == 2020)

# map settings

# creating custom color palette
self_palette <- c("#eff3ff", "#bdd7e7", "#6baed6", "#3182bd", "#08519c")

# bounding box
xlim <- c(2426378.0132, 6593974.6215)
ylim <- c(1328101.2618, 5446513.5222)

# create bins for chrolopeth map
dat_map <- nuts3 %>% left_join(age_dat, by = c("geo"))

data_bins <- round(BAMMtools::getJenksBreaks(dat_map$values, k = 6), 0)

med_age <- dat_map %>%
    mutate(val_int = cut(values,
        breaks = data_bins, ,
        labels = c(
            "34 - 41", "42 - 44",
            "45 - 47", "48 - 50",
            "50-56"
        )
    ))


age_map <- med_age %>%
    ggplot() +
    geom_sf(aes(fill = as.factor(val_int)),
        linewidth = 0.1, alpha = 1
    ) +
    coord_sf(xlim = xlim, ylim = ylim, expand = FALSE) +
    scale_fill_manual("Median Age",
        values = self_palette,
        na.value = "#a7a7a7"
    ) +
    labs(caption = "Source: Eurostat") +
    theme_base() +
    theme(
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        legend.position = c(0.91, 0.88)
    ) +
    annotation_scale(height = unit(0.15, "cm"))


# save plot
ggsave(
    filename = "graphs/age_map.png",
    plot = age_map,
    width = 25, height = 25, units = "cm"
)
