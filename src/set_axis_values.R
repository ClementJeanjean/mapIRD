# Permet d'adapter des graduations regulieres et entieres et "jolies" en fonction des valeurs dans les barplots



set_axis_values = function(vec){
  
  val = ceiling(1.1*max(vec))
  
  if (val >= 0 && val <= 10) {
    step = 1
  } else if (val >= 11 && val <= 20) {
    step = 2
  } else if (val >= 21 && val <= 50) {
    step = 5
  } else if (val >= 51 && val <= 100) {
    step = 10
  } else if (val >= 101 && val <= 200) {
    step = 20
  } else if (val >= 201 && val <= 250) {
    step = 25
  } else {
    step = 50
  }
  end_value = ceiling((val + 1) / step)*step
  axis_values = seq(0, end_value, by=step)
  
  return(axis_values)
}


