

server = function(input, output) {

  # ========================
  # DF_FILTRE
  # ========================
  # Crée un dataframe reactif en fonction des filtres de la sidebar (voir UI)
  # Utilisé par la suite notamment pour générer des plots réactifs aux filtres de la sidebar
  
  df_filtre = reactive({ 
    
    # CONDITION FILTRE "ZONE GEOGRAPHIQUE"
    if(is.null(input$select_zone)){
        # affiche toutes les données si le filtre n'est pas apppliqué
      selected_zone=unique(df_all$zone_geographique)
    } else{
        # affiche les données en fonction de la selection dans le filtre
      selected_zone=input$select_zone
    }
      # filtre les données brutes en fonction de selected_zone
    condition_zone = df_all$zone_geographique %in% selected_zone
    
    # CONDITION FILTRE "UMR"
    if(is.null(input$select_umr)){
      selected_umr=unique(split_vec_string(df_all$unite, sep="\t"))
    } else{
      selected_umr=input$select_umr
    }
    condition_umr = rep(FALSE,nrow(df_all))
    for(k in 1:length(selected_umr)){
      condition_umr = condition_umr | grepl(selected_umr[k], df_all$unite, fixed = TRUE)
    }
    condition_umr[is.na(condition_umr)]=TRUE
    
    # CONDITION FILTRE "PROJECTION"
    if(is.null(input$select_projection)){
      selected_proj_sud=unique(split_vec_string(df_all$proj_sud, sep="\t"))
    } else{
      selected_proj_sud=input$select_projection
    }
    condition_projection = rep(FALSE,nrow(df_all))
    for(k in 1:length(selected_proj_sud)){
      condition_projection = condition_projection | grepl(selected_proj_sud[k], df_all$proj_sud, fixed = TRUE)
    }
    condition_projection[is.na(condition_projection)]=TRUE
    
    # CONDITION FILTRE "THEMATIQUE"
    if(is.null(input$select_thematique)){
      selected_thematique=unique(split_vec_string(df_all$thematique, sep="\t"))
    } else{
      selected_thematique=input$select_thematique
    }
    condition_thematique = rep(FALSE,nrow(df_all))
    for(k in 1:length(selected_thematique)){
      condition_thematique = condition_thematique | grepl(selected_thematique[k], df_all$thematique, fixed = TRUE)
    }
    condition_thematique[is.na(condition_thematique)]=TRUE
    
    #CONDITION CHECKBOX
    if(input$checkbox_masquer_france){
      selected_checkbox=unique(df_all[!(df_all$pays_fr== "France métropolitaine"), ]$pays_fr,)
    } else{
      selected_checkbox=unique(df_all$pays_fr)
    }
    condition_checkbox = df_all$pays_fr %in% selected_checkbox

    # DEFINITION DF_FILTRE
    # Prend en compte l'ensemble des conditions/filtres détaillés précédement pour créer le dataframe réactif "df_filtre"
    df_filtre = df_all[condition_zone & condition_umr & condition_projection & condition_thematique & condition_checkbox,]
  
  }) # end of df_filtre()
  

  #########################################
  #               CARTE IRD               #
  #########################################
  
  
  # ========================
  # LEAFLET MAP
  # ========================
  # Carte du monde réactive aux filtres de la sidebar
  # Affiche un nombre d'agent par pays en fonction des filtres
  # Les pays comprenant des agents sont colorés par des polygones cliquables
  # Cliquer sur un polygone permettra d'afficher les informations relatives au pays dans des valueboxes, des cards etc.
  

  # Définition du nombre d'agent par pays en fonction des filtres
  nb_actions_unique_from_df_filtre = reactive ({ 
    data.frame(table(df_filtre()$name))$Freq[match(df_filtre()$name[!duplicated(df_filtre()$name)], data.frame(table(df_filtre()$name))$Var1)]
  })
  
  reactive_ird_map = reactive({
    
    # Group the data by the name column and calculate the centroids for each group
    centroids = df_filtre() %>%
      group_by(name) %>%
      summarise(centroid = st_centroid(st_union(geometry)))
    
    centroids_df = centroids %>%
      mutate(longitude = st_coordinates(.)[, 1],
             latitude = st_coordinates(.)[, 2]) %>%
      select(name, latitude, longitude)
    
    # Create leaflet object
    leaflet(options = leafletOptions(zoomSnap = 0.25, zoomDelta=0.25)) %>%
      # Choix du fond de carte
      addProviderTiles("CartoDB.PositronNoLabels") %>%
      # addProviderTiles("Esri.WorldImagery") %>%
      setView(lng=10, lat=0, zoom=2) %>%
      addMiniMap(width = 150, height = 150) %>%
      #Ajoute les polygones cliquables
      addPolygons(data=df_filtre()[!duplicated(df_filtre()$name),],
                  stroke = TRUE,
                  fillColor = my_color_palette(nb_actions_unique_from_df_filtre()),
                  fillOpacity = 0.7,
                  color = "white",
                  weight = 1) %>%
      # Ajoute les noms de pays au centre des polygones affiches correspondant
      addLabelOnlyMarkers(data = st_centroid(df_filtre()$geometry[!duplicated(df_filtre()$pays_fr),]),
                          label = df_filtre()$pays_fr[!duplicated(df_filtre()$pays_fr)],
                          labelOptions = labelOptions(noHide = TRUE,
                                                      textOnly = TRUE,
                                                      direction = "center",
                                                      style = list(font.size = "12px", font.weight = "bold", strokeColor = "#FFF", strokeWidth = 2, color="black"))) %>%
      
      
      addLegend(pal = colorNumeric(my_color_palette(seq(0,max(nb_actions_unique_from_df_filtre()),1)), domain= seq(0,max(nb_actions_unique_from_df_filtre()),1)),
                values = seq(0,max(nb_actions_unique_from_df_filtre()),1),
                opacity = 0.9,
                title = "Actions",
                position = "bottomleft",
                bins=length(unique(nb_actions_unique_from_df_filtre())))
  }) # end of reactive_ird_map
  
  
  # Output permettant d'afficher la carte dans l'UI
  output$mymap = renderLeaflet({
    reactive_ird_map()
  })
 

  #########################################
  #             STATISTIQUES              #
  #########################################
  # Statistiques globales et ractives en fonction des filtres
  # Ne sont pas influencées par les polygones cliqués
  
  selected_dispositif <- reactive({
    input$select_projection
  })

  # TITRES DE CARDS REACTIFS
  # output$title_planning_missions <- renderText({
  #   sprintf("Planning des missions (%s)", selected_dispositif())
  # })
  #
  # output$title_projections_pays <- renderText({
  #   sprintf("Répartition de la projection '%s' par pays", selected_dispositif())
  # })
  #
  # output$title_projections_zones <- renderText({
  #   sprintf("Répartition de la projection '%s' par zones", selected_dispositif())
  # })
  #
  # output$title_HF <- renderText({
  #   sprintf("Répartition Hommes-Femmes (%s)", selected_dispositif())
  # })

  
  # ==================
  # BAR PLOT PAYS 
  # ==================
  # Donne la repartition des agents par pays, en fonction des filtres

  output$stat_nb_actions_pays = renderPlot({
    data_all = as.data.frame(table(df_all$pays_fr))
    data_filtre = as.data.frame(table(df_filtre()$pays_fr))
    missing_values = setdiff(data_all$Var1,data_filtre$Var1)
    data_barplot = rbind(data_filtre, data.frame(Var1=missing_values, Freq=rep(0,length(missing_values))))
    tmp = sort.int(data_barplot$Freq, index.return=TRUE, decreasing = TRUE)
    data_barplot = data_barplot[tmp$ix,]
    par(mai=c(2, 0.5, 0.25, 0.25))
    bar_pays = barplot(data_barplot$Freq, names.arg = data_barplot$Var1, col="#1d71b8", border="white", las=2, ylim=c(0,ceiling(1.2*max(data_barplot$Freq))), yaxt="n")
    at_values = set_axis_values(data_barplot$Freq)
    abline(h = at_values, lwd = 0.5, col = "#8a8a8a", lty=2)
    axis(2, at = at_values, labels = at_values, las = 1)
    barplot(data_barplot$Freq, names.arg = data_barplot$Var1, col="#1d71b8", border="white", las=2, xlab="", ylab="", xaxt="n", yaxt="n", add=TRUE)
    text(bar_pays, data_barplot$Freq + 0.05*max(data_barplot$Freq), paste(data_barplot$Freq), pos=3)
  })
  
  # Telechargement de stat_nb_actions_pays
  output$downloadPlot_pays = downloadHandler(
    filename = sprintf("hist-pays-%s.png",Sys.Date()),
    content = function(file) {
      png(file, width=800, height=400)
      
      data_all = as.data.frame(table(df_all$pays_fr))
      data_filtre = as.data.frame(table(df_filtre()$pays_fr))
      missing_values = setdiff(data_all$Var1,data_filtre$Var1)
      data_barplot = rbind(data_filtre, data.frame(Var1=missing_values, Freq=rep(0,length(missing_values))))
      tmp = sort.int(data_barplot$Freq, index.return=TRUE, decreasing = TRUE)
      data_barplot = data_barplot[tmp$ix,]
      par(mai=c(2, 0.5, 0.25, 0.25))
      bar_pays = barplot(data_barplot$Freq, names.arg = data_barplot$Var1, col="#1d71b8", border="white", las=2, ylim=c(0,ceiling(1.2*max(data_barplot$Freq))), yaxt="n")
      at_values = set_axis_values(data_barplot$Freq)
      abline(h = at_values, lwd = 0.5, col = "#8a8a8a", lty=2)
      axis(2, at = at_values, labels = at_values, las = 1)
      barplot(data_barplot$Freq, names.arg = data_barplot$Var1, col="#1d71b8", border="white", las=2, xlab="", ylab="", xaxt="n", yaxt="n", add=TRUE)
      text(bar_pays, data_barplot$Freq + 0.05*max(data_barplot$Freq), paste(data_barplot$Freq), pos=3)
      
      dev.off()
    }
  )
  
  
  
  # ==================
  # BAR PLOT REGIONS
  # ==================
  # Donne la repartition des agents par zone geographique, en fonction des filtres
  
  output$stat_nb_actions_regions = renderPlot({
    data_all = as.data.frame(table(df_all$zone_geographique))
    data_filtre = as.data.frame(table(df_filtre()$zone_geographique))
    missing_values = setdiff(data_all$Var1,data_filtre$Var1)
    data_barplot = rbind(data_filtre, data.frame(Var1=missing_values, Freq=rep(0,length(missing_values))))
    tmp = sort.int(data_barplot$Freq, index.return=TRUE, decreasing = FALSE)
    data_barplot = data_barplot[tmp$ix,]
    par(mai=c(0.5, 3.5, 0.25, 0.25)) # marges = c(bas, gauche, haut, droite)
    bar_region = barplot(data_barplot$Freq, horiz = TRUE, names.arg = data_barplot$Var1, col="#1d71b8", border="white", las=2, xlim=c(0,1.2*max(data_barplot$Freq)), xaxt="n")
    at_values = set_axis_values(data_barplot$Freq)
    abline(v = at_values, lwd = 0.5, col = "#8a8a8a", lty=2)
    barplot(data_barplot$Freq, horiz = TRUE, names.arg = data_barplot$Var1, col="#1d71b8", border="white", las=2, xlab="", ylab="", xaxt="n", yaxt="n", add=TRUE)
    axis(1, at = at_values, labels = at_values)
    text(data_barplot$Freq + 1, bar_region, paste(data_barplot$Freq), pos=4) #pos=3 permet de centrer les valeurs par rapport aux barres, par exemle pos=2 place les valeurs un peu plus a gauche
    
  })
  
  # Telechargement de stat_nb_actions_regions
  output$downloadPlot_zones = downloadHandler(
    filename = sprintf("hist-zones-%s.png",Sys.Date()),
    content = function(file) {
      png(file, width=800, height=400)
      
      data_all = as.data.frame(table(df_all$zone_geographique))
      data_filtre = as.data.frame(table(df_filtre()$zone_geographique))
      missing_values = setdiff(data_all$Var1,data_filtre$Var1)
      data_barplot = rbind(data_filtre, data.frame(Var1=missing_values, Freq=rep(0,length(missing_values))))
      tmp = sort.int(data_barplot$Freq, index.return=TRUE, decreasing = FALSE)
      data_barplot = data_barplot[tmp$ix,]
      par(mai=c(0.5, 3.5, 0.25, 0.25)) # marges = c(bas, gauche, haut, droite)
      bar_region = barplot(data_barplot$Freq, horiz = TRUE, names.arg = data_barplot$Var1, col="#1d71b8", border="white", las=2, xlim=c(0,1.2*max(data_barplot$Freq)), xaxt="n")
      at_values = set_axis_values(data_barplot$Freq)
      abline(v = at_values, lwd = 0.5, col = "#8a8a8a", lty=2)
      barplot(data_barplot$Freq, horiz = TRUE, names.arg = data_barplot$Var1, col="#1d71b8", border="white", las=2, xlab="", ylab="", xaxt="n", yaxt="n", add=TRUE)
      axis(1, at = at_values, labels = at_values)
      text(data_barplot$Freq + 1, bar_region, paste(data_barplot$Freq), pos=4) #pos=3 permet de centrer les valeurs par rapport aux barres, par exemle pos=2 place les valeurs un peu plus a gauche
      
      dev.off()
    }
  )
  
  
  
  # ==================
  # BAR PLOT UNITES
  # ==================
  # Donne la distribution des agents en fonction de leurs unités
  
  output$stat_unite = renderPlot({
    data_all = as.data.frame(table(df_all$unite[df_all$unite %in% c("MARBEC", "LEGOS", "SECOPOL", "LOCEAN", "LEMAR", "MIO", "ENTROPIE")]))
    data_filtre = as.data.frame(table(df_filtre()$unite[df_filtre()$unite %in% c("MARBEC", "LEGOS", "SECOPOL", "LOCEAN", "LEMAR", "MIO", "ENTROPIE")]))
    missing_values = setdiff(data_all$Var1,data_filtre$Var1)
    data_barplot = rbind(data_filtre, data.frame(Var1=missing_values, Freq=rep(0,length(missing_values))))
    tmp = sort.int(data_barplot$Freq, index.return=TRUE, decreasing = TRUE)
    data_barplot = data_barplot[tmp$ix,]
    bar_hf= barplot(data_barplot$Freq, names.arg = data_barplot$Var1, col="#1d71b8", border="white", ylim=c(0,ceiling(1.2*max(data_barplot$Freq))), yaxt="n")
    par(mai=c(1.02, 1, 0.82, 0.42))
    # at_values = seq(0, ceiling(1.1*max(data_barplot$Freq)), by = ceiling(max(data_barplot$Freq)/6))
    at_values = set_axis_values(data_barplot$Freq)
    abline(h = at_values, lwd = 0.5, col = "#8a8a8a", lty=2)
    barplot(data_barplot$Freq, names.arg = data_barplot$Var1, col="#1d71b8", border="white", xlab="", ylab="", xaxt="n", yaxt="n", add=TRUE)
    axis(2, at = at_values, labels = at_values, las=1) #2:axe ordonnees, at: position, labels: labels
    text(bar_hf, data_barplot$Freq + 1, paste(data_barplot$Freq), pos=3)
  })
  
  output$downloadPlot_unite = downloadHandler(
    filename = sprintf("hist-hf-%s.png",Sys.Date()),
    content = function(file) {
      png(file, width=800, height=400)
      
      data_all = as.data.frame(table(df_all$unite[df_all$unite %in% c("MARBEC", "LEGOS", "SECOPOL", "LOCEAN", "LEMAR", "MIO", "ENTROPIE")]))
      data_filtre = as.data.frame(table(df_filtre()$unite[df_filtre()$unite %in% c("MARBEC", "LEGOS", "SECOPOL", "LOCEAN", "LEMAR", "MIO", "ENTROPIE")]))
      missing_values = setdiff(data_all$Var1,data_filtre$Var1)
      data_barplot = rbind(data_filtre, data.frame(Var1=missing_values, Freq=rep(0,length(missing_values))))
      tmp = sort.int(data_barplot$Freq, index.return=TRUE, decreasing = TRUE)
      data_barplot = data_barplot[tmp$ix,]
      bar_hf= barplot(data_barplot$Freq, names.arg = data_barplot$Var1, col="#1d71b8", border="white", ylim=c(0,ceiling(1.2*max(data_barplot$Freq))), yaxt="n")
      par(mai=c(1.02, 1, 0.82, 0.42))
      # at_values = seq(0, ceiling(1.1*max(data_barplot$Freq)), by = ceiling(max(data_barplot$Freq)/6))
      at_values = set_axis_values(data_barplot$Freq)
      abline(h = at_values, lwd = 0.5, col = "#8a8a8a", lty=2)
      barplot(data_barplot$Freq, names.arg = data_barplot$Var1, col="#1d71b8", border="white", xlab="", ylab="", xaxt="n", yaxt="n", add=TRUE)
      axis(2, at = at_values, labels = at_values, las=1) #2:axe ordonnees, at: position, labels: labels
      text(bar_hf, data_barplot$Freq + 1, paste(data_barplot$Freq), pos=3)
      
      dev.off()
  })
  
  
  
  # ==================
  # GANTT
  # ==================
  # Diagramme de GANTT donnant une projection temporelle des missions/affectations/contrats
  
  output$gantt_chart = renderPlotly({
    
    #recuperation des donnees
    df_gantt = df_filtre()[!is.na(df_filtre()$debut) & !is.na(df_filtre()$fin),c("debut","fin","pays_fr","duree","individu","unite")]
    df_gantt$geometry = NULL
    df_gantt$debut = as.POSIXct.Date(as.Date(df_gantt$debut, format = "%d/%m/%y"))
    df_gantt$fin = as.POSIXct.Date(as.Date(df_gantt$fin, format = "%d/%m/%y"))
    list_of_umr = unique(df_gantt$unite)
    n = length(list_of_umr)
    cols = rep(RColorBrewer::brewer.pal(12, name = "Set3"), 10)
    cols = cols[1:n]
    df_gantt$color = factor(df_gantt$unite, labels = cols)
    
    #reorder dataframe according to UMR
    reordering_umr = sort.int(df_gantt$unite, index.return=TRUE) # sort.int --> permutation, permet de rearranger les lignes entieres en fonction du tri des valeurs d'une colonne en particulier
    df_gantt = df_gantt[reordering_umr$ix,]
    
    row.names(df_gantt) = NULL
    
    # reorder dataframe by date
    df_gantt_sorted = data.frame(debut=numeric(0), fin=numeric(0), pays_fr=numeric(0), duree=numeric(0), agent=numeric(0), unite=numeric(0), color=numeric(0))
    for(k in 1:n){
      reordering_debut = sort.int(df_gantt$debut[df_gantt$unite==list_of_umr[k]], index.return=TRUE, decreasing=TRUE)
      df_gantt_sorted = rbind(df_gantt_sorted, df_gantt[df_gantt$unite==list_of_umr[k],][reordering_debut$ix,])
    }
    
    fig = plot_ly()
    
    tmp = list_of_umr
    for(i in 1:nrow(df_gantt_sorted)){
      
      # determine whether or not we show the legend
      show_legend = FALSE
      if(df_gantt_sorted$unite[i] %in% tmp){
        show_legend = TRUE
        tmp = setdiff(tmp, df_gantt_sorted$unite[i])
      }
      
      fig = add_trace(fig,
                      x = c(df_gantt_sorted$debut[i],df_gantt_sorted$fin[i]),
                      y = c(4*i,4*i),
                      type = "scatter",
                      mode = "lines",
                      line = list(color = df_gantt_sorted$color[i], width = 5), #df_gantt$color[i]
                      showlegend = show_legend,
                      name = df_gantt_sorted$unite[i],
                      hoverinfo = "text",
                      # choix des informations a afficher qund l'utilisateur place le curseur au bout d'une barre du gantt
                      text = paste("Pays: ", df_gantt_sorted$pays_fr[i], "<br>",
                                   "Début: ", df_gantt_sorted$debut[i], "<br>",
                                   "Fin: ", df_gantt_sorted$fin[i], "<br>",
                                   "Durée: ", df_gantt_sorted$duree[i], "<br>",
                                   "Agent: ", df_gantt_sorted$agent[i], "<br>",
                                   "Unité: ", df_gantt_sorted$unite[i]) 
      ) %>%
        layout(xaxis = list(type = "date", showaxis = TRUE, showgrid = TRUE, gridwidth = 0.5, gridcolor = '#cccccc', gridpattern = "dot", zeroline = FALSE), yaxis = list(showaxis = FALSE, showticklabels = FALSE))
    }
    fig
  })

  # Remarque : Pas besoin de coder un bouton de telechargement du gantt car plotly fournit un bouton directement sur le gantt dans l'ui
  
  
  ########## POLYGONS OBSERVE EVENT (ENVIRONNEMENT REACTIF) ##########
  
  # Permet de definir le click sur un polygone de la carte comme un evenemet declenchant l'affichage de donnes dans d'autres parties de l'application
  # Tout ce qui est contenu dans l'observeEvent ne sera declenche aue quand un polygone de la carte sera clique par l'utilisateur
  observeEvent(input$mymap_shape_click, {
    click = input$mymap_shape_click
    
    idx_country = st_intersects(st_point(c(click$lng, click$lat)), df_filtre()$geometry[!duplicated(df_filtre()$name)])[[1]]
    country_name = df_filtre()$name[!duplicated(df_filtre()$name)][idx_country] #on peut mettre pays_fr.x a la place du premier name
    country_name_fr = df_filtre()$french_short[!duplicated(df_filtre()$name)][idx_country] 
    
    # Définition des valueboxes réactives
    # Chaque valuebox indique combien on a de tel type de projection dans le pays cliqué sur la carte interactive
    output$value_box_pays = renderValueBox({
      valueBox(unique(df_all$pays_fr[df_all$name==country_name]),"")
    })
    
    output$value_box_MLD = renderValueBox({
      valueBox(sum((df_filtre()$name[!is.na(df_filtre()$proj_sud)]==country_name)&(df_filtre()$proj_sud[!is.na(df_filtre()$proj_sud)]=="Mission Longue Durée")),"") 
    })
    
    output$value_box_mobilite = renderValueBox({
      valueBox(sum((df_filtre()$name[!is.na(df_filtre()$proj_sud)]==country_name)&(df_filtre()$proj_sud[!is.na(df_filtre()$proj_sud)]=="Mobilité Sud Nord")),"") 
    })
    
    output$value_box_exp = renderValueBox({
      valueBox(sum((df_filtre()$name[!is.na(df_filtre()$proj_sud)]==country_name)&(df_filtre()$proj_sud[!is.na(df_filtre()$proj_sud)]=="Expatriation")),"") 
    })
    
    output$value_box_aff = renderValueBox({
      valueBox(sum((df_filtre()$name[!is.na(df_filtre()$proj_sud)]==country_name)&(df_filtre()$proj_sud[!is.na(df_filtre()$proj_sud)]=="Affectation")),"") 
    })
    
    output$value_box_volontaire_SC = renderValueBox({
      valueBox(sum((df_filtre()$name[!is.na(df_filtre()$proj_sud)]==country_name)&(df_filtre()$proj_sud[!is.na(df_filtre()$proj_sud)] %in% c("Volontaire de Service Civique","Volontaire Civil","Volontaire International en Administration"))),"") 
    })
    
    # =======================
    # TABLEAU DE BORD REACTIF
    # =======================
    
    # pays cliqué
    output$filtre_pays = renderText({
      paste(unique(df_all$pays_fr[df_all$name==country_name]))
    })
    
    # Unités présentes dans le pays 
    output$unites_pays = renderText({
      paste(paste(unique(df_all$unite[df_all$name==country_name]), collapse = ", "))
    })
    
    # THEMATIQUES
    # Lit les thematiques des differentes lignes de df_all en fonction du pays clique
    # extrait les differents elements des chaines de caracteres stockees dans chaque ligne et en fait une liste sans repetition

    thematique_pays = unique(na.omit(df_all$thematique[df_all$name==country_name]))
    thematique_pays_split = unlist(strsplit(thematique_pays, ";"))
    is_first_char_blank = substr(thematique_pays_split, 1, 1) == " "
    thematique_pays_split[is_first_char_blank] = substring(thematique_pays_split[is_first_char_blank], 2)
    thematique_pays_split = unique(thematique_pays_split)
    
    output$thematiques = renderUI({
      HTML(paste(thematique_pays_split, collapse = "<br>"))
    })
    
    # MOTS CLES
    # Lit les mots cles des differentes lignes de df_all en fonction du pays clique
    # Comme pour les thematiques, extrait les differents elements des chaines de caracteres stockees dans chaque ligne et en fait une liste sans repetition
    mots_cles_pays = unique(na.omit(df_all$mot_clef[df_all$name==country_name]))
    mots_cles_pays_split =  unlist(strsplit(mots_cles_pays, "\t"))
    is_first_char_blank = substr(mots_cles_pays_split, 1, 1) == " "
    mots_cles_pays_split[is_first_char_blank] = substring(mots_cles_pays_split[is_first_char_blank], 2)
    mots_cles_pays_split = unique(mots_cles_pays_split)

    # Affichage des mots cles dans l'interface
    output$mots_cles = renderText({
      paste(mots_cles_pays_split)
    })
      
        
    # df reactif pays, affichage infos dico dispositifs
    
    if (country_name_fr == "France"){
      df_data_dico_unites_filtre = df_data_dico_unites
      output$dico_dispositifs_filtre = DT::renderDataTable(
        DT::datatable(df_data_dico_unites_filtre, escape=FALSE,
                      options = list(
                        pageLength = 20, autoWidth = TRUE,
                        columnDefs = list(list( targets = 7, width = '800px')),
                        scrollX = TRUE 
                      )     
        )
      )
    } else {
      df_data_dico_dispositifs_filtre = df_data_dico_dispositifs[df_data_dico_dispositifs$Pays.d.implantation==country_name_fr, c("Dispositif", "Date.de.début", "Date.de.fin", "Acronyme", "Intitulé", "Unités.porteuses", "Porteur.s..Sud", "Porteur.s..IRD")]
      output$dico_dispositifs_filtre = DT::renderDataTable(
        DT::datatable(df_data_dico_dispositifs_filtre, escape=FALSE,
                      options = list(
                        pageLength = 20, autoWidth = TRUE,
                        columnDefs = list(list( targets = 5, width = '400px')),
                        scrollX = TRUE
                      )      
        )
      )
    }
        
        
    # donnes brutes filtrees
    # affiche un tableau reactif (en fonction des filtres) des donnees relatives au pays clique
    raw_df_filtre = df_filtre()[df_filtre()$name==country_name, c("proj_sud", "pays_fr", "debut", "fin", "unite", "dispositif", "agent")]
    raw_df_filtre$geometry = NULL
    output$pays_table = renderDataTable(raw_df_filtre)

  }) # End of ObserveEvent
  
  
  # ==============================
  # DONNEES DICTIONNAIRE UNITES
  # ==============================
  # affiche les donnes de la base CODEDISPOSITIFSOCEANS_ddmmyy
  output$donnees_dico_unites = DT::renderDataTable(
    DT::datatable(df_data_dico_unites, escape=FALSE,
                  options = list(
                    pageLength = 20, autoWidth = TRUE,
                    columnDefs = list(list( targets = 7, width = '800px')),
                    scrollX = TRUE
                  )
    )
  )
  
  # ===================================
  # DONNEES DICTIONNAIRE DISPOSITIFS
  # ===================================
  # affiche les donnes de la base CODEUNITESOCEANS_ddmmyy
  output$donnees_dico_dispositifs = DT::renderDataTable(
    DT::datatable(df_data_dico_dispositifs, escape=FALSE,
                  options = list(
                    pageLength = 20, autoWidth = TRUE,
                    columnDefs = list(list( targets = 5, width = '800px'),
                                      list( targets = 11, width = '800px')),
                    scrollX = TRUE
                  ) 
    )
  ) 
  
  # ========================
  # DONNEES BRUTES
  # ========================
  # affiche les donnes de la base oceansALL_ddmmyy
  output$raw_data <- DT::renderDataTable(
    DT::datatable(df_data, escape=FALSE, 
                  options = list(
                    pageLength = 20, autoWidth = TRUE,
                    columnDefs = list(list( targets = 21, width = '800px')),
                    scrollX = TRUE
                  )
    )
  )
  
}
  

