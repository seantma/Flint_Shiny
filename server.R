server <- function(input, output, session) {
  
  # Reactive expression for the data subsetted to what the user selected
  filteredData <- reactive({
    res_sent[res_sent$Lead..ppb. >= input$range[1] & res_sent$Lead..ppb. <= input$range[2], ]
  })
  
  # color palette function 
  pal <- colorFactor(palette = c("green","red"), 
                      domain = c("Safe", "unSafe"))
  
  # Render the static map with leaflet() first. Dynamic changes will be below.
  output$map <- renderLeaflet({
    leaflet(res_sent) %>% 
      addTiles() %>%
      #fitBounds(~min(Longitude), ~min(Latitude), ~max(Longitude), ~max(Latitude))
      setView(lat = 43.03, lng = -83.67, zoom = 12)
  })
  
  # Incremental changes to the map with leafletProxy().
  # Here, replacing the circles when new color is chosen.
  observe({
    leafletProxy("map", data = filteredData()) %>%
      clearMarkers() %>%
      addCircleMarkers(
        label = paste0("Source: ", res_sent$source, ", Lead: ", res_sent$Lead..ppb.), 
        lat = ~Latitude, lng = ~Longitude,
        radius = ~(log(res_sent$Lead..ppb.)+5),
        color = ~pal(LeadLevel),
        #fillColor = ~pal(LeadLevel), 
        weight = 5, 
        #color = "#777777",
        stroke = FALSE, fillOpacity = 0.5)
    })
  
  # Use a separate observer to recreate the legend as needed.
  observe({
    proxy <- leafletProxy("map", data = res_sent)
    proxy %>% clearControls()
    
    if (input$legend) {
      proxy %>% 
        addLegend(position = "bottomright", pal = pal, values = ~LeadLevel)
    }
  })
}
