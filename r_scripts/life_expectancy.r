# Title: Life Expectancy
# Date: 2023-10-10
# Purpose: Script Purpose
# /* cSpell:disable */


# Library --------------
library(dplyr)
library(ggplot2)
library(tidyr)
library(HMDHFDplus)
library(countrycode)
library(nationalparkcolors)

source("r_scripts/0_config.R")
source("r_scripts/0_settings.R")


# life expectancy graphs --------------

# Specify countries of interest
le_countries <- c("SWE", "POL", "ESP", "NLD", "BGR")

# create labels
cntry_labels <- setNames(
    countrycode(le_countries,
        origin = "iso3c",
        destination = "country.name"
    ),
    le_countries
)

# download data
le <- list()

for (i in seq_along(le_countries)) {
    le[[i]] <- readHMDweb(
        CNTRY = le_countries[i],
        "E0per",
        username = hmd_username,
        password = hmd_password,
        fixup = TRUE
    )
    le[[i]]$CNTRY <- le_countries[i]
}

# combine data
le_comb <- do.call(dplyr::bind_rows, le) %>%
    janitor::clean_names()

# create plot object
le_plot <- le_comb %>%
    filter(year %in% 1900:2021) %>%
    ggplot() +
    geom_line(aes(x = year, y = female, color = cntry), lwd = 1.25) +
    scale_x_continuous(
        limits = c(1900, 2021),
        breaks = seq(1900, 2020, 20)
    ) +
    scale_color_manual(
        values = park_palette("ArcticGates", length(le_countries)),
        labels = cntry_labels
    ) +
    labs(
        x = "Year", y = "Female Period Life Expectancy in Years",
        caption = "Source: Human Mortality Database"
    ) +
    theme_base() +
    theme(
        legend.position = "bottom",
        legend.title = element_blank()
    )

# save plot for text
ggsave(
    filename = "graphs/le_text.png",
    plot = le_plot,
    width = 25, height = 25, units = "cm"
)

# save plot for presentation
ggsave(
    filename = "graphs/le_pres.png",
    plot = le_plot,
    width = 32, height = 18, units = "cm"
)
