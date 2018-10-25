


shinyUI(fluidPage(

  theme = "bootstrap_simplex.css",

  # Application title
  headerPanel("ISRaD"),

  sidebarPanel(
                   radioButtons("presets", label = h3("Preset plots:"),
                                choices = list("Some layer data" = 1, "Some fraction data" = 2),
                                selected = 1),
                   fluidRow(column(6, selectInput("y_var", "Y Variable:",
                                                  list("None (histogram)" = "NULL",
                                                       "Top of layer" = "lyr_top",
                                                       "Bottom of layer" = "lyr_bot",
                                                       "C14 (layer)" = "lyr_14c",
                                                       "C14 (fraction)" = "frc_14c",
                                                       "Total Carbon (layer)" = "lyr_c_tot",
                                                       "Total Carbon (fraction)" = "frc_c_tot",
                                                       "Total Nitrogen" = "lyr_n_tot",
                                                       "Bulk Density" = "lyr_bd_tot",
                                                       "MAP" = "pro_MAP",
                                                       "MAT" = "pro_MAT"
                                                  ),
                                                  selected = "lyr_bot")),
                            column(6, selectInput("x_var", "X Variable:",
                                                  list("Top of layer" = "lyr_top",
                                                       "Bottom of layer" = "lyr_bot",
                                                       "C14 (layer)" = "lyr_14c",
                                                       "C14 (fraction)" = "frc_14c",
                                                       "Total Carbon (layer)" = "lyr_c_tot",
                                                       "Total Carbon (fraction)" = "frc_c_tot",
                                                       "Total Nitrogen" = "lyr_n_tot",
                                                       "Bulk Density" = "lyr_bd_tot",
                                                       "MAP" = "pro_MAP",
                                                       "MAT" = "pro_MAT"
                                                  ),
                                                  selected = "lyr_bd_tot"))),

                   fluidRow(column(7,   selectInput("col_facet_var", "Panel Variable:",
                                                    list("None" = "NULL",
                                                         "Top of layer" = "lyr_top",
                                                         "Bottom of layer" = "lyr_bot",
                                                         "C14 (layer)" = "lyr_14c",
                                                         "C14 (fraction)" = "frc_14c",
                                                         "Total Carbon (layer)" = "lyr_c_tot",
                                                         "Total Carbon (fraction)" = "frc_c_tot",
                                                         "Total Nitrogen" = "lyr_n_tot",
                                                         "Bulk Density" = "lyr_bd_tot",
                                                         "MAP" = "pro_MAP",
                                                         "MAT" = "pro_MAT"
                                                    ),
                                                    selected = "p_MAP")),
                            column(5, textInput("col_facet_thresh", "threshold", value = "500"))),

                   fluidRow(column(7,   selectInput("row_facet_var", "Panel Variable 2:",
                                                    list("None" = "NULL",
                                                         "Top of layer" = "lyr_top",
                                                         "Bottom of layer" = "lyr_bot",
                                                         "C14 (layer)" = "lyr_14c",
                                                         "C14 (fraction)" = "frc_14c",
                                                         "Total Carbon (layer)" = "lyr_c_tot",
                                                         "Total Carbon (fraction)" = "frc_c_tot",
                                                         "Total Nitrogen" = "lyr_n_tot",
                                                         "Bulk Density" = "lyr_bd_tot",
                                                         "MAP" = "pro_MAP",
                                                         "MAT" = "pro_MAT"
                                                    ),
                                                    selected = "p_MAT")),
                            column(5, textInput("row_facet_thresh", "threshold", value = "5"))),

                   fluidRow(column(7,  selectInput("col_var", "Color Variable:",
                                                   list("None" = "NULL",
                                                        "Fraction Property" = "frc_property",
                                                        "Top of layer" = "lyr_top",
                                                        "Bottom of layer" = "lyr_bot",
                                                        "C14 (layer)" = "lyr_14c",
                                                        "C14 (fraction)" = "frc_14c",
                                                        "Total Carbon (layer)" = "lyr_c_tot",
                                                        "Total Carbon (fraction)" = "frc_c_tot",
                                                        "Total Nitrogen" = "lyr_n_tot",
                                                        "Bulk Density" = "lyr_bd_tot",
                                                        "MAP" = "pro_MAP",
                                                        "MAT" = "pro_MAT"
                                                   ),
                                                   selected = "p_MAT")),
                            column(5, sliderInput("alpha", "transparency", min = 0,
                                                  max = 1, value = 0.7))),

                   selectInput("size_var", "Size Variable:",
                               list("None" = "NULL",
                                    "C14" = "lyr_14c",
                                    "Total Carbon" = "lyr_c_tot",
                                    "Total Nitrogen" = "lyr_n_tot",
                                    "Bulk Density" = "lyr_bd_tot",
                                    "MAP" = "pro_MAP",
                                    "MAT" = "pro_MAT")


  )),

  mainPanel(

    plotOutput("plot")
    )


))

