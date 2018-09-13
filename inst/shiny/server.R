
library(ggplot2)

shinyServer(function(input, output, session) {
  options(shiny.maxRequestSize=30*1024^2)

  observe({
    x <- input$presets

    if (x==1) {
      updateSelectInput(session, "y_var", selected = "lyr_bot")
      updateSelectInput(session, "x_var", selected = "lyr_bd_tot")
      updateSelectInput(session, "size_var", selected = "NULL")
      updateSelectInput(session, "col_var", selected = "pro_MAT")
      updateSelectInput(session, "col_facet_var", selected = "pro_MAP")
      updateSelectInput(session, "row_facet_var", selected = "pro_MAT")
    }
    if (x==2) {
      updateSelectInput(session, "y_var", selected = "frc_c_tot")
      updateSelectInput(session, "x_var", selected = "frc_14c")
      updateSelectInput(session, "size_var", selected = "NULL")
      updateSelectInput(session, "col_var", selected = "frc_property")
      updateSelectInput(session, "col_facet_var", selected = "NULL")
      updateSelectInput(session, "row_facet_var", selected = "NULL")
    }
  })

  output$plot <- renderPlot({

    variables<-list(
    y_var=input$y_var,
    x_var=input$x_var,
    size_var=input$size_var,
    col_var=input$col_var,
    col_facet_var=input$col_facet_var,
    row_facet_var=input$row_facet_var
    )
    variables[which(variables=="NULL")]<-NULL

    # variables<-list(y_var="layer_bot",
    #                 x_var="bd_tot",
    #                 size_var="NULL",
    #                 col_var="p_MAT",
    #                 col_facet_var="p_MAP",
    #                 row_facet_var="p_MAT")
    #unlist(variables) %in% colnames(soilcarbon_database)
    soilcarbon_database<-ISRaD_data
    soilcarbon_database <- lapply(soilcarbon_database, function(x) x %>% mutate_all(as.character))
    soilcarbon_database<-soilcarbon_database %>%
      Reduce(function(dtf1,dtf2) full_join(dtf1,dtf2), .)
    soilcarbon_database[]<-lapply(soilcarbon_database, type.convert)

    plot_data<-na.omit(soilcarbon_database[,unlist(variables)])
    plot_data$facet_cut<-""
    plot_data$facet_cut2<-""
    col_facet_thresh<-NA
    row_facet_thresh<-NA

    if ((input$col_facet_thresh != "" & !is.null(variables$col_facet_var))){
      col_facet_thresh<-as.numeric(input$col_facet_thresh)
      plot_data$facet_cut<-plot_data[,variables$col_facet_var] < col_facet_thresh
      plot_data$facet_cut[which(plot_data$facet_cut)]<-paste(variables$col_facet_var, " < ", col_facet_thresh)
      plot_data$facet_cut[which(plot_data$facet_cut==F)]<-paste(variables$col_facet_var, " > ", col_facet_thresh)
    }

    if ((input$row_facet_thresh != "" & !is.null(variables$row_facet_var))){
      row_facet_thresh<-as.numeric(input$row_facet_thresh)
      plot_data$facet_cut2<-plot_data[,variables$row_facet_var] < row_facet_thresh
      plot_data$facet_cut2[which(plot_data$facet_cut2)]<-paste(variables$row_facet_var, " < ", row_facet_thresh)
      plot_data$facet_cut2[which(plot_data$facet_cut2==F)]<-paste(variables$row_facet_var, " > ", row_facet_thresh)
    }

    if(is.null(variables$y_var)){
      p<-ggplot(plot_data, aes_string(x=variables$x_var,  col=variables$col_var))+
        geom_histogram(bins = 30)+
        facet_grid(facet_cut2~facet_cut)+
        scale_colour_gradient(low="dodgerblue", high="orange")+
        theme_light(base_size = 16)+
        theme(strip.background = element_blank())+
        theme(strip.text = element_text(colour = 'black'))
      p
    }else{
      p<-ggplot(plot_data, aes_string(x=variables$x_var, y=variables$y_var, col=variables$col_var))+
        facet_grid(facet_cut2~facet_cut)+
        theme_light(base_size = 16)+
        theme(strip.background = element_blank())+
        theme(strip.text = element_text(colour = 'black'))
      if(variables$y_var=="layer_top" | variables$y_var=="layer_bot"){
        p<-p+scale_y_reverse()
      }
    if(is.null(variables$size)){
      p<-p+geom_point(alpha=input$alpha, size=2)
      }else
    p<-p+geom_point(alpha=input$alpha, aes_string(size=variables$size_var))+ scale_size_continuous(range = c(1, 10))
    }
    print(p)

  })




})

