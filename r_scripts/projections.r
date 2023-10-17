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

# UN projections --------------

# Source: https://population.un.org/wpp/Download/

df_list <- lapply(excel_sheets("data/UN_PPP2022_Output_PopPerc.xlsx"), function(x) {
    read_excel("data/UN_PPP2022_Output_PopPerc.xlsx", sheet = x, skip = 16)
})

df_list[[6]] <- NULL


dat <- lapply(df_list, function(x) {
    x %>%
        janitor::clean_names() %>%
        filter(region_subregion_country_or_area == "EUROPE") %>%
        mutate(x65 = as.numeric(x65)) %>%
        select(c(variant, year, x65))
})


dat_comb <- do.call(dplyr::bind_rows, dat)

dat_comb %>%
    ggplot(aes(x = year, y = x65, color = variant)) +
    geom_line() +
    theme_base()


# Eurostat projections --------------

# get eurostat
age_proj_raw <- get_eurostat("proj_23np", time_format = "num")

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







try1 <-
    age_proj_raw %>%
    filter(
        geo %in% c("SE", "BG", "PL", "NL", "ES", "EU27_2020"),
        age %in% c("TOTAL", "Y_GE65"),
        sex == "F"
    ) %>%
    group_by(projection, geo, time) %>%
    summarize(values_new = values / lag(values, 1)) %>%
    drop_na(values_new) %>%
    ungroup()



try1 %>%
    ggplot(aes(x = time, y = values_new, linetype = projection)) +
    geom_line() +
    facet_wrap(~geo, ncol = 2)
