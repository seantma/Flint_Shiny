library(shiny)
library(leaflet)

source('data_clean.R')

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 10,
                sliderInput("range", "Lead Level", min(res_sent$Lead..ppb.), max(res_sent$Lead..ppb.),
                            value = range(res_sent$Lead..ppb.), step = 15),
                # selectInput("colors", "Color Scheme",
                #             rownames(subset(brewer.pal.info, category %in% c("seq", "div")))),
                checkboxInput("legend", "Show legend", TRUE)
  )
)
