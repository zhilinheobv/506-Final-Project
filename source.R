## Stats 506 Final Project
##
## This script is the core analysis script for the final project.
##
## Author: Zhilin He, zhilinhe@umich.edu
## Updated: December 7, 2020
# 79: -------------------------------------------------------------------------

library(survey)
library(ggplot2)
library(tidyverse)

## Load data
cbecs = read.csv("./2012_public_use_data_aug2016.csv")

## Select variables and clean the data
cbsdt = cbecs %>%
  mutate(gov=factor(GOVOWN), div=factor(CENDIV), fo_used=factor(FKUSED)) %>%
  select(id=PUBID, div, gov, fo_used, fo_type=FKTYPE, heating=FKHTBTU, 
         cooling=FKCLBTU, waterheating=FKWTBTU, cooking=FKCKBTU, 
         other=FKOTBTU, total=FKBTU, expenditure=FKEXP) %>%
  mutate(fo_type = factor(ifelse(fo_used == 1, 
                                 ifelse(fo_type %in% 4:7, 4, fo_type), NA)))
# There is 1 wrong observation for the FKTYPE variable.
cbswt = cbecs %>% select(starts_with("FINALWT")) # Replicate weights
levels(cbsdt$div)=c('New England', 'Middle Atlantic', 'East North Central',
                    'West North Central', 'South Atlantic', 
                    'East South Central', 'West South Central',
                    'Mountain', 'Pacific')
levels(cbsdt$gov) = c('Goverment', 'Non-goverment')
levels(cbsdt$fo_used) = c(TRUE, FALSE)
levels(cbsdt$fo_type) = c('Fuel oil', 'Diesel', 'Kerosene', 'More than one',
                          'Unknown')