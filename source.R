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

## Usage of fuel oil
sampweights = cbswt$FINALWT
wts = cbswt[, -1]
des = svrepdesign(weights=sampweights, repweights=wts, type="JK1", 
                  scale = 4/197, rscales = rep(1, 197), mse=TRUE,
                  data=cbsdt)
psumm = svyby(~fo_used, by=~gov+div, des, svytotal) %>%
  mutate(percent = fo_usedTRUE / (fo_usedTRUE + fo_usedFALSE))
p1 = ggplot(psumm, aes(x=div, y=percent, fill=gov)) +
  geom_bar(position="dodge", stat="identity") +
  scale_x_discrete(guide=guide_axis(n.dodge=2)) +
  xlab('Division') +
  ylab('Percent of buildings using fuel oil') +
  theme(legend.title = element_blank())
ptotal = svyby(~fo_used, by=~gov, des, svytotal)
ps = psumm %>% rename(ownership=gov, division=div, `percent used`=percent,
                      "fuel oil used" = fo_usedTRUE,
                      "fuel oil not used" = fo_usedFALSE) %>%
  mutate(`LB used` = `fuel oil used`-qnorm(.975)*se1,
         `UB used` = `fuel oil used`+qnorm(.975)*se1,
         `LB not used` = `fuel oil not used`+qnorm(.975)*se2,
         `UB not used` = `fuel oil not used`+qnorm(.975)*se2) %>%
  select(-c(se1, se2))
pchi = data.frame(matrix(ncol = 3, nrow = 10))
names(pchi) = c("Division", "Chi-squared statistic", "p-value")
pchi$Division = c(levels(cbsdt$div), "Total")
a = chisq.test(ptotal[, 2:3])
# Pearson chi-squared tests
for(i in 1:9) {
  res = chisq.test(psumm[(2 * i - 1):(2 * i), 3:4])
  pchi[i, 2] = res$statistic
  pchi[i, 3] = ifelse(res$p.value < 0.001, "p < 0.001", round(res$p.value, 3))
}
pchi[10, 2] = a$statistic
pchi[10, 3] = ifelse(a$p.value < 0.001, "p < 0.001", round(a$p.value, 3))

## Consumption
fouseddf = cbind(cbswt, cbsdt) %>% filter(fo_used == TRUE)
sampweights1 = fouseddf$FINALWT
wts1 = fouseddf[, 2:198]
des1 = svrepdesign(weights=sampweights1, repweights=wts1, type="JK1", 
                   scale = 4/197, rscales = rep(1, 197), mse=TRUE,
                   data=fouseddf)
pconsm = svyby(~total, by=~gov+div, des1, svymean) %>%
  mutate(lower = total - se * qnorm(.975),
         upper = total + se * qnorm(.975)) %>%
  rename(mean = total)
p2 = ggplot(pconsm, aes(x=div, y=mean, fill=gov)) +
  geom_bar(position="dodge", stat="identity") +
  geom_errorbar(aes(ymin=lower, ymax=upper), width=.2,
                position=position_dodge(.9)) +
  scale_x_discrete(guide=guide_axis(n.dodge=2)) +
  xlab('Division') +
  ylab('Mean annual consumption of fuel oil (thousand BTU)') +
  theme(legend.title = element_blank())
ptotcon = svyby(~total, by=~gov, des1, svymean) %>%
  mutate(lower = total - se * qnorm(.975),
         upper = total + se * qnorm(.975)) %>%
  rename(mean = total)
ptotcon$div = "Total"
pcon = rbind(pconsm, ptotcon)

## Uses
puses = svyby(~heating + cooling + waterheating + cooking + other,
              by=~gov+div, des1, svymean) 
ptuses = svyby(~heating + cooling + waterheating + cooking + other,
               by=~gov, des1, svymean) 
ptuses$div = "Total"
pus = rbind(puses, ptuses) %>% select(-starts_with("se"))
p3 = pus %>% 
  pivot_longer(-c(gov, div), names_to = "use", values_to = "consumption") %>%
  ggplot(aes(fill=use, x=gov, y=consumption)) +
  geom_bar(position="stack", stat="identity") +
  ylab('Annual onsumption (thousand BTU)') +
  xlab('Division') +
  facet_wrap(~div)

## Type
ptype = svyby(~fo_type, by=~gov+div, des1, svytotal) 
pttype = svyby(~fo_type, by=~gov, des1, svytotal)
pttype$div = "Total"
ptp = rbind(ptype, pttype) %>% select(-starts_with("se"))
p4 = ptp %>%
  pivot_longer(-c(gov, div), names_prefix = "fo_type",
               names_to = "type", values_to = "count") %>%
  ggplot(aes(fill=type, x=gov, y=count)) +
  geom_bar(position="fill", stat="identity") +
  ylab('Percent') +
  xlab('Division') +
  facet_wrap(~div)
