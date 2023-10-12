# Title: fertility
# Date: 2023-10-10
# Purpose: Script Purpose



# /* cSpell:disable */


library(dplyr)
library(ggplot2)
library(tidyr)
library(HMDHFDplus)
library(ggthemes)


source("r_scripts/0_config.R")
source("r_scripts/0_settings.R")



# Crude birth rates --------------

swe_pop <- readHMDweb(
    CNTRY = "SWE",
    "Population",
    username = hmd_username,
    password = hmd_password,
    fixup = TRUE
) %>%
    select(c(Year, Age, Total2)) %>%
    rename(pop = Total2) %>%
    group_by(Year) %>%
    summarise(across(
        .cols = c(pop),
        .fns = ~ sum(.x, na.rm = TRUE)
    )) %>%
    ungroup()


# crude birth rate
swe_births <- readHMDweb(
    CNTRY = "SWE",
    "Births",
    username = hfd_username,
    password = hfd_password,
    fixup = TRUE
) %>%
    select(-c(Female, Male)) %>%
    rename(births = Total)


swe_dat <- swe_births %>%
    left_join(swe_pop, by = c("Year")) %>%
    mutate(
        cbr = births / (pop / 1000)
    )



plot(swe_dat$Year, swe_dat$cbr, type = "l")



# TFR --------------

# Specify countries of interest
tfr_countries <- c("SWE", "POL", "ESP", "AUT", "NLD", "BGR")
tfr <- list()

# download data
for (i in seq_along(tfr_countries)) {
    tfr[[i]] <- readHFDweb(
        CNTRY = tfr_countries[i],
        username = hfd_username,
        password = hfd_password,
        item = "tfrRR",
        fixup = TRUE
    )
    tfr[[i]]$CNTRY <- tfr_countries[i]
}

# combine data
tfr_comb <- do.call(dplyr::bind_rows, tfr) %>%
    janitor::clean_names()


tfr_comb %>%
    filter(year %in% 1900:2021) %>%
    ggplot() +
    geom_line(aes(x = year, y = tfr)) +
    scale_x_continuous(
        limits = c(1900, 2021),
        breaks = seq(1900, 2020, 30)
    ) +
    theme_base() +
    facet_wrap(~cntry)

?scale_x_continuous()

tfr_comb %>%
    filter(year %in% 1900:2021) %>%
    ggplot() +
    geom_line(aes(x = year, y = tfr, color = cntry)) +
    scale_x_continuous(limits = c(1900, 2021), breaks = seq(1900, 2020, 20)) +
    theme_base()
