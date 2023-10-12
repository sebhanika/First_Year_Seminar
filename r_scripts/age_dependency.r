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
    filter(age > 65) %>%
    group_by(year) %>%
    summarize(old_age_pop = sum(pop, na.rm = FALSE))


old_pop <- swe_pop %>%
    filter(age > 65) %>%
    group_by(year) %>%
    summarize(old_age_pop = sum(pop, na.rm = FALSE))


work_pop <- swe_pop %>%
    filter(age %in% 15:65) %>%
    group_by(year) %>%
    summarize(old_age_pop = sum(pop, na.rm = FALSE))
