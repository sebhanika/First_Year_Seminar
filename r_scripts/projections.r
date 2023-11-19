# Title: Projections
# Date: 2023-10-16
# Purpose: Script Purpose
# /* cSpell:disable */

# Libraries --------------
library(readxl)
library(eurostat)
library(dplyr)
library(nationalparkcolors)
library(ggplot2)
library(ggthemes)
library(tidyr)


# Eurostat projections --------------

# get data
age_proj_raw <- get_eurostat("proj_23np", time_format = "num")

# define countries
proj_countries <- c("SE", "PL", "ES", "NL", "BG", "EU27_2020")

# create labels
country_labels <- c(
    SE = "Sweden", PL = "Poland", ES = "Spain",
    NL = "Netherlands", BG = "Bulgaria", EU27_2020 = "EU27"
)

proj_labels <- c(
    BSL = "Baseline", LFRT = "Lower Fertility",
    LMRT = "Lower mortatliy", HMIGR = "Higher Migration",
    LMIGR = "Lower Migration", NMIGR = "No migration"
)

# create filtered data for plots
dat_country_proj <-
    age_proj_raw %>%
    filter(
        geo %in% proj_countries,
        age %in% c("TOTAL", "Y_GE65"),
        sex == "T"
    ) %>%
    group_by(projection, geo, time) %>%
    reframe(values_new = values / lag(values, 1)) %>%
    drop_na(values_new)

# plot object
plot_country_proj <- dat_country_proj %>%
    ggplot(aes(
        x = time, y = values_new,
        shape = projection, color = projection
    )) +
    geom_point(size = 0.75) +
    geom_line(lwd = 0.3) +
    scale_color_manual(
        values = park_palette("ArcticGates", length(proj_countries)),
        labels = proj_labels
    ) +
    scale_shape_manual(
        values = c(1, 2, 3, 4, 5, 6),
        labels = proj_labels
    ) +
    labs(
        x = "Year", y = "Share of people aged 65+",
        caption = "Source: Eurostat"
    ) +
    facet_wrap(~geo, ncol = 2, labeller = as_labeller(country_labels)) +
    theme(
        legend.position = "bottom",
        panel.spacing = unit(1.2, "lines"),
        legend.key.size = unit(3, "line")
    )

# save plot
ggsave(
    filename = "graphs/age_proj_text.png",
    plot = plot_country_proj,
    width = 25, height = 25, units = "cm"
)

# plot needs editing for presentation (dimensions)
ggsave(
    filename = "graphs/age_proj_pres.png",
    plot = plot_country_proj,
    width = 32, height = 18, units = "cm"
)
