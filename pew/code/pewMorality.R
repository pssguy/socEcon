## read in files
# countries already there via global.R

allUnacc <- read_csv("pew/allUnacc.csv")
allAcc <- read_csv("pew/allAcc.csv")
allNot <- read_csv("pew/allNot.csv")



observe({
  
  if (is.null(input$choiceA)) return()
  
  if (input$choiceA=="Unacceptable"){ 
    summary.df <- allUnacc
  } else if (input$choiceA=="Acceptable") {
    summary.df <- allAcc  
  } else {
    summary.df <- allNot  
  }
  xtitle <- paste0("% Countries finding ",input$choiceA)
  summary.df %>% 
    gather(category,pc,-Country) %>% 
    group_by(category) %>% 
    ggvis(~pc, stroke= ~category,fill = ~category) %>% 
    layer_densities(fillOpacity := 0.5) %>%
    set_options(width = "auto", height = 400, resizable=FALSE) %>% 
    hide_axis("y") %>% 
    add_axis("x", title = xtitle) %>% 
    bind_shiny('summary')
  
})  


output$table <- DT::renderDataTable({
  if(is.null(input$choiceB)) return()
  if (input$choiceB=="Unacceptable") {
    DT::datatable(allUnacc, rownames=FALSE,options=list(paging = FALSE, searching = FALSE,info=FALSE))
  } else if (input$choiceB=="Acceptable") {
    DT::datatable(allAcc, rownames=FALSE,options=list(paging = FALSE, searching = FALSE,info=FALSE))
  } else {
    DT::datatable(allNot, rownames=FALSE,options=list(paging = FALSE, searching = FALSE,info=FALSE))
  }
})



observe({
#   print("input$choice")
#   print(input$choiceC)
  if (is.null(input$choiceC)) {
    df <- allUnacc
  }
  else if (input$choiceC=="Unacceptable") {
    df <- allUnacc
  }  else if (input$choiceC=="Acceptable") {
    df <- allAcc
  } else {
    df <- allNot
  }
  
#   print("input$issues") 
#   print(input$issues) 
  if (is.null(input$issues)) {
    theIssues <- c("Country","extramarital.affairs","divorce")
  }
  else  {
    theIssues <- c("Country",input$issues)
  }
  
#  print(theIssues)
  df <- data.frame(df)
#   print("str df")
#   print(str(df))
  test <-df %>% 
    mutate(tot=.[[2]]+.[[3]]+.[[4]]+.[[5]]+.[[6]]+.[[7]]+.[[8]]) %>% 
    arrange(desc(tot))
#   print("glimpse(test)")
#   print(glimpse(test))
  # str(test) # just df
  
  test2 <-  test %>% 
    # select(-tot) %>% 
    select(one_of(theIssues))
#  print(str(test2))
  
  test2 %>%
    gather(category,pc,-Country) %>% 
    
    group_by(category) %>%
    
    
    ggvis(~pc,~Country,fill = ~category) %>% 
    layer_points() %>% 
    add_axis("x", title = "%") %>% 
    add_axis("y", title = "") %>%
    set_options(width = "auto", height = 600, resizable=FALSE) %>% 
    bind_shiny('plot1')
})


# leaflet map




output$leafletMap <- renderLeaflet({
  
  if (is.null(input$choiceD)) return()
  if (input$choiceD=="Unacceptable") {
    temp <-allUnacc
    myTitle="Unacceptable" # for legend which still has issues
  } else if (input$choiceD=="Acceptable"){
    temp <-allAcc
    myTitle="Acceptable" 
  } else {
    temp <-allNot
    myTitle="Not Issue"   
  }
  # correct country names
  temp[temp$Country=="Britain",]$Country <- "United Kingdom"
  temp[temp$Country=="Czech Republic",]$Country <- "Czech Rep."
  temp[temp$Country=="Palestinian ter.",]$Country <- "Palestine"
  temp[temp$Country=="South Korea",]$Country <- "Korea"
  
  temp <- data.frame(temp)
  
  #colnames(temp)
  
  print("input$issues2")
  print(input$issues2)
  
  theCol <- str_replace(input$issues2,"-",".")
  #theCol <- "gambling"
  print(theCol)
  
  theCols <- c("Country",theCol)
  
  #temp <- temp[,c("Country","extramarital.affairs")]
  temp <- temp[,theCols]
  colnames(temp)[[2]] <- "value"
  
  countries2 <- sp::merge(countries, 
                          temp, 
                          by.x = "name", 
                          by.y = "Country",                    
                          sort = FALSE) 
  if (input$buckets!=1) {
    pal <- colorQuantile("RdBu", domain=NULL, n = input$buckets,na.color="#d3d3d3") #default na.color = "#808080" and I think this is what shows
  } else {
    pal <- colorNumeric("RdBu", domain=c(0,100), na.color="#d3d3d3") 
  }
  
  # reduce to countries covered by survey
  countries2 <- countries2[!is.na(countries2$value),] # this does work and gets map
  
  # create popup
  popUp<- sprintf("<table cellpadding='4' style='line-height:1'><tr>
                        <th>%1$s</th></tr>
                
                <tr align='center'><td>%2$s%%</td></tr>
                
                </table>",
                  countries2$name,
                  countries2$value
                  
                  
  )
  
  # render map
  
  countries2 %>% 
    leaflet() %>% 
    setView(lng=0,lat=0,zoom= 1) %>% 
    addTiles()  %>% # default to openstreetmap
    addPolygons(fillColor = ~pal(value), weight=1,color = "#BDBDC3"
                ,fillOpacity=0.9,
                popup = popUp) %>% 
    addLegend(pal=pal,values=~value ,title=myTitle)%>% 
    mapOptions(zoomToLimits="first") 
})

