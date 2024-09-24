
# =========================== #
# LECTURE GEOJSON
# =========================== #

root_dir <- getwd()
data_dir <- file.path(root_dir, "data")
filename <- "world-boundaries.geojson"
df_geojson <- read_sf(file.path(data_dir, filename))
df_geojson %>% rename(pays_en = name)

df_all <- merge(x=df_geojson, y=df_data, by.x="name", by.y="pays_en")

