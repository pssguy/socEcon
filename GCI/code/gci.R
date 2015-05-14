## could download and save to file which is read in but
## this shows method and is pretty brief anyways (for single index)

## data is in html table so this is easiest method - could look at XML2R
theUrl <- "http://www.goodcountry.org/overall"
tables = readHTMLTable(theUrl , stringsAsFactors=FALSE)

# check names and get appropriate
#names(tables)

data <- tables[["gci_data"]]

#review,name and classify columns
#str(data)
colnames(data) <- c("Rank","Country","Science","Culture","Security","World_Order","Climate","Prosperity","Health")
data[,3:9] <- lapply(data[,3:7], as.integer)

data$Rank <- as.integer(str_replace_all(data$Rank,"[a-z]",""))

# read in country shape files

countries <- readOGR(dsn=".",
                     layer = "ne_50m_admin_0_countries", 
                     encoding = "UTF-8",verbose=FALSE)

## check for differences in country names and correct
#sort(setdiff(data$Country,countries$name))

data[data$Country=="Bolivia (Plurinational State of)",]$Country <- "Bolivia"
data[data$Country=="Bosnia and Herzegovina",]$Country <- "Bosnia and Herz."
data[data$Country=="Czech Republic",]$Country <- "Czech Rep."
data[data$Country=="Democratic Republic of the Congo",]$Country <- "Dem. Rep. Congo"
data[data$Country=="Dominican Republic",]$Country <- "Dominican Rep."
data[data$Country=="Iran (Islamic Republic of)",]$Country <- "Iran"
data[data$Country=="Lao People's Democratic Republic",]$Country <- "Lao PDR"
data[data$Country=="Republic of Korea",]$Country <- "Dem. Rep. Korea"
data[data$Country=="Russian Federation",]$Country <- "Russia"
data[data$Country=="Syrian Arab Republic",]$Country <- "Syria"
data[data$Country=="United Republic of Tanzania",]$Country <- "Tanzania"
data[data$Country=="United States of America",]$Country <- "United States"
data[data$Country=="Venezuela (Bolivarian Republic of)",]$Country <- "Venezuela"
data[data$Country=="Viet Nam",]$Country <- "Vietnam"
data[data$Country=="Republic of Moldova",]$Country <- "Moldova"
data[data$Country=="The former Yugoslav Republic of Macedonia",]$Country <- "Macedonia"

# merge 
countries2 <- sp::merge(countries, 
                        data, 
                        by.x = "name", 
                        by.y = "Country",                    
                        sort = FALSE) 

# create popup

popUp <- paste0("<strong>",countries2$Rank,"  ", countries2$name, "</strong><br>",
                "<br><strong>Science: </strong>", countries2$Science, 
                "<br><strong>Culture: </strong>", countries2$Culture,
                "<br><strong>Security: </strong>", countries2$Security, 
                "<br><strong>World Order: </strong>", countries2$World_Order,
                "<br><strong>Climate: </strong>", countries2$Climate, 
                "<br><strong>Prosperity: </strong>", countries2$Prosperity)

output$gciMap <- renderLeaflet({
  
  if (is.null(input$bins)) return()
  print("input$bins")
  print(input$bins)
  buckets <- seq(from=1, to=125,by=125/input$bins)
#   buckets <- seq(from=1, to=125,by=125/5)
  
  
  for (i in 1:(length(buckets)-1)) {
    if (i!=1) {
      labs <- c(labs,paste0(floor(buckets[i]),"-",floor(buckets[i+1]-1)))
    } else {
      labs<- paste0(floor(buckets[i]),"-",floor(buckets[i+1]-1))
    }
    
  }
  labs <- c(labs,paste0(floor(buckets[i+1]),"-125"),"No Data")
  #labs
  binCount <- input$bins
  #bins <- 5
  if (binCount!=1) {
    pal <- colorQuantile("RdYlGn", domain=NULL, n = binCount,na.color="#808080") 
  } else {
    pal <- colorNumeric("RdGn", domain=c(0,100), na.color="#d3d3d3") 
  }
  
  ## render map
  
  countries2 %>% 
    leaflet() %>% 
    setView(lng=0,lat=0,zoom= 1) %>% 
    addTiles()  %>% # default to openstreetmap
    addPolygons(fillColor = ~pal(-Rank), weight=1,color = "#BDBDC3"
                ,fillOpacity=0.9 ,
                popup = popUp) %>% 
    # NB the reverse of colors Green= Good, Red= bad (or selfish)
    addLegend(colors = c(rev(RColorBrewer::brewer.pal(binCount, "RdYlGn")), "#808080"),  
              bins = binCount,
              position = 'bottomleft', 
              title = "Ranking", 
              labels = labs) %>% 
    mapOptions(zoomToLimits="first") 
})