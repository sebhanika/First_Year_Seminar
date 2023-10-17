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

# get eurostat
age_proj_raw <- get_eurostat("proj_23np", time_format = "num")
z
# temp storage
saveRDS(age_proj_raw, file = "data/age_proj_temp.RDS")

age_proj_raw <- readRDS("data/age_proj_temp.RDS")


# get data for sweden
age_proj_swe <- age_proj_raw %>%
    filter(
        geo == "SE",
        age %in% c(paste0("Y", 1:100)),
        sex %in% c("F", "M")
    ) %>%
    mutate(
        age = as.numeric(gsub("^.", "", age)),
        sex = factor(sex, levels = c("M", "F"))
    )



# Settings for labeling and filter for plot
years_p <- c(2040, 2060, 2080, 2100)
max_pop <- max(age_proj_swe$values)

# get first two digits of rounded max pop. expressed in thousands
max_pop_lim <- round(max_pop, -4)
max_pop_label <- as.numeric(substr(max_pop_lim, 1, 2))

# get breaks for axis, needs negative values
pop_brks <- seq(-max_pop_lim, max_pop_lim, max_pop_lim / 2)
# get nice labels
pop_labels <- abs(seq(-max_pop_label, max_pop_label, max_pop_label / 2))


# age pyramid plot
age_pyrs_proj <- age_proj_swe %>%
    filter(time %in% years_p, projection == "BSL") %>%
    ggplot(aes(
        x = age,
        y = ifelse(sex == "M", -values, values),
        fill = sex
    )) +
    geom_bar(stat = "identity") +
    scale_y_continuous(
        limits = c(-max_pop, max_pop),
        breaks = pop_brks,
        labels = pop_labels
    ) +
    scale_fill_manual(
        values = park_palette("ArcticGates", 2),
        labels = c("Male", "Female")
    ) +
    coord_flip() +
    labs(
        x = "Age",
        y = "Population in Thousand"
    ) +
    facet_wrap(~time) +
    theme(
        legend.position = "bottom",
        legend.title = element_blank()
    )
age_pyrs_proj



# save plot
ggsave(
    filename = "graphs/age_proj_swe.png",
    plot = age_pyrs_proj,
    width = 25, height = 25, units = "cm"
)



# Projections --------------

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
    labs(x = "Year", y = "Share of people aged 65+") +
    facet_wrap(~geo, ncol = 2, labeller = as_labeller(country_labels)) +
    theme(
        legend.position = "bottom",
        panel.spacing = unit(1.2, "lines"),
        legend.key.size = unit(3, "line")
    )
plot_country_proj

# save plot
ggsave(
    filename = "graphs/age_proj_countries.png",
    plot = plot_country_proj,
    width = 25, height = 25, units = "cm"
)
