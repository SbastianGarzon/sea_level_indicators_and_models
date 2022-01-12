# A methodology to compare sea-level indicators and sea-level models

This repository contains the code used to compile my thesis dissertation for the M.Sc Geoinformatics at the University of Münster during winter semester 2021/22. This document uses the [`oxforddown`](https://github.com/ulyngs/oxforddown) template for `R Markdown` published by Ulrik Lyngs. Prof. Pebesma (Institute of Geoinformatics - University of Münster) and Prof. Rovere (University of Venice) supervised the project. 

# Reproducibility

## Prerequisites

1. To reproduce this work you need `GDAL` in your machine. Different `GDAL` versions should work. However, the version that I used is `3.2.1`. 
In my machine, this is the `sf` loading message:
`Linking to GEOS 3.9.0, GDAL 3.2.1, PROJ 7.2.1`

2. Check that you have all the datasets described in the [`Data/README.md`]() file. You might need to [email me](mailto:jgarzon@uni-muenster.de) to access to the (60GB) NetCDF file with the GIA models.
I'm working to find a way to avoid this step. However, at this moment, this is the only option.

## Steps

1. Open the [`sea_level_indicators_and_models.Rproj`](https://github.com/SbastianGarzon/sea_level_indicators_and_models/blob/master/sea_level_indicators_and_models.Rproj) project. 

2. The first time you open the project, you need to install the R-packages. The [`renv.lock`](https://github.com/SbastianGarzon/sea_level_indicators_and_models/blob/master/renv.lock) file contains the packages required to reproduce the code. Use `renv::restore()` to install these packages.

3. Knit the document using Rstudio. 

4. Wait... The code compilation is slow. In my case, using a Macbook Air (M1,2020 - 8 GB RAM), the compilation process took around 20 hours. [Email me](mailto:jgarzon@uni-muenster.de) if you don't want to reproduce the whole process. With the cache, the knitting of the document should take less than 10 minutes.

# Cite this work

Garzon, Sebastian. 2022. A methodology to compare sea level-indicators and sea-level models. MSc Dissertation, University of Münster.
