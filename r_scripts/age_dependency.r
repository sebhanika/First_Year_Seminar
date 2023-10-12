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
    rename(pop = Total2)
