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
#' glitter:::is_prefixed("elem") #returns FALSE
#' glitter:::is_prefixed("wd:Q456") #returns TRUE
#' glitter:::is_prefixed("<http://qsdfqsdfsqdf>") #returns TRUE
is_prefixed=function(string){
  if(stringr::str_detect(string,"^<http.*>$")){return(FALSE)}
  if(stringr::str_detect(string,":")){
    return(TRUE)
  }
  return(FALSE)
}

#' checks whether string is a url
#' @param string
#' @examples
#' is_url("<http://qsdqsdfqsdfqs.html>")
is_url=function(string){
  if(stringr::str_detect(string,"^<http.*>$")){return(TRUE)}
  return(FALSE)
}



#' checks whether string is a value
#' @param string
#' @examples
#' glitter:::is_value("'blabla'") #TRUE
#' glitter:::is_value('"blabla"') #TRUE
#' glitter:::is_value('blabla') #FALSE
is_value=function(string){
  if(stringr::str_detect(string,"^[\'\"].+[\'\"].*$")){
  return(TRUE)}
  return(FALSE)
}

#' transforms paths into uris
#' @param string
#' @examples
#' glitter:::keep_prefixed("wdt:P31/wdt:P279*") # wdt:P31 wdt:P279*
#' glitter:::keep_prefixed("?item") # NULL
#' glitter:::keep_prefixed("<http://qdsfqsdfqsfqsdf.html>") # NULL
#' glitter:::keep_prefixed("wd:P343") # "wd:P343"
#' glitter:::keep_prefixed("'11992081'^^xsd:integer") # xsd:integer
keep_prefixed=function(string){
  if(is_prefixed(string)){
    prefixed=string
    if(stringr::str_detect(string,"\\/")){
      prefixed=stringr::str_split(string,"\\/") %>% unlist()
    }
    prefixed=stringr::str_extract(prefixed,
                                  "[^\\^]*$")
  }else{
    prefixed=NULL
  }
  return(prefixed)
}


is_prefix_correct=function(string,prefixes="",endpoint="Wikidata"){
  if(endpoint=="Wikidata"){
    prefixes=usual_prefixes %>% filter(type=="Wikidata")
  }
  prefix=stringr::str_extract(string,"^.*(?=:)")
  if(stringr::str_detect(prefix,"^<http")){
    return(TRUE)
  }
  if(!(prefix %in% prefixes$name)){

    stop(glue::glue("prefix {prefix} is not known. Please provide it through function spq_prefix()."))
  }
  return(is_prefixed(string))
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
#' glitter:::is_svo_correct("elem") #FALSE
#' glitter:::is_svo_correct("a") #TRUE
#' glitter:::is_svo_correct("is") #TRUE
#' glitter:::is_svo_correct("'0000000121012885'") #TRUE
#' glitter:::is_svo_correct(".") #TRUE
is_svo_correct=function(string){
  if(string %in% c(".", "a","is")){return(TRUE)}
  if(is_variable(string)){return(TRUE)}
  if(is_prefixed(string)){return(TRUE)}
  if(is_url(string)){return(TRUE)}
  if(is_value(string)){return(TRUE)}
  return(FALSE)
}

#add_triplets(t="?item wdt:P31 wd:Q11424")
