<!-- README.md is generated from README.Rmd. Please edit that file -->
About
=====

This package includes Qualified Health Plan (qhp) data in the Health Insurance Marketplace.

Installation
============

``` r
# install.packages("devtools")
devtools::install_github("jjchern/qhp")
```

Usage
=====

``` r
library(dplyr)

qhp::enrollment2014 %>% 
  filter(!is.na(PlanSelections)) %>% 
  group_by(countyname) %>% 
  summarise(enrollment = sum(PlanSelections)) %>% 
  arrange(desc(enrollment))
#> Source: local data frame [1,396 x 2]
#> 
#>             countyname enrollment
#>                  (chr)      (int)
#> 1    Miami-Dade County     256975
#> 2       Broward County     152745
#> 3        Harris County     139989
#> 4          Cook County     101171
#> 5        Dallas County      87370
#> 6      Maricopa County      77729
#> 7    Palm Beach County      75851
#> 8        Orange County      74027
#> 9         Bexar County      61539
#> 10 Philadelphia County      60724
#> ..                 ...        ...
```
