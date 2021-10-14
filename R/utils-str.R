is_variable=function(query_var){
  if(is.na(query_var)|is.null(query_var)){return(FALSE)}
  if(stringr::str_sub(query_var,1,1)=="?"){return(TRUE)}else{return(FALSE)}
}

as_value=function(string){
  if(stringr::str_detect(string,"@")){
    elts=stringr::str_split(string,"@") %>% unlist()
    result=glue::glue("'{elts[1]}'@{elts[2]}")
  }else{
    result=string
  }
  return(result)
}
