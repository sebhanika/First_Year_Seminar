# Title: Life Expectancy
# Date: 2023-10-10
# Purpose: Script Purpose
# /* cSpell:disable */


library(dplyr)
library(ggplot2)
library(tidyr)
library(HMDHFDplus)
library(ggthemes)


source("scripts/0_config.R")
source("scripts/0_settings.R")


# life expectancy --------------

# Specify countries of interest
le_countries <- c("SWE", "POL", "ESP", "AUT", "NLD", "GBRTENW", "BGR")
le <- list()

# download data
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


le_comb %>%
    filter(year %in% 1900:2021) %>%
    ggplot() +
    geom_line(aes(x = year, y = female, color = cntry)) +
    theme_base()
