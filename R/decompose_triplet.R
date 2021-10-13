#' Get elements subject, verb, object of a triplet as a list.
#' @param triplet the triplet statement (replaces arguments subject verb and object)
#' @param subject an anonymous variable (for instance, and by default, "?subject") or item (for instance "wd:Q456"))
#' @param verb the property (for instance "wdt:P190")
#' @param object an anonymous variable (for instance, and by default, "?object") or item (for instance "wd:Q456"))
decompose_triplet=function(triplet, subject,verb,object){
  if(!is.null(triplet)){
    elements=stringr::str_split(triplet,"\\s") %>%
      unlist()
    result=list(subject=elements[1],
                verb=elements[2],
                object=elements[3])
    return(result)
  }else{
    result=list(subject=subject,
                verb=verb,
                object=object)
    return(result)
  }
}
