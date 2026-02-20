# Adjusts axis ticks to regular, integer, and "pretty" values based on the data range in barplots
# Takes a numeric vector as input and returns a sequence of axis values

set_axis_values = function(vec){
  
  # Calculate the maximum value in the vector, then add 10% to ensure the axis extends beyond the data
  val = ceiling(1.1*max(vec))
  
  # Determine the step size for axis ticks based on the value range
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
  
  # Calculate the final axis value, ensuring it is a multiple of the step size
  end_value = ceiling((val + 1) / step)*step
  
  # Generate a sequence of axis values from 0 to end_value, using the determined step
  axis_values = seq(0, end_value, by=step)
  
  return(axis_values)
}


