if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, tidyquant, tidytext, lubridate, odbc, rebus, gghighlight, DataExplorer, devtools, skimr, magrittr,rvest, tidygraph, ggraph, colorspace, RCurl)
devtools::install_github('bradisbrad/olfatbones'); library(olfatbones)

hamco_link <- "http://health.hamiltontn.org/AllServices/Coronavirus(COVID-19).aspx"

hamco_row <- read_html(hamco_link) %>% 
  html_nodes('table') %>% 
  html_table() %>% 
  `[[`(1) %>% 
  set_names(c('headers', 'value')) %>% 
  mutate(headers = stringr::word(headers, 1)) %>% 
  pivot_wider(names_from = headers)

dt <- read_html(hamco_link) %>% 
  html_nodes('#dnn_ctr3740_HtmlModule_lblContent > p:nth-child(4) > span:nth-child(2)') %>% 
  html_text()

hamco_row  %<>%  
  mutate(date = mdy(dt),
         createdate = Sys.time())

hamco_tbl <- read_csv(here::here('data/hamco_tbl.csv'))
hamco_tbl <- distinct(bind_rows(hamco_tbl, hamco_row)) %>% 
  group_by(date) %>% 
  filter(createdate == max(createdate)) %>% 
  ungroup()
write_csv(hamco_tbl, here::here('data/hamco_tbl.csv'))
