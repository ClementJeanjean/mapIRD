
split_vec_string = function(vec, sep="\t"){
  
  vec_split = unlist(strsplit(vec, sep))
  is_first_char_blank = (substr(vec_split, 1, 1) == " ") & (!is.na(vec_split))
  vec_split[is_first_char_blank] = substring(vec_split[is_first_char_blank], 2)
  return(vec_split)

}
