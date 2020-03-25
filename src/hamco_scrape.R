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
  html_nodes(xpath = '/html/body/form/div[4]/div[2]/div/div[2]/section/div[1]/div/div[2]/div/div[2]/div/div/div/p[4]/span[2]') %>% 
  html_text()

if(length(dt) == 0){
  if(hour(Sys.time()) < 15){
  dt <- Sys.Date() - 1
  } else {
    dt <- Sys.Date()
  }
} else {
  dt <- mdy(dt)
}

hamco_row  %<>%  
  mutate(date = dt,
         createdate = Sys.time())

hamco_tbl <- read_csv('C:\\Users\\brad_hill\\Documents\\proj\\pers\\repo\\hamco_corona\\data\\hamco_tbl.csv')
hamco_tbl <- distinct(bind_rows(hamco_tbl, hamco_row)) %>% 
  group_by(date) %>% 
  filter(createdate == max(createdate)) %>% 
  ungroup()
write_csv(hamco_tbl, 'C:\\Users\\brad_hill\\Documents\\proj\\pers\\repo\\hamco_corona\\data\\hamco_tbl.csv')
