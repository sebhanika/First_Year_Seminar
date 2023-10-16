# Title: spatial_pop_age
# Date: 2023-10-15
# Purpose: Script Purpose


library(tidyverse)
library(geojsonsf)
library(sf)
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
    mutate(area = as.numeric(st_area(geometry) / 1000000)) # calc area


age_dat <- get_eurostat("demo_r_pjanind3", time_format = "num") %>%
    filter(indic_de == "MEDAGEPOP", time == 2021)




# map settings

# creating custom color palette
self.palette <- c("#cc99ff", "#C2E699", "#78C679", "#31A354", "#006837")

# create bins for chrolopeth map

data_bins <- round(BAMMtools::getJenksBreaks(dat_map$values, k = 6), 0)


dat_map <- nuts3 %>%
    left_join(age_dat, by = c("geo")) %>%
    mutate(val_int = cut(values,
        breaks = data_bins, ,
        labels = c(
            "34 - 41", "42 - 44",
            "45 - 47", "48 - 50",
            "50-56"
        )
    ))



dat_map %>%
    ggplot() +
    geom_sf(aes(fill = as.factor(val_int)), linewidth = 0.11) +
    coord_sf(xlim = c(-13, 37), ylim = c(33, 72), expand = FALSE) +
    scale_fill_manual("Median Age", values = self.palette) +
    theme_base()


# save plot
ggsave(
    filename = "graphs/age_pyr_swe.png",
    plot = age_pyrs,
    width = 25, height = 25, units = "cm"
)





# Leaflet Map --------------

# creating custom color palette
self.palette <- c("#cc99ff", "#C2E699", "#78C679", "#31A354", "#006837")

# create bins for chrolopeth map

data_bins <- BAMMtools::getJenksBreaks(dat_map$values, k = 6)


data.pal <- colorBin(
    palette = self.palette,
    na.color = "#F8F8F8", # specify NA color
    domain = dat_map$values,
    bins = data_bins
)



# Specify what should be shown when clicking on municipality up content
dat_map$popup <- paste(
    "<strong>", dat_map$name_latn, "</strong>", "</br>",
    dat_map$values, "</br>"
)



leaflet() %>%
    addProviderTiles(providers$CartoDB.Positron) %>%
    # polygons of Municipalities with Employment Growth data
    addPolygons(
        data = dat_map,
        stroke = TRUE,
        weight = 0.1,
        color = "#ABABAB",
        smoothFactor = 0.3,
        opacity = 0.9, # of stroke
        fillColor = ~ data.pal(dat_map$values),
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
            "33.8 - 41.8", "41.8-45.4", "45.4-49.1",
            "49.1-56.3", "56.3+", "No data"
        ),
        colors = c(
            "#cc99ff", "#C2E699", "#78C679",
            "#31A354", "#006837", "#F8F8F8"
        )
    )

data_bins
