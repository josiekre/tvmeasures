#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {


  output$remix_output <- renderDataTable(iris)

  output$cultural_environmental <- renderDataTable(iris)

  output$conveyal_output <- renderDataTable(iris)

  map = leaflet() %>% addTiles() %>% setView(-93.65, 42.0285, zoom = 17)

  output$raster_output <- renderLeaflet(map)


})
