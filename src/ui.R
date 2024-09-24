
ui <- page_navbar(

  
# ========================
# HEADER
# ======================== 
  
  title = tagList(
    img(src = "https://i.ibb.co/Hqrh8M5/Logo-IRD-2016-BLOC-FR-COUL.png", height = 60),
    "|  DEPARTEMENT OCEANS"
  ),
nav_spacer(),


# ========================
# SIDEBAR
# ========================
#Menus deroulants permettant de filtrer les donnees de df_all
sidebar = sidebar(
  "FILTRES :",
    selectInput("select_projection", "Outil de projection", choices = unique(split_vec_string(df_data$proj_sud[!is.na(df_data$proj_sud)], sep=";")), multiple = TRUE),
    selectInput("select_dispositif_structurant", "Dispositif structurant", choices = unique(split_vec_string(df_data$dispositif[!is.na(df_data$dispositif)], sep=";")), multiple = TRUE),
    selectInput("select_umr", "Unités", choices = unique(split_vec_string(df_data$unite[!is.na(df_data$unite)], sep=";")), multiple = TRUE),
    selectInput("select_zone", "Zones", choices = unique(df_data$zone_geographique), multiple = TRUE),
    selectInput("select_thematique", "Thématiques", choices = unique(split_vec_string(df_data$thematique[!is.na(df_data$thematique)], sep=";")), multiple = TRUE),
    selectInput("select_mots_cles", "Mots-clés", choices = unique(split_vec_string(df_data$mot_clef[!is.na(df_data$mot_clef)], sep=";")), multiple = TRUE),
    selectInput("select_genre", "Genre", choices = unique(df_data$genre[!is.na(df_data$genre)]), multiple = TRUE),
    checkboxInput("checkbox_masquer_france", "Masquer France Métropolitaine?")
  ), # end of sidebar

# ========================
# MAIN PANEL
# ========================
  
navset_card_tab(full_screen = TRUE,
                
  ###### CARTE ######
  nav_panel("Outils de projection - Pays", 
    fluidRow(
      column(width=8,
      ### Card Leaflet
      card(
        card_body(  
          withSpinner(
            leafletOutput("mymap", height="65vh"),
            type = 5,
            color = "#1d71b8",
            size = 0.5
          ),
          "*Cliquez sur un pays pour afficher les informations associées",
        )
      ), # end of card
      
      card(
        card_header(
          class = "bg-blue",
          "Infos dispositifs du pays sélectionné" 
        ),
        card_body(
          dataTableOutput("dico_dispositifs_filtre") 
        ) 
      ) # end of card
      ), # end of column
    
  ###### INFOS PAYS ######
  
      column(width=4, 
      
      ### Card value boxes
        card(
          fluidRow(
            column(width = 6,
                   value_box(
                     fill = FALSE,
                     title = NULL,
                     value = valueBoxOutput("value_box_pays", width=1),
                     theme = "lightgrey",
                     height = "100px"
                   )
            ),
            column(width = 6,
                   value_box(
                     fill = FALSE,
                     title = "MLD",
                     value = valueBoxOutput("value_box_MLD", width=1),
                     theme = "blue",
                     height = "100px"
                   )
            ),
            column(width = 6,
                   value_box(
                     fill = FALSE,
                     title = "Mobilité Sud/Nord",
                     value = valueBoxOutput("value_box_mobilite", width=1),
                     theme = "blue",
                     height = "100px"
                   )
            ),
            column(width = 6,
                   value_box(
                     fill = FALSE,
                     title = "Expatriation",
                     value = valueBoxOutput("value_box_exp", width=1),
                     theme = "blue",
                     height = "100px"
                   )
            ),
            column(width = 6,
                   value_box(
                     fill = FALSE,
                     title = "Affectation",
                     value = valueBoxOutput("value_box_aff", width=1),
                     theme = "blue",
                     height = "100px"
                   )
            ),
            column(width = 6,
                   value_box(
                     fill = FALSE,
                     title = "Volontariat",
                     value = valueBoxOutput("value_box_volontaire_SC", width=1),
                     theme = "blue",
                     height = "100px"
                   )
            )  
          
          ) # end of fluidrow
        ), # end of valuebox card

    
      ### Card mots-clés
      card(
        card_header(
          class = "bg-blue",
          "Mots-clés"
        ),
        card_body(
          textOutput("mots_cles")
        )
      ),

      ### Card infos pays
        card(
          card_header(
             class = "bg-blue",
             "Informations générales sur le pays cliqué"
          ),
          card_body(
             #textOutput("filtre_pays"),
             textOutput("unites_pays"),
             htmlOutput("thematiques")
           )
         ),
      
      ### Donnees filtrees
        card(
            card_body(
              dataTableOutput("pays_table", height="30px")
            )
        )

      ) # end of column
    ) # end of fluidrow
  ), # end of panel

  ## PANEL : STATISTIQUES ###

  nav_panel(
    "Outils de projection - Statistiques",
  card(
    card_body(
      "*Les statistiques réagissent aux filtres appliqués",
      br(),
      "**veuillez sélectionner un outil de projection et/ou un dispositif structurant",
      br(),
      "***Vous trouverez un bouton de téléchargement sous chaque graphe (scrollez si besoin)",
      layout_column_wrap(
        width = 1/2,
        height = 300,
        
        # Card GANTT 
        card(
          card_header(
            class = "bg-blue",
            "Planning des missions"
          ),
          card_body(
            withSpinner(
              plotlyOutput("gantt_chart"),
              type = 5,
              color = "#1d71b8",
              size = 0.5
            )
          )
        ),
        
        # Card repartition PAYS
        card(
          card_header(
            class = "bg-blue",
            "Répartition des projections par pays"
          ),
          card_body(
            withSpinner(
              plotOutput("stat_nb_actions_pays"),
              type = 5,
              color = "#1d71b8",
              size = 0.5
            ),
            downloadButton("downloadPlot_pays", "Download plot as PNG")
          )
        ),
  
        # Card repartition ZONES GEOGRAPHIQUES
        card(
          card_header(
            class = "bg-blue",
            "Répartition des projections par zones géographiques"
          ),
          card_body(
            withSpinner(
              plotOutput("stat_nb_actions_regions"),
              type = 5,
              color = "#1d71b8",
              size = 0.5
            ),
            downloadButton("downloadPlot_zones", "Download plot as PNG")
            
          )
        ),
        
        # Card repartition HOMMES/FEMMES
        card(
          card_header(
            class = "bg-blue",
            "Répartition Hommes/Femmes"
          ),
          card_body(
            withSpinner(
              plotOutput("stat_hf"),
              type = 5,
              color = "#1d71b8",
              size = 0.5
            ),
            downloadButton("downloadPlot_hf", "Download plot as PNG")
          )
        )
     ) # end of layout column wrap
    )  # end of body
    ) # end of statistics card
  ), # end of panel
  
  
  ###### PANEL : DICO UNITES #######
  
  nav_panel(
    "Dictionnaire unités OCEANS",
    card_body(
      "*Interface de recherche d'informations relatives aux unités du DS OCEANS",
      DT::dataTableOutput("donnees_dico_unites")
    )
  ), # end of panel
  
  ###### PANEL : DICO DISPOSITIFS #######
  
  nav_panel(
    "Dictionnaire dispositifs OCEANS",
    card_body(
      "*Interface de recherche d'informations relatives aux dispositifs OCEANS",
      DT::dataTableOutput("donnees_dico_dispositifs")
      
    )
  ), # end of panel 
  
  
  
  ###### PANEL : DONNEES BRUTES #######

  nav_panel(
    "Données brutes",
    card_body(
      "*Les données ci-dessous ne réagissent pas aux filtres appliqués",
      "**pays_fr : relatif à l'instrument de projection",
      downloadButton("downloadRawdata", "Download raw data as .csv"),
      DT::dataTableOutput("raw_data")
    )
  ), # end of panel
) # end of main 
) # end of UI


