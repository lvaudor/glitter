#' checks whether subject/object is a variable
#' @param string
#' @examples
#' glitter:::is_svo_correct("elem")
is_variable=function(string){
  if(is.na(string)|is.null(string)){return(FALSE)}
  if(stringr::str_sub(string,1,1)=="?"){return(TRUE)}else{return(FALSE)}
}

#' checks whether subject/verb/object is an item
#' @param string
#' @examples
#' glitter:::is_uri("elem") #returns FALSE
#' glitter:::is_uri("wd:Q456") #returns TRUE
#' glitter:::is_uri("<http://qsdfqsdfsqdf>") #returns TRUE
is_uri=function(string){
  if(stringr::str_detect(string,"^<http.*>$")){return(TRUE)}
  if(stringr::str_detect(string,":")){
    return(TRUE)
  }
  return(FALSE)
}

is_uri_correct=function(string,prefixes="",endpoint="Wikidata"){
  if(endpoint=="Wikidata"){
    prefixes=c(prefixes,"wd","wdt","ps","pq")
  }
  prefix=stringr::str_extract(string,"^.*(?=:)")
  if(stringr::str_detect(prefix,"^<http")){
    return(TRUE)
  }
  if(!(prefix %in% prefixes$name)){
    stop(glue::glue("prefix {prefix} is not known. Please provide it through function spq_prefix()."))
  }
  return(is_uri(string))
}


#' transforms subject-verb-object arguments into a vector of values if needed
#' @param string
#' @examples
#' object="wd:Q456|wd:Q23482"
as_values=function(string){
  if(stringr::str_detect(string,"\\|")){
    val=stringr::str_split(string,"\\|") %>%
      unlist()
  }else{val=string}
  return(val)
}


#' checks whether subject/verb/object is stated correctly
#' @param string
#' @examples
#' glitter:::is_svo_correct("elem")
is_svo_correct=function(string){
  if(is_variable(string)){return(TRUE)}
  if(is_uri(string)){return(TRUE)}
  return(FALSE)
}

#add_triplets(t="?item wdt:P31 wd:Q11424")
