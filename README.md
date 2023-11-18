# First Year Seminar

This repository contains the code and output for the visualizations of my first-year seminar as part of my PhD at the Department of Human Geography at Lund University. The visualizations illustrate the factors driving population aging in Sweden and selected European countries.

### Graphs
I begin by presenting changes in the period of female life expectancy and total fertility rates since 1900. Following that, I display the change in age structure in Sweden using age pyramids. Subsequently, I present different population projection scenarios created by Eurostat. The data presentation concludes with a map showcasing the median age for NUTS3 regions in Europe, highlighting the spatial variation of population aging.

### Data
The data is sourced from the [Human Mortality database](https://www.mortality.org/), the [Human Fertility database](https://www.humanfertility.org/) as well as Eurostat. The code is utilizing the [HMDHFDplus](https://cran.r-project.org/web/packages/HMDHFDplus/index.html) and [eurostat](https://cran.r-project.org/web/packages/eurostat/index.html) packages to download the data which simplifies the reproducibility.
The code uses an untracked "config.R" file to store passwords for the Human Mortality and fertility database. These would need to be added to the code separately by the user.  

## Presentation
Shortly before the seminar, this repository will also contain the text and presentation with updated figures.
