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

shinyServer(function(input, output) {


  # Remix output table
  #
  # This returns a datatable with three columns, one for each of the remix-
  # derived measures.
  #
  remix_table <- reactive({
    validate(
      need(input$remix_file != "", "Please select a Remix results CSV file")
    )

    inFile <- input$remix_file

    read_csv(inFile$datapath) %>%
      transmute(
        `Project` = project,
        `Efficiency` = asset_mgmt(population, jobs, service_miles),
        `Compatibility` = landuse_comp(population, jobs),
        `Social Equity` = social_equity(pct_minority, pct_poverty)
      )
  })

  output$remix_output <- renderDataTable({
    DT::datatable(remix_table()) %>%
      DT::formatRound(2:3) %>%
      DT::formatPercentage(4)
  })

  output$download_remix <- downloadHandler(
    filename = function(){"remix_output.csv"},
    content = function(file){
      write_csv(remix_table(), file)
    }
  )

  cultenv_table <- reactive({
    validate(
      need(input$cultenv_file != "",
           "Please select a cultural/environmental shape file")
    )

    ce_file <- input$cultenv_file$datapath

    sf::st_read(ce_file, stringsAsFactors = FALSE) %>%
      dplyr::group_by(project) %>%
      dplyr::summarise(
        cultenv = (sum(SUM) / sum(COUNT)) * sum(Acres)
      ) %>%
      dplyr::tbl_df()


  })

  output$cultural_environmental <- renderDataTable({
    DT::datatable(cultenv_table()) %>%
      DT::formatRound(2, digits = 0)
  })

  output$download_cultenv <- downloadHandler(
    filename = function(){"cultenv_output.csv"},
    content = function(file){
      write_csv(cultenv_table(), file)
    }
  )


  conveyal_table <- reactive({
    validate(
      need(input$tiffs != "", "Please select project tiff files"),
      need(input$raster_base != "", "Please select a base scenario .tiff file"),
      need(input$raster_pop  != "", "Please select a population weights tiff file"),
      need(input$raster_eta  != "", "Please select an ETA-weights tiff file")
    )

    project_files <- input$tiffs$datapath
    conveyal <- lapply(project_files, function(p){
      read_tiff(p)
    })

    names(conveyal) <- tools::file_path_sans_ext(basename(input$tiffs$name))

    # load reference files
    base_path <- input$raster_base$datapath
    base_tiff <- read_tiff(base_path)
    pop_path  <- input$raster_pop$datapath
    pop_tiff  <- read_tiff(pop_path)
    eta_path  <- input$raster_eta$datapath
    eta_tiff <-  read_tiff(eta_path)


    # Run the above function for total- and eta-weighted populations, and
    # join the results into a single table
    left_join(

      # total population weighted results
      table_builder(conveyal, base_tiff, pop_tiff, "pop"),

      # eta population weighted results
      table_builder(conveyal, base_tiff, eta_tiff, "eta"),

      by = "project"
    ) %>%
      transmute(
        Project = project,
        `POP Access` = `pop_total_%`/100,
        `POP 70` = `pop_70%`,
        `POP 90` = `pop_90%`,
        `EQ Access` = `eta_total_%`/100,
        `EQ 70` = `eta_70%`,
        `EQ 90` = `eta_90%`
      )



  })

  output$conveyal_output <- renderDataTable({
    DT::datatable(conveyal_table()) %>%
      DT::formatPercentage(c(2,5), digits = 2) %>%
      DT::formatRound(c(3, 4, 6, 7), digits = 0)
  })

  output$download_conveyal <- downloadHandler(
    filename = function(){"conveyal_output.csv"},
    content = function(file){
      write_csv(conveyal_table(), file)
    }
  )


  # Single project
  output$raster_output <- renderLeaflet({
    validate(
      need(input$raster_project != "", "Please select a project .tiff file"),
      need(input$project_shape  != "", "Please select a project .geojson shape file"),
      need(input$raster_base    != "", "Please select a base scenario .tiff file")
    )


    rasterFile <- input$raster_project
    pr <- read_tiff(rasterFile$datapath)

    shapeFile <- input$project_shape
    shp <- read_project(shapeFile$datapath)

    baseRasterFile <- input$raster_base
    br <- read_tiff(baseRasterFile$datapath)

    leaflet_raster(pr - br, shp, TRUE, cuts = c(10000, 100000))


  })


})
