# Title: fertility
# Date: 2023-10-10
# Purpose: Create a plot showing the TFR for selected countries
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


# TFR --------------

# Specify countries of interest
tfr_countries <- c("SWE", "POL", "ESP", "NLD", "BGR")

# create labels
cntry_labels <- setNames(
    countrycode(tfr_countries,
        origin = "iso3c",
        destination = "country.name"
    ),
    tfr_countries
)

# download data
tfr <- list()
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


# create plot
tfr_plot <- tfr_comb %>%
    filter(year %in% 1900:2021) %>%
    ggplot() +
    geom_line(aes(x = year, y = tfr, color = cntry), lwd = 1.25) +
    geom_hline(yintercept = 2.1, color = "black", lty = 2) +
    scale_x_continuous(
        limits = c(1900, 2021),
        breaks = seq(1900, 2020, 20)
    ) +
    scale_color_manual(
        values = park_palette("ArcticGates", length(tfr_countries)),
        labels = cntry_labels
    ) +
    labs(x = "Year", y = "Total Fertility Rate") +
    theme_base() +
    theme(
        legend.position = "bottom",
        legend.title = element_blank()
    )

# save plot text
ggsave(
    filename = "graphs/tfr_text.png",
    plot = tfr_plot,
    width = 25, height = 25, units = "cm"
)

# save plot presentation
ggsave(
    filename = "graphs/tfr_pres.png",
    plot = tfr_plot,
    width = 32, height = 18, units = "cm"
)
