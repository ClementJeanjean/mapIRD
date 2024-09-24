split_vec_string = function(vec, sep=";"){
  
  # thematique=df_all$thematique[!is.na(df_all$thematique)]
  vec_split = unlist(strsplit(vec, sep))
  
  is_first_char_blank = (substr(vec_split, 1, 1) == " ") & (!is.na(vec_split))
  vec_split[is_first_char_blank] = substring(vec_split[is_first_char_blank], 2)
  return(vec_split)

}
  
  


# for (k in 1:nrow(df_all)){
#   
#   thematique=df_all$thematique[k]
#   thematique_split = unlist(strsplit(thematique, ","))
#   
#   is_first_char_blank = substr(thematique_split, 1, 1) == " "
#   thematique_split[is_first_char_blank] = substring(thematique_split[is_first_char_blank], 2)
#   x = unique(thematique_split)
#   
#   if("" %in% x){
#     
#     print(k)
#     print(thematique)
#   }
#   
# }