library(dplyr)

server <- function(input, output, session) {

  # Reactive expression for the data subsetted to what the user selected
  filteredData <- reactive({
    filter(res_sent, Lead..ppb. >= input$range[1] & Lead..ppb. <= input$range[2])
    # slow way of filtering. trying the dplyr way
    # res_sent[res_sent$Lead..ppb. >= input$range[1] & res_sent$Lead..ppb. <= input$range[2], ]
  })

  # color palette function
  pal <- colorFactor(palette = c("red", "green"),
                      domain = c("Below 15ppb", "Above 15ppb"))

  # Render the static map with leaflet() first. Dynamic changes will be below.
  output$map <- renderLeaflet({
    leaflet(res_sent) %>%
      addTiles() %>%
      #fitBounds(~min(Longitude), ~min(Latitude), ~max(Longitude), ~max(Latitude)) %>%
      setView(lat = 43.03, lng = -83.67, zoom = 12) # zoom=12.5 doesn't work. might be why fitBounds() not working
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
        weight = 3,
        #color = "#777777",
        stroke = TRUE, fillOpacity = 0.5)
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
