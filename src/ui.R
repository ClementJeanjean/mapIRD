# Load the mapIRD logo from www folder
# (Shiny copies the contents of the www folder to a temporary web server directory when the app starts.)
logo_name = "mapIRD_logo.png"

# Define the UI using a navbar page layout

ui <- page_navbar(

  # ========================
  # HEADER
  # ========================
  # Set the page title with mapIRD logo
  title = tagList(
    img(src = logo_name, height = 60)
  ),
  nav_spacer(),
  
  # ========================
  # SIDEBAR
  # ========================
  # Sidebar with dropdown menus to filter data in df_all
  sidebar = sidebar(
    "FILTERS:",
    selectInput("select_projection", "Projection tool", choices = unique(split_vec_string(df_data$proj_sud[!is.na(df_data$proj_sud)], sep=";")), multiple = TRUE),
    selectInput("select_zone", "Zones", choices = unique(df_data$zone_geographique), multiple = TRUE),
    selectInput("select_thematique", "Themes", choices = unique(split_vec_string(df_data$thematique[!is.na(df_data$thematique)], sep=";")), multiple = TRUE),
    checkboxInput("checkbox_masquer_france", "Hide Metropolitan France?")
  ), # end of sidebar
  
  # ========================
  # MAIN PANEL
  # ========================
  # Main content area with tabbed panels
  navset_card_tab(full_screen = TRUE,
                  
                  # ==== TAB: PROJECTION TOOLS BY COUNTRY ====
                  nav_panel("Projection tools - Countries",
                            fluidRow(
                              column(width=8,
                                     # Leaflet map card
                                     card(
                                       card_body(
                                         withSpinner(
                                           leafletOutput("mymap", height="65vh"),
                                           type = 5,
                                           color = "#1d71b8",
                                           size = 0.5
                                         ),
                                         "*Click on a country to display associated information",
                                       )
                                     ), # end of card
                              ), # end of column
                              
                              # ==== COUNTRY INFO ====
                              column(width=4,
                                     
                                     # Value boxes card
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
                                                  title = "South/North Mobility",
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
                                                  title = "Assignment",
                                                  value = valueBoxOutput("value_box_aff", width=1),
                                                  theme = "blue",
                                                  height = "100px"
                                                )
                                         ),
                                         column(width = 6,
                                                value_box(
                                                  fill = FALSE,
                                                  title = "Volunteering",
                                                  value = valueBoxOutput("value_box_volontaire_SC", width=1),
                                                  theme = "blue",
                                                  height = "100px"
                                                )
                                         )
                                       ) # end of fluidrow
                                     ), # end of valuebox card
                                     
                                     # Country info card
                                     card(
                                       card_header(
                                         class = "bg-blue",
                                         "General information about the clicked country"
                                       ),
                                       card_body(
                                         textOutput("unites_pays"),
                                         htmlOutput("thematiques")
                                       )
                                     ),
                                     
                                     # Filtered data card
                                     card(
                                       card_body(
                                         dataTableOutput("pays_table", height="30px")
                                       )
                                     )
                              ) # end of column
                            ) # end of fluidrow
                  ), # end of panel
                  
                  # ==== TAB: PROJECTION TOOLS - STATISTICS ====
                  nav_panel(
                    "Projection tools - Statistics",
                    card(
                      card_body(
                        "*Statistics respond to applied filters",
                        br(),
                        "**Please select a projection tool",
                        br(),
                        "***You will find a download button under each graph (scroll if needed)",
                        layout_column_wrap(
                          width = 1/2,
                          height = 300,
                          
                          # Gantt chart card
                          card(
                            card_header(
                              class = "bg-blue",
                              "Mission planning"
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
                          
                          # Country distribution card
                          card(
                            card_header(
                              class = "bg-blue",
                              "Distribution of projections by country"
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
                          
                          # Geographic zone distribution card
                          card(
                            card_header(
                              class = "bg-blue",
                              "Distribution of projections by geographic zones"
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
                          
                          # Unit distribution card
                          card(
                            card_header(
                              class = "bg-blue",
                              "Distribution of projections by unit"
                            ),
                            card_body(
                              withSpinner(
                                plotOutput("stat_unite"),
                                type = 5,
                                color = "#1d71b8",
                                size = 0.5
                              ),
                              downloadButton("downloadPlot_unite", "Download plot as PNG")
                            )
                          )
                        ) # end of layout column wrap
                      )  # end of body
                    ) # end of statistics card
                  ), # end of panel
                  
                  # ==== TAB: UNITS DICTIONARY ====
                  nav_panel(
                    "OCEANS Units Dictionary",
                    card_body(
                      "*Search interface for information about OCEANS department units",
                      DT::dataTableOutput("donnees_dico_unites")
                    )
                  ), # end of panel
                  
                  # ==== TAB: RAW DATA ====
                  nav_panel(
                    "Raw Data",
                    card_body(
                      "*The data below does not respond to applied filters",
                      "**pays_fr: related to the projection instrument",
                      downloadButton("downloadRawdata", "Download raw data as .csv"),
                      DT::dataTableOutput("raw_data")
                    )
                  ), # end of panel
  ) # end of main
) # end of UI

