
# Extrait les valeurs de la base de données fournie et stocke ces valeurs dans un dataframe "df_data"

# =========================== 
# LECTURE DATABASE
# ===========================

root_dir = getwd()
data_dir = sprintf("%s/data",root_dir)
filename = "data.txt"

df_data <- read.delim(
  file = sprintf("%s/%s", data_dir, filename),
  header = TRUE,
  fileEncoding = "latin1",
  quote = "\"",
  stringsAsFactors = FALSE
)

names(df_data)[names(df_data)=="Individu"] = "individu"
names(df_data)[names(df_data)=="Genre"] = "genre"
names(df_data)[names(df_data)=="Pays_fr"] = "pays_fr"
names(df_data)[names(df_data)=="Pays_eng"] = "pays_en"
names(df_data)[names(df_data)=="Zone_géographique_fr"] = "zone_geographique"
names(df_data)[names(df_data)=="Acronyme_unité"] = "unite"
names(df_data)[names(df_data)=="Projection_sud"] = "proj_sud"
names(df_data)[names(df_data)=="Intitulé"] = "intitule"
names(df_data)[names(df_data)=="Durée"] = "duree"
names(df_data)[names(df_data)=="Début"] = "debut"
names(df_data)[names(df_data)=="Fin"] = "fin"
names(df_data)[names(df_data)=="Destination"] = "destination"
names(df_data)[names(df_data)=="Partenaires"] = "partenaires"
names(df_data)[names(df_data)=="Thématique"] = "thematique"


