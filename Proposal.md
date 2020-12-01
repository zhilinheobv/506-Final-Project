# Final Project Proposal

Author: Zhilin He, zhilinhe@umich.edu

Date: Dec 2nd, 2020

## Data

This project uses the 2012 CBECS Survey Data:
[Link](https://www.eia.gov/consumption/commercial/data/2012/index.php)

## Questions

Topic: The relationship between ownership status and fuel oil usage for
commercial buildings in US.

 - **Are government-owned commercial buildings in US more likely to
 use fuel oil as an energy source? Do they consume more fuel oil?**
 - **Does this relationship differ in different census regions?**
 - **What is fuel oil used for? Is the usage different for government-owned
 buildings?**

## Variable Descriptions

| Variables Name  | Variable Description                           |
| --------------- |:----------------------------------------------:|
| PUBID           | Building ID                                    |
| REGION          | Census region                                  |
| CENDIV          | Census division                                |
| GOVOWN          | Government owned (1) or not (2)                |
| GOVTYP          | Type of government                             |
| FKUSED          | Uses fuel oil/diesel/kerosene (1) or not (2)   |
| FKTYPE          | Fuel oil, diesel or kerosene used              |
| FKHTBTU         | Fuel oil^ used for heating (thousand BTU)      |
| FKCLBTU         | Fuel oil used for cooling (thousand BTU)       |
| FKWTBTU         | Fuel oil used for water heating (thousand BTU) |
| FKCKBTU         | Fuel oil used for cooking (thousand BTU)       |
| FKOTBTU         | Fuel oil used for other reasons (thousand BTU) |
| FKBTU           | Annual fuel oil consumption (thousand BTU)     |
| FKEXP           | Annual fuel oil expenditure ($)                |

^ Including diesel and kerosene. Same with "Fuel oil" below.

## Language and set-up

This project mainly uses R. The following packages are used: survey, ggplot2,
tidyverse.

## Outline

1. Data cleaning and visualization. Choose variables relevant to the question.
There are no missing values for the chosen variables.

2. Do some basic tests like chi-square tests for the whole dataset and for 
different regions/divisions.

3. Using the given survey weights, we can use a regression model to determine 
whether government owned commercial buildings use more fuel oil as an energy 
source. Confidence intervals for fuel oil consumption of buildings in different
regions can be constructed.

4. We can consider using propensity score analysis to infer possible causal
relationship between ownership status and fuel oil usage.<sup>[3]</sup>

## References

1. CBECS: [Link](https://www.eia.gov/consumption/commercial/)

2. Jackknife resampling in Wikipedia:
[Link](https://en.wikipedia.org/wiki/Jackknife_resampling)

3. Propensity Score Analysis with Survey Weighted Data:
[Link](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5802372/)


