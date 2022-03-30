library(shiny)
library(readxl)
library(ISRaD)
library(RCurl)
library(dplyr)
library(rio)

# Define UI for data upload app ----
ui <- fluidPage(

  # App title ----
  titlePanel(title = div(img(src = "https://github.com/International-Soil-Radiocarbon-Database/ISRaD/blob/master/shinyapp/www/ISRaDlogoTextBelow_small2.png?raw=true",
                             height = 104, width = 177),
                         "QA/QC",
                         style = "font-family:Avenir Roman;font-size:64px;")),

  # Sidebar layout with input and output definitions ----
  sidebarLayout(

    # Sidebar panel for inputs ----
    sidebarPanel(

      # Input: Select a file ----
      fileInput("file1", "Choose .xlsx file",
                multiple = TRUE,
                accept = c(".xlsx")),

      # Horizontal line ----
      tags$hr(),

      # Input: Checkbox if file has header ----
      # checkboxInput("header", "Header", TRUE),

      # Input: Select separator ----
      # radioButtons("sheet", "Sheet",
      #              choices = c(Metadata = "metadata",
      #                          Site = "site",
      #                          Profile = "profile",
      #                          Layer = 'layer',
      #                          Interstitial = 'interstitial'),
      #              selected = "metadata"),


      # Horizontal line ----
      tags$hr(),

      downloadButton('report', "Generate QA/QC Report")
    ),

    # Main panel for displaying outputs ----
    mainPanel(

      # Output: Data file ----
      tableOutput("contents")

    )

  )
)

# Define server logic to read selected file ----

server = function(input, output){

  # output$table <- renderTable({
  #   datasetInput()
  # })

  # output$contents <- renderTable({
  #   df = read_xlsx(input$file1$datapath, sheet = input$sheet)
  # })


  ### Access newest version of QAQC function
  QAQC <- eval(parse(text = getURL('https://raw.githubusercontent.com/International-Soil-Radiocarbon-Database/ISRaD/master/Rpkg/R/QAQC.R',
                  ssl.verifypeer = FALSE)))

  ### Generate and serve QAQC report
  output$report <- downloadHandler(
    filename = function() {paste0("QAQC_", gsub("\\.xlsx", ".txt", basename(input$file1$name)))},
    #file.path = paste0("QAQC_", gsub("\\.xlsx", ".txt", basename(input$file1$name))),
    content = function(file){
      QAQC(input$file1$datapath, TRUE, file, local = FALSE)

    }
  )

}

# Run the app ----
shinyApp(ui, server)
