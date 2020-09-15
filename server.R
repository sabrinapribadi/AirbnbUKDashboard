

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    
    
    # --- Dashboard Page --- #
    
    
    cities <- reactive({
        switch(input$selectCity,
               "Bristol" = bristol_listing, 
               "Edinburgh" = edinburgh_listing, 
               "Manchester" = manchester_listing, 
               "London" = london_listing
               
        )
    })
    
    
    
    city_maps <- reactive({
        switch(input$selectCity,
               "Bristol" = bristol_neigh, 
               "Edinburgh" = edinburgh_neigh, 
               "Manchester" = manchester_neigh, 
               "London" = london_neigh
               
        )
    })
    
    
    
    city_filter <- reactive({
        
        selectBorough = input$selectBorough
        selectRoom = input$selectRoom
        selectPrice = input$selectPrice
        
        cities() %>%
            filter(neighbourhood %in% selectBorough) %>% 
            filter(room_type %in% selectRoom) %>% 
            filter(between(price, input$selectPrice[1], input$selectPrice[2])) %>% 
            filter(between(minimum_nights, input$selectNights[1], input$selectNights[2]))
        
    })
    
    
    output$borough <- renderUI({
        
        div(style = "display:inline-block",
            pickerInput(inputId = "selectBorough", 
                        label = "Select Borough",
                        multiple = T,
                        selected = c("Ashley", "Abbeyhill", "Bradford", "Westminster"),
                        choices = as.character(levels(cities()$neighbourhood)),
                        options = list(`actions-box` = TRUE,
                                       `none-selected-text` = "Please make a selection!")
            )
        )
        
        
    })
    
    
    output$rooms <- renderUI({
        
        div(style = "display:inline-block",
            pickerInput(inputId = "selectRoom", 
                        label = "Select Room Type", 
                        multiple = T,
                        selected = c("Entire home/apt"),
                        choices = as.character(levels(cities()$room_type)),
                        options = list(`actions-box` = TRUE,
                                       `none-selected-text` = "Please make a selection!")
            )
        )
        
        
    })
    
    
    output$prices <- renderUI({
        
        sliderInput(inputId = "selectPrice", 
                    label = "Price Range", 
                    min = 0, 
                    max = max(cities()$price), 
                    value = c(10,500)
        )
        
    })
    
    output$nights <- renderUI({
        
        sliderInput(inputId = "selectNights", 
                    label = "Minimum Night(s) to Stay", 
                    min = 0, 
                    max = max(cities()$minimum_nights), 
                    value = c(0,5)
        )
        
    })
    
    
    # Show London maps
    output$dash_maps <- renderLeaflet({
        
        leaflet() %>%
            addTiles() %>%
            addPolygons(data = city_maps(), color = "#444444", weight = 2, opacity = 1) %>%  
            addMarkers(lng = city_filter()$longitude,
                       lat = city_filter()$latitude,
                       clusterOptions = markerClusterOptions(),
                       label = paste0("Host Name: ", city_filter()$host_name),
                       popup = paste0("Borough: ", city_filter()$neighbourhood,
                                      "<br>Room Type: ", city_filter()$room_type,
                                      "<br>Price: $", city_filter()$price,
                                      "<br>Min. Night: ", city_filter()$minimum_nights," night(s)")
            )
    })
    
    
    # --- Statistic Page --- #
    
    
    cities_top <- reactive({
        switch(input$selectCityTop,
               "Bristol" = bristol_listing, 
               "Edinburgh" = edinburgh_listing, 
               "Manchester" = manchester_listing, 
               "London" = london_listing
               
        )
    })
    
    
    observeEvent(input$selectCityTop,{
        
        value  <- 5
        updateSliderInput(session,"topN",value=value)
        
    })
    
    
    numTopN <- reactive({
        
        as.numeric(input$topN)
        
    })
    
    
    n_bor <- reactive({
        
        length(unique(cities_top()$neighbourhood))
        
        
    })
    
    n_host <- reactive({
        
        l_host <-  number(length(unique(cities_top()$host_name)), big.mark = ',', accuracy = 1)
        
        
    })
    
    avg_rent <- reactive({
        
        cities_top() %>% 
            group_by(year) %>% 
            summarize(avg_price = mean(price, na.rm = TRUE)) %>% 
            na.omit() %>% 
            top_n(1) %>% 
            mutate(avg_price = number(avg_price, big.mark = ',', accuracy = 0.01))
        
    })
    
    
    
    # Show top-N the most listings
    output$topNmost <- renderPlot({
        
        cities_top() %>% 
            group_by(neighbourhood) %>% 
            summarize(sum_neigh = n()) %>% 
            arrange(-sum_neigh) %>% 
            head(numTopN()) %>% 
            ggplot() +
            geom_bar(aes(reorder(as.factor(neighbourhood), sum_neigh), sum_neigh, fill=neighbourhood), stat = 'identity') +
            geom_text(aes(neighbourhood, sum_neigh, label = sum_neigh), hjust = 2.0,  color = "white") +
            scale_fill_brewer(palette = "Set3") +
            theme(legend.position = 'none') +
            ggtitle("The Most Listing Borough") + 
            xlab("Neighbourhood") + 
            ylab("Number of Listings") +
            theme(legend.position = 'none',
                  plot.title = element_text(color = 'black', size = 14, face = 'bold', hjust = 0.5),
                  axis.title.y = element_text(),
                  axis.title.x = element_text()) +
            coord_flip()
        
    })
    
    
    output$airbnbInfo <- renderUI({
        list(
            infoBox(
                title = "Number of Boroughs",
                value = n_bor(),
                color = "olive", 
                fill = T, 
                width = NULL,
                icon = icon("city")
            ),
            infoBox(
                title = "Number of hosts",
                value = n_host(),
                color = "olive", 
                fill = T, 
                width = NULL,
                icon = icon("house-user")
            ),
            infoBox(
                title = "Avg. Rent per Night ($)",
                value = avg_rent()[, 2],
                color = "olive", 
                fill = T, 
                width = NULL,
                icon = icon("hand-holding-usd")
            )
        )
    })
    
    
    
    # --- Trend Page --- #
    
    
    cities_trendsPrice <- reactive({
        switch(input$selectCitytrendsPrice,
               "Bristol" = bristol_listing, 
               "Edinburgh" = edinburgh_listing, 
               "Manchester" = manchester_listing, 
               "London" = london_listing
               
        )
    })
    
    
    cities_trendsReviews <- reactive({
        switch(input$selectCitytrendsReviews,
               "Bristol" = bristol_listing, 
               "Edinburgh" = edinburgh_listing, 
               "Manchester" = manchester_listing, 
               "London" = london_listing
               
        )
    })
    
    
    selectCityAvailability <- reactive({
        switch(input$selectCitytrendsReviews,
               "Bristol" = bristol_listing, 
               "Edinburgh" = edinburgh_listing, 
               "Manchester" = manchester_listing, 
               "London" = london_listing
               
        )
    })
    
    
    output$mo_price <- renderPlotly({
        
        season_mo_price <- cities_trendsPrice() %>% 
            group_by(month) %>%
            summarise(avg_pricemo=mean(price, na.rm = TRUE)) %>% 
            na.omit() %>%
            mutate(month_abbs = month.abb[month],
                   text =glue("<b>{month_abbs}</b>
                     Avg. Price: ${number(avg_pricemo, big.mark = ',', accuracy = 0.01)}"
                   )) %>%
            arrange(-month) %>% 
            ggplot(aes(month, avg_pricemo), text = text) +
            geom_point(aes(text = text), alpha = 0.5, color = "violetred") + 
            geom_line(aes(text = text), group = 1) +
            scale_y_continuous("Average Price",labels = scales::dollar) +
            scale_x_continuous("Month", breaks = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)) +
            labs(title = " Price Changes over Month")+
            theme(plot.title = element_text(hjust = 0.5))
        theme_bw()
        
        ggplotly(season_mo_price, tooltip = "text")
        
    })
    
    
    
    output$year_price <- renderPlotly({
        
        season_year_price <- cities_trendsPrice() %>%
            filter(year >= 2019) %>% 
            group_by(yearmo) %>%
            summarise(avg_price_yearmo=mean(price, na.rm = TRUE)) %>% 
            na.omit() %>%
            mutate(text =glue("<b>{yearmo}</b>
                     Avg. Price: ${number(avg_price_yearmo, big.mark = ',', accuracy = 0.01)}"
            )) %>%
            ggplot(aes(yearmo, avg_price_yearmo), text = text) +
            geom_point(aes(text = text), alpha = 0.5, color = "violetred") + 
            geom_line(aes(text = text), group = 1) +
            scale_y_continuous("Average Price",labels = scales::dollar) +
            labs(title = " Price changes over Date", x = "Date")+
            theme(plot.title = element_text(hjust = 0.5),
                  axis.text.x = element_text(angle = 50))
        theme_bw()
        
        ggplotly(season_year_price, tooltip = "text")
        
    })
    
    output$mo_revs <- renderPlotly({
        
        monthlyRev <- cities_trendsReviews() %>% 
            group_by(month) %>%
            summarise(count_rev = sum(number_of_reviews)) %>%
            na.omit() %>%
            mutate(month_abbs = month.abb[month],
                   text =glue("<b>{month_abbs}</b>
                     Total Reviews: {number(count_rev, big.mark = ',', accuracy = 1)}"
                   )) %>%
            ggplot(aes(month, count_rev), text = text) +
            geom_point(aes(text = text), color = "slategray1") + 
            geom_line(aes(month, count_rev), text = text, group = 1) +
            scale_y_continuous("Number of Reviews") +
            scale_x_continuous("Month", breaks = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)) +
            labs(title = " Monthly Seasonality", x = "Month")+
            theme(plot.title = element_text(hjust = 0.5))
        theme_bw()
        
        ggplotly(monthlyRev, tooltip = "text")
        
    })
    
    
    output$year_revs <- renderPlotly({
        
        yearlyRev <- cities_trendsReviews() %>%
            filter(year >= 2019) %>% 
            group_by(yearmo) %>%
            summarise(count_rev = sum(number_of_reviews)) %>% 
            mutate(text =glue("<b>{yearmo}</b>
                     Total Reviews: {number(count_rev, big.mark = ',', accuracy = 1)}"
            )) %>%
            ggplot(aes(yearmo, count_rev), text = text) +
            geom_point(aes(text = text), alpha = 0.5, color = "slategray1") + 
            geom_line(aes(text = text), group = 1) +
            scale_y_continuous("Number of Reviews") +
            labs(title = " Yearly Seasonality", x = "Date")+
            theme(plot.title = element_text(hjust = 0.5),
                  axis.text.x = element_text(angle = 50))
        theme_bw()
        
        ggplotly(yearlyRev, tooltip = "text")
        
    })
    
    
    output$year_avail <- renderPlotly({
        
        avail_dist <- selectCityAvailability() %>% 
            filter(!is.na(availability_365)) %>% 
            group_by(availability_365) %>% 
            mutate(count_avb = n(),
                   mean_avb = round(sum(price)/count_avb,2)) %>% 
            arrange(count_avb) %>% 
            filter(availability_365 >= 50) %>%
            mutate(text = glue("{availability_365} Days per year
                      Number of Listings: {number(count_avb, big.mark = ',', accuracy = 1)}
                      Avg. Price: ${number(mean_avb, big.mark = ',', accuracy = 0.01)}"
            )) %>% 
            ggplot(aes(availability_365, count_avb), text = text) +
            geom_point(aes(text = text), alpha = 0.15, color = "seagreen3") + 
            geom_line() +
            labs(title = " Availability During a Year", x =" Availability Days", y= "Count")+
            scale_x_continuous(breaks = seq(50, 365, 45)) +
            theme(plot.title = element_text(hjust = 0.5))
        
        ggplotly(avail_dist, tooltip = "text") %>%
            config(displaylogo = FALSE)
        
    })
    
    
    output$price_avail <- renderPlotly({
        
        avail_price <- selectCityAvailability() %>% 
            filter(!is.na(availability_365)) %>% 
            group_by(availability_365) %>% 
            mutate(count_avb = n(),
                   max_avb = max(price),
                   mean_avb = round(sum(price)/count_avb,2),
                   min_avb = min(price)) %>% 
            mutate(text =glue("{availability_365} Days per year
                     There are {count_avb} Listings
                     
                     Max. Price: ${number(max_avb, big.mark = ',', accuracy = 1)}
                     Avg. Price: ${mean_avb}
                     Min. Price: ${min_avb}"
            )) %>% 
            ggplot(aes(availability_365, price)) +
            geom_point(data = . %>% group_by(availability_365) %>% filter(price == max(price)), 
                       aes(text = text),
                       alpha = 0.2, color = "seagreen3") +
            geom_segment(aes(x=availability_365, xend=availability_365, y=0, yend=price)) +
            labs(title = " Availability vs Price", x ="Availability Days", y= "Price")+
            scale_x_continuous(breaks = seq(0, 365, 45)) +
            theme(plot.title = element_text(hjust = 0.5))
        
        ggplotly(avail_price, tooltip = "text")%>%
            config(displaylogo = FALSE)
        
    })
    
    
    
    # --- Data Page --- #
    
    
    cities_frame <- reactive({
        switch(input$selectCityframe,
               "Bristol" = bristol_listing, 
               "Edinburgh" = edinburgh_listing, 
               "Manchester" = manchester_listing, 
               "London" = london_listing
               
        )
    })
    
    
    frame_filter <- reactive({
        
        cities_frame() %>% 
            select(neighbourhood, host_name, name, price, room_type, number_of_reviews)
        
        
    })
    
    # Show Data
    
    output$table <- DT::renderDataTable({
        
        frame_filter()
    })
})
