if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, tidyquant, tidytext, lubridate, odbc, rebus, gghighlight, DataExplorer, devtools, skimr, magrittr,rvest, tidygraph, ggraph, colorspace, RCurl)
devtools::install_github('bradisbrad/olfatbones'); library(olfatbones)

tenn_link <- 'https://www.tn.gov/health/cedep/ncov.html'
if(as.numeric(format(Sys.time(), '%H')) >= 15){
  dt <- Sys.Date()
} else {
  dt <- Sys.Date() - 1
}

## Types
tn_types <- read_csv(here::here('data/tn_types.csv'))
types <- read_html(tenn_link) %>% 
  html_nodes('table') %>% 
  html_table() %>% 
  `[[`(1) %>% 
  set_names(c('type', 'total', 'negative', 'positive')) %>%
  as_tibble() %>% 
  filter(type != 'Total positives in TN') %>% 
  mutate(type = c('TN Govt', 'TN Comm')) %>% 
  mutate_at(vars(total, negative, positive), as.numeric)
types <- distinct(bind_rows(tn_types, types))
write_csv(types, here::here('data/tn_types.csv'))

## Counties
tn_locs <- read_csv(here::here('data/tn_locs.csv'))
locs <- read_html(tenn_link) %>% 
  html_nodes('table') %>% 
  html_table() %>% 
  `[[`(2) %>% 
  as_tibble() %>% 
  rename(cases = 2) %>% 
  mutate(date = dt)
locs <- distinct(bind_rows(tn_locs, locs))
write_csv(locs, here::here('data/tn_locs.csv'))

## Age Ranges
tn_ages <- read_csv(here::here('data/tn_ages.csv'))
ages <- read_html(tenn_link) %>% 
  html_nodes('table') %>% 
  html_table(header = F) %>% 
  `[[`(3) %>% 
  as_tibble() %>% 
  rename(range = 1,
         cases = 2) %>% 
  mutate(cases = as.numeric(cases)) %>% 
  filter(!is.na(cases),
         range != "")
ages <- distinct(bind_rows(tn_ages, ages))
write_csv(ages, here::here('data/tn_ages.csv'))



