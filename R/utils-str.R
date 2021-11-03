#' Checks whether element is a variable ("?...")
#' @param string a string
#' @examples
#' glitter:::is_svo_correct("elem")
is_variable=function(string){
  if(is.na(string)|is.null(string)){return(FALSE)}
  if(stringr::str_sub(string,1,1)=="?"){return(TRUE)}else{return(FALSE)}
}

#' Checks whether element is prefixed ("prefix::id")
#' @param string a string
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

#' Checks whether element is a url ("<http_blah_>")
#' @param string a string
#' @examples
#' is_url("<http://qsdqsdfqsdfqs.html>")
is_url=function(string){
  if(stringr::str_detect(string,"^<http.*>$")){return(TRUE)}
  return(FALSE)
}

#' Checks whether element is a value ("'blah'" or '"blah"')
#' @param string a string
#' @examples
#' glitter:::is_value("'blabla'") #TRUE
#' glitter:::is_value('"blabla"') #TRUE
#' glitter:::is_value('blabla') #FALSE
is_value=function(string){
  if(stringr::str_detect(string,"^[\'\"].+[\'\"].*$")){
  return(TRUE)}
  return(FALSE)
}


#' Checks whether the element has a known prefix
#' @param string a string
#' @examples
#' glitter:::is_prefix_known("wd:Q343",endpoint="Wikidata") # TRUE
#' #glitter:::is_prefix_known("blop:blabla",endpoint="other", prefixes=usual_prefixes) #returns error message
is_prefix_known=function(string,prefixes="",endpoint="Wikidata"){

  prefix=stringr::str_extract(string,"^.*(?=:)")
  if(stringr::str_detect(prefix,"^<http")){
    return(TRUE)
  }
  if(!(prefix %in% usual_prefixes$name)){

    stop(glue::glue("prefix {prefix} is not known. Please provide it through function spq_prefix()."))
  }
  return(is_prefixed(string))
}


#' transforms subject-verb-object arguments into a vector of values if needed
#' @param string a string
#' @examples
#' object="{c(wd:Q456,wd:Q23482)}"
as_values=function(string){
  # if string is within {...}
  if(str_detect(string,"(?<=^\\{).*(?=\\}$)")){
  string=string %>%
    str_extract("(?<=^\\{).*(?=\\}$)")
    # if remaining string contains c(...)
    if(str_detect(string,"(?<=^c\\().*(?=\\)$)")){
      string=string %>%
        str_extract("(?<=^c\\().*(?=\\)$)") %>%
        str_split(",") %>%
        unlist()
    }else{
      # object corresponds to name
      string=get(string)}
  }
  return(string)
}


#' Checks whether subject/verb/object is stated correctly
#' @param string a string
#' @examples
#' glitter:::is_svo_correct("elem") #FALSE
#' glitter::is_svo_correct("{choices}") #TRUE
#' glitter:::is_svo_correct("a") #TRUE
#' glitter:::is_svo_correct("is") #TRUE
#' glitter:::is_svo_correct("'0000000121012885'") #TRUE
#' glitter:::is_svo_correct(".") #TRUE
is_svo_correct=function(string){
  # if element is a special syntax element
  if(string %in% c(".","a","is","==","%in%")){return(TRUE)}
  # if element is an R code inclusion of the type {...}
  if(stringr::str_detect(string,"(?<=\\{).*(?=\\})")){return(TRUE)}
  # if element is a variable
  if(is_variable(string)){return(TRUE)}
  # if element is a prefixed URI
  if(is_prefixed(string)){return(TRUE)}
  # if element is a URI
  if(is_url(string)){return(TRUE)}
  # if element is a value
  if(is_value(string)){return(TRUE)}
  return(FALSE)
}



#' keep only prefixed elements and decompose paths
#' @param string a string
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

