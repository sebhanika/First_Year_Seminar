# First-Year Seminar

This repository contains the code and output for the visualizations of my first-year seminar as part of my PhD at the Department of Human Geography at Lund University. The visualizations illustrate the factors driving population aging in Sweden and selected European countries.

### Graphs
- I begin by illustrating the factors driving population aging in Europe. This is done by graphs depicting changes in female life expectancy [Life Expectancy](graphs/le_pres.png) and total fertility rates for selected countries from 1900 to the present.
- Following that, I display the change in age structure in Sweden using age pyramids.
- Subsequently, I present different population projection scenarios created by Eurostat (again using selected countries).
- Lastly, I show a map showcasing the median age for NUTS3 regions in Europe, highlighting the spatial variation of population aging.

### Data
The data is sourced from the [Human Mortality database](https://www.mortality.org/), the [Human Fertility database](https://www.humanfertility.org/) as well as [Eurostat](https://ec.europa.eu/eurostat/databrowser/). The code is utilizing the [HMDHFDplus](https://cran.r-project.org/web/packages/HMDHFDplus/index.html) and [eurostat](https://cran.r-project.org/web/packages/eurostat/index.html) packages to download the data which simplifies the reproducibility.
The code uses an untracked "config.R" file to store passwords for the Human Mortality and Fertility database. These would need to be added to the code separately by the user.  

## Correction
The initial version of the map depicting the median age in the NUTS3 area contained an error wherein Copenhagen was accidentally omitted. This error has been corrected, and the classes have been updated. The error stemmed from the application of a rounding function after the natural breaks classification. The overall distribution and message conveyed by the map remained unaffected by the error.

## Presentation
Shortly before the seminar, this repository will also contain the presentation with updated figures.
