#' Checks whether element is a variable ("?...")
#' @param vstring a string or vector of strings
#' @examples
#' glitter:::is_variable(c("?elem","?item")) #TRUE
is_variable=function(vstring){
  is_variable_1elem=function(string){
      if(is.na(string)|is.null(string)){
        return(FALSE)
      }
      if(stringr::str_sub(string,1,1)=="?"){
        return(TRUE)
      }else{
        return(FALSE)
      }
  }
  result=purrr::map_lgl(vstring,is_variable_1elem)
  result=all(result)
  return(result)
}

#' Checks whether element is prefixed ("prefix::id")
#' @param vstring a string or vector of strings
#' @examples
#' glitter:::is_prefixed("elem") #returns FALSE
#' glitter:::is_prefixed("wd:Q456") #returns TRUE
#' glitter:::is_prefixed("<http://qsdfqsdfsqdf>") #returns TRUE
is_prefixed=function(vstring){
  is_prefixed_1elem=function(string){
    if(stringr::str_detect(string,"^<http.*>$")){
      return(FALSE)
    }
    if(stringr::str_detect(string,":")){
      return(TRUE)
    }
    return(FALSE)
  }
  result=purrr::map_lgl(vstring,is_prefixed_1elem)
  result=all(result)
  return(result)
}

#' Checks whether element is a url ("<http_blah_>")
#' @param vstring a string or vector of strings
#' @examples
#' glitter:::is_url(c("<http://qsdqsdfqsdfqs.html>","<http blablabla>")) #TRUE
is_url=function(vstring){
  is_url_1elem=function(string){
      if(stringr::str_detect(string,"^<http.*>$")){
        return(TRUE)
      }
      return(FALSE)
  }
  result=purrr::map_lgl(vstring,is_url_1elem)
  result=all(result)
  return(result)
}

#' Checks whether element is a value ("'blah'" or '"blah"')
#' @param vstring a string or vector of strings
#' @examples
#' glitter:::is_value("'blabla'") #TRUE
#' glitter:::is_value('"blabla"') #TRUE
#' glitter:::is_value('blabla') #FALSE
is_value=function(vstring){
  is_value_1elem=function(string){
    if(stringr::str_detect(string,"^[\'\"].+[\'\"].*$")){
      return(TRUE)
    }
    return(FALSE)
  }
  result=purrr::map_lgl(vstring,is_value_1elem)
  result=all(result)
  return(result)
}


#' Checks whether the element has a known prefix
#' @param prefixes_used a string or vector of strings
#' @param prefixes_known a tibble detailing known prefixes
#' @param endpoint the endpoint considered (defaults to Wikidata)
#' @examples
#' glitter:::is_prefix_known(prefixes_used=c("wd","wdt"),prefixes_known=usual_prefixes,endpoint="Wikidata") # TRUE
#' glitter:::is_prefix_known("blop:blabla", prefixes_known=usual_prefixes,endpoint="other") #returns error message
is_prefix_known=function(prefixes_used,prefixes_known, endpoint="Wikidata"){
  is_prefix_known_1elem=function(prefix){
    if(stringr::str_detect(prefix,"^<http")){
      return(TRUE)
    }
    if(!(prefix %in% prefixes_known$name)){
      stop(glue::glue("prefix {prefix} is not known. Please provide it through function spq_prefix()."))
    }
    return(TRUE)
  }
  result=purrr::map_lgl(prefixes_used,is_prefix_known_1elem)
  result=all(result)
  return(result)
}


#' transforms subject-verb-object arguments into a vector of values if needed
#' @param vstring a string of R code or R vector of strings
#' @examples
#' object="{c(wd:Q456,wd:Q23482)}"
#' glitter:::as_values(object)
#' object=c("wd:Q456","wd:Q23482")
#' glitter:::as_values(object)
as_values=function(vstring){
  if(length(vstring)>1){
    result=vstring
    return(result)
  }
  # if string is within {...}
  if(str_detect(vstring,"(?<=^\\{).*(?=\\}$)")){
    result=vstring %>%
      str_extract("(?<=^\\{).*(?=\\}$)")
      # if remaining string contains c(...)
    if(str_detect(result,"(?<=^c\\().*(?=\\)$)")){
        result %<>%
          str_extract("(?<=^c\\().*(?=\\)$)") %>%
          str_split(",") %>%
          unlist()
    }else{
        # object corresponds to name
        result=get(result)}
    }
  return(result)
}

#' interprets if element is an R code inclusion of the type {...}
#' @param string a string
#' @examples
#' obj1="0000000121012885"
#' glitter:::interpret_svo("{obj1}")
#' obj2=c("wd:Q432","wd:Q576")
#' glitter:::interpret_svo("{obj2}")
interpret_svo=function(string){
  if(!str_detect(string,"[{}]")){return(string)}
  string=stringr::str_extract(string,
                       "(?<=\\{).*(?=\\})")
  string=get(string, envir=globalenv())
  return(string)
}

#' Checks whether subject/verb/object is stated correctly
#' @param vstring a string or vector of strings
#' @examples
#' glitter:::is_svo_correct("elem") #FALSE
#' glitter:::is_svo_correct("a") #TRUE
#' glitter:::is_svo_correct("is") #TRUE
#' glitter:::is_svo_correct("'0000000121012885'") #TRUE
#' glitter:::is_svo_correct(".") #TRUE
#' glitter:::is_svo_correct("[]") #TRUE
is_svo_correct=function(vstring){
  is_svo_correct_1elem=function(string){
      # if element is a special syntax element
      if(string %in% c(".","a","is","==","%in%","[]")){return(TRUE)}
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
  result=purrr::map_lgl(vstring,is_svo_correct_1elem)
  result=all(result)
  return(result)
}



#' keep only prefixes (decomposing paths if necessary)
#' @param vstring a string or vector of strings
#' @examples
#' glitter:::keep_prefix("wdt:P31/wdt:P279*") # wdt
#' glitter:::keep_prefix("?item") # NULL
#' glitter:::keep_prefix("<http://qdsfqsdfqsfqsdf.html>") # NULL
#' glitter:::keep_prefix("wd:P343") # "wd:P343"
#' glitter:::keep_prefix("'11992081'^^xsd:integer") # xsd:integer
#' glitter:::keep_prefix(c("wd:P343","wdt:P249"))
keep_prefix=function(vstring){
  keep_prefix_1elem=function(string)
  if(glitter:::is_prefixed(string)){
    prefixed=string
    if(stringr::str_detect(string,"\\/")){
      prefixed=stringr::str_split(string,"\\/") %>% unlist()
    }
    prefix=stringr::str_extract(prefixed,
                                "[a-zA-Z0-9]*(?=\\:)") %>%
      unique()
  }else{
    prefix=NA
  }
  prefixes=purrr::map_chr(vstring,keep_prefix_1elem) %>%
    unique()
  return(prefixes)
}

