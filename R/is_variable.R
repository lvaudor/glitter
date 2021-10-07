is_variable=function(query_var){
  if(is.na(query_var)|is.null(query_var)){return(FALSE)}
  if(stringr::str_sub(query_var,1,1)=="?"){return(TRUE)}else{return(FALSE)}
}
