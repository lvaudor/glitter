#' Get elements subject, verb, object of a triplet as a list.
#' @param triplet the triplet statement (replaces arguments subject verb and object)
#' @param subject an anonymous variable (for instance, and by default, "?subject") or item (for instance "wd:Q456"))
#' @param verb the property (for instance "wdt:P190")
#' @param object an anonymous variable (for instance, and by default, "?object") or item (for instance "wd:Q456"))
decompose_triplet=function(triplet, subject,verb,object){
  # decompose triplet if necessary: get three elements subject-verb-object as a list
  if(!is.null(triplet)){
    elements=stringr::str_split(triplet,"\\s") %>% unlist()
    elements=list(subject=elements[1],
                  verb=elements[2],
                  object=elements[3])
    }else{
    elements=list(subject=subject,
                  verb=verb,
                  object=object)
  }
  # tests for syntax error in subject verb and object
  elements_correct=purrr::map_lgl(elements,is_svo_correct)
  if(!all(elements_correct)){
      stop("At least one element among subject, verb or object is incorrectly stated.")
  }
  return(elements)
}
