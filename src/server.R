server = function(input, output) {
  
  # ========================
  # DF_FILTRE
  # ========================
  # Creates a reactive dataframe based on sidebar filters (see UI)
  # Used later to generate plots reactive to sidebar filters
  
  df_filtre = reactive({ 
    
    # FILTER CONDITION: "GEOGRAPHICAL ZONE"
    if (is.null(input$select_zone)) {
      # Display all data if the filter is not applied
      selected_zone = unique(df_all$zone_geographique)
    } else {
      # Display data according to the filter selection
      selected_zone = input$select_zone
    }
    
    # Filter raw data based on selected_zone
    condition_zone = df_all$zone_geographique %in% selected_zone
    
    # FILTER CONDITION: "UMR"
    if (is.null(input$select_umr)) {
      selected_umr = unique(split_vec_string(df_all$unite, sep = "\t"))
    } else {
      selected_umr = input$select_umr
    }
    
    condition_umr = rep(FALSE, nrow(df_all))
    for (k in 1:length(selected_umr)) {
      condition_umr = condition_umr | grepl(selected_umr[k], df_all$unite, fixed = TRUE)
    }
    condition_umr[is.na(condition_umr)] = TRUE
    
    # FILTER CONDITION: "PROJECTION"
    if (is.null(input$select_projection)) {
      selected_proj_sud = unique(split_vec_string(df_all$proj_sud, sep = "\t"))
    } else {
      selected_proj_sud = input$select_projection
    }
    
    condition_projection = rep(FALSE, nrow(df_all))
    for (k in 1:length(selected_proj_sud)) {
      condition_projection = condition_projection | grepl(selected_proj_sud[k], df_all$proj_sud, fixed = TRUE)
    }
    condition_projection[is.na(condition_projection)] = TRUE
    
    # FILTER CONDITION: "THEMATIC"
    if (is.null(input$select_thematique)) {
      selected_thematique = unique(split_vec_string(df_all$thematique, sep = "\t"))
    } else {
      selected_thematique = input$select_thematique
    }
    
    condition_thematique = rep(FALSE, nrow(df_all))
    for (k in 1:length(selected_thematique)) {
      condition_thematique = condition_thematique | grepl(selected_thematique[k], df_all$thematique, fixed = TRUE)
    }
    condition_thematique[is.na(condition_thematique)] = TRUE
    
    # CHECKBOX CONDITION
    if (input$checkbox_masquer_france) {
      selected_checkbox = unique(df_all[!(df_all$pays_fr == "France métropolitaine"), ]$pays_fr)
    } else {
      selected_checkbox = unique(df_all$pays_fr)
    }
    condition_checkbox = df_all$pays_fr %in% selected_checkbox
    
    # DF_FILTRE DEFINITION
    # Applies all previously defined conditions to create the reactive dataframe "df_filtre"
    df_filtre = df_all[
      condition_zone &
        condition_umr &
        condition_projection &
        condition_thematique &
        condition_checkbox,
    ]
    
  }) # End of df_filtre()
  
  
  #########################################
  #               IRD MAP                 #
  #########################################
  
  # ========================
  # LEAFLET MAP
  # ========================
  # World map reactive to sidebar filters
  # Displays the number of individuals per country based on filters
  # Countries with individuals are colored with clickable polygons
  # Clicking a polygon displays country-specific information in value boxes, cards, etc.
  
  # Define the number of individuals per country based on filters
  nb_actions_unique_from_df_filtre = reactive({ 
    data.frame(table(df_filtre()$name))$Freq[
      match(
        df_filtre()$name[!duplicated(df_filtre()$name)],
        data.frame(table(df_filtre()$name))$Var1
      )
    ]
  })
  
  reactive_ird_map = reactive({
    
    # Group data by country name and calculate centroids
    centroids = df_filtre() %>%
      group_by(name) %>%
      summarise(centroid = st_centroid(st_union(geometry)))
    
    centroids_df = centroids %>%
      mutate(
        longitude = st_coordinates(.)[, 1],
        latitude  = st_coordinates(.)[, 2]
      ) %>%
      select(name, latitude, longitude)
    
    # Create leaflet object
    leaflet(options = leafletOptions(zoomSnap = 0.25, zoomDelta = 0.25)) %>%
      addProviderTiles("CartoDB.PositronNoLabels") %>%
      setView(lng = 10, lat = 0, zoom = 2) %>%
      addMiniMap(width = 150, height = 150) %>%
      
      # Add clickable polygons
      addPolygons(
        data = df_filtre()[!duplicated(df_filtre()$name), ],
        stroke = TRUE,
        fillColor = my_color_palette(nb_actions_unique_from_df_filtre()),
        fillOpacity = 0.7,
        color = "white",
        weight = 1
      ) %>%
      
      # Add country labels at polygon centroids
      addLabelOnlyMarkers(
        data = st_centroid(df_filtre()$geometry[!duplicated(df_filtre()$pays_fr), ]),
        label = df_filtre()$pays_fr[!duplicated(df_filtre()$pays_fr)],
        labelOptions = labelOptions(
          noHide = TRUE,
          textOnly = TRUE,
          direction = "center",
          style = list(
            font.size = "12px",
            font.weight = "bold",
            strokeColor = "#FFF",
            strokeWidth = 2,
            color = "black"
          )
        )
      ) %>%
      
      addLegend(
        pal = colorNumeric(
          my_color_palette(seq(0, max(nb_actions_unique_from_df_filtre()), 1)),
          domain = seq(0, max(nb_actions_unique_from_df_filtre()), 1)
        ),
        values = seq(0, max(nb_actions_unique_from_df_filtre()), 1),
        opacity = 0.9,
        title = "Actions",
        position = "bottomleft",
        bins = length(unique(nb_actions_unique_from_df_filtre()))
      )
  }) # End of reactive_ird_map
  
  # Output to display the map in the UI
  output$mymap = renderLeaflet({
    reactive_ird_map()
  })
  
  
  #########################################
  #              STATISTICS               #
  #########################################
  # Global and reactive statistics based on filters
  # Not influenced by clicked polygons
  
  selected_dispositif <- reactive({
    input$select_projection
  })
  
  
  # ==================
  # BAR PLOT: COUNTRIES
  # ==================
  # Displays the distribution of individuals by country, based on filters
  
  output$stat_nb_actions_pays = renderPlot({
    data_all = as.data.frame(table(df_all$pays_fr))
    data_filtre = as.data.frame(table(df_filtre()$pays_fr))
    missing_values = setdiff(data_all$Var1, data_filtre$Var1)
    
    data_barplot = rbind(
      data_filtre,
      data.frame(Var1 = missing_values, Freq = rep(0, length(missing_values)))
    )
    
    tmp = sort.int(data_barplot$Freq, index.return = TRUE, decreasing = TRUE)
    data_barplot = data_barplot[tmp$ix, ]
    
    par(mai = c(2, 0.5, 0.25, 0.25))
    bar_pays = barplot(
      data_barplot$Freq,
      names.arg = data_barplot$Var1,
      col = "#1d71b8",
      border = "white",
      las = 2,
      ylim = c(0, ceiling(1.2 * max(data_barplot$Freq))),
      yaxt = "n"
    )
    
    at_values = set_axis_values(data_barplot$Freq)
    abline(h = at_values, lwd = 0.5, col = "#8a8a8a", lty = 2)
    axis(2, at = at_values, labels = at_values, las = 1)
    
    barplot(
      data_barplot$Freq,
      names.arg = data_barplot$Var1,
      col = "#1d71b8",
      border = "white",
      las = 2,
      xaxt = "n",
      yaxt = "n",
      add = TRUE
    )
    
    text(
      bar_pays,
      data_barplot$Freq + 0.05 * max(data_barplot$Freq),
      paste(data_barplot$Freq),
      pos = 3
    )
  })
  
  
  # Download handler for stat_nb_actions_pays
  output$downloadPlot_pays = downloadHandler(
    filename = sprintf("hist-pays-%s.png", Sys.Date()),
    content = function(file) {
      png(file, width = 800, height = 400)
      
      data_all = as.data.frame(table(df_all$pays_fr))
      data_filtre = as.data.frame(table(df_filtre()$pays_fr))
      missing_values = setdiff(data_all$Var1, data_filtre$Var1)
      
      data_barplot = rbind(
        data_filtre,
        data.frame(Var1 = missing_values, Freq = rep(0, length(missing_values)))
      )
      
      tmp = sort.int(data_barplot$Freq, index.return = TRUE, decreasing = TRUE)
      data_barplot = data_barplot[tmp$ix, ]
      
      par(mai = c(2, 0.5, 0.25, 0.25))
      bar_pays = barplot(
        data_barplot$Freq,
        names.arg = data_barplot$Var1,
        col = "#1d71b8",
        border = "white",
        las = 2,
        ylim = c(0, ceiling(1.2 * max(data_barplot$Freq))),
        yaxt = "n"
      )
      
      at_values = set_axis_values(data_barplot$Freq)
      abline(h = at_values, lwd = 0.5, col = "#8a8a8a", lty = 2)
      axis(2, at = at_values, labels = at_values, las = 1)
      
      barplot(
        data_barplot$Freq,
        names.arg = data_barplot$Var1,
        col = "#1d71b8",
        border = "white",
        las = 2,
        xaxt = "n",
        yaxt = "n",
        add = TRUE
      )
      
      text(
        bar_pays,
        data_barplot$Freq + 0.05 * max(data_barplot$Freq),
        paste(data_barplot$Freq),
        pos = 3
      )
      
      dev.off()
    }
  )
  
  
  # ==================
  # BAR PLOT: REGIONS
  # ==================
  # Displays the distribution of individuals by geographical zone
  
  output$stat_nb_actions_regions = renderPlot({
    data_all = as.data.frame(table(df_all$zone_geographique))
    data_filtre = as.data.frame(table(df_filtre()$zone_geographique))
    missing_values = setdiff(data_all$Var1, data_filtre$Var1)
    
    data_barplot = rbind(
      data_filtre,
      data.frame(Var1 = missing_values, Freq = rep(0, length(missing_values)))
    )
    
    tmp = sort.int(data_barplot$Freq, index.return = TRUE, decreasing = FALSE)
    data_barplot = data_barplot[tmp$ix, ]
    
    par(mai = c(0.5, 3.5, 0.25, 0.25))  # margins = c(bottom, left, top, right)
    bar_region = barplot(
      data_barplot$Freq,
      horiz = TRUE,
      names.arg = data_barplot$Var1,
      col = "#1d71b8",
      border = "white",
      las = 2,
      xlim = c(0, 1.2 * max(data_barplot$Freq)),
      xaxt = "n"
    )
    
    at_values = set_axis_values(data_barplot$Freq)
    abline(v = at_values, lwd = 0.5, col = "#8a8a8a", lty = 2)
    
    barplot(
      data_barplot$Freq,
      horiz = TRUE,
      names.arg = data_barplot$Var1,
      col = "#1d71b8",
      border = "white",
      las = 2,
      xaxt = "n",
      yaxt = "n",
      add = TRUE
    )
    
    axis(1, at = at_values, labels = at_values)
    text(data_barplot$Freq + 1, bar_region, paste(data_barplot$Freq), pos = 4)
  })
  
  
  # Download handler for stat_nb_actions_regions
  output$downloadPlot_zones = downloadHandler(
    filename = sprintf("hist-zones-%s.png", Sys.Date()),
    content = function(file) {
      png(file, width = 800, height = 400)
      
      data_all = as.data.frame(table(df_all$zone_geographique))
      data_filtre = as.data.frame(table(df_filtre()$zone_geographique))
      missing_values = setdiff(data_all$Var1, data_filtre$Var1)
      
      data_barplot = rbind(
        data_filtre,
        data.frame(Var1 = missing_values, Freq = rep(0, length(missing_values)))
      )
      
      tmp = sort.int(data_barplot$Freq, index.return = TRUE, decreasing = FALSE)
      data_barplot = data_barplot[tmp$ix, ]
      
      par(mai = c(0.5, 3.5, 0.25, 0.25))
      bar_region = barplot(
        data_barplot$Freq,
        horiz = TRUE,
        names.arg = data_barplot$Var1,
        col = "#1d71b8",
        border = "white",
        las = 2,
        xlim = c(0, 1.2 * max(data_barplot$Freq)),
        xaxt = "n"
      )
      
      at_values = set_axis_values(data_barplot$Freq)
      abline(v = at_values, lwd = 0.5, col = "#8a8a8a", lty = 2)
      
      barplot(
        data_barplot$Freq,
        horiz = TRUE,
        names.arg = data_barplot$Var1,
        col = "#1d71b8",
        border = "white",
        las = 2,
        xaxt = "n",
        yaxt = "n",
        add = TRUE
      )
      
      axis(1, at = at_values, labels = at_values)
      text(data_barplot$Freq + 1, bar_region, paste(data_barplot$Freq), pos = 4)
      
      dev.off()
    }
  )
  
  
  #########################################
  #            GANTT CHART                #
  #########################################
  # Gantt chart providing a temporal projection of missions / assignments / contracts
  # Note: No download button needed, Plotly provides one directly in the UI
  
  output$gantt_chart = renderPlotly({
    df_gantt = df_filtre()[
      !is.na(df_filtre()$debut) & !is.na(df_filtre()$fin),
      c("debut", "fin", "pays_fr", "duree", "individu", "unite")
    ]
    
    if (nrow(df_gantt) == 0) {
      return(plot_ly() %>% layout(title = "No data available for the Gantt chart"))
    }
    
    df_gantt$geometry = NULL
    df_gantt$debut = as.POSIXct.Date(as.Date(df_gantt$debut, format = "%d/%m/%y"))
    df_gantt$fin   = as.POSIXct.Date(as.Date(df_gantt$fin,   format = "%d/%m/%y"))
    
    list_of_umr = unique(df_gantt$unite)
    n = length(list_of_umr)
    
    cols = rep(RColorBrewer::brewer.pal(12, "Set3"), 10)[1:n]
    df_gantt$color = factor(df_gantt$unite, labels = cols)
    
    reordering_umr = sort.int(df_gantt$unite, index.return = TRUE)
    df_gantt = df_gantt[reordering_umr$ix, ]
    
    df_gantt_sorted = data.frame()
    for (k in 1:n) {
      reorder = sort.int(
        df_gantt$debut[df_gantt$unite == list_of_umr[k]],
        index.return = TRUE,
        decreasing = TRUE
      )
      df_gantt_sorted = rbind(
        df_gantt_sorted,
        df_gantt[df_gantt$unite == list_of_umr[k], ][reorder$ix, ]
      )
    }
    
    fig = plot_ly()
    tmp = list_of_umr
    
    for (i in 1:nrow(df_gantt_sorted)) {
      show_legend = df_gantt_sorted$unite[i] %in% tmp
      tmp = setdiff(tmp, df_gantt_sorted$unite[i])
      
      fig = add_trace(
        fig,
        x = c(df_gantt_sorted$debut[i], df_gantt_sorted$fin[i]),
        y = c(4 * i, 4 * i),
        type = "scatter",
        mode = "lines",
        line = list(color = df_gantt_sorted$color[i], width = 5),
        showlegend = show_legend,
        name = df_gantt_sorted$unite[i],
        hoverinfo = "text",
        text = paste(
          "Country:", df_gantt_sorted$pays_fr[i], "<br>",
          "Start:", df_gantt_sorted$debut[i], "<br>",
          "End:", df_gantt_sorted$fin[i], "<br>",
          "Duration:", df_gantt_sorted$duree[i], "<br>",
          "Individual:", df_gantt_sorted$individu[i], "<br>",
          "Unit:", df_gantt_sorted$unite[i]
        )
      )
    }
    
    fig %>%
      layout(
        xaxis = list(type = "date", showgrid = TRUE),
        yaxis = list(showticklabels = FALSE)
      )
  })
  
  
  #########################################
  #        MAP POLYGON CLICK EVENT        #
  #########################################
  # Defines a polygon click as a reactive trigger
  # Everything inside observeEvent is executed only when a polygon is clicked
  
  observeEvent(input$mymap_shape_click, {
    click = input$mymap_shape_click
    
    idx_country = st_intersects(
      st_point(c(click$lng, click$lat)),
      df_filtre()$geometry[!duplicated(df_filtre()$name)]
    )[[1]]
    
    country_name = df_filtre()$name[!duplicated(df_filtre()$name)][idx_country]
    country_name_fr = df_filtre()$french_short[!duplicated(df_filtre()$name)][idx_country]
    
    # Reactive value boxes
    output$value_box_pays = renderValueBox({
      valueBox(unique(df_all$name[df_all$name == country_name]), "")
    })
    
    output$value_box_MLD = renderValueBox({
      valueBox(
        sum(df_filtre()$name == country_name &
              df_filtre()$proj_sud == "Mission Longue Durée", na.rm = TRUE),
        ""
      )
    })
    
    output$value_box_mobilite = renderValueBox({
      valueBox(
        sum(df_filtre()$name == country_name &
              df_filtre()$proj_sud == "Mobilité Sud Nord", na.rm = TRUE),
        ""
      )
    })
    
    output$value_box_exp = renderValueBox({
      valueBox(
        sum(df_filtre()$name == country_name &
              df_filtre()$proj_sud == "Expatriation", na.rm = TRUE),
        ""
      )
    })
    
    output$value_box_aff = renderValueBox({
      valueBox(
        sum(df_filtre()$name == country_name &
              df_filtre()$proj_sud == "Affectation", na.rm = TRUE),
        ""
      )
    })
    
    output$value_box_volontaire_SC = renderValueBox({
      valueBox(
        sum(
          df_filtre()$name == country_name &
            df_filtre()$proj_sud %in%
            c(
              "Volontaire de Service Civique",
              "Volontaire Civil",
              "Volontaire International en Administration"
            ),
          na.rm = TRUE
        ),
        ""
      )
    })
    
    # Raw filtered data table for clicked country
    raw_df_filtre = df_filtre()[
      df_filtre()$name == country_name,
      c("proj_sud", "pays_fr", "debut", "fin", "unite", "individu")
    ]
    raw_df_filtre$geometry = NULL
    
    output$pays_table = renderDataTable(raw_df_filtre)
  })
  
  
  #########################################
  #        DICTIONARY DATA TABLES         #
  #########################################
  
  output$donnees_dico_unites = DT::renderDataTable(
    DT::datatable(df_data_dico_unites, escape = FALSE,
                  options = list(pageLength = 20, scrollX = TRUE))
  )
  

  
  #########################################
  #              RAW DATA                 #
  #########################################
  
  output$raw_data = DT::renderDataTable(
    DT::datatable(df_data, escape = FALSE,
                  options = list(pageLength = 20, scrollX = TRUE))
  )
  
}

