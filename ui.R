

# Define UI for application that draws a histogram
shinyUI(
    
    dashboardPage(
        
        dashboardHeader(title = "Airbnb in United Kingdom") , 
        
        dashboardSidebar( 
            
            sidebarMenu(
                
                menuItem(text = "Dashboard", icon = icon("globe-europe"), tabName = "dashboard" ) ,
                
                menuItem(text = "Statistics", icon = icon("chalkboard"), tabName = "stat") ,
                
                menuItem(text = "Trend", icon = icon("calendar-alt"), tabName = "trend") ,
                
                menuItem(text = "Data", icon = icon("database"), tabName = "data")
            )
            
        ) ,
        
        dashboardBody(  
            
            tabItems( 
                
                tabItem(tabName = "dashboard", align = "center",
                        
                        # page header
                        h2("UK Airbnb Distribution") ,
                        
                        ## widget input
                        div(style = "display:inline-block",
                            pickerInput(inputId = "selectCity", 
                                        label = "Select City",
                                        selected = c("London"), 
                                        choices = c("Bristol", "Edinburgh", "Manchester", "London"),
                                        options = list(`actions-box` = TRUE,
                                                       `none-selected-text` = "Please make a selection!"))
                        ) ,
                        
                        div(style = "display:inline-block",
                            uiOutput("borough")
                            
                        ),
                        
                        div(style = "display:inline-block",
                            uiOutput("rooms")
                            
                        ),
                        
                        
                        fluidRow(
                            
                            column(3, ) ,
                            
                            
                            column(3,
                                
                                   uiOutput("prices")
                                
                            ) ,
                            
                            
                            column(3,
                                   
                                   uiOutput("nights")
                                   
                                   ) ,
                            
                            column(3, )
                            
                        ),
                        
                        
                        ## leaflet London maps
                        leafletOutput(outputId = "dash_maps")
                        
                ) ,   
                
                tabItem(tabName = "stat",
                        
                        fluidRow(
                            
                            column(3,
                                   h2("Statistic Informations", align = "center"),
                                   uiOutput("airbnbInfo")
                            ),
                            
                            column(9, align = "center",
                                   h2("Top-N Borough"),
                                   
                                   # input widget
                                   
                                   pickerInput(inputId = "selectCityTop", 
                                               label = "Select City",
                                               selected = c("London"), 
                                               choices = c("Bristol", "Edinburgh", "Manchester", "London"),
                                               options = list(`actions-box` = TRUE,
                                                              `none-selected-text` = "Please make a selection!")),
                                   
                                   sliderInput(inputId = "topN", 
                                               label = "Select Top-N Value",
                                               min = 0, 
                                               max = 10, 
                                               value = 5) ,
                                   
                                   plotOutput(outputId = "topNmost")
                                   
                            )
                        )
                        
                        
                        
                ),   
                
                
                tabItem(tabName = "trend",
                        
                        tabsetPanel(type = "pills",
                                    
                                    tabPanel("Based on Price", align = "center",
                                             
                                             pickerInput(inputId = "selectCitytrendsPrice", 
                                                         label = "Select City",
                                                         selected = c("London"), 
                                                         choices = c("Bristol", "Edinburgh", "Manchester", "London"),
                                                         options = list(`actions-box` = TRUE,
                                                                        `none-selected-text` = "Please make a selection!")),
                                             
                                             fluidRow(
                                                 
                                                 column(6,
                                                        
                                                        plotlyOutput(outputId = "mo_price")
                                                        
                                                 ),
                                                 
                                                 column(6,
                                                        
                                                        
                                                        plotlyOutput(outputId = "year_price")
                                                        
                                                 )
                                             )
                                             
                                             
                                    ),
                                    
                                    tabPanel("Based on Reviews", align = "center",
                                             
                                             pickerInput(inputId = "selectCitytrendsReviews", 
                                                         label = "Select City",
                                                         selected = c("London"), 
                                                         choices = c("Bristol", "Edinburgh", "Manchester", "London"),
                                                         options = list(`actions-box` = TRUE,
                                                                        `none-selected-text` = "Please make a selection!")),
                                             
                                             fluidRow(
                                                 
                                                 column(6,
                                                        
                                                        plotlyOutput(outputId = "mo_revs")
                                                        
                                                 ),
                                                 
                                                 column(6,
                                                        
                                                        
                                                        plotlyOutput(outputId = "year_revs")
                                                        
                                                 )
                                             )
                                             
                                    ),
                                    
                                    tabPanel("Based on Availability", align = "center",
                                             
                                             pickerInput(inputId = "selectCityAvailability", 
                                                         label = "Select City",
                                                         selected = c("Edinburgh"), 
                                                         choices = c("Bristol", "Edinburgh", "Manchester", "London"),
                                                         options = list(`actions-box` = TRUE,
                                                                        `none-selected-text` = "Please make a selection!")),
                                             
                                             fluidRow(
                                                 
                                                 column(6,
                                                        
                                                        plotlyOutput(outputId = "year_avail")
                                                        
                                                 ),
                                                 
                                                 column(6,
                                                        
                                                        
                                                        plotlyOutput(outputId = "price_avail")
                                                        
                                                 )
                                             )
                                             
                                    )
                                    
                        )
                        
                        
                        
                        
                ),
                
                
                
                tabItem(tabName = "data", align = "center",
                        
                        h2("Airbnb Listings in UK"), # h2 = heading 2
                        
                        # input widget
                        
                        selectInput(inputId = "selectCityframe", 
                                    label = "Select City",
                                    selected = c("Bristol"), 
                                    choices = c("Bristol", "Edinburgh", "Manchester", "London")),
                        
                        
                        DT::dataTableOutput(outputId = "table")
                        
                )  
                
            )
            
        )
        
    )
)