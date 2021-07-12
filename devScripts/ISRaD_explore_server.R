input <- list(tabs = c('site', 'fraction'))
input$frc_scheme <- fracvoc
input$frc_property <- 'heavy'

#db <- ISRaD.getdata('/Users/shane/14Constraint Dropbox/Shane Stoner/IMPRS/Database/ISRaD/ISRaD/ISRaD_data_files')

fracvoc <- unname(unlist(strsplit(unlist(readxl::read_xlsx('/Users/shane/14Constraint Dropbox/Shane Stoner/IMPRS/Database/ISRaD/ISRaD/Rpkg/inst/extdata/ISRaD_Template_Info.xlsx',
                         sheet = 'fraction')[8,'Vocab']), ', ')))

input <- list(tabs = c('site', 'fraction'))
input$frc_scheme <- fracvoc

### SERVER ###
server <- function(input, output, session) {
  #reactive function to create data table
  data.tbl_filter <- reactive({

    df <- NULL

    ifelse(c('flux','layer','interstitial','fraction','incubation')
           %in% input$tabs, df <- merge(db$site, db$profile), print(''))

    if(length(input$tabs) == 1 & input$tabs == 'site'){df <- db$site} else {

      for(x in input$tabs){
        if(x == 'site'){df <- db$site}
        if(x == 'profile')df <- merge(df, db$profile, all = TRUE)
        if(x == 'flux')df <- merge(df, db$flux, all = TRUE)
        if(x == 'layer')df <- merge(df, db$layer, all = TRUE)
        if(x == 'interstitial')df <- merge(df, db$interstitial, all = TRUE)
        if(x == 'fraction')df <- merge(df, db$fraction, all = TRUE)
        if(x == 'incubation')df <- merge(df, db$incubation, all = TRUE)
        print(x)
        print(dim(df))
      }
    }
    return(df)

  })

  output$tbl_filter = renderDT(
    data.tbl_filter(),
    options = list(lengthChange = TRUE,
                   pageLength = 50),
    class = 'white-space: nowrap'
  )

  #### Table for exploring fractions

  data.tbl_fraction <- reactive({
    df_frac <- NULL
    df_frac <- filter(db$fraction, frc_scheme == input$frc_scheme)

    frac_props <- c('ALL', as.character(unique(na.omit(df_frac$frc_property))))
    # df_frac <- filter(df_frac, input$frc_property)

    if(input$frc_property != "ALL"){
      df_frac <- filter(df_frac, input$frc_property %in% df_frac$frc_property)
      df_frac <- slice(df_frac, match(frc_property, input$frc_property, ))
      df_frac <- df_frac[df_frac$frc_property %in% input$frc_property,]
    }

    return(df_frac)
  })

  output$tbl_frac = renderDT(
    data.tbl_fraction(),
    options = list(lengthChange = TRUE,
                   pageLength = 50),
    class = 'white-space: nowrap'
  )



}


shinyApp(ui, server)

shinyApp(sodah_ui, sodah_server)

