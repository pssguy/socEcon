library(shiny)

#
shinyUI(
  navbarPage("myTinyShinys",inverse=TRUE,theme = shinytheme("cosmo"),collapsible= TRUE,
             
             tabPanel("Front",
                      fluidRow(
                        column(4,
                               h4("About Socio-Economic Site"),
                               includeMarkdown("aboutSE.md"),
                               # includeCSS("custom.css"),
#                                br(),
#                                tags$body(includeScript("twitter.js"),
#                                          # tags$link(rel = 'stylesheet', type = 'text/css', href = 'custom.css'),
#                                          
                                         a("Fun", class="twitter-timeline",
                                           href="https://twitter.com/pssGuy/timelines/530058458880409600",
                                           "data-widget-id" = "530058992483958785",
                                           "data-chrome" ="nofooter transparent noheader")),
                       
                        
                        column(4),
                             #  h4(textOutput("randomChartText")),
                             #  dataTableOutput("randomChart")
                               #includeMarkdown("frontPage.md")
                               
                       
                        
                        
                        column(4)
                               #   h4("? Latest charts")
                               
                               
                        )
                        
             ),

navbarMenu("Pew Research",
           tabPanel("Religion"),
          tabPanel("Morality",
                   tabsetPanel(id="q",
                               tabPanel("Summary",
                   fluidRow(
                     column(4,
                   includeMarkdown("pew/aboutMorality.md")
                   ),
                  
                   
                  
                     column(8,
                            radioButtons("choiceA",label="",choices=c("Unacceptable","Acceptable","Not a Moral Issue"), inline=TRUE), 
                            ggvisOutput('summary'))
                   )),
                   tabPanel("Table",
                            
                                     radioButtons("choiceB",label="",choices=c("Unacceptable","Acceptable","Not a Moral Issue"), inline=TRUE), 
                                     DT::dataTableOutput("table", width=200) # width test did not work)
                             
                   ), # end tabPanel
                   
                   tabPanel("Graph",
                            
                          
                            checkboxGroupInput("issues","",choices=issues,selected=c("extramarital.affairs","divorce"), inline=TRUE),
                            radioButtons("choiceC",label="",choices=c("Unacceptable","Acceptable","Not a Moral Issue"), inline=TRUE),
                            
                            ggvisOutput('plot1')
                            
                   ), # end tabPanel
                   tabPanel("Map",
                            
                            
                            radioButtons("choiceD",label="",choices=c("Unacceptable","Acceptable","Not a Moral Issue"), inline=TRUE),
                            radioButtons("issues2",label="",choices=issues2, inline=TRUE),
                            numericInput("buckets","Groups(1 is continuous)",value=4,min=1,max=9,step=1),
                            
                            leafletOutput('leafletMap')
                            
                   ) # end tabPanel      
                   
                   ))),

             tabPanel("Good Country Index",
                      fluidRow(
                        column(4,
                               includeMarkdown("GCI/aboutGCI.md")
                        ),
                        
                        
                        
                        column(8,
                               numericInput("bins","Groups(1 is continuous)",value=5,min=1,max=9,step=1)#,
                              # leafletOutput("gciMap")
                              )
                      )),
           
             tabPanel("World Development",
                      inputPanel(
                        selectInput("indicator", "Choose Indicator", indicatorChoice),
                        leafletOutput("WDImap")
                      )),
                     
            tabPanel("World Bank"),
             
             
             
             
             #              tabPanel("MiniApps",
             #                       tags$iframe(src="https://pssguy.shinyapps.io/UKcharts/blog.Rmd", width = "1000", height="600",frameborder=0, seamless="seamless")
             #              )#,
             
             navbarMenu("mts Sites",
                        tabPanel(a("Premier League", href="https://mytinyshinys.shinyapps.io/premierLeague")),
                        tabPanel(a("Sports", href="https://mytinyshinys.shinyapps.io/sports")),
                        tabPanel(a("Science", href="https://mytinyshinys.shinyapps.io/science")),
                        tabPanel(a("Socio-Economic", href="https://mytinyshinys.shinyapps.io/socioEconomic")),
                        tabPanel(a("Diversions", href="https://mytinyshinys.shinyapps.io/diversions"))
                        
             )
             
             
             
             
             
  ))

