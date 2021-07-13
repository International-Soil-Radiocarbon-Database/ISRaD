#Create UI option vectors

tabs <- names(db)

ui <- fluidPage(
  # javascript cde for google analytics. if app gets too big, we can move this to it's own script
  # and use includeScript inside tags$head
  tags$head(
    #shiny::includeHTML("google-analytics.html")
    # javascript code for google analytics. if app gets too big, we can move this to it's own script
    # and use includeScript inside tags$head
    HTML(
      "<!-- Google Analytics -->
        <script>
          (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
          (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
          m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
          })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

          ga('create', 'UA-148614327-1', 'auto');
          ga('send', 'pageview');


        </script>"
    )
  ),
  theme = "bootstrap.css",
  tags$style(
    HTML(
      "
      .navbar-default .navbar-brand {color: white;font-size: 22px;font-family: sans-serif;}
      .navbar-default .navbar-brand:hover {color: #3a3a3a;}
      .navbar { background-color: #3a3a3a;}
      .navbar-default .navbar-nav > li > a {color:white;font-size: 16px;}
      .navbar-default .navbar-nav > .active > a,
      .navbar-default .navbar-nav > .active > a:focus,
      .navbar-default .navbar-nav > .active > a:hover {color: white;background-color: #222222;font-size: 18px;outline: 0;}
      .navbar-default .navbar-nav > li > a:hover {color: white;background-color:#222222;font-size: 17px;}
      "
    )
  ),
  useShinyjs(),
  navbarPage(
    a("ISRaD", href = "https://soilradiocarbon.org",  style = "color:#6a59cd"),
    windowTitle = "International Soil Radiocarbon Database",
    tabPanel(
            "Query",
            fluidRow(column(
              12,
              offset = 0,
              titlePanel(title = "International Soil Radiocarbon Database")
            )),
            hr(),

            # data filters ------------------------------------------------------------

            h2("Filters"),
            fluidRow(
              column(3,
                     wellPanel(
                       checkboxGroupInput("tabs", "Choose data types:",
                                          choices = tabs[2:8],
                                          selected = 'site'
                       ),
                       textOutput("txt"),
              )),
            ),
            hr(),

        mainPanel(
          tabsetPanel(
            # tabPanel("Plot", value = 1, plotOutput("dataPlot")),
            # tabPanel("Map", value = 2, leafletOutput("som_map")),
            tabPanel("Table", value = 1, DTOutput('tbl_filter')),
            id = "conditionedPanels"
          )
        )
      )
    ,

    ### Fraction exploration tab
    tabPanel(
      "Fractions",
      tabsetPanel(
        tabPanel(
          "Fractionation Scheme",
          hr(),
          fluidRow(
            column(
              width = 3,
              selectInput('frc_scheme',
                          'Scheme:',
                          choices = fracvoc,
                          selected = "Density")
            ),
            column(
              width = 3,
              selectInput(
                'frac_props',
                'Property:',
                choices = c("ALL", frac_props),
                selected = ""
              )
            ),


      # "Fractions",
      # fluidRow(column(
      #   12,
      #   offset = 0,
      #   titlePanel(title = "International Soil Radiocarbon Database")
      # )),
      # hr(),
      #
      # # data filters ------------------------------------------------------------
      #
      # h2("Fractions"),
      # fluidRow(
      #   column(4,
      #          wellPanel(
      #            selectInput("frc_scheme", "Choose fraction scheme:",
      #                               choices = fracvoc,
      #                               selected = 'Density'
      #            ),
      #            textOutput("txt"),
      #          )),
      #   column(
      #     width = 4
      #         )
      # ),
      # hr(),

      tabPanel(
        tabsetPanel(
          tabPanel("Table", value = 1, DTOutput('tbl_frac')),
          id = "fractionpanels"
        )
      )
    )

))



    #For exploring fractions
    # tabPanel("Fractions",
    #          tabsetPanel(
    #            tabPanel(
    #              "Schemes",
    #              hr(),
    #              fluidRow(
    #                column(width = 3,
    #                       selectInput("frc_scheme",
    #                                   "Scheme",
    #                                   choices = fracvoc,
    #                                   selected = 'Density')
    #                       ),
    #                hr(),
    #                DTOutput('tbl_frac')
    #              )
    #            )
    #          ))


#     tabPanel("Fractions",
#          tabsetPanel(
#            tabPanel(
#              "By Analytes",
#              hr(),
#              fluidRow(
#                column(
#                  width = ,
#                 selectInput('frc_scheme',
#                              'Method:',
#                              choices = fracvoc,
#                              selected = "Density")
#                ),
#                textOutput("txt"),
#
#              ),
#              hr(),
#
#              mainPanel(
#                tabsetPanel(
#                  # tabPanel("Plot", value = 1, plotOutput("dataPlot")),
#                  # tabPanel("Map", value = 2, leafletOutput("som_map")),
#                  tabPanel("Table", value = 3, DTOutput('tbl_frac')),
#                  id = "conditionedPanels"
#                )
#              )
#            ),
#

#   ### app versioning ###
#   # Last updated on commit by Derek Pierson: April 21, 2020
#   column(
#     width = 12,
#     style = "text-align: right; color:grey; font-size: 9px; padding-top: 10px;",
#     p("Shiny SoDaH Version: 1.06")
#   )
#   )
# )



