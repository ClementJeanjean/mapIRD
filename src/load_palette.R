
# my_color_palette = function(vec, col_1="#DAF4FF", col_2="#003052", na.color="#FFFFFF"){
my_color_palette = function(vec, col_1="#ccf2ff", col_2="#002633", na.color="#FFFFFF"){
    
  
  # raw color palette
  n_raw = 250
  raw_palette = colorRampPalette(c(col_1, col_2))(n_raw)
  
  # determine for each element the associated color in palette
  n_vec = length(vec)
  if(n_vec > 0){
    my_palette = rep(na.color, n_vec)
    if(min(vec) != max(vec)){
      for(k in 1:n_vec){
        t = (vec[k]- min(vec))/(max(vec) - min(vec))
        my_palette[k] = raw_palette[min(1+round(n_raw*t),n_raw)] 
      }
    } else{
      my_palette = rep(col_1, n_vec) 
    }
  } else{
    my_palette = c()  
  }
  
  return(my_palette)
}
