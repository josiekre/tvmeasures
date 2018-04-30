#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

  # Application title
  titlePanel("Concept 3 Evaluation Measures"),

  #
  sidebarLayout(
    sidebarPanel(
      p("This application aids ARC staff as they compute the output from",
        "a Concept 3 project evaluation. There are four tabs, each with",
        "independent input files."),

      # remix table with population, jobs, etc
      h4("Remix"),
      includeMarkdown("remix.md"),
      fileInput("remix_file", "Choose CSV File",
                accept = c(
                  "text/csv",
                  "text/comma-separated-values,text/plain",
                  ".csv")
      ),


      # cultural/environmental shapefile or geojson
      h4("Cultural / Environmental"),
      includeMarkdown("cultenv.md"),
      #fileInput(),


      # conveyal rasters
      h4("Conveyal"),
      includeMarkdown("conveyal.md"),
      fileInput("tiffs", "Choose Conveyal outputs", multiple = TRUE),
      fileInput("raster_base1", "Choose base layer tiff file"),
      fileInput("raster_pop", "Choose population weights tiff file"),
      fileInput("raster_eta", "Choose ETA weights tiff file"),


      # map
      h4("Accessibility Map"),
      includeMarkdown("raster.md"),
      fileInput("project_shape", "Choose GeoJson project file"),
      fileInput("raster_project", "Choose project .tiff"),
      fileInput("raster_base2", "Choose base layer .tiff")



    ),

    # Show a plot of the generated distribution
    mainPanel(

      tabsetPanel(
        type = "tabs",

        tabPanel("Remix",
                 dataTableOutput("remix_output"),
                 includeMarkdown("remix_definitions.md")
                 ),


        tabPanel("Cultural/Environmental", dataTableOutput("cultural_environmental")),
        tabPanel("Conveyal", dataTableOutput("conveyal_output")),
        tabPanel("Accessibility Map", leafletOutput("raster_output"))
      )
    )
  )
))
