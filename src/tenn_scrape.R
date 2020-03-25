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
tn_types <- read_csv('C:\\Users\\brad_hill\\Documents\\proj\\pers\\repo\\hamco_corona\\data\\tn_types.csv')
type_table <- read_html(tenn_link) %>% 
  html_nodes('table') %>% 
  html_table() %>% 
  map(names) %>% 
  map(~any(grepl('Type', .))) %>% 
  purrr::flatten_lgl() %>% 
  which(.)

types <- read_html(tenn_link) %>% 
  html_nodes('table') %>% 
  html_table() %>% 
  `[[`(type_table) %>% 
  set_names(c('type', 'total', 'negative', 'positive')) %>%
  as_tibble() %>% 
  filter(row_number() <= 2) %>% 
  mutate(type = c('TN Govt', 'TN Comm')) %>% 
  mutate_at(vars(total, negative, positive), olfatbones::split_numeric) %>% 
  mutate(date = dt)
types <- distinct(bind_rows(tn_types, types))
write_csv(types, 'C:\\Users\\brad_hill\\Documents\\proj\\pers\\repo\\hamco_corona\\data\\tn_types.csv')

## Counties
tn_locs <- read_csv('C:\\Users\\brad_hill\\Documents\\proj\\pers\\repo\\hamco_corona\\data\\tn_locs.csv')
loc_table <- read_html(tenn_link) %>% 
  html_nodes('table') %>% 
  html_table() %>% 
  map(names) %>% 
  map(~any(grepl('County', .))) %>% 
  purrr::flatten_lgl() %>% 
  which(.)

locs <- read_html(tenn_link) %>% 
  html_nodes('table') %>% 
  html_table() %>% 
  `[[`(loc_table) %>% 
  as_tibble() %>% 
  rename(cases = 2) %>% 
  mutate(date = dt)
locs <- distinct(bind_rows(tn_locs, locs))
write_csv(locs, 'C:\\Users\\brad_hill\\Documents\\proj\\pers\\repo\\hamco_corona\\data\\tn_locs.csv')

## Age Ranges
tn_ages <- read_csv('C:\\Users\\brad_hill\\Documents\\proj\\pers\\repo\\hamco_corona\\data\\tn_ages.csv')
age_table <- read_html(tenn_link) %>% 
  html_nodes('table') %>% 
  html_table() %>% 
  map(names) %>% 
  map(~any(grepl('Age', .))) %>% 
  purrr::flatten_lgl() %>% 
  which(.)

ages <- read_html(tenn_link) %>% 
  html_nodes('table') %>% 
  html_table(header = F) %>% 
  `[[`(age_table) %>% 
  as_tibble() %>% 
  rename(range = 1,
         cases = 2) %>% 
  mutate(cases = split_numeric(cases)) %>% 
  filter(!is.na(cases),
         range != "") %>% 
  mutate(date = dt)
ages <- distinct(bind_rows(tn_ages, ages))
write_csv(ages, 'C:\\Users\\brad_hill\\Documents\\proj\\pers\\repo\\hamco_corona\\data\\tn_ages.csv')



