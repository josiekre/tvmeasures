#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(tvmeasures)
library(leaflet)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {


  output$remix_output <- renderDataTable({

    if (is.null(input$remix_file)){
      return (NULL)
    }
    inFile <- input$remix_file


    tryCatch({
      d <- read_csv(inFile$datapath) %>%
        transmute(
          `Project` = project,
          `Efficiency` = asset_mgmt(population, jobs, service_miles),
          `Compatibility` = landuse_comp(population, jobs),
          `Social Equity` = social_equity(pct_minority, pct_poverty)
        )

      DT::datatable(d) %>%
        DT::formatRound(2:3) %>%
        DT::formatPercentage(4)



    }, error = function(e){
      stop(e)

    })

  })

  output$cultural_environmental <- renderDataTable(iris)

  output$conveyal_output <- renderDataTable(iris)

  map = leaflet() %>% addTiles() %>% setView(-93.65, 42.0285, zoom = 17)

  output$raster_output <- renderLeaflet(map)


})
