# Generates a custom color palette mapping values to a gradient between two colors
# vec: numeric vector to map to colors
# col_1: starting color (default: light blue)
# col_2: ending color (default: dark blue)
# na.color: color for NA or undefined values (default: white)

my_color_palette = function(vec, col_1="#ccf2ff", col_2="#002633", na.color="#FFFFFF"){
  
  # Generate a raw color palette with 250 shades between col_1 and col_2
  n_raw = 250
  raw_palette = colorRampPalette(c(col_1, col_2))(n_raw)
  
  # Map each element in the input vector to a color in the palette
  n_vec = length(vec)
  if(n_vec > 0){
    # Initialize palette with NA color
    my_palette = rep(na.color, n_vec)
    if(min(vec) != max(vec)){
      # If there is variation in the vector, map each value to a color
      for(k in 1:n_vec){
        # Normalize value to [0,1] range
        t = (vec[k]- min(vec))/(max(vec) - min(vec))
        # Assign corresponding color from the raw palette
        my_palette[k] = raw_palette[min(1+round(n_raw*t),n_raw)]
      }
    } else{
      # If all values are the same, use the starting color
      my_palette = rep(col_1, n_vec)
    }
  } else{
    # Return empty vector if input is empty
    my_palette = c()
  }
  
  return(my_palette)
}
