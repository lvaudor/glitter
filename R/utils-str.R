#' Checks whether element is a variable ("?...")
#' @param string a string or vector of strings
#' @noRd
#' @examples
#' is_variable("?elem") #TRUE
is_variable = function(string){
  nzchar(string) && grepl("^\\?", string)
}

#' Checks whether element is prefixed ("prefix::id")
#' @param string a string or vector of strings
#' @noRd
#' @examples
#' is_prefixed("elem") # returns FALSE
#' is_prefixed("wd:Q456") # returns TRUE
#' is_prefixed("<http://qsdfqsdfsqdf>") # returns TRUE
is_prefixed = function(string){
  grepl("^<http.*>$", string) || grepl(".*:.*", string)
}

#' Checks whether element is a url ("<http_blah_>")
#' @param string a string or vector of strings
#' @examples
#' is_url(c("<http://qsdqsdfqsdfqs.html>","<http blablabla>")) #TRUE
#' @noRd
is_url = function(string){
  grepl("^<http.*>$", string)
}

#' Checks whether element is a value ("'blah'" or '"blah"')
#' @param string a string or vector of strings
#' @noRd
#' @examples
#' is_value("'blabla'") #TRUE
#' is_value('"blabla"') #TRUE
#' is_value('blabla') #FALSE
is_value = function(string){
  grepl("^[\'\"].+[\'\"].*$", string)
}


#' Checks whether the element has a known prefix
#' @param prefixes_used a string or vector of strings
#' @param prefixes_known a tibble detailing known prefixes
#' @noRd
#' @examples
#' check_prefix(prefixes_used=c("wd","wdt"), prefixes_known = usual_prefixes) # TRUE
#' check_prefix("blop:blabla", prefixes_known=usual_prefixes) #returns error message
check_prefix = function(prefixes_used, prefixes_known) {
  unknown_prefixes <- prefixes_used[!(prefixes_used %in% prefixes_known$name)]
  if (length(unknown_prefixes) == 0) {
    return(TRUE)
  }

  stop(glue::glue("Can't find prefix(es) {toString(unknown_prefixes)}. Please use spq_prefix()."))

}


#' transforms subject-verb-object arguments into a vector of values if needed
#' @param string a string of R code or R vector of strings
#' @examples
#' as_values("{c(wd:Q456,wd:Q23482)}")
#' as_values(c("wd:Q456","wd:Q23482"))
#' as_values(c("wd:Q7732"))
#' @noRd
as_values = function(string){
  if (length(string) > 1) {
    return(string)
  }

  # if string is not within {...}
  if (!stringr::str_detect(string,"(?<=^\\{).*(?=\\}$)")) {
    return(string)
  }

  result = stringr::str_extract("(?<=^\\{).*(?=\\}$)", string)
  # if remaining string contains c(...)
  if (stringr::str_detect(result, "(?<=^c\\().*(?=\\)$)")) {
    result = result %>%
      stringr::str_extract("(?<=^c\\().*(?=\\)$)") %>%
      stringr::str_split(",") %>%
      unlist()
  } else {
    # object corresponds to name
    result = get(result)
  }
  return(result)

}

#' interprets if element is an R code inclusion of the type {...}
#' @param string a string
#' @noRd
#' @examples
#' obj1="0000000121012885"
#' interpret_svo("{obj1}")
#' obj2=c("wd:Q432","wd:Q576")
#' interpret_svo("{obj2}")
#' obj3="'Cristiano_Ronaldo'@en"
#' interpret_svo(obj3)
interpret_svo = function(string){
  if (stringr::str_detect(string,"[\'\"]")) {
    string=stringr::str_replace(string,"_"," ")
    return(string)
  }
  if(!stringr::str_detect(string,"[{}]")){
    return(string)
  }
  string = stringr::str_extract(string,
                       "(?<=\\{).*(?=\\})")
  string = get(string, envir = parent.env(environment()))
  return(string)
}

#' Checks whether subject/verb/object is stated correctly
#' @param string a string
#' @noRd
is_svo_correct = function(string){
  # if element is a special syntax element
  if (string %in% c(".","a","is","==","%in%","[]")) return(TRUE)

  # if element is a variable
  if (is_variable(string)) return(TRUE)

   # if element is a prefixed URI
  if (is_prefixed(string)) return(TRUE)

  # if element is a URI
  if (is_url(string)) return(TRUE)

  # if element is a value
  if (is_value(string)) return(TRUE)

  return(FALSE)
}

#' keep only prefixes (decomposing paths if necessary)
#' @param string a string or vector of strings
#' @noRd
#' @examples
#' keep_prefix("wdt:P31/wdt:P279*") # wdt
#' keep_prefix("?item") # NA
#' keep_prefix("<http://qdsfqsdfqsfqsdf.html>") # NA
#' keep_prefix("wd:P343") # "wd:P343"
#' keep_prefix("'11992081'^^xsd:integer") # xsd:integer
#' keep_prefix(c("wd:P343","wdt:P249"))
keep_prefix = function(string){

  if (!is_prefixed(string) || is_url(string)) {
    return(NA)
  }

  prefixed = string
  if(stringr::str_detect(string,"\\/")){
    prefixed = stringr::str_split(string,"\\/") %>% unlist()
  }

  prefix = stringr::str_extract(prefixed, "[^\\s^\\^]*(?=\\:)") %>% unique()

  return(prefix)
}


#' get full specification of variables (as in SELECT part of SPARQL query)
#' based on variable names
#' @param vars the selected variables (formula and name)
#' @noRd
#' @examples
#' get_varformula(c("?author","?document","(year(?date) AS ?year)"))
get_varformula = function(selected) {
    if (stringr::str_detect(selected,"\\(.* AS .*\\)")) {
      formula = stringr::str_extract(selected, "(?<=\\().*(?= AS )")
      name = stringr::str_extract(selected, "(?<= AS ).*(?=\\))")
      args = list(stringr::str_extract(formula, "\\?[a-zA-Z0-9\\_]+"))
    } else {
      formula = selected
      name = selected
      args = NULL
    }

  tibble::tibble(
    full = selected,
    name = name,
    formula = formula,
    args = args
  )
}
