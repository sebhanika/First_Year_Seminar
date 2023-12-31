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
tfr_countries <- c("SWE", "POL", "NLD", "BGR") # del when spain fixed
tfr_countries_comp <- c("SWE", "POL", "ESP", "NLD", "BGR")


# create labels
cntry_labels <- setNames(
    countrycode(tfr_countries_comp,
        origin = "iso3c",
        destination = "country.name"
    ),
    tfr_countries_comp
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


########
# Somehow there is an error when downloading spanish data
# this error just started recently, it worked before
# It could not be solved yet but  will be investigated furhter
# In the mean time one needs to download the data manually

# load spanish data

spain <- readHFD(filepath = "ESPtfrRR.txt", fixup = TRUE) %>%
    mutate(CNTRY = "ESP")


# combine data
tfr_comb <- do.call(dplyr::bind_rows, tfr) %>%
    bind_rows(spain) %>%
    janitor::clean_names()


# create plot
tfr_plot <- tfr_comb %>%
    filter(year %in% 1900:2021) %>%
    ggplot() +
    geom_line(aes(
        x = year, y = tfr,
        color = cntry, linetype = cntry
    ), lwd = 1.25) +
    geom_hline(yintercept = 2.1, color = "black", lty = 2) +
    scale_x_continuous(
        limits = c(1900, 2021),
        breaks = seq(1900, 2020, 20)
    ) +
    scale_color_manual(
        values = park_palette("ArcticGates", length(tfr_countries_comp)),
        labels = cntry_labels
    ) +
    scale_linetype_manual(
        values = c(1, 2, 3, 4, 6),
        labels = cntry_labels
    ) +
    labs(
        x = "", y = "Total Fertility Rate",
        caption = "Source: Human Fertility Database"
    ) +
    annotate("text",
        x = 1907.5, y = 2.15,
        label = "Replacement-level fertility"
    ) +
    theme_base() +
    theme(
        legend.position = "bottom",
        legend.title = element_blank(),
        legend.key.width = unit(1.5, "cm")
    )
tfr_plot

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
