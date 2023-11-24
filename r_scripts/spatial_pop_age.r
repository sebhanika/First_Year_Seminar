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
library(htmlwidgets)


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

data_bins <- BAMMtools::getJenksBreaks(dat_map$values, k = 6)

med_age <- dat_map %>%
    mutate(val_int = cut(values,
        breaks = data_bins, ,
        labels = c(
            "33.8 - 40.7", "40.7 - 43.8",
            "43.8 - 46.5", "46.5 - 49.5",
            "49.5 - 55.8"
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

# Leaflet map --------------

# leaflet needs WGS to work
dat_leaflet <- med_age %>%
    st_transform(4326)

# create bins for chrolopeth map


data_pal <- colorBin(
    palette = self_palette,
    na.color = "#757575", # specify NA color
    domain = dat_leaflet$values,
    bins = data_bins
)



# Specify what should be shown when clicking on municipality up content
dat_leaflet$popup <- paste(
    "<strong>", dat_leaflet$name_latn, "</strong>", "</br>",
    dat_leaflet$values, "</br>"
)


map_leaflet <-
    leaflet() %>%
    addProviderTiles(providers$CartoDB.PositronNoLabels) %>%
    # polygons of Municipalities with Employment Growth data
    addPolygons(
        data = dat_leaflet,
        stroke = TRUE,
        weight = 0.1,
        color = "#ABABAB",
        smoothFactor = 0.3,
        opacity = 0.9, # of stroke
        fillColor = ~ data_pal(dat_leaflet$values),
        fillOpacity = 0.8,
        popup = ~popup,
        highlightOptions = highlightOptions(
            color = "#E2068A", # highlights borders when hovering
            weight = 1.5,
            bringToFront = TRUE,
            fillOpacity = 0.5
        )
    ) %>%
    addLegend(
        position = "bottomright", # adding legend
        opacity = 0.9,
        title = "Median Age 2021",
        labels = c(
            "33.8 - 40.7", "40.7 - 43.8",
            "43.8 - 46.5", "46.5 - 49.5",
            "49.5 - 55.8", "No values"
        ),
        colors = c(self_palette, "#757575")
    )

saveWidget(map_leaflet,
    file = "graphs/map_leaflet.html",
    selfcontained = FALSE
)
