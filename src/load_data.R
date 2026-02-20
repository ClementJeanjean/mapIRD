# Extracts data from the provided database and stores it in a data frame named "df_data"

# ===========================
# READ DATABASE
# ===========================

# Set the root directory to the current working directory
root_dir = getwd()
# Define the data directory path
data_dir = sprintf("%s/data", root_dir)
# Specify the data file name
filename = "data.txt"

# Read the data file into a data frame, using tab as delimiter and latin1 encoding
df_data <- read.delim(
  file = sprintf("%s/%s", data_dir, filename),
  header = TRUE,
  fileEncoding = "utf-8",
  quote = "\"",
  stringsAsFactors = FALSE
)

# Rename data frame columns for clarity and consistency
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

# Load the units dictionary from a CSV file
filename_dico_unites = "CODEUNITESOCEANS.csv"
df_data_dico_unites = read.csv(
  file=sprintf("%s/%s", data_dir, filename_dico_unites),
  header=TRUE,
  sep=",",
  fileEncoding="utf-8"
)






