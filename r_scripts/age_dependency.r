# Title: Old-age dependency
# Date: 2023-10-12
# Purpose: Script Purpose

# /* cSpell:disable */

library(dplyr)
library(ggplot2)
library(tidyr)
library(HMDHFDplus)
library(gganimate)
library(nationalparkcolors)

source("r_scripts/0_config.R")
source("r_scripts/0_settings.R")

# Age pyramid data  --------------

swe_pop <- readHMDweb(
    CNTRY = "SWE",
    "Population",
    username = hmd_username,
    password = hmd_password,
    fixup = TRUE
) %>%
    select(c(Year, Age, Total2)) %>%
    rename(pop = Total2) %>%
    janitor::clean_names()

dep_pop <- swe_pop %>%
    filter(age %!in% 15:65) %>%
    group_by(year) %>%
    summarize(dep_pop = sum(pop, na.rm = FALSE))


old_pop <- swe_pop %>%
    filter(age > 65) %>%
    group_by(year) %>%
    summarize(old_pop = sum(pop, na.rm = FALSE))


work_pop <- swe_pop %>%
    filter(age %in% 15:65) %>%
    group_by(year) %>%
    summarize(work_pop = sum(pop, na.rm = FALSE))


dat_plot <- dep_pop %>%
    left_join(old_pop) %>%
    left_join(work_pop) %>%
    mutate(
        old_pop_ratio = old_pop / work_pop,
        dep_pop_ratio = dep_pop / work_pop
    ) %>%
    select(-c(old_pop, work_pop, dep_pop)) %>%
    pivot_longer(
        cols = c(old_pop_ratio, dep_pop_ratio)
    )



# create plot object
dat_plot %>%
    filter(year %in% 1900:2021) %>%
    ggplot() +
    geom_line(aes(x = year, y = value, color = name), lwd = 1.25) +
    scale_x_continuous(
        limits = c(1900, 2021),
        breaks = seq(1900, 2020, 20)
    ) +
    scale_color_manual(
        values = park_palette("ArcticGates", 3)
    ) +
    labs(x = "Year", y = "Dep ratios") +
    theme_base() +
    theme(
        legend.position = "bottom",
        legend.title = element_blank()
    )
