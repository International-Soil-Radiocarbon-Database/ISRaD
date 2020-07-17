library(shiny)
library(readxl)
library(ISRaD)

# Define UI for data upload app ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("Uploading Files"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Input: Select a file ----
      fileInput("file1", "Choose .xlsx File",
                multiple = TRUE,
                accept = c(".xlsx")),
      
      # Horizontal line ----
      tags$hr(),
      
      # Input: Checkbox if file has header ----
      checkboxInput("header", "Header", TRUE),
      
      # Input: Select separator ----
      radioButtons("sheet", "Sheet",
                   choices = c(Metadata = "metadata",
                               Site = "site",
                               Profile = "profile"),
                   selected = "metadata"),
      
      # Input: Select quotes ----
      radioButtons("quote", "Quote",
                   choices = c(None = "",
                               "Double Quote" = '"',
                               "Single Quote" = "'"),
                   selected = '"'),
      
      # Horizontal line ----
      tags$hr(),
      
      # Input: Select number of rows to display ----
      radioButtons("disp", "Display",
                   choices = c(Head = "head",
                               All = "all"),
                   selected = "head"),
      
      downloadButton('report', "Generate Report")
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
  output$report <- downloadHandler(
    filename = 'report.txt',
    content = function(file){
      tempreport <- file.path(tempdir(), 'report2.txt')
      file.copy('report2.txt', tempreport, overwrite = TRUE)
      
      report <- cat(QAQC_shiny(input$file1$datapath))
      
    }
  )
}



# server <- function(input, output) {
#   
#   
#   output$contents <- renderTable({
#   #   
#   #   # input$file1 will be NULL initially. After the user selects
#   #   # and uploads a file, head of that data file by default,
#   #   # or all rows if selected, will be shown.
#   #   
#   req(input$file1)
#   #   
#   #   df = read_xlsx(input$file1$datapath, sheet = input$sheet)
#   #   
#   #   # df <- read.table(input$file1$datapath,
#   #   #                header = input$header,
#   #   #                sep = input$sep,
#   #   #                quote = input$quote)
#   inFile <- input$file1
#   #   #textOutput(input$file1$name)
#   #   #textOutput('Farts')
#   #   
#   df <- read_xlsx(inFile$datapath, sheet = input$sheet)
#   #   
#   #   
#   #   if(input$disp == "head") {
#   #     return(head(df))
#   #   }
#   #   else {
#   #     return(df)
#   #   }
#   #   
#     
#     
#   })
#   
#   txtname <- file.path(tempdir(), "QAQC", paste0("QAQC_", gsub("\\.xlsx", ".txt", 
#                                                                basename(input$file1$datapath))))
#   
#   QAQC_shiny(inFile$datapath) 
#   
#   output$report <- downloadHandler(
#     filename <- txtname,
#     content = txtname
#   )
#   
#   
#   
# }
# Run the app ----
shinyApp(ui, server)















