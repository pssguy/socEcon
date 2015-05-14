library(shiny)
library(shinythemes)

library(DT)
library(ggvis)
library(tidyr)
library(dplyr)
library(readr)
library(leaflet)
library("choroplethr")
library(choroplethrMaps)
library(rgdal)
library(stringr)


library(XML)
library(httr)

library(WDI)



# for leaflet maps
countries <- readOGR(dsn=".",
                     layer = "ne_50m_admin_0_countries", 
                     encoding = "UTF-8",verbose=FALSE)

## need to set up for - . in Pew Morality
issues <- c("extramarital.affairs", "gambling","homosexuality","abortion","premarital.sex","alcohol.use","divorce", "contraception.use")
issues2 <- c("extramarital-affairs", "gambling","homosexuality","abortion","premarital-sex","alcohol-use","divorce", "contraception-use")


### world bank indicators = needs to be here to be available in ui
## WDI indicators (? specific set? look at openDataBlog to see details?)
indicators <- read_csv("WDI/popWDI.csv")


##
indicatorChoice <- indicators$indicator
names(indicatorChoice) <- indicators$description

