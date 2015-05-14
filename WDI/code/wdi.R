# ## WDI indicators (? specific set? look at openDataBlog to see details?)
# indicators <- read_csv("WDI/popWDI.csv")
# 
# 
# ##
# indicatorChoice <- indicators$indicator
# names(indicatorChoice) <- indicators$description


indy <- reactive({
  
  choice <- input$indicator
  # print(choice) choice <- "EN.ATM.CO2E.PC"
  
  dat <- WDI(country = "all", 
             indicator = choice, 
             start = 1980, 
             end = 2015)
  
  #dat$SP.DYN.LE00.IN <- round(dat$SP.DYN.LE00.IN, 1)
  dat[3] <- round(dat[3], 1)
  #head(dat[3]) #head(dat,1) #str(dat)
  names(dat)[3] <- "value"
  #dat <-dat[!is.na(dat$value),]
  #dat[dat$value<0,]$value <- 0
  print(min(dat$value))
  minYr <- min(dat[!is.na(dat$value),]$year)
  maxYr <- max(dat[!is.na(dat$value),]$year)
  description <- indicators[indicators$indicator==choice,]$description
  #print(description)
  info=list(dat=dat,minYr=minYr,maxYr=maxYr,description=description)
  # print(maxYr)
  # print(str(dat))
  return(info)
  
  
})


# 
# ## Perform the merge.  The sort = FALSE argument is crucial here - but be sure to double-check as merge 
# ## can behave badly with spatial objects in R. 
# 
# 
#print("so good so far")








mb_tiles <- "http://a.tiles.mapbox.com/v3/kwalkertcu.l1fc0hab/{z}/{x}/{y}.png"

mb_attribution <- 'Mapbox <a href="http://mapbox.com/about/maps" target="_blank">Terms &amp; Feedback</a>'

#df <- data.frame(Age_Range=levels(cut(countries2$SP.DYN.LE00.IN,6)))
#print("so good so far")

# class(countries2) #SpatialPolygonsDataFrame
#  str(countries2@data)
# 'data.frame':  241 obs. of  66 variables:
# inc $ SP.DYN.LE00.IN: num  75.2

output$a <- renderUI({
  #    maxYr <- as.integer(indy()$maxYr)
  #    print(maxYr)
  
  inputPanel(
    
    sliderInput("year","Choose Year",min=indy()$minYr, max=indy()$maxYr,value=indy()$maxYr,step=1,sep=""),
    sliderInput("buckets","No. Groups (1=continuous)",min=1, max=11,value=6,step=1,sep="")
  )
})

uiOutput('a')
## Create the map

dt <- reactive({ 
  
  
  yearDat <- indy()$dat %>% 
    filter(year==input$year)
  
  #   yearDat <- dat %>% 
  #   filter(year==1999)
  
  countries2 <- sp::merge(countries, 
                          yearDat, 
                          by.x = "iso_a2", 
                          by.y = "iso2c",                    
                          sort = FALSE)
  
  if (input$buckets>1){
    df <- data.frame(valueRange=levels(cut(countries2$value,input$buckets)))
    valueRange <-(levels(df$valueRange))
  } else {
    df <- NULL
    valueRange <- NULL
  }
  
  # print(str(df))
  
  
  country_popup <- paste0("<strong>Country: </strong>", 
                          countries2$country, 
                          "<br><strong>",indy()$description," ",input$year,": </strong>",
                          countries2$value)
  
  
  info=list(countries2=countries2,df=df,country_popup=country_popup,valueRange=valueRange)
  return(info)
  
})


output$ages <- renderText({
  if (is.null(indy()$maxYr)) return()
  if (is.null(dt()$valueRange)) return()
  paste(indy()$description,"   ",paste(dt()$valueRange,collapse=", "))
})

textOutput("ages")

output$WDImap <- renderLeaflet({
  if (is.null(input$buckets)) return()
  if (input$buckets!=1) {
    pal <- colorQuantile("RdBu", NULL, n = input$buckets)
  } else {
    # pal <- colorBin(colorRamp(c("#FFFFFF", "#006633"), interpolate="spline"),domain=NULL)
    pal <- colorBin(colorRamp(c("#b2182b", "#2166ac"), interpolate="spline"),domain=NULL)
  }
  
  #    print("print class")
  #    print(class(dt()$countries2))
  
  leaflet(data = dt()$countries2) %>%
    addTiles(urlTemplate = mb_tiles,  
             attribution = mb_attribution) %>%
    addPolygons(fillColor = ~pal(value), 
                fillOpacity = 0.8, 
                color = "#BDBDC3", 
                weight = 1, 
                popup = dt()$country_popup) %>% 
    mapOptions(zoomToLimits="first")
})