# Title: Projections
# Date: 2023-10-16
# Purpose: Script Purpose

# Source: https://population.un.org/wpp/Download/


library(readxl)
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
