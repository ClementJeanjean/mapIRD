
# Extrait les valeurs de la base de données fournie et stocke ces valeurs dans un dataframe "df"

# =========================== 
# LECTURE DATABASE
# ===========================

root_dir = getwd()
data_dir = sprintf("%s/data",root_dir)
filename = "oceansALL_140924.csv"
df_data = read.csv(file=sprintf("%s/%s", data_dir, filename), header=TRUE, sep=",", fileEncoding="latin1")
names(df_data)[names(df_data)=="Année"] = "annee"
names(df_data)[names(df_data)=="Agent"] = "agent"
names(df_data)[names(df_data)=="Genre"] = "genre"
names(df_data)[names(df_data)=="Pays_fr"] = "pays_fr"
names(df_data)[names(df_data)=="Pays_eng"] = "pays_en"
names(df_data)[names(df_data)=="Zone.géographique_fr"] = "zone_geographique"
names(df_data)[names(df_data)=="Acronyme_unité"] = "unite"
names(df_data)[names(df_data)=="Projection_sud"] = "proj_sud"
names(df_data)[names(df_data)=="Ressources.humaines"] = "ressource_humaine"
names(df_data)[names(df_data)=="Observatoires"] = "observatoire"
names(df_data)[names(df_data)=="Intitulé"] = "intitule"
names(df_data)[names(df_data)=="Durée"] = "duree"
names(df_data)[names(df_data)=="Début"] = "debut"
names(df_data)[names(df_data)=="Fin"] = "fin"
names(df_data)[names(df_data)=="Destination"] = "destination"
names(df_data)[names(df_data)=="Dispositif.structurant"] = "dispositif"
names(df_data)[names(df_data)=="Partenaires.sud"] = "partenaire_sud"
names(df_data)[names(df_data)=="Bénéficiaire"] = "beneficiaire"
names(df_data)[names(df_data)=="Thématique"] = "thematique"
names(df_data)[names(df_data)=="Mots.clés"] = "mot_clef"
names(df_data)[names(df_data)=="Commentaires"] = "commentaire"

filename_dico_unites = "CODEUNITESOCEANS.csv"
df_data_dico_unites = read.csv(file=sprintf("%s/%s", data_dir, filename_dico_unites), header=TRUE, sep=",", fileEncoding="latin1")

filename_dico_dispositifs = "CODEDISPOSITIFSOCEANS_270824.csv"
df_data_dico_dispositifs = read.csv(file=sprintf("%s/%s", data_dir, filename_dico_dispositifs), header=TRUE, sep=",", fileEncoding="latin1")


