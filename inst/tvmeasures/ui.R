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
library(DT)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

  # Application title
  titlePanel("Concept 3 Evaluation Measures"),

  #
  sidebarLayout(
    sidebarPanel(
      p("This application aids ARC staff as they compute the output from",
        "a Concept 3 project evaluation. There are four tabs, each with",
        "their own independent input files. The analysis in the tabs also depend",
        "on three reference files."),
      fileInput("raster_base", "Choose base tiff file"),
      p("The base file represents the existing transit network and must be run",
        "with the same Conveyal routing engine as the project tiff files."),

      fileInput("raster_pop", "Choose population weights tiff file"),
      p("The population weights tiff file is available by selecting the 'Jobs total'",
        "opportunity dataset in Conveyal and pressing 'Generate & Download GeoTIFFs"),
      fileInput("raster_eta", "Choose ETA weights tiff file"),
      p("The ETA weights tiff file is available by selecting the 'ETA Zones: eta_pop'",
        "opportunity dataset in Conveyal and pressing 'Generate & Download GeoTIFFs")



    ),

    mainPanel(

      tabsetPanel(
        type = "tabs",

        tabPanel("Remix",
                 includeMarkdown("remix.md"),
                 fileInput("remix_file", "Choose CSV File",
                           accept = c(
                             "text/csv",
                             "text/comma-separated-values,text/plain",
                             ".csv")
                 ),
                 DTOutput("remix_output"),
                 br(),
                 downloadButton("download_remix", label = "Save"),
                 includeMarkdown("remix_definitions.md") ),


        tabPanel("Cultural/Environmental",
                 includeMarkdown("cultenv.md"),
                 dataTableOutput("cultural_environmental")),
        tabPanel("Conveyal",
                 includeMarkdown("conveyal.md"),
                 fileInput("tiffs", "Choose Conveyal outputs", multiple = TRUE),
                 DTOutput("conveyal_output"),
                 br(),
                 br(),
                 br(),
                 br(),
                 downloadButton("download_conveyal", label = "Save"),
                 includeMarkdown("conveyal_definitions.md")
        ),


        tabPanel("Accessibility Map",
                 # cultural/environmental shapefile or geojson
                 includeMarkdown("raster.md"),
                 fileInput("project_shape", "Choose GeoJson project file"),
                 fileInput("raster_project", "Choose project .tiff"),
                 leafletOutput("raster_output"))
      )
    )
  )
))
